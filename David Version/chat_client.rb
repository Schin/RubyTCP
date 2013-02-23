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
		@status = "connected"
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
				puts "Bye !"
				stop
			when "002" # AFM
				if data != @username
					puts data + " is Away From Master"
				else 
					puts "You are now Away From Master"
				end
			when "003" # BACK
				if data != @username
					puts data + " is back"
				else 
					puts "Welcome back !"
				end
			when "004" # COLLAR
				old_username, new_username = data.split(" ")
				if @username != "" then
					if old_username != @username then
						puts old_username + " is now known as " + new_username
					else
						puts new_username + " is now written on your collar."
						@username = new_username
					end
				else
					@username = new_username
				end
			when "005" # BARK
				puts data.upcase
			when "006" # PET
				user, target = data.split(" ")
				case @username
					when user
						puts "You pet " + target if target != @username
					when target
						puts "You have been petted by " + user
					else
				end
			when "008" # SNIFF
				names = data.split(" ")
				puts "Connected dogs in this kennel :"
				names.each{ |dog|
					puts " - " + dog
				}
			when "009" # LICK
				puts "TO DO : Lick"
			when "010" # BITE
				name, kennel = data.split(" ")
				if name == @username
					puts "You left "+kennel
				else
					puts data+" has left "+kennel
				end
			when "011" # FETCH
			when "012" # HELP
			#--- 1XX: Error return ---#
			when "100" # BAD COMMAND USAGE
				puts "BAD COMMAND USAGE" + data
			when "101" # AFM
				puts "You are AFM you need to use /BACK."
			when "102" # BACK
				puts "BACK" + data
			when "103" # COLLAR already exists
				puts "COLLAR already exists" + data
			when "104" # COLLAR invalid
				puts "COLLAR invalid" + data
			when "105" # PET
				puts "PET" + data
			when "106" # LICK kennel already exists
				puts "LICK kennel already exists" + data
			when "107" # LICK user-name does not exist
				puts "LICK user-name does not exist" + data
			when "108" # BITE
				puts "You're in public kennel, use /GO if you want leave the chat."
			when "109" # FETCH impossible communication 
				puts "FETCH impossible communication " + data
			when "110" # FETCH invalid file
				puts "FETCH invalid file" + data
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
		end
	end
end

client = DNC_Client.new(DOMAIN, PORT).run
