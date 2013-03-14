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
				name, msg = data.split(" ",2)
				if name == "!" then
					puts msg
				else
					puts "["+name+"]: "+msg
				end
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
				inviter, ip, port, file = data.split(" ")
				puts "File tarnsfer : #{file}. Do you accept ? [Y/N]"
				file_menu(file, port, ip)
			when "012" # HELP
			when "013" # YAP
				name, msg = data.split(" ",2)
				puts name+"->"+msg
			#--- 1XX: Error return ---#
			when "100" # BAD COMMAND USAGE
				puts "BAD COMMAND USAGE" + data
			when "101" # AFM
				puts "You are currently AFM you need to use /BACK."
			when "102" # BACK
				puts data
			when "103" # COLLAR already exists
				puts data+" is already written on a dog collar"
			when "104" # COLLAR invalid
				puts data+" is not a proper dog name. Your master will never call you like that !"
			when "105" # non existant username
				puts "I'm affraid " + data + " is not among us..."
			when "106" # LICK kennel already exists + not a member
				puts data+" already hosts some dogs. Try another name or become a member of "+data
			when "107" # Already in private kennel
				puts "You're in a public kennel, use /GO if you want leave the chat."
			when "108" # FETCH impossible communication
				name, file = data.split(" ",2)
				puts name+" did not succeeded in establishing a communication to transfer "+file
			when "109" # FETCH invalid file
				puts data+" is an invalid file"
			when "110" # Invalid kennel
				puts data + " is an invalid kennel name. Moreover I don't think many dogs would like a kennel with that kind of name !"
			#--- 2XX: Accept return ---#
			when "201" # Accept LICK
			when "202" # Accept FETCH
			#--- 3XX: Refuse return ---#
			when "301" # Refuse LICK
			when "302" # Refuse FETCH
			#--- 4XX: Other return ---#	
			when "404" # Unknown command
				puts "Interesting command. It's a shame we don't know it !"
			when "666" # Server shutting down
				puts data
				stop
			else
		end
	end

	def file_transfer(filename, port, target)
		sock = TCPSocket.new(target, port)
		puts "Transfering : #{filename}"
		begin		
			file = open(filename, "rb")
			fileContent = file.read
			sock.puts fileContent
		rescue Exception => e

		ensure
			sock.close
			file.close
		end
		puts "Transfered"
	end

	def file_receive(filename, port)
		sock = TCPServer.new("", port)
		puts "Waiting for file : #{filename}"
		con = sock.accept
		msg = con.read
		begin
			destFile = File.open(filename, 'wb')
			destFile.print msg
		rescue Exception => e
		
		ensure
			destFile.close
			sock.close
		end

		puts "Transfered"
	end

	def file_menu(filename, port, target="")
	    choice = gets.chomp
	    case choice
	    when "Y" or "y"
	      @chat_client.puts "CMD Public ACCEPT_LICK \r\n"
	    when "N" or "n" 
	      @chat_client.puts "CMD Public "+line[1..-1].strip + "\r\n"
	    else
	      puts "Choose either Y or N."
	      file_menu
	    end
	end
end

client = DNC_Client.new(DOMAIN, PORT).run

