                                                                  
@tool
extends Node

signal axiebdny(action_type: String, success: bool, error_message: String, node_name: String, subresource_name: String, button: Button)
signal cdsrnkbh(action_type: String, disable: bool)

                                     
const kqspcekb = preload("res://addons/gamedev_assistant/scripts/actions/action_parser_utils.gd")
const awrjrlec = preload("res://addons/gamedev_assistant/scripts/actions/create_file_action.gd")
const dfmkrmsi = preload("res://addons/gamedev_assistant/scripts/actions/create_scene_action.gd")
const yscxtmri = preload("res://addons/gamedev_assistant/scripts/actions/create_node_action.gd")
const rmbkhzxw = preload("res://addons/gamedev_assistant/scripts/actions/edit_node_action.gd")
const wjviuiss = preload("res://addons/gamedev_assistant/scripts/actions/add_subresource_action.gd")
const ienblvig = preload("res://addons/gamedev_assistant/scripts/actions/edit_subresource_action.gd")
const juczxiyz = preload("res://addons/gamedev_assistant/scripts/actions/assign_script_action.gd")
const vlbyikeg = preload("res://addons/gamedev_assistant/scripts/actions/add_existing_scene_action.gd")
const meltahtw = preload("res://addons/gamedev_assistant/scripts/actions/edit_script_action.gd")

const qmmtotut = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_ActionButton.tscn")
const magukmoo = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_ApplyAllButton.tscn")
const kezzecqv = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_ActionsContainer.tscn")
const ivffphhu = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_Spacing.tscn")

var xnopiedt: Control
var gvsgpvlf : VBoxContainer
var eurfhota: Array = []
var xyjbqyrs : Button
var raimpalk : bool
var qncnzfxz : bool
var cephvxcm = 0

                             
var laejvpuk: Timer

func _ready():
    
    var vcjfgpdw = EditorInterface.get_editor_settings()       
    qncnzfxz = vcjfgpdw.has_setting("gamedev_assistant/development_mode") and vcjfgpdw.get_setting('gamedev_assistant/development_mode') == true    

                                                           
    axiebdny.connect(euivkzkv)
    cdsrnkbh.connect(rdlkeufw)

                                    
    laejvpuk = Timer.new()
    laejvpuk.wait_time = 0.2
    laejvpuk.one_shot = true
    add_child(laejvpuk)
    laejvpuk.timeout.connect(ciroodxe)

                            
func rcrmbsak(pamhxmox: String, cpbnfvny: int) -> Array:
    var lkwicfuo = []

    var lwduausc = "[gds_actions]"
    var pmgrxdjl = "[/gds_actions]"

    var kuhwrlgi = pamhxmox.find(lwduausc)
    var kybmctkt = pamhxmox.find(pmgrxdjl)

    if kuhwrlgi == -1 or kybmctkt == -1:
        return lkwicfuo                                       

                                                                
    var uifajcxm = kuhwrlgi + lwduausc.length()
    var zhilidxj = kybmctkt - uifajcxm
    var rnlswymn = pamhxmox.substr(uifajcxm, zhilidxj).strip_edges()
    
    if qncnzfxz:
        print(rnlswymn)

                                        
    var gzrybpwq = rnlswymn.split("\n")
    for line in gzrybpwq:
        line = line.strip_edges()
        if line == "":
            continue

        var inppefbf = dfoqpxcg(line, pamhxmox)
        if inppefbf:
            inppefbf["message_id"] = cpbnfvny
            lkwicfuo.append(inppefbf)

    return lkwicfuo


                    
func qisagktf(ulzptxgn: String, jxerdepa: String, mshqqxgh: Button) -> bool:
    var pjutcvkk = awrjrlec.execute(ulzptxgn, jxerdepa)
    axiebdny.emit("create_file", pjutcvkk.success, pjutcvkk.error_message, "", "", mshqqxgh)
    return pjutcvkk.success

                     
func rhnyfhic(iwanzqfc: String, oexeyzox: String, wxqddgzi: String, tmkjvgyf: Button) -> bool:
    var dkuyflhp = dfmkrmsi.execute(iwanzqfc, oexeyzox, wxqddgzi)
    axiebdny.emit("create_scene", dkuyflhp.success, dkuyflhp.error_message, "", "", tmkjvgyf)
    return dkuyflhp.success

                    
func lpnficst(dzhdaiak: String, weezcapl: String, efjiwfuy: String, gjaeoxuh: String, cjuwspmf: Dictionary, jiiwqbry: Button) -> bool:
    var sootiakv = yscxtmri.execute(dzhdaiak, weezcapl, efjiwfuy, gjaeoxuh, cjuwspmf)
    axiebdny.emit("create_node", sootiakv.success, sootiakv.error_message, weezcapl, "", jiiwqbry)
    return sootiakv.success
    
                  
