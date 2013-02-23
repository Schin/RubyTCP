=begin
** Form generated from reading ui file 'dnc_client.ui'
**
** Created: ven. févr. 22 16:45:59 2013
**      by: Qt User Interface Compiler version 4.8.3
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
=end

require 'Qt4'

class Ui_DNC_chat
    attr_reader :actionConnection
    attr_reader :actionDeconnection
    attr_reader :actionQuit
    attr_reader :centralwidget
    attr_reader :tabWidget
    attr_reader :tab_public
    attr_reader :gridLayoutWidget
    attr_reader :chat_layout
    attr_reader :send_button
    attr_reader :message_line
    attr_reader :listUsers
    attr_reader :chat_display
    attr_reader :menubar
    attr_reader :menuConnection
    attr_reader :statusbar

    def setupUi(dNC_chat)
    if dNC_chat.objectName.nil?
        dNC_chat.objectName = "dNC_chat"
    end
    dNC_chat.enabled = true
    dNC_chat.resize(802, 500)
    dNC_chat.minimumSize = Qt::Size.new(800, 500)
    dNC_chat.contextMenuPolicy = Qt::NoContextMenu
    dNC_chat.acceptDrops = false
    dNC_chat.tabShape = Qt::TabWidget::Rounded
    dNC_chat.dockNestingEnabled = false
    @actionConnection = Qt::Action.new(dNC_chat)
    @actionConnection.objectName = "actionConnection"
    @actionDeconnection = Qt::Action.new(dNC_chat)
    @actionDeconnection.objectName = "actionDeconnection"
    @actionQuit = Qt::Action.new(dNC_chat)
    @actionQuit.objectName = "actionQuit"
    @centralwidget = Qt::Widget.new(dNC_chat)
    @centralwidget.objectName = "centralwidget"
    @tabWidget = Qt::TabWidget.new(@centralwidget)
    @tabWidget.objectName = "tabWidget"
    @tabWidget.geometry = Qt::Rect.new(0, 0, 801, 471)
    @tabWidget.minimumSize = Qt::Size.new(801, 0)
    @tabWidget.tabShape = Qt::TabWidget::Rounded
    @tabWidget.iconSize = Qt::Size.new(16, 16)
    @tabWidget.usesScrollButtons = true
    @tab_public = Qt::Widget.new()
    @tab_public.objectName = "tab_public"
    @gridLayoutWidget = Qt::Widget.new(@tab_public)
    @gridLayoutWidget.objectName = "gridLayoutWidget"
    @gridLayoutWidget.geometry = Qt::Rect.new(0, 0, 801, 421)
    @gridLayoutWidget.minimumSize = Qt::Size.new(801, 0)
    @chat_layout = Qt::GridLayout.new(@gridLayoutWidget)
    @chat_layout.objectName = "chat_layout"
    @chat_layout.setContentsMargins(0, 0, 0, 0)
    @send_button = Qt::PushButton.new(@gridLayoutWidget)
    @send_button.objectName = "send_button"
    @send_button.minimumSize = Qt::Size.new(80, 30)
    @chat_layout.addWidget(@send_button, 1, 1, 1, 1)

    @message_line = Qt::LineEdit.new(@gridLayoutWidget)
    @message_line.objectName = "message_line"
    @message_line.minimumSize = Qt::Size.new(262, 30)

    @chat_layout.addWidget(@message_line, 1, 0, 1, 1)

    @listUsers = Qt::ListView.new(@gridLayoutWidget)
    @listUsers.objectName = "listUsers"
    @listUsers.minimumSize = Qt::Size.new(100, 0)
    @listUsers.maximumSize = Qt::Size.new(200, 16777215)
    @listUsers.frameShadow = Qt::Frame::Sunken

    @chat_layout.addWidget(@listUsers, 0, 2, 1, 1)

    @chat_display = Qt::PlainTextEdit.new(@gridLayoutWidget)
    @chat_display.objectName = "chat_display"
    @chat_display.enabled = false
    @chat_display.minimumSize = Qt::Size.new(316, 0)

    @chat_layout.addWidget(@chat_display, 0, 0, 1, 2)

    @tabWidget.addTab(@tab_public, Qt::Application.translate("DNC_chat", "Public", nil, Qt::Application::UnicodeUTF8))
    dNC_chat.centralWidget = @centralwidget
    @menubar = Qt::MenuBar.new(dNC_chat)
    @menubar.objectName = "menubar"
    @menubar.geometry = Qt::Rect.new(0, 0, 802, 25)
    @menuConnection = Qt::Menu.new(@menubar)
    @menuConnection.objectName = "menuConnection"
    dNC_chat.setMenuBar(@menubar)
    @statusbar = Qt::StatusBar.new(dNC_chat)
    @statusbar.objectName = "statusbar"
    dNC_chat.statusBar = @statusbar

    @menubar.addAction(@menuConnection.menuAction())
    @menuConnection.addSeparator()
    @menuConnection.addAction(@actionConnection)
    @menuConnection.addAction(@actionDeconnection)
    @menuConnection.addSeparator()
    @menuConnection.addAction(@actionQuit)

    retranslateUi(dNC_chat)
    Qt::Object.connect(@actionQuit, SIGNAL('activated()'), dNC_chat, SLOT('close()'))
    @tabWidget.setCurrentIndex(0)


    Qt::MetaObject.connectSlotsByName(dNC_chat)
    end # setupUi

    def setup_ui(dNC_chat)
        setupUi(dNC_chat)
    end

    def retranslateUi(dNC_chat)
    dNC_chat.windowTitle = Qt::Application.translate("DNC_chat", "DNC Client", nil, Qt::Application::UnicodeUTF8)
    @actionConnection.text = Qt::Application.translate("DNC_chat", "Connection", nil, Qt::Application::UnicodeUTF8)
    @actionConnection.shortcut = Qt::Application.translate("DNC_chat", "Alt+C", nil, Qt::Application::UnicodeUTF8)
    @actionDeconnection.text = Qt::Application.translate("DNC_chat", "Deconnection", nil, Qt::Application::UnicodeUTF8)
    @actionDeconnection.shortcut = Qt::Application.translate("DNC_chat", "Alt+D", nil, Qt::Application::UnicodeUTF8)
    @actionQuit.text = Qt::Application.translate("DNC_chat", "Quit", nil, Qt::Application::UnicodeUTF8)
    @actionQuit.shortcut = Qt::Application.translate("DNC_chat", "Alt+Q", nil, Qt::Application::UnicodeUTF8)
    @send_button.text = Qt::Application.translate("DNC_chat", "Send", nil, Qt::Application::UnicodeUTF8)
    @tabWidget.setTabText(@tabWidget.indexOf(@tab_public), Qt::Application.translate("DNC_chat", "Public", nil, Qt::Application::UnicodeUTF8))
    @menuConnection.title = Qt::Application.translate("DNC_chat", "Server", nil, Qt::Application::UnicodeUTF8)
    end # retranslateUi

    def retranslate_ui(dNC_chat)
        retranslateUi(dNC_chat)
    end   

end

module Ui
    class DNC_chat < Ui_DNC_chat   
        
    end
end  # module Ui

if $0 == __FILE__
    a = Qt::Application.new(ARGV)
    u = Ui_DNC_chat.new
    w = Qt::MainWindow.new
    u.setupUi(w)
    w.show
    a.exec
end
