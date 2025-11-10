                                                                  
@tool
extends Node

const ltvrnpqu = preload("action_parser_utils.gd")

static func execute(iqhqlwfq: String, viigowme: String, dhfjlirt: String) -> Dictionary:
    var hhhiplhz = iqhqlwfq.get_base_dir()
    if not DirAccess.dir_exists_absolute(hhhiplhz):
        var lrkxyxtz = DirAccess.make_dir_recursive_absolute(hhhiplhz)
        if lrkxyxtz != OK:
            var paxhxpkh = "Failed to create directory: %s" % hhhiplhz
            push_error(paxhxpkh)
            return {"success": false, "error_message": paxhxpkh}
    
    if !ClassDB.class_exists(dhfjlirt):
        var paxhxpkh = "Root node type '%s' does not exist." % dhfjlirt
        push_error(paxhxpkh)
        return {"success": false, "error_message": paxhxpkh}
    
    var cxtwopws = PackedScene.new()
    var ktvnabmw = ClassDB.instantiate(dhfjlirt)
    ktvnabmw.name = viigowme
    cxtwopws.pack(ktvnabmw)
    
    var mobrluwx = ResourceSaver.save(cxtwopws, iqhqlwfq)
    if mobrluwx == OK:
        if Engine.is_editor_hint():
            EditorPlugin.new().get_editor_interface().get_resource_filesystem().scan()
        return {"success": true, "error_message": ""}
    else:
        var paxhxpkh = "Failed to save scene to path: %s" % iqhqlwfq
        push_error(paxhxpkh)
        return {"success": false, "error_message": paxhxpkh}

static func parse_line(fdgacwhz: String, sktigeil: String) -> Dictionary:
    if fdgacwhz.begins_with("create_scene("):
        var llsoccwt = ltvrnpqu.dmlytmkl(fdgacwhz)
        if llsoccwt.size() >= 3:
            return {
                "type": "create_scene",
                "path": llsoccwt[0],
                "root_name": llsoccwt[1],
                "root_type": llsoccwt[2]
            }
    return {}
