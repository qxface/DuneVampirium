                                                               
@tool
extends Node

const srixtxbb = preload("action_parser_utils.gd")

static func execute(ckczkkgu: String, oefkznmi: String, vjpatbbu: Dictionary) -> Dictionary:
    var dlvyggze = EditorPlugin.new().get_editor_interface()
    var occnsarp = dlvyggze.get_open_scenes()

                                   
    for scene in occnsarp:
        if scene == oefkznmi:
                                                     
            dlvyggze.reload_scene_from_path(oefkznmi)
                                                             
            return krlojrhz(ckczkkgu, dlvyggze.get_edited_scene_root(), vjpatbbu)

                                                        
                                               
    return zvkwjwba(ckczkkgu, oefkznmi, vjpatbbu)


static func krlojrhz(dlgmlybw: String, npbgvkqo: Node, yptqopqy: Dictionary) -> Dictionary:
    var jcdpozah = npbgvkqo.find_child(dlgmlybw, true, true)
    
    if not jcdpozah and dlgmlybw == npbgvkqo.name:
        jcdpozah = npbgvkqo

    if not jcdpozah:
        var fnpimaad = "Node '%s' not found in open scene root '%s'." % [dlgmlybw, npbgvkqo.name]
        push_error(fnpimaad)
        return {"success": false, "error_message": fnpimaad, "node_type": ""}

                                                 
    var vqozxazp = inpfrwon(jcdpozah, yptqopqy, npbgvkqo)
    if not vqozxazp.success:
        return {"success": false, "error_message": vqozxazp.error_message, "node_type": jcdpozah.get_class()}
        
                                                  
    if EditorInterface.save_scene() == OK:
        return {"success": true, "error_message": "", "node_type": jcdpozah.get_class()}
    else:
        var fnpimaad = "Failed to save the scene."
        push_error(fnpimaad)
        return {"success": false, "error_message": fnpimaad, "node_type": jcdpozah.get_class()}


static func zvkwjwba(vrsyycqv: String, qfkpjsme: String, kljzwrkj: Dictionary) -> Dictionary:
    var cdghrtdc = load(qfkpjsme)
    if !(cdghrtdc is PackedScene):
        var zrkvfgsg = "Failed to load scene '%s' as PackedScene." % qfkpjsme
        push_error(zrkvfgsg)
        return {"success": false, "error_message": zrkvfgsg, "node_type": ""}

    var hvivfayt = cdghrtdc.instantiate()
    if not hvivfayt:
        var zrkvfgsg = "Could not instantiate scene '%s'." % qfkpjsme
        push_error(zrkvfgsg)
        return {"success": false, "error_message": zrkvfgsg, "node_type": ""}

    var ouvperdu = hvivfayt.find_child(vrsyycqv, true, true)
    
    if not ouvperdu and vrsyycqv == hvivfayt.name:
        ouvperdu = hvivfayt

    if not ouvperdu:
        var zrkvfgsg = "Node '%s' not found in scene instance root '%s'." % [vrsyycqv, hvivfayt.name]
        push_error(zrkvfgsg)
        return {"success": false, "error_message": zrkvfgsg, "node_type": ""}

                                                        
    var bnrrgjco = inpfrwon(ouvperdu, kljzwrkj, hvivfayt)
    if not bnrrgjco.success:
        return {"success": false, "error_message": bnrrgjco.error_message, "node_type": ouvperdu.get_class()}

                                
    cdghrtdc.pack(hvivfayt)
    if ResourceSaver.save(cdghrtdc, qfkpjsme) == OK:
        return {"success": true, "error_message": "", "node_type": ouvperdu.get_class()}
    else:
        var zrkvfgsg = "Failed to save the packed scene."
        push_error(zrkvfgsg)
        return {"success": false, "error_message": zrkvfgsg, "node_type": ouvperdu.get_class()}


