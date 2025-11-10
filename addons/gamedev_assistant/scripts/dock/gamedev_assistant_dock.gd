                                         
@tool
extends Control

@onready var sxpqstvy = $Screen_Conversations
@onready var atfzvool = $Screen_Chat
@onready var ywtttuwh = $Screen_Settings

@onready var vkzbsjll = $Header/HBoxContainer/ConversationsButton
@onready var emppbbpv = $Header/ChatButton
@onready var mmorpejr = $Header/HBoxContainer/SettingsButton
@onready var tolxciur = $Header/ScreenText

@onready var yyxoqpgp = $ConversationManager
@onready var twbewjrd = $APIManager

                                          
var zkgxaktd : bool = false

                                                    
var dqafdojh : bool = false

func _ready():
    okadulel(false)
    
                                       
    twbewjrd.izldnmgc.connect(gumwutlp)
    twbewjrd.vmcxdzpr.connect(gumwutlp)
    
                                   
    emppbbpv.pressed.connect(tokfzgxw)
    mmorpejr.pressed.connect(rpotbpkj)
    vkzbsjll.pressed.connect(evrsirvb)
    
    var dyhqctma = EditorInterface.get_editor_settings()
    
                                        
    var oqyyehnw = dyhqctma.has_setting("gamedev_assistant/development_mode") and dyhqctma.get_setting('gamedev_assistant/development_mode') == true    
    if oqyyehnw:
        uickxiyy()
    
    if dyhqctma.has_setting("gamedev_assistant/validated"):
        if dyhqctma.get_setting("gamedev_assistant/validated") == true:
            tokfzgxw()
            okadulel(true)
                        
                                                             
            twbewjrd.nwmgpvao(true)
            return
                                          
    elif !dyhqctma.has_setting("gamedev_assistant/onboarding_shown"):
        uickxiyy()
        dyhqctma.set_setting("gamedev_assistant/onboarding_shown", true)
        
    lwffwpic(ywtttuwh, "Settings")

func lwffwpic (kjgvugbt, quzxqthz):
    sxpqstvy.visible = false
    atfzvool.visible = false
    ywtttuwh.visible = false
    
                                                 
    kjgvugbt.visible = true
    kjgvugbt._on_open()
    
    tolxciur.text = quzxqthz
    
    dqafdojh = kjgvugbt == atfzvool
    
                       
    twbewjrd.tyylnebm.emit()
    
                                                                
                                                           
                                       

func evrsirvb():
    lwffwpic(sxpqstvy, "Conversations")

func tokfzgxw():
    yyxoqpgp.nnyutcvt()
    lwffwpic(atfzvool, "New Conversation")
    atfzvool.nfxknjao()
    twbewjrd.tyylnebm.emit()

func rpotbpkj():
    if ywtttuwh.visible:
        return
    
    lwffwpic(ywtttuwh, "Settings")

func rubfwwhb (jpsizwqn : Conversation):
    yyxoqpgp.ytvlehxr(jpsizwqn.id)
    lwffwpic(atfzvool, "Chat")

func okadulel (podckikm : bool):
    zkgxaktd = podckikm
    emppbbpv.disabled = !podckikm
    vkzbsjll.disabled = !podckikm
    
                                                               
func gumwutlp(tztzqxqo, param2 = ""):
                                                                                       
                                                            
    
    var srolntia = AcceptDialog.new()
    srolntia.get_ok_button().text = "Close"
    
                                                                                 
    if tztzqxqo is bool:
                                                             
        var bpsmvlhf = tztzqxqo
        var zgqidrkp = param2
        
                                                   
        if bpsmvlhf:
            srolntia.title = "GameDev Assistant Update"
            srolntia.dialog_text = "An update is available! Latest version: " + zgqidrkp + ". Go to https://app.gamedevassistant.com to download it."
            add_child(srolntia)
            srolntia.popup_centered()
    else:
                                                           
        var thftyxnf = tztzqxqo
        srolntia.title = "GameDev Assistant Update"
        srolntia.dialog_text = thftyxnf
        add_child(srolntia)
        srolntia.popup_centered()

func uickxiyy():
    var dhsmhrda = AcceptDialog.new()
    dhsmhrda.title = "Welcome Aboard! 🚀"
    dhsmhrda.dialog_text = "Welcome to GameDev Assistant by Zenva!\n\n🌟 To get started:\n1. Find the Assistant tab (next to Inspector, Node, etc, use arrows < > to find it)\n2. Enter your token in Settings\n3. Start a chat with the + button\n4. Switch between Chat and Agent mode to find your perfect workflow\n\n\nHappy gamedev! 🎮"
    dhsmhrda.ok_button_text = "Close"
    dhsmhrda.dialog_hide_on_ok = true
    add_child(dhsmhrda)
    dhsmhrda.popup_centered()

func ffwqmbig():
    return yyxoqpgp
