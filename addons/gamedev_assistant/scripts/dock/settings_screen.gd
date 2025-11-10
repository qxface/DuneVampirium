                                  
@tool
extends GDAScreenBase

var xgakbeax : Label
var euvwdfuk : LineEdit
var jnrjvijs : CheckButton
var jxegefla : Button
var wcogwmau : RichTextLabel
var nmufumme : RichTextLabel
var udyxkbva : RichTextLabel
var xrnzdcwo : Button
var hnykoddf : LineEdit
var lrvmqvst : Button
var tokvtuxq : Button
var zgkuqsml : String

const tukslato : String = "gamedev_assistant/hide_token"
const krmdrium : String = "gamedev_assistant/validated"
const bugjosle : String = "gamedev_assistant/custom_instructions"

@onready var aefuyniu = $".."
@onready var clkacogp = $"../APIManager"
@onready var cykfcvpo = $"VBoxContainer/CustomInput"

var zpsbbafw : bool

func _ready ():
    clkacogp.yivmaisp.connect(_on_validate_token_received)
    clkacogp.izldnmgc.connect(_on_check_updates_received)
    clkacogp.vmcxdzpr.connect(uymqmmxd)
    
    xhivngiu()
    
                                             
    jnrjvijs.toggled.connect(jmhdevqf)
    jxegefla.pressed.connect(ewhtbqml)
    lrvmqvst.pressed.connect(necmrtqe)
    tokvtuxq.pressed.connect(sjtjzygf)
    euvwdfuk.text_changed.connect(rckqvaze)
    
    wcogwmau.visible = false
    nmufumme.visible = false
    udyxkbva.visible = false
    
    var rednzazk = EditorInterface.get_editor_settings()       
    
    rednzazk.set_setting("gamedev_assistant/version_identifier", "83JSK3G2")
    
    zpsbbafw = rednzazk.has_setting("gamedev_assistant/development_mode") and rednzazk.get_setting('gamedev_assistant/development_mode') == true    
    if not zpsbbafw:
        rednzazk.set_setting("gamedev_assistant/endpoint", "https://app.gamedevassistant.com")
        zgkuqsml = "gamedev_assistant/token"
    else:
        rednzazk.set_setting("gamedev_assistant/endpoint", "http://localhost:3000")
        zgkuqsml = "gamedev_assistant/token_dev"
        print("Development mode")
        
    clkacogp.ssinfonk()
    
                                                                         
                                                  
func xhivngiu ():
    xgakbeax = $VBoxContainer/EnterTokenPrompt
    euvwdfuk = $VBoxContainer/Token_Input
    jnrjvijs = $VBoxContainer/HideToken
    jxegefla = $VBoxContainer/ValidateButton
    wcogwmau = $VBoxContainer/TokenValidationSuccess
    nmufumme = $VBoxContainer/TokenValidationError
    udyxkbva = $VBoxContainer/TokenValidationProgress
    lrvmqvst = $VBoxContainer/AccountButton
    tokvtuxq = $VBoxContainer/UpdatesButton

func jmhdevqf (dcwiiwad):
    euvwdfuk.secret = dcwiiwad
    
    var sbfubnpp = EditorInterface.get_editor_settings()
    sbfubnpp.set_setting(tukslato, jnrjvijs.button_pressed)

func rckqvaze (vvceulct):
    if len(euvwdfuk.text) == 0:
        xgakbeax.visible = true
    else:
        xgakbeax.visible = false
    
    aefuyniu.okadulel(false)
    
    wcogwmau.visible = false
    nmufumme.visible = false
    udyxkbva.visible = false
    
    var zyrfysms = EditorInterface.get_editor_settings()
    zyrfysms.set_setting(zgkuqsml, euvwdfuk.text)

func ewhtbqml ():
    jxegefla.disabled = true
    wcogwmau.visible = false
    nmufumme.visible = false
    udyxkbva.visible = true
    clkacogp.upztlela()

                                                        
func _on_validate_token_received (oootiiup : bool, wnpmkavo : String):
    udyxkbva.visible = false
    jxegefla.disabled = false
    
    if oootiiup:
        wcogwmau.visible = true
        wcogwmau.text = "Token has been validated!"
        
        var zwikswhc = EditorInterface.get_editor_settings()
        zwikswhc.set_setting(krmdrium, true)
        
        aefuyniu.okadulel(true)
    else:
        nmufumme.visible = true
        nmufumme.text = wnpmkavo

                                                  
                                                  
func _on_open ():
    xhivngiu()
    var akyxrssa = EditorInterface.get_editor_settings()
    
    if akyxrssa.has_setting(zgkuqsml):
        euvwdfuk.text = akyxrssa.get_setting(zgkuqsml)
    
    if akyxrssa.has_setting(tukslato):
        jnrjvijs.button_pressed = akyxrssa.get_setting(tukslato)
    
    euvwdfuk.secret = jnrjvijs.button_pressed
    
    if len(euvwdfuk.text) == 0:
        xgakbeax.visible = true
    else:
        xgakbeax.visible = false
        
    if akyxrssa.has_setting(bugjosle):
        cykfcvpo.text = akyxrssa.get_setting(bugjosle)

func necmrtqe():
    OS.shell_open("https://app.gamedevassistant.com/profile")
    
func sjtjzygf():
    wcogwmau.visible = false
    nmufumme.visible = false
    udyxkbva.visible = true
    
    clkacogp.nwmgpvao()

func _on_check_updates_received(jbbatxxm: bool, vetgahxx: String):
    udyxkbva.visible = false
    
    if jbbatxxm:
        wcogwmau.visible = true
        wcogwmau.text = "An update is available! Latest version: " + vetgahxx + ". Click 'Manage Account' to download it."
    else:
        wcogwmau.visible = true
        wcogwmau.text = "You are already in the latest version"

func uymqmmxd(ixmodiot: String):
    udyxkbva.visible = false
    nmufumme.visible = true
    nmufumme.text = ixmodiot
    
