                                                               
@tool
extends RefCounted

const qmeyaelb = "@OpenScripts"
const vlgddrcv = "@SceneTree"
const zdtynkho = "@OpenScenes"
const mwqjwqhy = "@FileTree"
const ewmhjuty = "@Output"
const haflxypr = "@GitDiff"
const tbnzunyn = "@Docs"
const iqhptucu = "@ProjectSettings"
const eviotpcw = 10000
const olbxgbkk = 5000
const vqneevra = 75000

var soznuosc = {}                                  
var wgxyeebi = []                                     

                              
func dhwyisqo() -> void:
    soznuosc.clear()
    wgxyeebi.clear()

func swsmygoy(eeizxarg: String, wleducgg: EditorInterface) -> String:
                                                         
    if not zaaepycf(eeizxarg):
        return eeizxarg
        
                            
    var ecdmcmmc = eeizxarg
    
    if qmeyaelb in eeizxarg:
                                      
        ecdmcmmc = zpxidsqv(ecdmcmmc, wleducgg)
        
    if vlgddrcv in eeizxarg:
                                     
        ecdmcmmc = nusjyrgu(ecdmcmmc, wleducgg)

    if zdtynkho in eeizxarg:
        ecdmcmmc = yijkksyp(ecdmcmmc, wleducgg)

    if mwqjwqhy in eeizxarg:
                                     
        ecdmcmmc = lmwlhiys(ecdmcmmc, wleducgg)

    if ewmhjuty in eeizxarg:
                                        
        ecdmcmmc = kdhlwnpz(ecdmcmmc, wleducgg)
    
    if haflxypr in eeizxarg:                                                             
        ecdmcmmc = cgzsbric(ecdmcmmc, wleducgg)      
    
    if iqhptucu in ecdmcmmc:
        ecdmcmmc = onmxkxzv(ecdmcmmc)
    
    return ecdmcmmc

func zaaepycf(afsuhagk: String) -> bool:
                                  
    return qmeyaelb in afsuhagk or vlgddrcv in afsuhagk or mwqjwqhy in afsuhagk or ewmhjuty in afsuhagk or iqhptucu in afsuhagk or zdtynkho in afsuhagk

func zpxidsqv(xbjydggp: String, ovvckybf: EditorInterface) -> String:
    var mpohuirq = xbjydggp.replace(qmeyaelb, qmeyaelb.substr(1)).strip_edges()
    
    var ipzyquqe = ezqmqetv(ovvckybf)
    wgxyeebi.clear()
    
                         
    var ocythtlb = "\n[gds_context]\nScripts for context:\n"
    
                                                             
    var rtciugue = {}
    wgxyeebi = []
    for file_path in ipzyquqe:
       var oexztten = ipzyquqe[file_path]
       if soznuosc.has(file_path) and soznuosc[file_path] == oexztten:
          wgxyeebi.append(file_path)
       else:
                                                                      
          rtciugue[file_path] = oexztten

                                                                                             
    var bntaerul = ""
    if not wgxyeebi.is_empty():
       bntaerul = "The following scripts remain the same: %s\n" % [wgxyeebi]

                                                                       
    var eyoxfmug = ""
    var dnjmquiv = []
    var rdwynnqy = false

    for file_path in rtciugue:
       var nqjipsxj = rtciugue[file_path]
       var skyygtoz = "File: %s\nContent:\n```%s\n```\n" % [file_path, nqjipsxj]

                                                                   
       if eyoxfmug.length() + skyygtoz.length() > vqneevra:
          rdwynnqy = true
          break                                                                  
       
                                                                                    
       eyoxfmug += skyygtoz
       dnjmquiv.append(file_path)
       soznuosc[file_path] = nqjipsxj

                                                                                         
    if rdwynnqy:
       var vcvklfsx = []
                                                 
       for file_path in rtciugue.keys():
          if not file_path in dnjmquiv:
             vcvklfsx.append(file_path)
       
       push_warning("Character limit reached for @OpenScripts. Not all files could be included in the message.")
       if not vcvklfsx.is_empty():
          push_warning("These files were NOT sent to the LLM: %s" % [vcvklfsx])

                                                         
    ocythtlb = ocythtlb + bntaerul + eyoxfmug
        
    return mpohuirq + ocythtlb + "\n[/gds_context]"

