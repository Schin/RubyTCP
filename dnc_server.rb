require 'socket'
require "./config_server.rb"

class DNCServer

	attr_accessor :kennels, :server, :verbose, :errors, :timeout

	def initialize (port=PORT, verbose=VERBOSE, errors=ERRORS, timeout=TIMEOUT, domain=DOMAIN)
		#On fait un Hash contenant : Nom du kennel => tableau d'users
		@kennels = Hash.new
		#On stock tous les users dès leur connection dans le kennel public
		@kennels["Public"] = Kennel.new("Public")
		#On set le socket TCP du serveur
		@server = TCPServer.new(domain, port)
		#compteur de génération des noms
		@cpt_name = 0
		#talking mode
		@verbose = verbose
		#errors mode
		@errors  = errors

		@timeout = timeout
		@verbose and puts START+"#{port}"
	end

	def run
		trap(:SIGINT) {
      		stop
    	}
		loop do
			@cpt_name = 0 if @cpt_name >= 99999999
			if sock = get_socket 
				# a message has arrived, it must be read from sock
				message = sock.gets( "\r\n" ).chomp( "\r\n" )
				type, data = message.split(" ",2)
				# arbitrary examples how to handle incoming messages:
				if type == "CMD"
					command_processing(data, sock)
				elsif type == "MSG"
					message_processing(data, sock)
				elsif message =~ /^echo (.*)$/
					# send something back to the client
					sock.write( "server echo: '#{$1}'\r\n" )
				else
					puts "unexpected message from #{sock}: '#{$1}'"
				end
			else
				sleep 0.01 # free CPU for other jobs, humans won't notice this latency
			end
		end
	end


	def get_socket
        # Process incoming connections and messages.

        # When a message has arrived, we return the connection's TcpSocket.
        # Applications can read from this socket with gets(),
        # and they can respond with write().

        # one select call for three different purposes -> saves timeouts
        connections = kennels["Public"].sockets

 		ios = select([server]+connections, nil, connections, timeout) or
            return nil
        # disconnect any clients with errors
        ios[2].each do |sock|
            sock.close
            kennels["Public"].delete(sock)
        end

        # accept new clients
        ios[0].each do |s| 
            # loop runs over server and connections; here we look for the former
            s==server or next
            accept = accept_new_connection
           	puts "server: incoming connection, but no client" if errors and not accept
        end

        # process input from existing client
        ios[0].each do |s|
            # loop runs over server and connections; here we look for the latter
            s==server and next
            # since s is an element of @kennels["Public"].sockets, it is a client created
            # by @server.accept, hence a TcpSocket < IPSocket < BaseSocket
            if s.eof?
                # client has closed connection
                user = kennels["Public"].get_user_sock(s)
                kennels["Public"].delete(s)
                puts "#{user.name} has left DNC" if @verbose
                broadcast("000", kennels["Public"], "#{user.name} has left DNC")
                next
            end

            return s # message can be read from this
        end

        return nil # no message arrived
    end

	def stop
		puts M666
		broadcast("666", kennels["Public"], M666)
	    @server.close
	    puts "Server off"
	    exit!(0)
	end
	def command_processing(data, sock)
		kennel, cmd, params = data.split(" ", 3)
		case cmd
			when "GO", "go"
				go(sock)
			when "AFM", "afm"
				afm(sock)
			when "BACK", "back"
				back(sock)
			when "COLLAR", "collar"
				collar(sock, params)
			when "BARK", "bark"
				puts "bark"
			when "PET","pet"
				puts "pet"
			when "SNIFF", "sniff"
				puts "sniff"
			when "LICK", "lick"
				puts "lick"
			when "BITE", "bite"
				puts "bite"
			when "FETCH", "fetch"
				puts "fetch"
			when "HELP", "help"
				puts "help"
			else

		end
	end

	def go(socket)
		respond("001", socket, "")
	end

	def afm(socket)
		user = kennels["Public"].get_user_sock(socket)
		if user.status == "AFM" then
			respond("101", socket, "How did you do that ? Aren't you already AFM ?")
		else
			user.status = "AFM"
			broadcast("002", kennels["Public"], user.name)
		end
	end

	def back(socket)
		user = kennels["Public"].get_user_sock(socket)
		if user.status == "connected" then
			respond("102", socket, "Hum... you're already here...")
		else
			user.status = "connected"
			broadcast("003", kennels["Public"], user.name)
		end
	end

	def collar(socket, params)
		user = kennels["Public"].get_user_sock(socket)
		err = username_validator(params)
		if err == 0 then
			broadcast("004", kennels["Public"], user.name+" "+params)
			user.name = params
		else
			respond("104", socket, "#{params}") if err == 1
			respond("103", socket, "#{params}") if err == 2
		end
	end

	def bark(socket)
	end

	def pet(socket)
	end

	def sniff(socket)
	end

	def lick(socket)
	end

	def bite(socket)
	end

	def fetch(socket)
	end

	def help(socket)
	end

	def message_processing(data, sock)
		kennel, message = data.split(" ", 2)
		if(message != "")
			user = kennels["Public"].get_user_sock(sock)
			broadcast("000", kennels[kennel], "[#{user.name}] : " + message)
		end
	end

	def broadcast(type, kennel, message)
		kennel.users.each { |key, value|
			value.socket.puts type + " " + kennel.name + " " + message if key != "unknown"
		}
		#Save dans logs
	end

	def respond(type, user_sock, message)
		user_sock.puts type + " Self " + message
	end

	def accept_new_connection
	    new_sock = @server.accept

	    #LOG : puts sprintf("Client joined %s:%s\n", newsock.peeraddr[2], newsock.peeraddr[1]))
		new_user = User.new(new_sock)
		new_name = "dog" + @cpt_name.to_s

		#begin
		#	new_name = new_user.socket.gets().chomp
		#rescue Exception
		#	return false
		#end
		#
		#while (err = username_validator(new_name)) != 0 do
		#	errors and puts "New connection : Invalid username #{new_name} (#{err})"
		#	new_user.socket.puts "105 Public #{new_name}" if err == 1
		#	new_user.socket.puts "104 Public #{new_name}" if err == 2
		#    begin
		#    	new_name = new_user.socket.gets().chomp
		#    rescue Exception
		#    	return false
		#    end
		#end
		puts "New user connected : #{new_name} #{new_sock.peeraddr[2]}:#{new_sock.peeraddr[1]}" 
		new_user.name = new_name

	    kennels["Public"].users[new_name] = new_user
	    str = "unknown #{new_name}"
	    respond("004",new_user.socket, str)
	    @cpt_name += 1
	    return true
  	end

  	def username_validator(username)
  		return 1 if !/^[a-zA-Z0-9]{3,12}$/.match(username) 
		kennels["Public"].users[username] ? 2 : 0
  	end

	class User

		attr_accessor :name, :status, :socket

		def initialize(name="unknown", status="connected", socket)
			@name   = name
			@status = status
			@socket = socket
		end

		def ip
			socket.peeraddr[2].to_s
		end

		def port
			socket.peeraddr[1].to_s
		end
	end

	class Kennel

		attr_accessor :name, :users

		def initialize(name)
			@name  = name
			@users = Hash.new
			@users["unknown"] = User.new(nil)
		end

		def sockets
			res = []
			users.each { |key, value|
				res.push value.socket if key != "unknown"
			}
			return res
		end

		def delete(sock)
			users.each { |key, value|
				users.delete(key) if key != "unknown" and value.socket == sock
			}
		end

		def get_user_sock(sock)
			users.each { |key, value|
				return value if key != "unknown" and value.socket == sock
			}
		end
	end

end

dnc_server = DNCServer.new(2626, true, true, 1).run