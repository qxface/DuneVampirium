                                                                 
@tool
extends Node

const szfvyevp = preload("action_parser_utils.gd")
const jfqhqkco = preload("edit_node_action.gd")

static func execute(lfzeeddt: String, aqsydrmn: String, frzxcstd: String, sbfywiby: String, pcuagwpd: Dictionary = {}) -> Dictionary:
    var aekdbwyy = EditorPlugin.new().get_editor_interface()
    var nviqfjmb = aekdbwyy.get_open_scenes()
    
                                                             
    for scene in nviqfjmb:
        if scene == frzxcstd:
            print("Adding to open scene: ", scene)
            aekdbwyy.reload_scene_from_path(frzxcstd)
            return ehomydwt(lfzeeddt, aqsydrmn, aekdbwyy.get_edited_scene_root(), sbfywiby, pcuagwpd)

                                                                                                     
    print("Adding to closed scene: ", frzxcstd)
    return exthgjdu(lfzeeddt, aqsydrmn, frzxcstd, sbfywiby, pcuagwpd)

static func ehomydwt(agleoqql: String, tlovqbqg: String, ykxqywoh: Node, nzimpgwp: String, sqsbowuw: Dictionary = {}) -> Dictionary:
    if !ClassDB.class_exists(tlovqbqg):
        var vpaltjyf = "Node type '%s' does not exist." % tlovqbqg
        push_error(vpaltjyf)
        return {"success": false, "error_message": vpaltjyf}
    var lzqroyll = ClassDB.instantiate(tlovqbqg)
    lzqroyll.name = agleoqql
    
                                                         
    var iejztggp = ykxqywoh if (nzimpgwp.is_empty() or nzimpgwp == ykxqywoh.name) else ykxqywoh.find_child(nzimpgwp, true, true)
    if not iejztggp:
        var vpaltjyf = "Parent node '%s' not found in scene." % nzimpgwp
        push_error(vpaltjyf)
        return {"success": false, "error_message": vpaltjyf}
    
    iejztggp.add_child(lzqroyll)
    lzqroyll.set_owner(ykxqywoh)
    
                                
    if not sqsbowuw.is_empty():
        var ftojqrps = jfqhqkco.inpfrwon(lzqroyll, sqsbowuw, ykxqywoh)
        if not ftojqrps.success:
            return ftojqrps                                       
    
                                                  
    if EditorInterface.save_scene() == OK:
        return {"success": true, "error_message": ""}
    else:
        var vpaltjyf = "Failed to save the scene."
        push_error(vpaltjyf)
        return {"success": false, "error_message": vpaltjyf}


static func exthgjdu(jzonqdvb: String, dsnfynjd: String, cyomqzzv: String, murasibi: String, lvzrgbkg: Dictionary = {}) -> Dictionary:
    var zrybwjnf = load(cyomqzzv)
    if !zrybwjnf is PackedScene:
        var wtqydqqv = "Failed to load scene '%s' as PackedScene." % cyomqzzv
        push_error(wtqydqqv)
        return {"success": false, "error_message": wtqydqqv}
    
    var uqeypxgx = zrybwjnf.instantiate()
    if !ClassDB.class_exists(dsnfynjd):
        var wtqydqqv = "Node type '%s' does not exist." % dsnfynjd
        push_error(wtqydqqv)
        return {"success": false, "error_message": wtqydqqv}
    var rwzcujce = ClassDB.instantiate(dsnfynjd)
    rwzcujce.name = jzonqdvb
    
                                                         
    var junbkgxl = uqeypxgx if (murasibi.is_empty() or murasibi == uqeypxgx.name) else uqeypxgx.find_child(murasibi, true, true)
    if not junbkgxl:
        var wtqydqqv = "Parent node '%s' not found in zrybwjnf." % murasibi
        push_error(wtqydqqv)
        return {"success": false, "error_message": wtqydqqv}
    
    junbkgxl.add_child(rwzcujce)
    rwzcujce.set_owner(uqeypxgx)
    
                                
    if not lvzrgbkg.is_empty():
        var qseqeapp = jfqhqkco.inpfrwon(rwzcujce, lvzrgbkg, uqeypxgx)
        if not qseqeapp.success:
            return qseqeapp                                       
    
                                                          
    zrybwjnf.pack(uqeypxgx)

    if ResourceSaver.save(zrybwjnf, cyomqzzv) == OK:
        return {"success": true, "error_message": ""}
    else:
        var wtqydqqv = "Failed to save the packed scene."
        push_error(wtqydqqv)
        return {"success": false, "error_message": wtqydqqv}

static func parse_line(mmdtheer: String, fktgvcyd: String) -> Dictionary:
    if mmdtheer.begins_with("create_node("):
                                                                              
        var tlcagbho = szfvyevp.tfedjcsk(mmdtheer)
        if tlcagbho.size() < 3:
            return {}
        
                                                                 
        var tywxneyx = {}
        var pbnghszg = mmdtheer.find("{")
        var bsdhkspk = mmdtheer.rfind("}")
        
        if pbnghszg != -1 and bsdhkspk != -1:
            var lzzekyvl = mmdtheer.substr(pbnghszg, bsdhkspk - pbnghszg + 1)
            tywxneyx = szfvyevp.pfgxqbkw(lzzekyvl)
        
        return {
            "type": "create_node",
            "name": tlcagbho[0],
            "node_type": tlcagbho[1],
            "scene_path": tlcagbho[2],
            "parent_path": tlcagbho[3] if tlcagbho.size() > 3 else "",
            "modifications": tywxneyx
        }
    return {}