func jcztdops(iidvbcyu: String, njdmjpiw: String, xxeytogt: Dictionary, rdoazzfn: Button) -> bool:
    var pfaeonkz = rmbkhzxw.execute(iidvbcyu, njdmjpiw, xxeytogt)
    axiebdny.emit("edit_node", pfaeonkz.success, pfaeonkz.error_message, pfaeonkz.node_type, "", rdoazzfn)
    return pfaeonkz.success
    
func pcuxyhhg(sxuycekg: String, kmusswad: String, dgdycjmk: String, gjgrlwmy: Dictionary, lczmsysw: Button) -> bool:
    var efrrdjrt = wjviuiss.execute(sxuycekg, kmusswad, dgdycjmk, gjgrlwmy)
    axiebdny.emit("add_subresource", efrrdjrt.success, efrrdjrt.error_message, efrrdjrt.node_type, dgdycjmk, lczmsysw)
    return efrrdjrt.success

                         
func nvfglzfw(ubydkxgf: String, gunvebyc: String, akeyanxi: String, kvgqpnwl: Dictionary, qrcvrlmt: Button) -> bool:
    var hjzcaznd = ienblvig.execute(ubydkxgf, gunvebyc, akeyanxi, kvgqpnwl)
                                                                              
    axiebdny.emit("edit_subresource", hjzcaznd.success, hjzcaznd.error_message, hjzcaznd.node_type, hjzcaznd.subresource_type, qrcvrlmt)
    return hjzcaznd.success

func bttudyqr(tyflkifn: String, jbfewrks: String, arvtarvo: String, jzwjbkzg: Button) -> bool:  
      var upbdwvyw = juczxiyz.execute(tyflkifn, jbfewrks, arvtarvo)  
      axiebdny.emit("assign_script", upbdwvyw.success, upbdwvyw.error_message, "", "", jzwjbkzg)  
      return upbdwvyw.success  

func vkninqmv(yzrnrkxz: String, mjqpiklc: String, kehfaopc: String, fgwdnidm: String, zqcqknth: Dictionary, crjqfpus: Button) -> bool:
    var xydsngvy = vlbyikeg.execute(yzrnrkxz, mjqpiklc, kehfaopc, fgwdnidm, zqcqknth)
    axiebdny.emit("add_existing_scene", xydsngvy.success, xydsngvy.error_message, "", "", crjqfpus)
    return xydsngvy.success  
    
func jqexxiks(ckodofyw: String, uylhvfjq: int, jljiwxui: Button) -> void:
    var joahlzgt = $"../APIManager"
    var jewesgcv = meltahtw.execute(ckodofyw, uylhvfjq, jljiwxui, joahlzgt)
    
                                                                                                     
                                                                                   
    if jewesgcv is Dictionary:
        axiebdny.emit("edit_script", jewesgcv.success, jewesgcv.error_message, "", "", jljiwxui)
    
                                                                                  
                                                                           


                                 
