                                                                      
@tool
extends Node

const ktsceped = preload("action_parser_utils.gd")

static func execute(bbjbcoae: String, uwhbeati: int, fgubuqcu: Button, bpwnhhsi: Node) -> Variant:
                                      
    var ryphcecv = FileAccess.open(bbjbcoae, FileAccess.READ)
    if not ryphcecv:
        var ccnpfevs = FileAccess.get_open_error()
        var fxzchbqz = "Failed to load script: " + bbjbcoae + " (Error: " + error_string(ccnpfevs) + ")"
        push_error(fxzchbqz)
        return {"success": false, "error_message": fxzchbqz}
    
                                
    var tlbqlpuj = ryphcecv.get_as_text()
    ryphcecv.close()
        
                                                                                        
    bpwnhhsi.fzcguaqa(bbjbcoae, uwhbeati, tlbqlpuj, fgubuqcu)
    
                                                                                       
    return null

static func parse_line(qesllhre: String, jozgvdaw: String) -> Dictionary:
    if qesllhre.begins_with("edit_script("):
        var oqouqqnf = ktsceped.qcizkoub(qesllhre)
        if not oqouqqnf.is_empty():
            return {
                "type": "edit_script",
                "path": oqouqqnf.get("path", ""),
                "message_id": oqouqqnf.get("message_id", -1)
            }
    return {}
