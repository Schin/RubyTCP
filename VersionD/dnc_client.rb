# main.rb
# version 1
#       
require 'Qt4'
require './ui/dnc_client_ui'   # load ui file generated by the Designer

class DNC_Client_Form < Qt::MainWindow

	slots 'send()'
	def initialize
		super
		@ui = Ui::DNC_chat.new
		@ui.setup_ui(self)
		Qt::Object.connect(@ui.send_button, SIGNAL('clicked()'), self, SLOT('send()'))

    	self.show

    end

    def send()
        @ui.chat_display.insertPlainText(@ui.message_line.text + "\n")
        @ui.message_line.text = ""        
    end
end

if $0 == __FILE__
    a = Qt::Application.new(ARGV)
    DNC_Client_Form.new
    a.exec
end