func eqfdbevf(ntzqanub: Array, jpzvkhgg: Control) -> void:
    
    xnopiedt = jpzvkhgg    
    ccumjrwb()
    
    gvsgpvlf = kezzecqv.instantiate()
    var xvubyumy = ivffphhu.instantiate()
    gvsgpvlf.add_child(xvubyumy)
    xnopiedt.add_child(gvsgpvlf)
    
                                                        
    if ntzqanub.size() > 1:
        xyjbqyrs = magukmoo.instantiate()
        xyjbqyrs.text = "Apply All"
        xyjbqyrs.disabled = false
        xyjbqyrs.pressed.connect(pjpixadv)
        xyjbqyrs.tooltip_text = "Apply the actions listed below from top to bottom"
        gvsgpvlf.add_child(xyjbqyrs)

    for action in ntzqanub:
        var fdtgwtvj = qmmtotut.instantiate()

        var yjaydfom = ""
        var rleriuyd = []
        
        match action.type:
            "create_file":
                yjaydfom = "Create {path}".format({"path": action.path})
                rleriuyd.append("Create file")
            "create_scene":
                yjaydfom = "Create {path}".format({
                    "path": action.path,
                })
                rleriuyd.append("Create scene")
            "create_node":
                var taqzyvsc = action.scene_path.get_file()
                var ddqxmrow = action.parent_path if action.parent_path != "" else "root"
                yjaydfom = "Create {type} \"{node_name}\"".format({
                    "type": action.node_type,
                    "node_name": action.name
                })
                rleriuyd.append("Create node")
                rleriuyd.append("Scene: %s" % taqzyvsc)                
            "edit_node":
                var taqzyvsc = action.scene_path.get_file()
                yjaydfom = "Edit %s" % [action.node_name]
                
                rleriuyd.append("Edit node")
                rleriuyd.append("Scene: %s" % taqzyvsc)
            "add_subresource":
                var taqzyvsc = action.scene_path.get_file()
                yjaydfom = "Add %s to %s" % [
                    action.subresource_type,
                    action.node_name
                ]                
                rleriuyd.append("Add subresource")
                rleriuyd.append("Scene: %s" % taqzyvsc)
            "edit_subresource":
                var taqzyvsc = action.scene_path.get_file()
                yjaydfom = "Edit %s on %s" % [
                    action.subresource_property_name,                                       
                    action.node_name                                                
                ]
                rleriuyd.append("Edit subresource")
                rleriuyd.append("Scene: %s" % taqzyvsc)
                rleriuyd.append("Property: %s" % action.subresource_property_name)                
            "assign_script":  
                var taqzyvsc = action.scene_path.get_file()  
                var cbnqylxz = action.script_path.get_file()
                yjaydfom = "Attach %s to %s" % [  
                    cbnqylxz,  
                    action.node_name  
                ]
                rleriuyd.append("Attach script")
                rleriuyd.append("File: %s" % cbnqylxz)
                rleriuyd.append("Scene: %s" % taqzyvsc)                
            "add_existing_scene":
                var nxladfbe = action.existing_scene_path.get_file()
                var gurhcfxl = action.target_scene_path.get_file()
                yjaydfom = "Add %s to %s" % [nxladfbe, gurhcfxl]
                
                rleriuyd.append("Add existing scene")
                rleriuyd.append("Source: %s" % nxladfbe)
                rleriuyd.append("Target: %s" % gurhcfxl)  
            "edit_script":
                yjaydfom = "Edit {path}".format({"path": action.path})
                rleriuyd.append("Edit script")
                rleriuyd.append("Path: %s" % action.path)
                                
                              
        if action.has("path"):
            rleriuyd.append("Path: %s" % action.path)
        
        if action.has("scene_name"):
            rleriuyd.append("Scene: %s" % action.scene_name)
        
        if action.has("node_type"):
            rleriuyd.append("Node type: %s" % action.node_type)
        
        if action.has("root_type"):
            rleriuyd.append("Root type: %s" % action.root_type)
            
        if action.has("subresource_type"):
            rleriuyd.append("Subresource type: %s" % action.subresource_type)
        
        if action.has("name"):
            rleriuyd.append("Name: %s" % action.name)
        
        if action.has("node_name"):
            rleriuyd.append("Node name: %s" % action.node_name)
       
        if action.has("parent_path"):      
            rleriuyd.append("Parent: %s" % (action.parent_path if action.parent_path else "root"))
            
        if action.has("modifications") or action.has("properties"):
            var bfbhydpt = action.get("modifications", action.get("properties", {}))
            if bfbhydpt.size() > 0:
                rleriuyd.append("\nProperties to apply:")
                for key in bfbhydpt:
                    rleriuyd.append("• %s = %s" % [key, str(bfbhydpt[key])])
                
        fdtgwtvj.tooltip_text = "\n".join(rleriuyd)

        fdtgwtvj.text = yjaydfom
        fdtgwtvj.set_meta("action", action)
        fdtgwtvj.pressed.connect(ykjapwjg.bind(fdtgwtvj))

        gvsgpvlf.add_child(fdtgwtvj)
        eurfhota.append(fdtgwtvj)


                          
func ccumjrwb() -> void:
    if xnopiedt == null:
        return
        
                                                                     
    if is_instance_valid(gvsgpvlf) and gvsgpvlf.is_inside_tree():
                                                                     
        if xnopiedt.has_node(gvsgpvlf.get_path()):
                                                                  
            xnopiedt.remove_child(gvsgpvlf)
    
                                    
    eurfhota.clear()

                                                  
func ykjapwjg(gaeokopx: Button) -> void:
        raimpalk = false
        qrqjyhmn(gaeokopx)

                                                  
