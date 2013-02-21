require "socket"

TAILLE_TAMPON = 1000

TIMEOUT = 10
DOMAIN = "localhost"
PORT = 2626


class DNC_Client
	def initialize(domaine, port)
		@chat_client = TCPSocket.new(domaine, port)
	end
	def run
		trap(:SIGINT) {
      		puts "I'm off !"
      		stop
    	}
		@pid = fork do
		   loop do
		       res_mess = @chat_client.recvfrom(TAILLE_TAMPON)[0].chomp
		       type, kennel, data = res_mess.split(" ",3)
		       data_processing(type, kennel, data)
		   end
		end
		begin
			while line = gets do
				if /^\//.match(line) then
      				@chat_client.puts "CMD Public "+line[1..-1].strip + "\r\n"
    			else
    				@chat_client.puts "MSG Public "+line.strip + "\r\n"
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
	def data_processing(type, kennel, data)
		case type
		when "000"
			puts data
		when "004"
			puts "Good pseudo man !"
		when "111"
			puts data
		when "666"
			puts data
			stop
		when "0"
			puts "OFF"
		else
			puts data
		end
	end
end
client = DNC_Client.new(DOMAIN, PORT).run