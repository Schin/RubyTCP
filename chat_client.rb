require "socket"
require "thread"
TAILLE_TAMPON = 1000

TIMEOUT = 10
DOMAIN = "localhost"
PORT = 2626


class DNC_Client
	def initialize(domaine, port)
		@chat_client = TCPSocket.new(domaine, port)
		@username = ""
	end
	def run
		trap(:SIGINT) {
      		puts "I'm off!"
      		stop
    	}
		Thread.new do
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
			#--- 0XX: Valid return ---#
			when "000" # Message
				puts data
			when "001" # GO
				puts "GO GO GO ! "
				stop
			when "002" # AFM
				if data != @username
					puts data + " is Away From Master"
				else 
					puts "You are now Away From M"
				end
			when "003" # BACK
				if data != @username
					puts data + " is back"
				else 
					puts "Welcome back !"
				end
			when "004" # COLLAR
				new_username = data.split(" ")[1]
				puts @username+" is now known as "+new_username
				@username = new_username
			when "005" # BARK
				puts data.upcase
			when "006" # PET
			when "008" # SNIFF
			when "009" # LICK
			when "010" # BITE
			when "011" # FETCH
			when "012" # HELP
			#--- 1XX: Error return ---#
			when "100" # BAD COMMAND USAGE
			when "101" # AFM
				puts data
			when "102" # BACK
			when "103" # COLLAR already exists
			when "104" # COLLAR invalid
			when "105" # PET
			when "106" # LICK kennel already exists
			when "107" # LICK user-name does not exist
			when "108" # BITE
			when "109" # FETCH impossible communication 
			when "110" # FETCH invalid file
			#--- 2XX: Accept return ---#
			when "201" # Accept LICK
			when "202" # Accept FETCH
			#--- 3XX: Refuse return ---#
			when "301" # Refuse LICK
			when "302" # Refuse FETCH
			#--- 4XX: Other return ---#	
			when "404" # Unknown command
				puts "Command not found"
			when "666" # Server shutting down
				puts data
				stop
			else
				puts data
		end
	end
end
client = DNC_Client.new(DOMAIN, PORT).run