func qrqjyhmn(wzlhtbby: Button) -> void:
    var jplaqrwk = wzlhtbby.get_meta("action") if wzlhtbby.has_meta("action") else {}
    
    wzlhtbby.disabled = true

    match jplaqrwk.type:
        "create_file":
            qisagktf(jplaqrwk.path, jplaqrwk.content, wzlhtbby)
        "create_scene":
            rhnyfhic(jplaqrwk.path, jplaqrwk.root_name, jplaqrwk.root_type, wzlhtbby)
        "create_node":
            var sblgmudc = jplaqrwk.modifications if jplaqrwk.has("modifications") else {}
            lpnficst(jplaqrwk.name, jplaqrwk.node_type, jplaqrwk.scene_path, jplaqrwk.parent_path, sblgmudc, wzlhtbby)
        "edit_node":
            jcztdops(jplaqrwk.node_name, jplaqrwk.scene_path, jplaqrwk.modifications, wzlhtbby)
        "add_subresource":
            pcuxyhhg(
                jplaqrwk.node_name,
                jplaqrwk.scene_path,
                jplaqrwk.subresource_type,
                jplaqrwk.properties,
                wzlhtbby
            )
        "edit_subresource":
             nvfglzfw(
                jplaqrwk.node_name,
                jplaqrwk.scene_path,
                jplaqrwk.subresource_property_name,
                jplaqrwk.properties,                                                    
                wzlhtbby
             )
        "assign_script":  
              bttudyqr(jplaqrwk.node_name, jplaqrwk.scene_path, jplaqrwk.script_path, wzlhtbby)  
        "add_existing_scene":
            vkninqmv(
                jplaqrwk.node_name,
                jplaqrwk.existing_scene_path,
                jplaqrwk.target_scene_path,
                jplaqrwk.parent_path,
                jplaqrwk.modifications,
                wzlhtbby
            )
        "edit_script":
            jqexxiks(jplaqrwk.path, jplaqrwk.message_id, wzlhtbby)
        _:
            push_warning("Unrecognized action type: %s" % jplaqrwk.type)


                                             
func euivkzkv(usfhwdhi: String, eovegrnf: bool, ksvvbvqm: String, urkzeyjf: String, pzfhacpn: String, apypkmlp: Button) -> void:
    if not is_instance_valid(apypkmlp):
        return

                                                                         
    var pxrdjxnk = apypkmlp.text
    var ptnukiai = apypkmlp.tooltip_text
    
                                                         
    if is_instance_valid(xyjbqyrs):
        xyjbqyrs.disabled = true

    var mqosxplk = apypkmlp.get_meta("action")
    var dlqzkqof = mqosxplk.get("message_id", -1)

    if dlqzkqof != -1:
        $"../APIManager".kevulpbh(dlqzkqof, eovegrnf, usfhwdhi, urkzeyjf, pzfhacpn, ksvvbvqm)

                                                                             
    if usfhwdhi == mqosxplk.type:
        var ynqpowtk = "✓ " if eovegrnf else "✗ "
        var owzwcaqh = "\n\nACTION COMPLETED" if eovegrnf else "\n\nACTION FAILED:\n%s\nClick to retry." % ksvvbvqm
        var gidbdlml = ""                               

                                                                   
        match usfhwdhi:
            "create_file":
                gidbdlml = ("Created file {path}" if eovegrnf else "Failed: file creation {path}").format({"path": mqosxplk.path})
            "create_scene":
                gidbdlml = ("Created scene {path}, root: {root_type}" if eovegrnf else "Failed: scene creation {path}, root: {root_type}").format({
                    "path": mqosxplk.path,
                    "root_type": mqosxplk.root_type
                })
            "create_node":
                var vjlvkjwl = mqosxplk.scene_path.get_file()
                var uhtqigqn = mqosxplk.parent_path if mqosxplk.parent_path != "" else "root"
                var ikffaywl = ""
                if mqosxplk.has("modifications") and mqosxplk.modifications.size() > 0:
                    ikffaywl = " with %s props" % mqosxplk.modifications.size()
                gidbdlml = ("Created node {name}, type {type}, parent {parent} in scene {scene}{props}" if eovegrnf
                                else "Failed: creating node {name}, type {type}, parent {parent} in scene {scene}{props}"
                                ).format({
                                    "name": mqosxplk.name,
                                    "type": mqosxplk.node_type,
                                    "scene": vjlvkjwl,
                                    "parent": uhtqigqn,
                                    "props": ikffaywl
                                })
            "edit_node":
                gidbdlml = ("Edited node \"%s\" in scene %s" if eovegrnf
                                else "Failed: editing node \"%s\", scene: %s"
                                ) % [mqosxplk.node_name, mqosxplk.scene_path.get_file()]

            "add_subresource":
                var vjlvkjwl = mqosxplk.scene_path.get_file()
                var qrxcqwva = str(mqosxplk.properties.size())
                gidbdlml = ("Added subresource %s to node %s in scene %s (%s properties)" if eovegrnf
                                else "Failed: adding subresource %s to node %s, scene: %s (%s properties)"
                                ) % [mqosxplk.subresource_type, mqosxplk.node_name, vjlvkjwl, qrxcqwva]
                                
            "edit_subresource":
                 var vjlvkjwl = mqosxplk.scene_path.get_file()
                 var qrxcqwva = str(mqosxplk.properties.size())
                 gidbdlml = ("Edited subresource property '%s' on node '%s' in scene %s (%s properties changed)" if eovegrnf
                                 else "Failed: editing subresource property '%s' on node '%s', scene: %s (%s properties attempted)"
                                 ) % [mqosxplk.subresource_property_name, mqosxplk.node_name, vjlvkjwl, qrxcqwva]

            "assign_script":
                gidbdlml = ("Assigned script to node \"%s\" in scene %s" if eovegrnf
                                else "Failed: assigning script to node \"%s\", scene: %s"
                                ) % [mqosxplk.node_name, mqosxplk.scene_path.get_file()]

            "add_existing_scene":
                var hbinwigw = mqosxplk.target_scene_path.get_file()
                var vjlvkjwl = mqosxplk.existing_scene_path.get_file()
                var qrxcqwva = str(mqosxplk.modifications.size())
                gidbdlml = ("Added %s to %s" if eovegrnf
                              else "Failed: adding %s to %s"
                              ) % [vjlvkjwl, hbinwigw]
                if mqosxplk.modifications.size() > 0:
                    gidbdlml += " (%s props)" % qrxcqwva
            "edit_script":
                gidbdlml = ("Edited script %s" if eovegrnf else "Failed: editing script %s") % [mqosxplk.path]

                                                         
        apypkmlp.text = ynqpowtk + pxrdjxnk

                                                             
        apypkmlp.tooltip_text = ptnukiai + owzwcaqh

                                               
                                                             
        print('[GameDev Assistant] ' + ynqpowtk + gidbdlml) 

        if not eovegrnf:
            apypkmlp.self_modulate = Color(1, 0, 0)                               
            
                                  
        apypkmlp.set_meta("completed", true)
        
                               
        if usfhwdhi == "edit_script":
            rdlkeufw(usfhwdhi, false)
            
                                          
        if eovegrnf:
            apypkmlp.disabled = true
        
                              
