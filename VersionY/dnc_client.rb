#encoding : UTF-8
require "socket"
require "thread"
require 'Qt4'
require './ui/dnc_client_ui'   # load ui file generated by the Designer

TAILLE_TAMPON = 1000

TIMEOUT = 10
DOMAIN = "localhost"
PORT = 2626

class DNC_Client_Form < Qt::MainWindow

	slots 'send()'
	def initialize
		super
		@ui = Ui::DNC_chat.new
		@ui.setup_ui(self)
		Qt::Object.connect(@ui.send_button, SIGNAL('clicked()'), self, SLOT('send()'))
        @chat_client = TCPSocket.new(DOMAIN, PORT)
        @username = ""
        @status = "connected"
    	self.show
        run
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
    end

    def stop
        @chat_client.close
        exit!(0)
    end

    def data_processing(type, kennel, data)
        case type
            #--- 0XX: Valid return ---#
            when "000" # Message
                @ui.chat_display.insertPlainText(data + "\n")
            when "001" # GO
                @ui.chat_display.insertPlainText("Bye !" + "\n")
                stop
            when "002" # AFM
                if data != @username
                    @ui.chat_display.insertPlainText(data + " is Away From Master" + "\n")
                else 
                    @ui.chat_display.insertPlainText("You are now Away From Master" + "\n")
                end
            when "003" # BACK
                if data != @username
                    @ui.chat_display.insertPlainText(data + " is back" + "\n")
                else 
                    @ui.chat_display.insertPlainText("Welcome back !" + "\n")
                end
            when "004" # COLLAR
                old_username, new_username = data.split(" ")
                if @username != "" then
                    if old_username != @username then
                        @ui.chat_display.insertPlainText(old_username + " is now known as " + new_username + "\n")
                    else
                        @ui.chat_display.insertPlainText(new_username + " is now written on your collar." + "\n")
                        @username = new_username
                    end
                else
                    @username = new_username
                end
            when "005" # BARK
                @ui.chat_display.insertPlainText(data.upcase + "\n")
            when "006" # PET
                user, target = data.split(" ")
                case @username
                    when user
                        @ui.chat_display.insertPlainText( "You pet " + target + "\n") if target != @username
                    when target
                        @ui.chat_display.insertPlainText( "You have been petted by " + user + "\n")
                    else
                end
            when "008" # SNIFF
                names = data.split(" ")
                @ui.chat_display.insertPlainText( "Connected dogs in this kennel :" + "\n")
                names.each{ |dog|
                    @ui.chat_display.insertPlainText( " - " + dog + "\n")
                }
            when "009" # LICK
                @ui.chat_display.insertPlainText( "TO DO : Lick" + "\n")
            when "010" # BITE
                name, kennel = data.split(" ")
                if name == @username
                    @ui.chat_display.insertPlainText( "You left "+kennel + "\n")
                else
                    @ui.chat_display.insertPlainText( data+" has left "+kennel + "\n")
                end
            when "011" # FETCH
            when "012" # HELP
            #--- 1XX: Error return ---#
            when "100" # BAD COMMAND USAGE
                @ui.chat_display.insertPlainText( "BAD COMMAND USAGE" + data + "\n")
            when "101" # AFM
                @ui.chat_display.insertPlainText( "You are AFM you need to use /BACK." + "\n")
            when "102" # BACK
                @ui.chat_display.insertPlainText( "BACK" + data + "\n")
            when "103" # COLLAR already exists
                @ui.chat_display.insertPlainText( "COLLAR already exists" + data + "\n")
            when "104" # COLLAR invalid
                @ui.chat_display.insertPlainText( "COLLAR invalid" + data + "\n")
            when "105" # PET
                @ui.chat_display.insertPlainText( "PET" + data + "\n")
            when "106" # LICK kennel already exists
                @ui.chat_display.insertPlainText( "LICK kennel already exists" + data + "\n")
            when "107" # LICK user-name does not exist
                @ui.chat_display.insertPlainText( "LICK user-name does not exist" + data + "\n")
            when "108" # BITE
                @ui.chat_display.insertPlainText( "You're in public kennel, use /GO if you want leave the chat." + "\n")
            when "109" # FETCH impossible communication 
                @ui.chat_display.insertPlainText( "FETCH impossible communication " + data + "\n")
            when "110" # FETCH invalid file
                @ui.chat_display.insertPlainText( "FETCH invalid file" + data + "\n")
            #--- 2XX: Accept return ---#
            when "201" # Accept LICK
            when "202" # Accept FETCH
            #--- 3XX: Refuse return ---#
            when "301" # Refuse LICK
            when "302" # Refuse FETCH
            #--- 4XX: Other return ---# 
            when "404" # Unknown command
                @ui.chat_display.insertPlainText("Command not found" + "\n")
            when "666" # Server shutting down
                @ui.chat_display.insertPlainText(data + "\n")
                stop
            else
        end
    end

    def send()
        line = @ui.message_line.text
        if /^\//.match(line) then
            @chat_client.puts "CMD Public "+line[1..-1].strip + "\r\n"
        else
            @chat_client.puts "MSG Public "+line.strip + "\r\n"
        end
        @ui.message_line.text = ""        
    end
end

if $0 == __FILE__
    a = Qt::Application.new(ARGV)
    DNC_Client_Form.new
    a.exec
end
