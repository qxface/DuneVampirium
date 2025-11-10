                                                                 
@tool
extends Node

const nclaludc = preload("res://addons/gamedev_assistant/scripts/actions/action_parser_utils.gd")

static func execute(lllthukw: String, bydehmye: String, jrahumgh: String) -> Dictionary:
    var szkfvrml = EditorPlugin.new().get_editor_interface()
    var agmrlbnd = szkfvrml.get_open_scenes()

                                   
    for scene in agmrlbnd:
        if scene == bydehmye:
                                                                         
            szkfvrml.reload_scene_from_path(bydehmye)
            return btbvqlcc(lllthukw, szkfvrml.get_edited_scene_root(), jrahumgh)

                                                        
                                                                   
    return wpsxrqky(lllthukw, bydehmye, jrahumgh)

static func btbvqlcc(vmoxbwrk: String, bncyzyad: Node, nbodzjpv: String) -> Dictionary:
    var mvpaswnt = bncyzyad.find_child(vmoxbwrk, true, true)
    
    if not mvpaswnt and vmoxbwrk == bncyzyad.name:
        mvpaswnt = bncyzyad

    if not mvpaswnt:
        var ovcshdli = "Node '%s' not found in open scene root '%s'." % [vmoxbwrk, bncyzyad.name]
        push_error(ovcshdli)
        return {"success": false, "error_message": ovcshdli}

                       
    var srvuhhyp = load(nbodzjpv)
    if not srvuhhyp:
        var ovcshdli = "Failed to load script at path: %s" % nbodzjpv
        push_error(ovcshdli)
        return {"success": false, "error_message": ovcshdli}

    mvpaswnt.set_script(srvuhhyp)
    
                                                       
    if EditorInterface.save_scene() == OK:
        return {"success": true, "error_message": ""}
    else:
        var ovcshdli = "Failed to save the scene."
        push_error(ovcshdli)
        return {"success": false, "error_message": ovcshdli}


static func wpsxrqky(jbtjusyo: String, mtijvliv: String, gzctycye: String) -> Dictionary:
    var tzkkvvcq = load(mtijvliv)
    if not (tzkkvvcq is PackedScene):
        var mdhpwogi = "Failed to load scene '%s' as PackedScene." % mtijvliv
        push_error(mdhpwogi)
        return {"success": false, "error_message": mdhpwogi}

    var rjlijihn = tzkkvvcq.instantiate()
    if not rjlijihn:
        var mdhpwogi = "Could not instantiate scene '%s'." % mtijvliv
        push_error(mdhpwogi)
        return {"success": false, "error_message": mdhpwogi}

    var dsugfwiw = rjlijihn.find_child(jbtjusyo, true, true)
    
    if not dsugfwiw and jbtjusyo == rjlijihn.name:
        dsugfwiw = rjlijihn

    if not dsugfwiw:
        var mdhpwogi = "Node '%s' not found in scene instance root '%s'." % [jbtjusyo, rjlijihn.name]
        push_error(mdhpwogi)
        return {"success": false, "error_message": mdhpwogi}

                       
    var azixjbcz = load(gzctycye)
    if not azixjbcz:
        var mdhpwogi = "Failed to load script at path: %s" % gzctycye
        push_error(mdhpwogi)
        return {"success": false, "error_message": mdhpwogi}

    dsugfwiw.set_script(azixjbcz)

                                
    tzkkvvcq.pack(rjlijihn)
    if ResourceSaver.save(tzkkvvcq, mtijvliv) == OK:
        return {"success": true, "error_message": ""}
    else:
        var mdhpwogi = "Failed to save the packed scene."
        push_error(mdhpwogi)
        return {"success": false, "error_message": mdhpwogi}


                                                                             
                 
                                                                      
                                                                             
static func parse_line(kthcpnaf: String, scpkqnoa: String) -> Dictionary:
                                                         
    if kthcpnaf.begins_with("assign_script("):
        var omejefkx = kthcpnaf.replace("assign_script(", "").replace(")", "").strip_edges()
        var sppxezvf = []
        var tmgbnqpe = 0
        while true:
            var amshkjoe = omejefkx.find('"',tmgbnqpe)
            if amshkjoe == -1:
                break
            var crmwdxvh = omejefkx.find('"', amshkjoe + 1)
            if crmwdxvh == -1:
                break
            sppxezvf.append(omejefkx.substr(amshkjoe + 1, crmwdxvh - amshkjoe - 1))
            tmgbnqpe = crmwdxvh + 1

                                                                                
        if sppxezvf.size() != 3:
            return {}

        return {
            "type": "assign_script",
            "node_name": sppxezvf[0],
            "scene_path": sppxezvf[1],
            "script_path": sppxezvf[2]
        }

    return {}
