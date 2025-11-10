                                                                  
@tool
extends Node

static func lwlfieos(cknnqxyn: String) -> String:
    var kqlvkpvb = cknnqxyn.find('"')
    if kqlvkpvb == -1:
        return ""
    var bvucrgkt = cknnqxyn.find('"', kqlvkpvb + 1)
    if bvucrgkt == -1:
        return ""
    return cknnqxyn.substr(kqlvkpvb + 1, bvucrgkt - (kqlvkpvb + 1))


static func tzxwljiw(ovspbsvm: String, dknvpmmi: String) -> String:
    var exuowbtd = RegEx.new()
    exuowbtd.compile("```.*\\n# New file: " + ovspbsvm + "\\n([\\s\\S]*?)```")
    var znpwtlzn = exuowbtd.search(dknvpmmi)
    return znpwtlzn.get_string(1).strip_edges() if znpwtlzn else ""


static func dmlytmkl(ohflozzd: String) -> Array:
    var kgyjdvtq = ohflozzd.replace("create_scene(", "").replace(")", "").strip_edges()
    var xecwkwvs = []
    var boufmsgd = 0
    while true:
        var drmueoda = kgyjdvtq.find('"',boufmsgd)
        if drmueoda == -1:
            break
        var qkthjobn = kgyjdvtq.find('"', drmueoda + 1)
        if qkthjobn == -1:
            break
        xecwkwvs.append(kgyjdvtq.substr(drmueoda + 1, qkthjobn - drmueoda - 1))
        boufmsgd = qkthjobn + 1
    return xecwkwvs


                                                     
static func tfedjcsk(uckxzxwq: String) -> Array:
    var ljvljooh = uckxzxwq.replace("create_node(", "")
    
                                                                                                    
    var eejqdeba = ljvljooh.rfind(")")
    if eejqdeba != -1:
        ljvljooh = ljvljooh.substr(0, eejqdeba)
    
    ljvljooh = ljvljooh.strip_edges()
    
                                                   
    var sxyujfss = ljvljooh.find("{")
    if sxyujfss != -1:
        ljvljooh = ljvljooh.substr(0, sxyujfss).strip_edges()
    
    var nrjetfio = []
    var otxashij = 0
    while true:
        var seexjvvx = ljvljooh.find('"',otxashij)
        if seexjvvx == -1:
            break
        var kshyygch = ljvljooh.find('"', seexjvvx + 1)
        if kshyygch == -1:
            break
        nrjetfio.append(ljvljooh.substr(seexjvvx + 1, kshyygch - seexjvvx - 1))
        otxashij = kshyygch + 1
    return nrjetfio


                                                                             
                   
                                                                             
static func fwkieqnb(yoboekja: String) -> Dictionary:
                                 
    var mjgblerm = yoboekja.replace("edit_node(", "")

                                    
    if mjgblerm.ends_with(")"):
        mjgblerm = mjgblerm.substr(0, mjgblerm.length() - 1)

                     
    mjgblerm = mjgblerm.strip_edges()

                                                                  
    var qkbqtnqt = []
    var qphdndqb = 0
    while true:
        var nttjzxnb = mjgblerm.find('"',qphdndqb)
        if nttjzxnb == -1:
            break
        var yetjpbrq = mjgblerm.find('"', nttjzxnb + 1)
        if yetjpbrq == -1:
            break

        qkbqtnqt.append(mjgblerm.substr(nttjzxnb + 1, yetjpbrq - nttjzxnb - 1))
        qphdndqb = yetjpbrq + 1

                              
    var tzvgxmpm = mjgblerm.find("{")
    var nnsnuqvn = mjgblerm.rfind("}")
    if tzvgxmpm == -1 or nnsnuqvn == -1:
                                           
        return {}

    var kzwdbufp = mjgblerm.substr(tzvgxmpm, nnsnuqvn - tzvgxmpm + 1)

                                             
    var yxyfvfhx = ""
    if qkbqtnqt.size() > 0:
        yxyfvfhx = qkbqtnqt[0]

    var gunnrxfk = ""
    if qkbqtnqt.size() > 1:
        gunnrxfk = qkbqtnqt[1]

    return {
        "node_name": yxyfvfhx,
        "scene_path": gunnrxfk,
        "modifications": pfgxqbkw(kzwdbufp)
    }


static func pfgxqbkw(auwdyghp: String) -> Dictionary:
                                                          
    var giytyzqi = auwdyghp.strip_edges()

                                    
    if giytyzqi.begins_with("{"):
        giytyzqi = giytyzqi.substr(1, giytyzqi.length() - 1)
                                     
    if giytyzqi.ends_with("}"):
        giytyzqi = giytyzqi.substr(0, giytyzqi.length() - 1)

                                      
    giytyzqi = giytyzqi.strip_edges()

                                                              
    var xsjavwmb = []
    var jcittifv = ""
    var yjyluudl = 0

    for i in range(giytyzqi.length()):
        var tcndsfgy = giytyzqi[i]
        if tcndsfgy == "(":
            yjyluudl += 1
        elif tcndsfgy == ")":
            yjyluudl -= 1

        if tcndsfgy == "," and yjyluudl == 0:
            xsjavwmb.append(jcittifv.strip_edges())
            jcittifv = ""
        else:
            jcittifv += tcndsfgy

    if jcittifv != "":
        xsjavwmb.append(jcittifv.strip_edges())

                                 
    var nxwdlevk = {}
    for entry in xsjavwmb:
        var kjbiwcvu = entry.find(":")
        if kjbiwcvu == -1:
            continue

        var bixoxeui = entry.substr(0, kjbiwcvu).strip_edges()
        var gqefmojz = entry.substr(kjbiwcvu + 1).strip_edges()

                                                                        
        if bixoxeui.begins_with("\"") and bixoxeui.ends_with("\"") and bixoxeui.length() >= 2:
            bixoxeui = bixoxeui.substr(1, bixoxeui.length() - 2)

        nxwdlevk[bixoxeui] = gqefmojz

    return nxwdlevk

static func qcizkoub(rec_line: String) -> Dictionary:
    var ooegsbik = rec_line.replace("edit_script(", "")
    var lqnuryib = ooegsbik.length()
    if ooegsbik.ends_with(")"):
        ooegsbik = ooegsbik.substr(0, lqnuryib - 1)
    
    lqnuryib = ooegsbik.length()
    
    var vgqhculs = []
    var luxsokiz = 0
    var cbnvuadp = false
    var dndszobp = ""
    
    for i in range(lqnuryib):
        var kzzvbahq = ooegsbik[i]
        var taemqsjg = ooegsbik[i-1]
        if kzzvbahq == '"' and (i == 0 or taemqsjg != '\\'):
            cbnvuadp = !cbnvuadp
            continue
            
        if !cbnvuadp and kzzvbahq == ',':
            vgqhculs.append(dndszobp.strip_edges())
            dndszobp = ""
            continue
            
        dndszobp += kzzvbahq
    
    if dndszobp != "":
        vgqhculs.append(dndszobp.strip_edges())
    
    if vgqhculs.size() < 2:
        return {}
    
    return {
        "path": vgqhculs[0].strip_edges().trim_prefix('"').trim_suffix('"'),
        "message_id": vgqhculs[1].to_int()
    }
