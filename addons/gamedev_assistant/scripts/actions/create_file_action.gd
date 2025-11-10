                                                                 
@tool
extends Node

const adsxajtj = preload("action_parser_utils.gd")

static func execute(kcfjtxgs: String, afjzjssl: String) -> Dictionary:
    var emkhbbse = kcfjtxgs.get_base_dir()
    if not DirAccess.dir_exists_absolute(emkhbbse):
        var jxekxgzu = DirAccess.make_dir_recursive_absolute(emkhbbse)
        if jxekxgzu != OK:
            var tzfspwot = "Failed to create directory: %s" % emkhbbse
            push_error(tzfspwot)
            return {"success": false, "error_message": tzfspwot}
    
    var gxqqtblo = FileAccess.open(kcfjtxgs, FileAccess.WRITE)
    if gxqqtblo:
        gxqqtblo.store_string(afjzjssl)
        gxqqtblo.close()
        if Engine.is_editor_hint():
            EditorPlugin.new().get_editor_interface().get_resource_filesystem().scan()
        return {"success": true, "error_message": ""}
    else:
        var dtfpmdql = FileAccess.get_open_error()
        var tzfspwot = "Failed to create file at path '%s'. Error: %s" % [kcfjtxgs, error_string(dtfpmdql)]
        push_error(tzfspwot)
        return {"success": false, "error_message": tzfspwot}


static func parse_line(igutzlss: String, idydphsy: String) -> Dictionary:
    if igutzlss.begins_with("create_file("):
        var mzifmsdq = adsxajtj.lwlfieos(igutzlss)
        return {
            "type": "create_file",
            "path": mzifmsdq,
            "content": adsxajtj.tzxwljiw(mzifmsdq, idydphsy)
        }
    return {}
