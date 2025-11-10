                                                                      
@tool
extends Node

const ebqrnhsb = preload("action_parser_utils.gd")
                                                                            
                                                   
const ibopqbjt = preload("add_subresource_action.gd")

static func execute(zgqmaooj: String, bwizhwvd: String, zgynhknf: String, vnwquhvf: Dictionary) -> Dictionary:
    var zdxebkwg = EditorPlugin.new().get_editor_interface()
    var ostlfbtx = zdxebkwg.get_open_scenes()

                                   
    for scene in ostlfbtx:
        if scene == bwizhwvd:
                                                                    
            zdxebkwg.reload_scene_from_path(bwizhwvd)
            return _edit_in_open_scene(zgqmaooj, zdxebkwg.get_edited_scene_root(), zgynhknf, vnwquhvf)

                                           
                                                              
    return _edit_in_closed_scene(zgqmaooj, bwizhwvd, zgynhknf, vnwquhvf)


static func _edit_in_open_scene(iolwvjug: String, darlyfym: Node, ifmuiwct: String, pmdnbctw: Dictionary) -> Dictionary:
    var limrbbrw = ibopqbjt.jiypoaqe(iolwvjug, darlyfym)               
    if not limrbbrw:
                                              
        return {"success": false, "error_message": "Node '%s' not found." % iolwvjug, "node_type": "", "subresource_type": ""}

    var lbsrrpgg = limrbbrw.get(ifmuiwct)
    if not (lbsrrpgg is Resource):
        var iqtqhzud = "Property '%s' on node '%s' is not a Resource or doesn't exist." % [ifmuiwct, iolwvjug]
        push_error(iqtqhzud)
        return {"success": false, "error_message": iqtqhzud, "node_type": limrbbrw.get_class(), "subresource_type": ""}

    var onvixcxe = tmmafyck(lbsrrpgg, pmdnbctw)
    if not onvixcxe.success:
        return {"success": false, "error_message": onvixcxe.error_message, "node_type": limrbbrw.get_class(), "subresource_type": lbsrrpgg.get_class()}

                         
    EditorInterface.edit_resource(lbsrrpgg)                                 
    if EditorInterface.save_scene() == OK:
        return {"success": true, "error_message": "", "node_type": limrbbrw.get_class(), "subresource_type": lbsrrpgg.get_class()}
    else:
        var iqtqhzud = "Failed to save the scene."
        push_error(iqtqhzud)
        return {"success": false, "error_message": iqtqhzud, "node_type": limrbbrw.get_class(), "subresource_type": lbsrrpgg.get_class()}

static func _edit_in_closed_scene(zsnsiytq: String, nstfyfly: String, grzsbvib: String, ocpmcdox: Dictionary) -> Dictionary:
    var erxqlljz = load(nstfyfly)
    if !(erxqlljz is PackedScene):
        var uzztugjp = "Failed to load scene '%s' as PackedScene." % nstfyfly
        push_error(uzztugjp)
        return {"success": false, "error_message": uzztugjp, "node_type": "", "subresource_type": ""}

    var wylvbyvc = erxqlljz.instantiate()
    if not wylvbyvc:
        var uzztugjp = "Could not instantiate scene '%s'." % nstfyfly
        push_error(uzztugjp)
        return {"success": false, "error_message": uzztugjp, "node_type": "", "subresource_type": ""}

    var ituihtlh = ibopqbjt.jiypoaqe(zsnsiytq, wylvbyvc)               
    if not ituihtlh:
        wylvbyvc.free()
        return {"success": false, "error_message": "Node '%s' not found." % zsnsiytq, "node_type": "", "subresource_type": ""}

    var awzjfloz = ituihtlh.get(grzsbvib)
    if not (awzjfloz is Resource):
        var uzztugjp = "Property '%s' on node '%s' is not a Resource or doesn't exist." % [grzsbvib, zsnsiytq]
        push_error(uzztugjp)
        wylvbyvc.free()
        return {"success": false, "error_message": uzztugjp, "node_type": ituihtlh.get_class(), "subresource_type": ""}

    var qccsjzss = tmmafyck(awzjfloz, ocpmcdox)
    if not qccsjzss.success:
        wylvbyvc.free()
        return {"success": false, "error_message": qccsjzss.error_message, "node_type": ituihtlh.get_class(), "subresource_type": awzjfloz.get_class()}

    erxqlljz.pack(wylvbyvc)
    var lpgemrxc = ResourceSaver.save(erxqlljz, nstfyfly)
    wylvbyvc.free()

    if lpgemrxc == OK:
        return {"success": true, "error_message": "", "node_type": ituihtlh.get_class(), "subresource_type": awzjfloz.get_class()}
    else:
        var uzztugjp = "Failed to save the packed scene."
        push_error(uzztugjp)
        return {"success": false, "error_message": uzztugjp, "node_type": ituihtlh.get_class(), "subresource_type": awzjfloz.get_class()}


                                                                             
         
                                                                             
