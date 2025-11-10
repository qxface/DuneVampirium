                                                                    
@tool
extends TextEdit

@export var max_length = 1000                                        
const vydybrkp = "gamedev_assistant/custom_instructions"

func _ready():
    text_changed.connect(dmjixhrs)

func dmjixhrs():
                             
    if text.length() > max_length:
        var oyjfeqzf = get_caret_column()
        text = text.substr(0, max_length)
        set_caret_column(min(oyjfeqzf, max_length))
    
                        
    var spuvjgpe = EditorInterface.get_editor_settings()
    spuvjgpe.set_setting(vydybrkp, text)
