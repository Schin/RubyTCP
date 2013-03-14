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
					user = kennels["Public"].get_user_by_sock(sock)
					if user.status != "AFM" then
						message_processing(data, sock)
					else
						respond("101", sock, "")
					end
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
            if accept then
            	broadcast("000", kennels["Public"], "! "+accept+" is now connected")
            else
           		puts "server: incoming connection, but no client" if errors
           	end
        end

        # process input from existing client
        ios[0].each do |s|
            # loop runs over server and connections; here we look for the latter
            s==server and next
            # since s is an element of @kennels["Public"].sockets, it is a client created
            # by @server.accept, hence a TcpSocket < IPSocket < BaseSocket
            if s.eof?
                # client has closed connection
                user = kennels["Public"].get_user_by_sock(s)
                kennels["Public"].delete(s)
                puts "#{user.name} has left DNC" if @verbose
                broadcast("000", kennels["Public"], "! #{user.name} has left DNC")
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
		cmd.upcase!
		case cmd
			when "GO"
				go(kennel, sock)
			when "AFM"
				afm(kennel, sock)
			when "BACK"
				back(kennel, sock)
			when "COLLAR"
				collar(kennel, sock, params)
			when "BARK"
				bark(kennel, sock, params)
			when "PET"
				pet(kennel, sock, params)
			when "SNIFF"
				sniff(kennel, sock, kennel)
			when "LICK"
				lick(kennel, sock, params)
			when "ACCEPT_LICK"
				response_lick(kennel, sock, params, true)
			when "REFUSE_LICK"
				response_lick(kennel, sock, params, false)
			when "BITE"
				bite(kennel, sock)
			when "FETCH"
				fetch(kennel, sock, params)
			when "ACCEPT_FETCH"
				response_fetch(kennel, sock, params, true)
			when "REFUSE_FETCH"
				response_fetch(kennel, sock, params, false)
			when "IMPOSSIBLE_FETCH"
				impossible_fetch(kennel, sock, params)
			when "HELP"
				help(kennel, sock)
			when "YAP"
				yap(kennel, sock, params)
			else

		end
	end

	def go(kennel, socket)
		respond("001", socket, "")
	end

	def afm(kennel, socket)
		user = kennels["Public"].get_user_by_sock(socket)
		if user.status == "AFM" then
			respond("101", socket, "")
		else
			user.status = "AFM"
			broadcast("002", kennels["Public"], user.name)
		end
	end

	def back(kennel, socket)
		user = kennels["Public"].get_user_by_sock(socket)
		if user.status == "connected" then
			respond("102", socket, "Hum... you're already here...")
		else
			user.status = "connected"
			broadcast("003", kennels["Public"], user.name)
		end
	end

	def collar(kennel, socket, name)
		if not name then
			respond("100", socket, "")
			return
		end

		user = kennels["Public"].get_user_by_sock(socket)

		if user.status == "AFM" then
			respond("101", socket, "")
			return
		end

		err = username_validator(name)

		if err == 0 then
			broadcast("004", kennels["Public"], user.name+" "+name)
			kennels["Public"].delete(socket)
			user.name = name
			kennels["Public"].users[name] = user
		else
			respond("104", socket, name) if err == 1
			respond("103", socket, name) if err == 2
		end
	end

	def bark(kennel, socket, message)
		if kennels["Public"].get_user_by_sock(socket).status == "AFM" then
			respond("101", socket, "")
			return
		end

		if message and kennels[kennel] then
			broadcast("005", kennels[kennel], message)
		end
	end

	def pet(kennel, socket, name)
		user = kennels["Public"].get_user_by_sock(socket)

		if not name then
			respond("100", socket, "")
			return
		end

		if user.status == "AFM" then
			respond("101", socket, "")
			return
		end

		if not kennels["Public"].exists_user(name) then
			respond("105", socket, name)
			return
		end

		broadcast("006", kennels[kennel], user.name+" "+name) if kennels[kennel]
	end

	def sniff(kennelFrom, socket, kennel)
		list_users = kennels[kennel].get_all_names
		respond("008", socket, list_users)
	end

	def lick(kennelFrom, socket, params)
		if not params then
			respond("100", socket, "")
			return
		else
			kennel, name = params.split(" ")
			if not kennel or not name then
				respond("100", socket, "")
				return	
			end
		end

		user = kennels["Public"].get_user_by_sock(socket)

		if user.status == "AFM" then
			respond("101", socket, "")
			return
		end

		#Improvment : Un contrôle pour qu'on se lick pas soit même
		
		if not kennels["Public"].exists_user(name) then
			respond("105", socket, name)
			return
		end

		err = kennelname_validator(kennel)

		if err == 1 then
			respond("111", socket, kennel)
			return
		else
			if err == 2 and not kennels[kennel].get_user_by_name(user.name) then
				respond("106", socket, kennel)
				return
			end
		end

		kennels[kennel] = Kennel.new(kennel)
		kennels[kennel].users[user.name] = user

		target = kennels["Public"].users[name].socket

		respond("009", target, user.name+" "+kennel)
	end

	def response_lick(kennelFrom, socket, params, status)
		if not params then
			respond("100", socket, "")
			return
		else
			kennel, name = params.split(" ")
			if not kennel or not name then
				respond("100", socket, "")
				return	
			end
		end

		user = kennels["Public"].get_user_by_sock(socket)

		if not kennels["Public"].exists_user(name) then
			respond("105", socket, name)
			return
		end

		if not kennels[kennel] then
			respond("111", socket, kennel)
			return
		end

		target = kennels["Public"].users[name].socket

		if status then
			kennels[kennel].users[user.name] = user
			respond("201", target, kennel+" "+user.name)
		else
			respond("301", target, kennel+" "+user.name)
		end
	end

	def bite(kennel, socket)
		user = kennels["Public"].get_user_by_sock(socket)

		if user.status == "AFM" then
			respond("101", socket, "")
			return
		end

		if not kennels[kennel] then
			respond("111", socket, kennel)
			return
		end

		if kennel == "Public" then
			respond("108", socket, "")
		else
			kennels[kennel].delete(socket)
			broadcast("010", kennel, kennel+" "+user.name)
		end
	end

	def fetch(kennel, socket, params)
		if not params then
			respond("100", socket, "")
			return
		else
			name, port, file = params.split(" ")
			if not file or not name then
				respond("100", socket, "")
				return	
			end
		end

		user = kennels["Public"].get_user_by_sock(socket)

		if user.status == "AFM" then
			respond("101", socket, "")
			return
		end

		#Un contrôle pour qu'on se fetch pas soit même ?
		
		if not kennels["Public"].exists_user(name) then
			respond("105", socket, name)
			return
		end

		target = kennels["Public"].users[name].socket

		respond("011", target, user.name+" "+user.ip+" "+port+" "+file)
	end

	def response_fetch(kennel, socket, params, status)
		if not params then
			respond("100", socket, "")
			return
		else
			name, file = params.split(" ")
			if not file or not name then
				respond("100", socket, "")
				return	
			end
		end

		user = kennels["Public"].get_user_by_sock(socket)

		target = kennels["Public"].users[name].socket

		if status then
			respond("202", target, user.name+" "+file)
		else
			respond("302", target, user.name+" "+file)
		end
	end

	def impossible_fetch(kennel, socket, params)
		if not params then
			respond("100", socket, "")
			return
		else
			file, name = params.split(" ")
			if not file or not name then
				respond("100", socket, "")
				return	
			end
		end

		user = kennels["Public"].get_user_by_sock(socket)

		target = kennels["Public"].users[name].socket

		respond("108", target, user.name+" "+file)
	end

	def help(kennel, socket)
		list = "yap-Send_a_private_message_to_the_specified_dog"
		respond("012", socket, list)
	end

	def yap(kennel, socket, params)
		user = kennels["Public"].get_user_by_sock(socket)

		if not params then
			respond("100", socket, "")
			return
		else
			name, msg = params.split(" ")
			if not name or not msg then
				respond("100", socket, "")
				return
			end
		end

		if user.status == "AFM" then
			respond("101", socket, "")
			return
		end

		target = kennels["Public"].get_user_by_name(name)

		if not target then
			respond("105", socket, target)
			return
		end

		respond("013", target.socket, target.name+" "+msg)
	end

	def message_processing(data, sock)
		kennel, message = data.split(" ", 2)
		if(message != "")
			user = kennels["Public"].get_user_by_sock(sock)
			broadcast("000", kennels[kennel], user.name+ " " +message)
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

		puts "New user connected : #{new_name} #{new_sock.peeraddr[2]}:#{new_sock.peeraddr[1]}" 
		new_user.name = new_name

	    kennels["Public"].users[new_name] = new_user
	    str = "unknown #{new_name}"
	    respond("004",new_user.socket, str)
	    @cpt_name += 1
	    return new_name
  	end

  	def username_validator(username)
  		return 1 if !/^[a-zA-Z0-9]{3,12}$/.match(username) 
		kennels["Public"].users[username] ? 2 : 0
  	end

  	def kennelname_validator(name)
  		return 1 if !/^[a-zA-Z0-9]{3,18}$/.match(name) or name.upcase == "PUBLIC"
		kennels[name] ? 2 : 0
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

		def get_all_names
			res = ""
			users.each { |key, value|
				res+=key+" " if key != "unknown"
			}
			return res
		end

		def get_user_by_sock(sock)
			users.each { |key, value|
				return value if key != "unknown" and value.socket == sock
			}
			return nil
		end

		def get_user_by_name(name)
			users.each { |key, value|
				return value if key == name
			}
			return nil
		end

		def exists_user(name)
			return users.member?(name)
		end
	end

end

dnc_server = DNCServer.new(2626, true, true, 1).run