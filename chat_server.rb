require 'socket'

class DNCServer

 def initialize ( port )
    @descriptors  = Array::new # array to keep track of the sockets that exist for the server
    @clients      = Hash::new  # hash to keep all pseudo of the ips for the server
    @serverSocket = TCPServer.new("", port)
    @serverSocket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    puts "Dog Now Chat started on port #{port}"
    @descriptors.push( @serverSocket ) #add socket to descriptor array
 end

 # implements the chat functionality
 def run
    trap(:SIGINT) {
       broadcast_string("Server shuting down..." , @serverSocket)
       puts "Server off"
       @serverSocket.close
       exit!(0)
       }
    while 1
     res = select(@descriptors, nil, nil ,nil)
     if res != nil then
       #Iterate through the tagged read descriptors
       for sock in res[0]
         #Recieved a connect to the server (listening) socket
         if sock == @serverSocket then
             accept_new_connection
         else
           #Received something on a client socket
           if sock.eof? then
             print(sprintf("Client left %s: %s \n",
                           sock.peeraddr[2], sock.peeraddr[1]))
             ip = sock.peeraddr[2].to_s+"|"+sock.peeraddr[1].to_s
             str = @clients[ip] + " left the server.\n"
             broadcast_string( str, sock )
             sock.close
             @descriptors.delete(sock)
           else
             ip = sock.peeraddr[2].to_s+"|"+sock.peeraddr[1].to_s
             str = sprintf("[%s]: %s", @clients[ip], sock.gets())
             broadcast_string( str, sock )
           end
         end
       end
     end
    end
 end


 private #these methods are used for internally sending a message to all
         #clients and accepting a new client connection

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
   
    newsock.write("You're connected to X's personal chatserver\n")
    print(sprintf("Client joined %s:%s\n", newsock.peeraddr[2], newsock.peeraddr[1]))
    ip = newsock.peeraddr[2].to_s+"|"+newsock.peeraddr[1].to_s
    begin
     @clients[ip] = newsock.gets().chomp
    rescue Exception => e
     return false
    end
    str = @clients[ip] + " joined the server.\n"
    @descriptors.push(newsock)
    broadcast_string( str, newsock )
 end

end




myDogServer = DNCServer.new(2626).run