func ezqmqetv(oynfxckd: EditorInterface) -> Dictionary:
    var wwrokyam = oynfxckd.get_script_editor()
    var foyrixbk: Array = wwrokyam.get_open_scripts()
    
    var kugrejwd: Dictionary = {}
    
    for script in foyrixbk:
        var sofiwkfx: String = script.get_source_code()
        var wqkbipnx: String = script.get_path()
                                            
        kugrejwd[wqkbipnx] = sofiwkfx
        
    return kugrejwd

func nusjyrgu(kxpkaetm: String, iydufxuf: EditorInterface) -> String:
                                                                                                                          
    var szbwrovg = kxpkaetm.replace(vlgddrcv, vlgddrcv.substr(1)).strip_edges()
    
                               
    var jqiwhpne = iydufxuf.get_edited_scene_root()
    if not jqiwhpne:
        return szbwrovg + "\n[gds_context]Node tree: No scene is currently being edited.[/gds_context]"
    
                                
    var lyfdntbm = "\n[gds_context]Node tree:\n"
    lyfdntbm += nzaghizp(jqiwhpne)
    lyfdntbm += "--\n"

    if lyfdntbm.length() > eviotpcw:                                                            
        lyfdntbm = lyfdntbm.substr(0, eviotpcw) + "..."
        
    lyfdntbm += "\n[/gds_context]"
        
    return szbwrovg + lyfdntbm

func nzaghizp(vnbqvoqt: Node, woqvdgth: String = "") -> String:
    var mbmowhcd = woqvdgth + "- " + vnbqvoqt.name
    mbmowhcd += " (" + vnbqvoqt.get_class() + ")"
    
                                                 
    if vnbqvoqt is Node2D:
        mbmowhcd += " position " + str(vnbqvoqt.position)
    elif vnbqvoqt is Control:                      
        mbmowhcd += " position " + str(vnbqvoqt.position)
    elif vnbqvoqt is Node3D:
        mbmowhcd += " position " + str(vnbqvoqt.position)

                                                                              
    if vnbqvoqt.owner and vnbqvoqt.owner != vnbqvoqt:
        mbmowhcd += " [owner: " + vnbqvoqt.owner.name + "]"
    
    mbmowhcd += "\n"
    var aqrcdxcd = woqvdgth + "  "
    
                                                  
    if vnbqvoqt is CollisionObject2D or vnbqvoqt is CollisionObject3D:
        var rvxoocmp = []
        var tankowho = []
        
                            
        for i in range(1, 33):                                
            if vnbqvoqt.get_collision_layer_value(i):
                rvxoocmp.append(str(i))
            if vnbqvoqt.get_collision_mask_value(i):
                tankowho.append(str(i))
        
        if rvxoocmp.size() > 0 or tankowho.size() > 0:
            mbmowhcd += aqrcdxcd + "Collision: layer: " + ",".join(rvxoocmp)
            mbmowhcd += " mask: " + ",".join(tankowho) + "\n"
    
                                                                          
                                                                 
    if vnbqvoqt.is_inside_tree():
                                
        var vpqdwcpt = []
        for prop in vnbqvoqt.get_property_list():
            var iwyzauvp = prop["name"]
            var lhvorrmy = vnbqvoqt.get(iwyzauvp)
            if lhvorrmy is Resource and lhvorrmy != null:
                var dwnpkawa = lhvorrmy.get_class()
                if lhvorrmy.resource_name != "":
                    dwnpkawa = lhvorrmy.resource_name
                vpqdwcpt.append("%s (%s)" % [iwyzauvp, dwnpkawa])
            
        if not vpqdwcpt.is_empty():
            mbmowhcd += aqrcdxcd + "Assigned subresources: " + ", ".join(vpqdwcpt) + "\n"
        
                                       
    if vnbqvoqt.get_script():
        mbmowhcd += aqrcdxcd + "Script: " + vnbqvoqt.get_script().resource_path + "\n"
    
                            
    if vnbqvoqt.unique_name_in_owner:
        mbmowhcd += aqrcdxcd + "Unique name: %" + vnbqvoqt.name + "\n"
    
                
    var jkgyoxjf = vnbqvoqt.get_groups()
    if not jkgyoxjf.is_empty():
                                                              
        jkgyoxjf = jkgyoxjf.filter(func(group): return not group.begins_with("_"))
        if not jkgyoxjf.is_empty():
            mbmowhcd += aqrcdxcd + "Groups: " + ", ".join(jkgyoxjf) + "\n"
    
                                           
    if vnbqvoqt.scene_file_path:
        mbmowhcd += aqrcdxcd + "Instanced from: " + vnbqvoqt.scene_file_path + "\n"
    
                      
    for child in vnbqvoqt.get_children():
        mbmowhcd += nzaghizp(child, aqrcdxcd)
    return mbmowhcd

