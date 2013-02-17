require 'socket'

class DNCServer

  def initialize ( port )
    @descriptors  = Array::new #Permet de stocker tous les sockets
    @kennels      = Hash::new #Permet de garder toutes les Kennels
    @clients      = Hash::new #Permet de gardes les pseudos des users et leur ip
    @serverSocket = TCPServer.new("", port)
    @serverSocket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    puts "Dog Now Chat started on port #{port}"
    @descriptors.push( @serverSocket ) #add socket to descriptor array
  end

  # implements the chat functionality
  def run
    trap(:SIGINT) {
      stop
    }
    while true
      res = select(@descriptors, nil, nil ,nil)
      if res != nil then
        #Iterate through the tagged read descriptors
        for sock in res[0]
          #Recieved a connect to the server (listening) socket
          if sock == @serverSocket then
            raise "ERROR " if not accept_new_connection
          else
          #Received something on a client socket
            if sock.eof? then
              print(sprintf("Client left %s: %s \n", sock.peeraddr[2], sock.peeraddr[1]))

              ip  = sock.peeraddr[2].to_s+"|"+sock.peeraddr[1].to_s
              str = @clients[ip] + " left the server.\n"

              broadcast_string(str, sock)

              sock.close

              @descriptors.delete(sock)
            else
              ip      = sock.peeraddr[2].to_s+"|"+sock.peeraddr[1].to_s
              
              tram = sock.gets()
              processing_tram(tram)
              str     = sprintf("[%s]: %s", @clients[ip], message)

              broadcast_string(str, sock)
            end
          end
        end
      end
    end
  end

  def stop
    broadcast_string("666 Server shuting down..." , @serverSocket)
    @descriptors.each do |clisock|
      if clisock != @serverSocket
        clisock.close
      end
    end
    @serverSocket.close
    puts "Server off"
    exit!(0)
  end

  private

  def processing_string (str)
  end

  def broadcast_string (str, omit_sock)
    @descriptors.each do |clisock|
      if clisock != @serverSocket && clisock != omit_sock
        clisock.write(str)
      end
    end
    print("CLIENT : " + str)
  end

  def accept_new_connection
    newsock = @serverSocket.accept

    newsock.write("000 You're connected to Dog Now Chat server\n")
    print(sprintf("Client joined %s:%s\n", newsock.peeraddr[2], newsock.peeraddr[1]))

    ip  = newsock.peeraddr[2].to_s+"|"+newsock.peeraddr[1].to_s
    str = @clients[ip] + " joined the server.\n"

    begin
      @clients[ip] = newsock.gets().chomp
    rescue Exception
      return false
    end

    @descriptors.push(newsock)
    broadcast_string( str, newsock )

    return true
  end
  class User
    def initialize(name, socket)
      @name   = name
      @ip     = socket.peeraddr[2].to_s
      @port   = socket.peeraddr[1].to_s
      @socket = socket
    end
  end
  class Kennel
    def initialize(name)
      @name = name
      @users = Array::new
    end
  end
end




myDogServer = DNCServer.new(2626).run