static func inpfrwon(ornbqvhr: Node, bgfchpww: Dictionary, yzqqmvuw: Node = null) -> Dictionary:
    for property_name in bgfchpww.keys():
        var autjyuid = bgfchpww[property_name]
        var yreuiqpt = _parse_value(autjyuid)
        if yreuiqpt == null and autjyuid != null:
            var jbahpeeq = "Failed to parse value '%s' for property '%s'." % [str(autjyuid), property_name]
            push_error(jbahpeeq)
            return {"success": false, "error_message": jbahpeeq}
            
                                     
                                                                                                           
                                                             
        var ccpwjrim = _try_set_property(ornbqvhr, property_name, yreuiqpt, yzqqmvuw)
        if not ccpwjrim:
                                                                       
            var jbahpeeq = "Failed to set property '%s' on node '%s'." % [property_name, ornbqvhr.name]
            return {"success": false, "error_message": jbahpeeq}

    return {"success": true, "error_message": ""}

static func _parse_value(glgiglzs) -> Variant:
                                                                                            
    if glgiglzs is String:
        var zhmhdiyn = glgiglzs.strip_edges()
        
                                                        
        if zhmhdiyn.length() >= 2 and zhmhdiyn.begins_with('"') and zhmhdiyn.ends_with('"'):
            zhmhdiyn = zhmhdiyn.substr(1, zhmhdiyn.length() - 2)
        elif zhmhdiyn.length() >= 2 and zhmhdiyn.begins_with("'") and zhmhdiyn.ends_with("'"):
            zhmhdiyn = zhmhdiyn.substr(1, zhmhdiyn.length() - 2)
        
        if zhmhdiyn.begins_with("(") and zhmhdiyn.ends_with(")"):
            var bphrpvxv = zhmhdiyn.substr(1, zhmhdiyn.length() - 2)
            var skftoaje = bphrpvxv.split(",", false)
                                                  
            if skftoaje.size() == 2:
                var bqrlcoin = float(skftoaje[0].strip_edges())
                var fzqwzaiq = float(skftoaje[1].strip_edges())
                return Vector2(bqrlcoin, fzqwzaiq)
                                                  
            if skftoaje.size() == 3:
                var qihstxbq = float(skftoaje[0].strip_edges())
                var qzoinczd = float(skftoaje[1].strip_edges())
                var ayzsrshb = float(skftoaje[2].strip_edges())
                return Vector3(qihstxbq, qzoinczd, ayzsrshb)
                                                  
            if skftoaje.size() == 4:
                var akxrzypl = float(skftoaje[0].strip_edges())
                var rozaohur = float(skftoaje[1].strip_edges())
                var awvptwvv = float(skftoaje[2].strip_edges())
                var cstcftzx = float(skftoaje[3].strip_edges())
                return Vector4(akxrzypl, rozaohur, awvptwvv, cstcftzx)
                               
        if zhmhdiyn.to_lower() == "true":
            return true
        if zhmhdiyn.to_lower() == "false":
            return false
                                
        if zhmhdiyn.is_valid_float():
            return float(zhmhdiyn)
                                                
        return zhmhdiyn

                                                             
    return glgiglzs

static func vdwtblhe(vacnnkxs: String, hejiwrqm: String) -> String:
    var cdwbmusv = ""
    var rukjcdnt = vacnnkxs.length()
    var poiazwgl = hejiwrqm.length()
    var lwkcokoa = min(rukjcdnt, poiazwgl)

    for i in range(lwkcokoa):
        if vacnnkxs[i] != hejiwrqm[i]:
            cdwbmusv += "Difference at index: " + str(i) + ", String1: " + vacnnkxs[i] + ", String2: " + hejiwrqm[i]
            break

    return cdwbmusv