func yijkksyp(tjnowisd: String, oldscyhc: EditorInterface) -> String:
    var ciwdvufr = tjnowisd.replace(zdtynkho, zdtynkho.substr(1)).strip_edges()

    var cpctttrq: Array = Array(oldscyhc.get_open_scenes())
    if cpctttrq.is_empty():
        return ciwdvufr + "\n[gds_context]Node tree:\n No scenes are currently open.[/gds_context]"

    var eyaxvtbx = "\n[gds_context]Node tree:\n"
    
    for scene_path in cpctttrq:
        var vcftmort: PackedScene = load(scene_path)
        if not vcftmort:
            eyaxvtbx += "Could not load scene: %s\n" % scene_path
            continue

        var zpykqbbz: Node = vcftmort.instantiate()
        if not zpykqbbz:
            continue

        var yuhbmxif = nzaghizp(zpykqbbz)

        eyaxvtbx += "Scene: %s\n" % scene_path
        eyaxvtbx += yuhbmxif
        eyaxvtbx += "--\n"
        
                                
        zpykqbbz.free()

    if eyaxvtbx.length() > eviotpcw:
        eyaxvtbx = eyaxvtbx.substr(0, eviotpcw) + "..."

    eyaxvtbx += "\n[/gds_context]"

    return ciwdvufr + eyaxvtbx

func lmwlhiys(xjapumuj: String, nmupoajy: EditorInterface) -> String:
                                                                                                                          
    var vkilxctc = xjapumuj.replace(mwqjwqhy, mwqjwqhy.substr(1)).strip_edges()

    var rhwwnwjp = nmupoajy.get_resource_filesystem()
    var gtxvoltr = "res://"
    
                                
    var ywajigqx = "\n[gds_context]\nFile Tree:\n"
    ywajigqx += jlqztoza(rhwwnwjp.get_filesystem_path(gtxvoltr))
    ywajigqx += "--\n"
    
    if ywajigqx.length() > eviotpcw:                                                            
        ywajigqx = ywajigqx.substr(0, eviotpcw) + "..."
            
    ywajigqx += "\n[/gds_context]"
    
    return vkilxctc + ywajigqx

func jlqztoza(qjjcttrd: EditorFileSystemDirectory, wyalsvmx: String = "") -> String:
    var emdcwxtg = ""
    
                                                          
    var otpuobtj = qjjcttrd.get_path()
    if otpuobtj == "res://addons/gamedev_assistant/":
                                
        var mrxxqcfs = EditorInterface.get_editor_settings()
        var ehqshmdx = mrxxqcfs.has_setting("gamedev_assistant/development_mode") and mrxxqcfs.get_setting("gamedev_assistant/development_mode") == true
        if not ehqshmdx:
            return wyalsvmx + "+ gamedev_assistant/\n"                                            
    
                                                   
    if qjjcttrd.get_path() != "res://":
        emdcwxtg += wyalsvmx + "+ " + qjjcttrd.get_name() + "/\n"
        wyalsvmx += "  "
    
                                      
    for i in qjjcttrd.get_subdir_count():
        var igyzmxkn = qjjcttrd.get_subdir(i)
        emdcwxtg += jlqztoza(igyzmxkn, wyalsvmx)
    
    for i in qjjcttrd.get_file_count():
        var rtqxihtj = qjjcttrd.get_file(i)
        emdcwxtg += wyalsvmx + "- " + rtqxihtj + "\n"
    
    return emdcwxtg

