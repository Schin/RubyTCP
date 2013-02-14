require "socket"

DOMAIN = "172.31.190.56"
PORT = 2626
TAILLE_TAMPON = 1000

chat_client = TCPSocket.new(DOMAIN, PORT)

fork do
   first=true
   loop do
       puts chat_client.recvfrom(TAILLE_TAMPON)[0].chomp
       print "Enter your username : " if first
       first = false if first
   end
end

while line = gets do
   chat_client.puts line
end