func dfoqpxcg(easnzpnj: String, ycojadlu: String) -> Dictionary:
    var nyeizpsi = [awrjrlec, dfmkrmsi, yscxtmri, rmbkhzxw, wjviuiss, ienblvig, juczxiyz, vlbyikeg, meltahtw]
    for parser in nyeizpsi:
        var lcuojucp = parser.parse_line(easnzpnj, ycojadlu)
        if not lcuojucp.is_empty():
            return lcuojucp
    return {}
    
func pjpixadv() -> void:
    if raimpalk:
        return                                                   
        
    raimpalk = true
    xyjbqyrs.disabled = true
    cephvxcm = 0
    
                                                               
    for button in eurfhota:
                                                              
        if not button.get_meta("completed", false):
            button.disabled = true
    
                                                                   
    axiebdny.connect(npcdrqor)
    
                                                      
    jtsqmfbd()

func npcdrqor(aozjtdmi, ddkshayz, erscztgj, juioxyhj, xsgqyhkt, wfwsrces: Button):
                                                                           
    if not raimpalk:
        return

                                                                                  
    if eurfhota.size() > cephvxcm and wfwsrces == eurfhota[cephvxcm]:
        cephvxcm += 1
                                                                                        
        laejvpuk.start()

func jtsqmfbd():
                                                        
    if cephvxcm >= eurfhota.size():
        raimpalk = false
        axiebdny.disconnect(npcdrqor)                                     
        print("[GameDev Assistant] Apply All sequence completed.")
        return

                                            
    var ksuqyluu = eurfhota[cephvxcm]
    if is_instance_valid(ksuqyluu):
                                                                
        if ksuqyluu.get_meta("completed", false):
            cephvxcm += 1
            jtsqmfbd()
            return
            
        qrqjyhmn(ksuqyluu)
    else:
                                                                            
        cephvxcm += 1
        jtsqmfbd()

func ciroodxe():
                                                                                    
    call_deferred("jtsqmfbd")

func rdlkeufw(etggomfd: String, vnkdtplg: bool) -> void:

    if raimpalk:
        return
    
    for button in eurfhota:
        var nptidxls = button.get_meta("action") if button.has_meta("action") else {}
        if nptidxls.get("type", "") == etggomfd:
                                                
            if not button.get_meta("completed", false):
                button.disabled = vnkdtplg