func kdhlwnpz(iptzragd: String, yldvbspo: EditorInterface) -> String:
                                                                                                                          
    var zhfmsqho = iptzragd.replace(ewmhjuty, ewmhjuty.substr(1)).strip_edges()

                                                                                                       
    var mpatlswy: Node = yldvbspo.get_base_control()
    var mdirfttx: RichTextLabel = ggksvgap(mpatlswy)

    if mdirfttx:
        var qysmymxm = mdirfttx.get_parsed_text()
        
        if qysmymxm.length() > olbxgbkk:                     
                                                                                            
            qysmymxm = qysmymxm.substr(-olbxgbkk) + "..."
        
        if qysmymxm.length() > 0:
            return zhfmsqho + "\n[gds_context]\nOutput Panel:\n" + qysmymxm + "\n[/gds_context]"
        else:
            return zhfmsqho + "\n[gds_context]No contents in the Output Panel.[/gds_context]"
    else:
        print("No RichTextLabel under @EditorLog was found.")
        return zhfmsqho + "\n--\nOutput Panel: Could not find the label.\n--\n"

func ggksvgap(cocjlfwf: Node) -> RichTextLabel:
                                              
    if cocjlfwf is RichTextLabel:
        var mefkonur: Node = cocjlfwf.get_parent()
        if mefkonur:
            var denzvnyw: Node = mefkonur.get_parent()
                                                           
            if denzvnyw and denzvnyw.name.begins_with("@EditorLog"):
                return cocjlfwf

                              
    for child in cocjlfwf.get_children():
        var ztneomlx: RichTextLabel = ggksvgap(child)
        if ztneomlx:
            return ztneomlx

    return null

func cgzsbric(sgoztxrx: String, ftajamxf: EditorInterface) -> String:         
                                                                                                                          
    var judbzjfv = sgoztxrx.replace(haflxypr, haflxypr.substr(1)).strip_edges()
                                                                                                    
                                                                                                  
    var lrhavdji = []                                                                              
    var hswvhtcg = OS.execute("git", ["diff"], lrhavdji, true)                                    
                                                                                                    
    if hswvhtcg == 0:                                                                            
        var vylumsir = "\n[gds_context]\nGit Diff:\n" + "\n".join(lrhavdji) + "\n"  
        
        if vylumsir.length() > eviotpcw:                                                            
            vylumsir = vylumsir.substr(0, eviotpcw) + "..."
        
        vylumsir += "[/gds_context]"
        
        return judbzjfv + vylumsir                                                
    else:                                                                                         
        return judbzjfv + "\n--\nGit Diff: Failed to execute git diff command.\n--\n"

func brfqocbe(ivuvrxjf: String, qttezpje: EditorInterface) -> String:
                                                                                                                          
    var ktcjoywe = ivuvrxjf.replace(tbnzunyn, tbnzunyn.substr(1)).strip_edges()
    return ktcjoywe

func onmxkxzv(afkbsbne: String) -> String:
    var zwuxpioh = afkbsbne.replace(iqhptucu, iqhptucu.substr(1)).strip_edges()
    
    var dbbqdmqm = []
    var dcaogipp = ProjectSettings.get_property_list()
    
    for prop in dcaogipp:
        var qdikaxsl: String = prop["name"]
        var lmrsjlcn = ProjectSettings.get(qdikaxsl)
        
                                             
        if qdikaxsl.begins_with("input/"):
            if lmrsjlcn is Dictionary or lmrsjlcn is Array:
                dbbqdmqm.append("%s = %s" % [qdikaxsl, str(lmrsjlcn)])
            elif lmrsjlcn == null or (lmrsjlcn is String and lmrsjlcn.is_empty()):
                continue
            else:
                dbbqdmqm.append("%s = %s" % [qdikaxsl, lmrsjlcn])
            continue
        
                                         
        if lmrsjlcn is Dictionary or lmrsjlcn is Array:
            continue
            
                                                      
        if lmrsjlcn == null or (lmrsjlcn is String and lmrsjlcn.is_empty()):
            continue
            
        dbbqdmqm.append("%s = %s" % [qdikaxsl, lmrsjlcn])
    
    dbbqdmqm.sort()
    var dwagijhy = "Unassigned project settings have been omitted from this list:\n" + "\n".join(dbbqdmqm)
    
    zwuxpioh = zwuxpioh + "\n" + dwagijhy
    return zwuxpioh