static func tmmafyck(vlsrmqgu: Resource, berjsbth: Dictionary) -> Dictionary:
    for property_name in berjsbth.keys():
        var orewqalu = berjsbth[property_name]
        var lswohkrx = ibopqbjt._parse_value(orewqalu)
        if lswohkrx == null and orewqalu != null:
            var hcemtbpv = "Failed to parse value '%s' for property '%s'." % [str(orewqalu), property_name]
            push_error(hcemtbpv)
            return {"success": false, "error_message": hcemtbpv}

        if not ibopqbjt.wgsfzmnb(vlsrmqgu, property_name, lswohkrx):
                                               
            var hcemtbpv = "Failed to set property '%s' on resource '%s'." % [property_name, vlsrmqgu.get_class()]
            return {"success": false, "error_message": hcemtbpv}

    return {"success": true, "error_message": ""}

                                                                             
            
                                                       
                                                                
                                                                                                                     
                                                                             
static func parse_line(ljbsofuf: String, sylrkrvt: String) -> Dictionary:
    if ljbsofuf.begins_with("edit_subresource("):
        var oxgqecfc = ljbsofuf.replace("edit_subresource(", "")
        if oxgqecfc.ends_with(")"):
            oxgqecfc = oxgqecfc.substr(0, oxgqecfc.length() - 1)             
        oxgqecfc = oxgqecfc.strip_edges()

                                                                                                
        var ylukdkhe = []
        var gfaoszcq = 0
        var vdezmits = 0
        while vdezmits < 3:                             
            var gstjrybz = oxgqecfc.find('"',gfaoszcq)
            if gstjrybz == -1:
                break                         
            var gfhuzwps = oxgqecfc.find('"', gstjrybz + 1)
            if gfhuzwps == -1:
                break                       
            ylukdkhe.append(oxgqecfc.substr(gstjrybz + 1, gfhuzwps - (gstjrybz + 1)))             
            gfaoszcq = gfhuzwps + 1
            vdezmits += 1
                                                                         
            var qabosawk = oxgqecfc.find(",", gfaoszcq)
            if qabosawk != -1:
                gfaoszcq = qabosawk + 1
            else:
                                                                                                    
                if vdezmits < 3: break                                               

        if ylukdkhe.size() < 3:
            push_error("Edit Subresource: Failed to parse required string arguments (node_name, scene_path, subresource_property_name). Line: " + ljbsofuf)
            return {}

                                                                        
        var qigfyzmy = oxgqecfc.find("{", gfaoszcq)                                 
        var nvtckmyc = oxgqecfc.rfind("}")
        if qigfyzmy == -1 or nvtckmyc == -1 or nvtckmyc < qigfyzmy:
            push_error("Edit Subresource: Failed to find or parse properties dictionary. Line: " + ljbsofuf)
            return {}

        var mfbjuzxw = oxgqecfc.substr(qigfyzmy, nvtckmyc - qigfyzmy + 1)             
                                                                           
        var mxtqyydl = ebqrnhsb.pfgxqbkw(mfbjuzxw)                                 

                                                                           
                                                                                   

        return {
            "type": "edit_subresource",
            "node_name": ylukdkhe[0],
            "scene_path": ylukdkhe[1],
            "subresource_property_name": ylukdkhe[2],
            "properties": mxtqyydl                                         
        }

    return {}
