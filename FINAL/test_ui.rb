=begin
** Form generated from reading ui file 'test.ui'
**
** Created: jeu. mars 14 10:13:54 2013
**      by: Qt User Interface Compiler version 4.8.3
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
=end

require 'Qt4'

class Ui_MainWindow
    attr_reader :vL_Main
    attr_reader :horizontalLayout_5
    attr_reader :hL_Body
    attr_reader :u_HL_Chat
    attr_reader :vL_Chat
    attr_reader :tab_Kennel
    attr_reader :vL_Kennel
    attr_reader :verticalLayout_3
    attr_reader :text_Messages
    attr_reader :hL_Send
    attr_reader :lineEdit_Send
    attr_reader :button_Send
    attr_reader :u_HL_Infos
    attr_reader :vL_Infos
    attr_reader :logo
    attr_reader :infos_Perso
    attr_reader :list_Users
    attr_reader :menubar
    attr_reader :menuA
    attr_reader :statusbar

    def setupUi(mainWindow)
    if mainWindow.objectName.nil?
        mainWindow.objectName = "mainWindow"
    end
    mainWindow.resize(800, 600)
    @sizePolicy = Qt::SizePolicy.new(Qt::SizePolicy::Maximum, Qt::SizePolicy::Maximum)
    @sizePolicy.setHorizontalStretch(1)
    @sizePolicy.setVerticalStretch(1)
    @sizePolicy.heightForWidth = mainWindow.sizePolicy.hasHeightForWidth
    mainWindow.sizePolicy = @sizePolicy
    mainWindow.autoFillBackground = false
    @vL_Main = Qt::Widget.new(mainWindow)
    @vL_Main.objectName = "vL_Main"
    @sizePolicy.heightForWidth = @vL_Main.sizePolicy.hasHeightForWidth
    @vL_Main.sizePolicy = @sizePolicy
    @vL_Main.autoFillBackground = true
    @horizontalLayout_5 = Qt::HBoxLayout.new(@vL_Main)
    @horizontalLayout_5.objectName = "horizontalLayout_5"
    @hL_Body = Qt::HBoxLayout.new()
    @hL_Body.objectName = "hL_Body"
    @hL_Body.sizeConstraint = Qt::Layout::SetNoConstraint
    @u_HL_Chat = Qt::HBoxLayout.new()
    @u_HL_Chat.objectName = "u_HL_Chat"
    @u_HL_Chat.sizeConstraint = Qt::Layout::SetNoConstraint
    @vL_Chat = Qt::VBoxLayout.new()
    @vL_Chat.objectName = "vL_Chat"
    @vL_Chat.sizeConstraint = Qt::Layout::SetNoConstraint
    @tab_Kennel = Qt::TabWidget.new(@vL_Main)
    @tab_Kennel.objectName = "tab_Kennel"
    @sizePolicy1 = Qt::SizePolicy.new(Qt::SizePolicy::Expanding, Qt::SizePolicy::Expanding)
    @sizePolicy1.setHorizontalStretch(1)
    @sizePolicy1.setVerticalStretch(1)
    @sizePolicy1.heightForWidth = @tab_Kennel.sizePolicy.hasHeightForWidth
    @tab_Kennel.sizePolicy = @sizePolicy1
    @tab_Kennel.autoFillBackground = false
    @vL_Kennel = Qt::Widget.new()
    @vL_Kennel.objectName = "vL_Kennel"
    @sizePolicy.heightForWidth = @vL_Kennel.sizePolicy.hasHeightForWidth
    @vL_Kennel.sizePolicy = @sizePolicy
    @verticalLayout_3 = Qt::VBoxLayout.new(@vL_Kennel)
    @verticalLayout_3.objectName = "verticalLayout_3"
    @verticalLayout_3.sizeConstraint = Qt::Layout::SetNoConstraint
    @text_Messages = Qt::TextEdit.new(@vL_Kennel)
    @text_Messages.objectName = "text_Messages"
    @sizePolicy1.heightForWidth = @text_Messages.sizePolicy.hasHeightForWidth
    @text_Messages.sizePolicy = @sizePolicy1
    @text_Messages.autoFillBackground = false

    @verticalLayout_3.addWidget(@text_Messages)

    @tab_Kennel.addTab(@vL_Kennel, Qt::Application.translate("MainWindow", "Tab 1", nil, Qt::Application::UnicodeUTF8))

    @vL_Chat.addWidget(@tab_Kennel)

    @hL_Send = Qt::HBoxLayout.new()
    @hL_Send.objectName = "hL_Send"
    @hL_Send.sizeConstraint = Qt::Layout::SetNoConstraint
    @lineEdit_Send = Qt::LineEdit.new(@vL_Main)
    @lineEdit_Send.objectName = "lineEdit_Send"
    @sizePolicy2 = Qt::SizePolicy.new(Qt::SizePolicy::Expanding, Qt::SizePolicy::Fixed)
    @sizePolicy2.setHorizontalStretch(0)
    @sizePolicy2.setVerticalStretch(0)
    @sizePolicy2.heightForWidth = @lineEdit_Send.sizePolicy.hasHeightForWidth
    @lineEdit_Send.sizePolicy = @sizePolicy2

    @hL_Send.addWidget(@lineEdit_Send)

    @button_Send = Qt::PushButton.new(@vL_Main)
    @button_Send.objectName = "button_Send"

    @hL_Send.addWidget(@button_Send)


    @vL_Chat.addLayout(@hL_Send)


    @u_HL_Chat.addLayout(@vL_Chat)


    @hL_Body.addLayout(@u_HL_Chat)

    @u_HL_Infos = Qt::HBoxLayout.new()
    @u_HL_Infos.objectName = "u_HL_Infos"
    @u_HL_Infos.sizeConstraint = Qt::Layout::SetNoConstraint
    @vL_Infos = Qt::VBoxLayout.new()
    @vL_Infos.objectName = "vL_Infos"
    @vL_Infos.sizeConstraint = Qt::Layout::SetNoConstraint
    @logo = Qt::Frame.new(@vL_Main)
    @logo.objectName = "logo"
    @sizePolicy3 = Qt::SizePolicy.new(Qt::SizePolicy::Minimum, Qt::SizePolicy::Minimum)
    @sizePolicy3.setHorizontalStretch(0)
    @sizePolicy3.setVerticalStretch(0)
    @sizePolicy3.heightForWidth = @logo.sizePolicy.hasHeightForWidth
    @logo.sizePolicy = @sizePolicy3
    @logo.frameShape = Qt::Frame::StyledPanel
    @logo.frameShadow = Qt::Frame::Raised

    @vL_Infos.addWidget(@logo)

    @infos_Perso = Qt::GroupBox.new(@vL_Main)
    @infos_Perso.objectName = "infos_Perso"

    @vL_Infos.addWidget(@infos_Perso)

    @list_Users = Qt::ListWidget.new(@vL_Main)
    @list_Users.objectName = "list_Users"

    @vL_Infos.addWidget(@list_Users)


    @u_HL_Infos.addLayout(@vL_Infos)


    @hL_Body.addLayout(@u_HL_Infos)


    @horizontalLayout_5.addLayout(@hL_Body)

    mainWindow.centralWidget = @vL_Main
    @menubar = Qt::MenuBar.new(mainWindow)
    @menubar.objectName = "menubar"
    @menubar.geometry = Qt::Rect.new(0, 0, 800, 25)
    @menuA = Qt::Menu.new(@menubar)
    @menuA.objectName = "menuA"
    mainWindow.setMenuBar(@menubar)
    @statusbar = Qt::StatusBar.new(mainWindow)
    @statusbar.objectName = "statusbar"
    mainWindow.statusBar = @statusbar

    @menubar.addAction(@menuA.menuAction())

    retranslateUi(mainWindow)

    @tab_Kennel.setCurrentIndex(0)


    Qt::MetaObject.connectSlotsByName(mainWindow)
    end # setupUi

    def setup_ui(mainWindow)
        setupUi(mainWindow)
    end

    def retranslateUi(mainWindow)
    mainWindow.windowTitle = Qt::Application.translate("MainWindow", "MainWindow", nil, Qt::Application::UnicodeUTF8)
    @tab_Kennel.setTabText(@tab_Kennel.indexOf(@vL_Kennel), Qt::Application.translate("MainWindow", "Tab 1", nil, Qt::Application::UnicodeUTF8))
    @button_Send.text = Qt::Application.translate("MainWindow", "PushButton", nil, Qt::Application::UnicodeUTF8)
    @infos_Perso.title = Qt::Application.translate("MainWindow", "GroupBox", nil, Qt::Application::UnicodeUTF8)
    @menuA.title = Qt::Application.translate("MainWindow", "A", nil, Qt::Application::UnicodeUTF8)
    end # retranslateUi

    def retranslate_ui(mainWindow)
        retranslateUi(mainWindow)
    end

end

module Ui
    class MainWindow < Ui_MainWindow
    end
end  # module Ui

if $0 == __FILE__
    a = Qt::Application.new(ARGV)
    u = Ui_MainWindow.new
    w = Qt::MainWindow.new
    u.setupUi(w)
    w.show
    a.exec
end
