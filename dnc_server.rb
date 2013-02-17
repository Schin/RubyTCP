require 'socket'

class DNCServer
	def initialize (port, verbose=false, errors=true, timeout=2)
		#On fait un Hash contenant : Nom du kennel => tableau d'users
		@kennels = Hash.new
		#On stock tous les users dès leur connection dans le kennel public
		@kennels["Public"] = Kennel.new("Public")
		#On set le socket TCP du serveur
		@server = TCPServer.new("", port)

		#talking mode
		@verbose = verbose
		#errors mode
		@errors  = errors

		@timeout = timeout
		@verbose and puts "Dogs Now Chat started on port #{port}"
	end

	def run
		trap(:SIGINT) {
      		stop
    	}
		loop do
			if sock = get_socket
				# a message has arrived, it must be read from sock
				message = sock.gets( "\r\n" ).chomp( "\r\n" )
				# arbitrary examples how to handle incoming messages:
				if message == 'quit'
					raise SystemExit
				elsif message =~ /^puts (.*)$/
					puts "message from #{sock.peeraddr.join(':')}: '#{$1}'"
				elsif message =~ /^echo (.*)$/
					# send something back to the client
					sock.write( "server echo: '#{$1}'\r\n" )
				else
					puts "unexpected message from #{sock.peeraddr}: '#{$1}'"
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
        connections = @kennels["Public"].sockets

 		ios = select( [@server]+connections, nil, connections, @timeout ) or
            return nil
        # disconnect any clients with errors
        ios[2].each do |sock|
            sock.close
            @kennels["Public"].delete(sock)
            @errors and puts "socket #{sock.peeraddr.join(':')} had error"
        end
        # accept new clients
        ios[0].each do |s| 
            # loop runs over server and connections; here we look for the former
            s==@server or next 
            accept_new_connection or
               @errors and puts "server: incoming connection, but no client"
        end
        # process input from existing client
        ios[0].each do |s|
            # loop runs over server and connections; here we look for the latter
            s==@server and next
            # since s is an element of @kennels["Public"].sockets, it is a client created
            # by @server.accept, hence a TcpSocket < IPSocket < BaseSocket
            if s.eof?
                # client has closed connection
                @kennels["Public"].delete(s)
                next
            end
            return s # message can be read from this
        end
        return nil # no message arrived
    end


	def stop
		broadcast_string(@kennels["Public"], "666 Server shuting down...")
	    @server.close
	    puts "Server off"
	    exit!(0)
	end

	def broadcast(kennel, message, sender)
		kennel.users.each { |key, value|
			value.socket.puts sender.name + message if key != "unknown"
		}
		#Save dans logs
	end

	def accept_new_connection
	    new_sock = @server.accept

	    new_sock.puts "000 You're connected to Dogs Now Chat server."

	    #LOG : puts sprintf("Client joined %s:%s\n", newsock.peeraddr[2], newsock.peeraddr[1]))
		new_user = User.new(new_sock)
		new_name = "unknown"

		begin
			new_name = new_user.socket.gets().chomp
		rescue Exception
			return false
		end

		while err = username_validator(new_name) != 0 do
			new_user.socket.puts "105 Public #{new_name}" if err == 1
			new_user.socket.puts "104 Public #{new_name}" if err == 2
		    begin
		    	new_name = new_user.socket.gets().chomp
		    rescue Exception
		    	return false
		    end
		end

		new_user.name = new_name

	    @kennels["Public"].users[new_name] = new_user
	    str = "004 Public unknown #{new_name}"
	    broadcast(@kennels["Public"], str, new_user)
	    return true
  	end

  	def username_validator(username)
  		return 1 if username.match(/regexpduZboob/) 
		@kennels["Public"].users[username] ? 2 : 0
  	end

	class User

		attr_accessor :name, :status, :socket

		def initialize(name="unknown", status="connected", socket)
			@name   = name
			@status = status
			@socket = socket
		end

		def ip
			@socket.peeraddr[2].to_s
		end

		def port
			@socket.peeraddr[1].to_s
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
			@users.each { |key, value|
				res.push value.socket if key != "unknown"
			}
			return res
		end
		def delete(sock)
			@users.each { |key, value|
				@users.delete(key) if key != "unknown" and value.socket == sock
			}
		end
	end

end

dnc_server = DNCServer.new(2626, true, true, 1).run