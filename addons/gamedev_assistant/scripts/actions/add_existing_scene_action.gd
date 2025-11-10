                                                                 
@tool
extends Node

const xnmpngvs = preload("action_parser_utils.gd")
const iznnlfwd = preload("edit_node_action.gd")

static func execute(eiceptyc: String, logoctbf: String, gmsoreey: String, vouplsoi: String, vtlvblka: Dictionary) -> Dictionary:
    var jhqofdlu = EditorPlugin.new().get_editor_interface()
    var odqkqpqj = jhqofdlu.get_open_scenes()
    
    var ejdmlvlq = load(logoctbf)
    if not ejdmlvlq is PackedScene:
        var ylggdtes = "Invalid or non-existent scene file: " + logoctbf
        push_error(ylggdtes)
        return {"success": false, "error_message": ylggdtes}
    
    if gmsoreey in odqkqpqj:
        return efpdbfiv(eiceptyc, ejdmlvlq, gmsoreey, vouplsoi, vtlvblka)
    else:
        return txxrhkqq(eiceptyc, ejdmlvlq, gmsoreey, vouplsoi, vtlvblka)

static func efpdbfiv(nboimgyn: String, tufmkagq: PackedScene, jyyjretp: String, fqlhmjxp: String, rnadxdnz: Dictionary) -> Dictionary:
    var msrgllli = EditorPlugin.new().get_editor_interface()
    msrgllli.reload_scene_from_path(jyyjretp)
    var dvfylgpk = msrgllli.get_edited_scene_root()
    
    var cjzvatsu = dvfylgpk if (fqlhmjxp.is_empty() or fqlhmjxp == dvfylgpk.name) else dvfylgpk.find_child(fqlhmjxp, true, true)
    if not cjzvatsu:
        var kfmpleqx = "Parent node '%s' not found in scene '%s'." % [fqlhmjxp, jyyjretp]
        push_error(kfmpleqx)
        return {"success": false, "error_message": kfmpleqx}
    
    var oltqfowe = tufmkagq.instantiate()
    oltqfowe.name = nboimgyn
    cjzvatsu.add_child(oltqfowe)
    oltqfowe.set_owner(dvfylgpk)
    
    if not rnadxdnz.is_empty():
        var rtrfdvxq = iznnlfwd.inpfrwon(oltqfowe, rnadxdnz, dvfylgpk)
        if not rtrfdvxq.success:
            return rtrfdvxq                                       
    
    if EditorPlugin.new().get_editor_interface().save_scene() == OK:
        return {"success": true, "error_message": ""}
    else:
        var kfmpleqx = "Failed to save scene '%s'." % jyyjretp
        push_error(kfmpleqx)
        return {"success": false, "error_message": kfmpleqx}


static func txxrhkqq(nwlftrud: String, ybijjjcs: PackedScene, xttbdxsf: String, rmximbhz: String, znbryfhm: Dictionary) -> Dictionary:
    var kbriaghw = load(xttbdxsf)
    if not kbriaghw is PackedScene:
        var xovhtarx = "Invalid or non-existent target scene: " + xttbdxsf
        push_error(xovhtarx)
        return {"success": false, "error_message": xovhtarx}
    
    var rbkuavhj = kbriaghw.instantiate()
    var wobrwdcz = rbkuavhj if (rmximbhz.is_empty() or rmximbhz == rbkuavhj.name) else rbkuavhj.find_child(rmximbhz, true, true)
    if not wobrwdcz:
        var xovhtarx = "Parent node '%s' not found in scene '%s'." % [rmximbhz, xttbdxsf]
        push_error(xovhtarx)
        return {"success": false, "error_message": xovhtarx}
    
    var lsqbpjdg = ybijjjcs.instantiate()
    lsqbpjdg.name = nwlftrud
    wobrwdcz.add_child(lsqbpjdg)
    lsqbpjdg.set_owner(rbkuavhj)
    
    if not znbryfhm.is_empty():
        var aypxkfai = iznnlfwd.inpfrwon(lsqbpjdg, znbryfhm, rbkuavhj)
        if not aypxkfai.success:
            return aypxkfai                                       
    
    kbriaghw.pack(rbkuavhj)
    if ResourceSaver.save(kbriaghw, xttbdxsf) == OK:
        return {"success": true, "error_message": ""}
    else:
        var xovhtarx = "Failed to save packed scene '%s'." % xttbdxsf
        push_error(xovhtarx)
        return {"success": false, "error_message": xovhtarx}

static func parse_line(ghiucycb: String, qbaouluh: String) -> Dictionary:
    if ghiucycb.begins_with("add_existing_scene("):
        var ciqzyvyg = ghiucycb.replace("add_existing_scene(", "").strip_edges()
        if ciqzyvyg.ends_with(")"):
            ciqzyvyg = ciqzyvyg.substr(0, ciqzyvyg.length() - 1).strip_edges()
        
        var buzdysit = []
        var hmhykoqa = 0
                                             
        for _i in range(4):
            var anztggqh = ciqzyvyg.find('"',hmhykoqa)
            if anztggqh == -1: return {}
            var yuiqpgbh = ciqzyvyg.find('"', anztggqh + 1)
            if yuiqpgbh == -1: return {}
            buzdysit.append(ciqzyvyg.substr(anztggqh + 1, yuiqpgbh - anztggqh - 1))
            hmhykoqa = yuiqpgbh + 1
        
                                        
        var johwyysa = {}
        var wegxpapk = ciqzyvyg.substr(hmhykoqa).strip_edges()
        if wegxpapk.begins_with("{"):
            johwyysa = xnmpngvs.pfgxqbkw(wegxpapk)
        
        return {
            "type": "add_existing_scene",
            "node_name": buzdysit[0],
            "existing_scene_path": buzdysit[1],
            "target_scene_path": buzdysit[2],
            "parent_path": buzdysit[3],
            "modifications": johwyysa
        }
    return {}
