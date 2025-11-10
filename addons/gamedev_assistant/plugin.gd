            
@tool
extends EditorPlugin

var wpvkncuj
var aqtjfpzd = preload("res://addons/gamedev_assistant/scripts/code_editor/CodeContextMenuPlugin.gd")
var tartizho:EditorContextMenuPlugin

func _enter_tree():
                                           
    wpvkncuj = preload("res://addons/gamedev_assistant/dock/gamedev_assistant_dock.tscn").instantiate()
    add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, wpvkncuj)
    
                              
    tartizho = aqtjfpzd.new(wpvkncuj)        
    add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE,tartizho)

func _exit_tree():
                                
    remove_control_from_docks(wpvkncuj)
    wpvkncuj.queue_free()
    
    remove_context_menu_plugin(tartizho)
