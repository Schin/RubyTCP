require "socket"

DOMAIN = "localhost"
PORT = 2626
TAILLE_TAMPON = 1000

class DNC_Client
	def initialize(domaine, port, username)
		@chat_client = TCPSocket.new(domaine, port)
		@chat_client.puts username
	end
	def run
		trap(:SIGINT) {
      		puts "I'm off !"
      		stop
    	}
		@pid = fork do
		   loop do
		       res_mess = @chat_client.recvfrom(TAILLE_TAMPON)[0].chomp
		       type, data = res_mess.split(" ",2)
		       display(type, data)
		   end
		end
		begin
			while line = gets do
				if line.match(/^\//) then
      				@chat_client.puts "CMD "+line[1..-1].strip
    			else
    				@chat_client.puts "MSG "+line.strip
				end
			end
		rescue Exception
			stop
		end
	end
	def stop
		@chat_client.close
		exit!(0)
	end
	def display(type, data)
		case type
		when "000"
			puts data
		when "111"
			puts data
		when "666"
			puts data
			stop
		else
			puts type+data
		end
	end
end
print "Enter your username: "
username = gets.chomp
client = DNC_Client.new(DOMAIN, PORT, username).run