static func _try_set_property(ackkamvl: Node, vpxhdmag: String, sojytlcm: Variant, sdofeqwd: Node = null) -> bool:  
                                      
    if vpxhdmag == "parent":
        if not sojytlcm is String:
            push_error("Parent value must be a string (name of the new parent)")
            return false

        if sdofeqwd == null:
            push_error("Cannot re-parent without a valid scene root.")
            return false

        var qrekygnc = sojytlcm.strip_edges()
        var aidglnox: Node

                                                 
                                                                          
        if qrekygnc == "" or qrekygnc == sdofeqwd.name:
            aidglnox = sdofeqwd
        else:
            aidglnox = sdofeqwd.find_child(qrekygnc, true, true)
            if not aidglnox:
                push_error("Failed to find parent node with name: %s" % qrekygnc)
                return false
        
                   
        if ackkamvl.get_parent():
            ackkamvl.get_parent().remove_child(ackkamvl)
        aidglnox.add_child(ackkamvl)

                                                                          
        ackkamvl.set_owner(sdofeqwd)

        return true

                                      
    var pwvnmqnk = ackkamvl.get_property_list()
    for prop in pwvnmqnk:
        if prop.name == vpxhdmag:
                        
            if prop.type == TYPE_COLOR:
                match typeof(sojytlcm):
                    TYPE_VECTOR2:
                                                            
                        sojytlcm = Color(sojytlcm.x, sojytlcm.y, 0, 1.0)
                    TYPE_VECTOR3:
                                                                
                        sojytlcm = Color(sojytlcm.x, sojytlcm.y, sojytlcm.z, 1.0)
                    TYPE_VECTOR4:
                        sojytlcm = Color(sojytlcm.x, sojytlcm.y, sojytlcm.z, sojytlcm.w)
                    TYPE_ARRAY:
                                                                                                  
                        if sojytlcm.size() == 3:
                            sojytlcm = Color(sojytlcm[0], sojytlcm[1], sojytlcm[2], 1.0)
                        elif sojytlcm.size() == 4:
                            sojytlcm = Color(sojytlcm[0], sojytlcm[1], sojytlcm[2], sojytlcm[3])

                                                                       
            elif prop.type == TYPE_OBJECT and prop.hint == PROPERTY_HINT_RESOURCE_TYPE:
                var bxgfpmxy = prop.hint_string
                
                                           
                if bxgfpmxy == "Texture2D" or bxgfpmxy.contains("Texture2D"):
                    var nlvnqacy = load(sojytlcm)

                                                                                        
                    if "_" in vpxhdmag:
                        var hasznskt = vpxhdmag.split("_")
                        if hasznskt.size() > 1:
                            var bntbqshd = hasznskt[1]
                            var rwotcflx = "set_texture_" + bntbqshd
                            if ackkamvl.has_method(rwotcflx):
                                ackkamvl.call(rwotcflx, nlvnqacy)
                                return true

                                                                           
                    if ackkamvl.has_method("set_texture"):
                        ackkamvl.set_texture(nlvnqacy)
                        return true
                        
                                             
                elif bxgfpmxy == "Mesh" or bxgfpmxy.contains("Mesh"):
                    var mykgztdr = load(sojytlcm)
                    if not mykgztdr:
                        push_error("Failed to load mesh at path: %s" % sojytlcm)
                        return false
                    
                    if "_" in vpxhdmag:
                        var hasznskt = vpxhdmag.split("_")
                        if hasznskt.size() > 1:
                            var bntbqshd = hasznskt[1]
                            var rwotcflx = "set_mesh_" + bntbqshd
                            if ackkamvl.has_method(rwotcflx):
                                ackkamvl.call(rwotcflx, mykgztdr)
                                return true
                    
                    ackkamvl.set(vpxhdmag, mykgztdr)
                    return true
                
                                                
                elif bxgfpmxy == "AudioStream" or bxgfpmxy.contains("AudioStream"):
                    var bwgobxsg = load(sojytlcm)
                    if not bwgobxsg:
                        push_error("Failed to load audio stream at path: %s" % sojytlcm)
                        return false
                    ackkamvl.set(vpxhdmag, bwgobxsg)
                    return true



                                                                 
    if not ackkamvl.has_method("get") or ackkamvl.get(vpxhdmag) == null:
        push_error("Property '%s' doesn't exist on node '%s'." % [vpxhdmag, ackkamvl.name])
        return false

                                    
    ackkamvl.set(vpxhdmag, sojytlcm)

                                                               
                                                          
    return true


                                                                             
                 
                                                                      
                                                                             
static func parse_line(lstjjsqt: String, ydgdnzem: String) -> Dictionary:
                                                     
    if lstjjsqt.begins_with("edit_node("):
        var ezppbpge = srixtxbb.fwkieqnb(lstjjsqt)
                                                            
        if ezppbpge.size() == 0:
            return {}
        if not ezppbpge.has("node_name") \
            or not ezppbpge.has("scene_path") \
            or not ezppbpge.has("modifications"):
            return {}

        return {
            "type": "edit_node",
            "node_name": ezppbpge.node_name,
            "scene_path": ezppbpge.scene_path,
            "modifications": ezppbpge.modifications
        }

    return {}
