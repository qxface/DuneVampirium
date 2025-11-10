extends EditorContextMenuPlugin

var oigpjiby: Control

func _init(cjbtokpg: Control):                                                
    oigpjiby = cjbtokpg

                                                                              
func lhmefndt(vomzdmmc: PackedStringArray):
    add_context_menu_item("Add to Chat",dsfffnub)
    add_context_menu_item("Explain Code",fzizalja)

func fzizalja(uyluwwrr: Node):
    if not (uyluwwrr is CodeEdit):
        return
    if uyluwwrr.has_selection():
        var bjskdvsc = uyluwwrr.get_selected_text()
        if bjskdvsc:         
                                                      
            var ydgcgifc = Engine.get_singleton("EditorInterface")
            var hecysqgo = ydgcgifc.get_script_editor().get_current_script()
            if hecysqgo:
                bjskdvsc = "Explain this code from %s:\n\n%s" % [hecysqgo.resource_path, bjskdvsc]
            
                                                                                    
            if oigpjiby:  
                if not oigpjiby.is_open_chat:
                    print("Please open the chat to use this command")
                    return
                                                                    
                var nksglehf : TextEdit = oigpjiby.get_node("Screen_Chat/Footer/PromptInput")         
                if nksglehf:                                               
                    nksglehf.insert_text_at_caret("\n" +bjskdvsc)          
                else:                                                               
                    print("PromptInput node not found in the dock.")                
            else:                                                                   
                print("Dock reference is null.")          

func dsfffnub(zqvhzqgw: Node):
    if not (zqvhzqgw is CodeEdit):
        return
    if zqvhzqgw.has_selection():
        var faaqnnia = zqvhzqgw.get_selected_text()
        if faaqnnia:
                                                      
            var yhgeqqak = Engine.get_singleton("EditorInterface")
            var oqkldqyn = yhgeqqak.get_script_editor().get_current_script()
            if oqkldqyn:
                faaqnnia = "Snippet from %s:\n%s" % [oqkldqyn.resource_path, faaqnnia]
            
                                                                                    
            if oigpjiby:          
                if not oigpjiby.is_open_chat:
                    print("Please open the chat to use this command")
                    return
                                                                      
                var gvjxrqls : TextEdit = oigpjiby.get_node("Screen_Chat/Footer/PromptInput")         
                if gvjxrqls:                                               
                    gvjxrqls.insert_text_at_caret("\n" +faaqnnia)             
                else:                                                               
                    print("PromptInput node not found in the dock.")                
            else:                                                                   
                print("Dock reference is null.")          

            
            
            
