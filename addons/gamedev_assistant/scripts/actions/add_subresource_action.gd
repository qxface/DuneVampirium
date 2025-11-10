                                                                     
@tool
extends Node

const ktulliya = preload("action_parser_utils.gd")

static func execute(mauuxrrb: String, zjnncndz: String, kthiivyg: String, ljgyaknl: Dictionary) -> Dictionary:
    var exywouob = EditorPlugin.new().get_editor_interface()
    var lyadjzsd = exywouob.get_open_scenes()

                                   
    for scene in lyadjzsd:
        if scene == zjnncndz:
                                                                   
            exywouob.reload_scene_from_path(zjnncndz)
            return _add_to_open_scene(mauuxrrb, exywouob.get_edited_scene_root(), kthiivyg, ljgyaknl)

                                           
                                                             
    return _add_to_closed_scene(mauuxrrb, zjnncndz, kthiivyg, ljgyaknl)


static func _add_to_open_scene(ttmhvaay: String, rreuqikz: Node, mawhslmh: String, pwonkgfu: Dictionary) -> Dictionary:
    var fpnazsiw = jiypoaqe(ttmhvaay, rreuqikz)
    if not fpnazsiw:
        return {"success": false, "error_message": "Node '%s' not found." % ttmhvaay, "node_type": ""}

    var dgdlwpjf = eqsqithp(mawhslmh, pwonkgfu)
    if not dgdlwpjf:
                                       
        return {"success": false, "error_message": "Could not create or configure resource '%s'." % mawhslmh, "node_type": fpnazsiw.get_class()}

    if not pwonkgfu.has("assign_to_property"):
        var axymtpid = "No 'assign_to_property' field in pwonkgfu dictionary."
        push_error(axymtpid)
        return {"success": false, "error_message": axymtpid, "node_type": fpnazsiw.get_class()}

    var gclipmix = String(pwonkgfu["assign_to_property"])
    if not olwplblt(fpnazsiw, gclipmix, dgdlwpjf):
                                       
        var axymtpid = "Failed to assign new resource to property '%s'." % gclipmix
        return {"success": false, "error_message": axymtpid, "node_type": fpnazsiw.get_class()}

    if EditorInterface.save_scene() == OK:
        return {"success": true, "error_message": "", "node_type": fpnazsiw.get_class()}
    else:
        var axymtpid = "Failed to save the scene."
        push_error(axymtpid)
        return {"success": false, "error_message": axymtpid, "node_type": fpnazsiw.get_class()}

static func _add_to_closed_scene(qlaevfqx: String, jmkybqrr: String, ytibcall: String, teinsoso: Dictionary) -> Dictionary:
    var svouonio = load(jmkybqrr)
    if !(svouonio is PackedScene):
        var iakszmtn = "Failed to load scene '%s' as PackedScene." % jmkybqrr
        push_error(iakszmtn)
        return {"success": false, "error_message": iakszmtn, "node_type": ""}

    var ehmuoelq = svouonio.instantiate()
    if not ehmuoelq:
        var iakszmtn = "Could not instantiate scene '%s'." % jmkybqrr
        push_error(iakszmtn)
        return {"success": false, "error_message": iakszmtn, "node_type": ""}

    var ffootxzd = jiypoaqe(qlaevfqx, ehmuoelq)
    if not ffootxzd:
        return {"success": false, "error_message": "Node '%s' not found." % qlaevfqx, "node_type": ""}

    var lxijdueo = eqsqithp(ytibcall, teinsoso)
    if not lxijdueo:
        return {"success": false, "error_message": "Could not create or configure resource '%s'." % ytibcall, "node_type": ffootxzd.get_class()}

    if not teinsoso.has("assign_to_property"):
        var iakszmtn = "No 'assign_to_property' field in teinsoso dictionary."
        push_error(iakszmtn)
        return {"success": false, "error_message": iakszmtn, "node_type": ffootxzd.get_class()}

    var lekmknye = String(teinsoso["assign_to_property"])
    if not olwplblt(ffootxzd, lekmknye, lxijdueo):
        var iakszmtn = "Failed to assign new resource to property '%s'." % lekmknye
        return {"success": false, "error_message": iakszmtn, "node_type": ffootxzd.get_class()}

    svouonio.pack(ehmuoelq)
    if ResourceSaver.save(svouonio, jmkybqrr) == OK:
        return {"success": true, "error_message": "", "node_type": ffootxzd.get_class()}
    else:
        var iakszmtn = "Failed to save the packed scene."
        push_error(iakszmtn)
        return {"success": false, "error_message": iakszmtn, "node_type": ffootxzd.get_class()}

                                                                             
         
                                                                             
static func jiypoaqe(jigmdffq: String, ihkgjfec: Node) -> Node:
    var itysixqe = ihkgjfec.find_child(jigmdffq, true, true)
    if not itysixqe and jigmdffq == ihkgjfec.name:
        itysixqe = ihkgjfec

    if not itysixqe:
        push_error("Node '%s' not found in the scene." % jigmdffq)
        return null

    return itysixqe


static func eqsqithp(kxamhrmu: String, obpdlyic: Dictionary) -> Resource:
    if not ClassDB.class_exists(kxamhrmu):
        push_error("Resource type '%s' does not exist." % kxamhrmu)
        return null

    var ggwpbrxw = ClassDB.instantiate(kxamhrmu)
    if not ggwpbrxw:
        push_error("Could not instantiate resource of type '%s'." % kxamhrmu)
        return null

                                                                  
    for property_name in obpdlyic.keys():
        if property_name == "assign_to_property":
            continue

        var wevvrzdn = obpdlyic[property_name]
        var bezxbcao = _parse_value(wevvrzdn)
        if bezxbcao == null and wevvrzdn != null:
            push_error("Failed to parse value '%s' for property '%s'." % [str(wevvrzdn), property_name])
            return null

        if not wgsfzmnb(ggwpbrxw, property_name, bezxbcao):
            return null

    return ggwpbrxw


static func _parse_value(dkslxkou) -> Variant:
                                                             
    if dkslxkou is String:
        var movudvmu = dkslxkou.strip_edges()
                                                 
        if movudvmu.begins_with("(") and movudvmu.ends_with(")"):
            var vnlxyjlo = movudvmu.substr(1, movudvmu.length() - 2)
            var mmonqmqp = vnlxyjlo.split(",", false)
            if mmonqmqp.size() == 2:
                return Vector2(float(mmonqmqp[0].strip_edges()), float(mmonqmqp[1].strip_edges()))
            elif mmonqmqp.size() == 3:
                return Vector3(float(mmonqmqp[0].strip_edges()), float(mmonqmqp[1].strip_edges()), float(mmonqmqp[2].strip_edges()))
            elif mmonqmqp.size() == 4:
                return Vector4(float(mmonqmqp[0].strip_edges()), float(mmonqmqp[1].strip_edges()), float(mmonqmqp[2].strip_edges()), float(mmonqmqp[3].strip_edges()))
        if movudvmu.to_lower() == "true":
            return true
        if movudvmu.to_lower() == "false":
            return false
        if movudvmu.is_valid_float():
            return float(movudvmu)
                                       
        return movudvmu

                                                                  
    return dkslxkou


static func olwplblt(zvayitqm: Node, qoniczke: String, kdtrxych: Variant) -> bool:
    var xrawoxxy = zvayitqm.get(qoniczke)
    var fcjtnywv = true
                                                                                          
                                                                                                        
                                         
      
                                                                                                            
                                                                 

                    
    zvayitqm.set(qoniczke, kdtrxych)
                                               
    if zvayitqm.get(qoniczke) != kdtrxych:
        push_error("Failed to set property '%s' on node '%s' value: %s." % [qoniczke, zvayitqm.name, kdtrxych])
        fcjtnywv = false
                          
    return fcjtnywv


static func wgsfzmnb(yxalqqcc: Resource, xasbezua: String, gitiypkw: Variant) -> bool:
                                                    
    var hbfuirwx = yxalqqcc.get_property_list()
    var afxuthpd = null

                                           
    for prop_info in hbfuirwx:
        if prop_info.name == xasbezua:
            afxuthpd = prop_info.type
            break

                                              
    if afxuthpd == null:
        push_error("Property '%s' doesn't exist on resource '%s'." % [xasbezua, yxalqqcc.get_class()])
        return true                                                              

                                                                                 
                                         
    if afxuthpd == TYPE_COLOR:
        match typeof(gitiypkw):
            TYPE_VECTOR2:
                                                    
                gitiypkw = Color(gitiypkw.x, gitiypkw.y, 0, 1.0)
            TYPE_VECTOR3:
                                                        
                gitiypkw = Color(gitiypkw.x, gitiypkw.y, gitiypkw.z, 1.0)
            TYPE_VECTOR4:
                                                        
                gitiypkw = Color(gitiypkw.x, gitiypkw.y, gitiypkw.z, gitiypkw.w)
            TYPE_ARRAY:
                                                                                         
                if gitiypkw.size() == 3:
                    gitiypkw = Color(gitiypkw[0], gitiypkw[1], gitiypkw[2], 1.0)
                elif gitiypkw.size() == 4:
                    gitiypkw = Color(gitiypkw[0], gitiypkw[1], gitiypkw[2], gitiypkw[3])
                                                                       
                                           
            
                                                                    
    elif afxuthpd == TYPE_VECTOR3 and typeof(gitiypkw):
        gitiypkw = Vector3(gitiypkw.x, gitiypkw.y, 0)

                    
    yxalqqcc.set(xasbezua, gitiypkw)

                                                   
    var lmjbbvsj = yxalqqcc.get(xasbezua)
    
    var sgrykuyx : bool
    
    if typeof(gitiypkw) in [TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4]:
        if typeof(lmjbbvsj) == typeof(gitiypkw):
            sgrykuyx = lmjbbvsj.is_equal_approx(gitiypkw)
        else:
            push_error("Wrong data type for property %s" % [xasbezua])
            sgrykuyx = false
    elif typeof(gitiypkw) == TYPE_FLOAT and typeof(lmjbbvsj) == TYPE_FLOAT:
                             
                         
        sgrykuyx = is_equal_approx(gitiypkw, lmjbbvsj)
    else:
        sgrykuyx = lmjbbvsj == gitiypkw

                                                                              
    if typeof(lmjbbvsj) == typeof(gitiypkw) and not sgrykuyx:
        push_error("Failed to set resource property '%s' on resource '%s' value: %s " % [xasbezua, yxalqqcc.get_class(), gitiypkw])
        return false

    return true



                                                                             
            
                                                       
                                                               
                                                                             
                           
static func parse_line(gbbmexet: String, tegmgohy: String) -> Dictionary:
    if gbbmexet.begins_with("add_subresource("):
        var ljqemdux = gbbmexet.replace("add_subresource(", "")
        if ljqemdux.ends_with(")"):
            ljqemdux = ljqemdux.substr(0, ljqemdux.length() - 1)
        ljqemdux = ljqemdux.strip_edges()

        var iyxmilil = []
        var qcczhgzl = 0
        while true:
            var ieirzmte = ljqemdux.find('"',qcczhgzl)
            if ieirzmte == -1:
                break
            var tblzrfkv = ljqemdux.find('"', ieirzmte + 1)
            if tblzrfkv == -1:
                break
            iyxmilil.append(ljqemdux.substr(ieirzmte + 1, tblzrfkv - (ieirzmte + 1)))
            qcczhgzl = tblzrfkv + 1

        var mqqbmqab = ljqemdux.find("{")
        var yugwksoh = ljqemdux.rfind("}")
        if mqqbmqab == -1 or yugwksoh == -1:
            return {}

        var wsuhvgvs = ljqemdux.substr(mqqbmqab, yugwksoh - mqqbmqab + 1)
        var xcrxrcbl = ktulliya.pfgxqbkw(wsuhvgvs)

                                                                               
                                                                                
                                  
        for key in xcrxrcbl.keys():
            var kvmleoqq = xcrxrcbl[key]
            if kvmleoqq is String:
                var jumctxnx = kvmleoqq.strip_edges()
                if jumctxnx.begins_with("\"") and jumctxnx.ends_with("\"") and jumctxnx.length() > 1:
                    jumctxnx = jumctxnx.substr(1, jumctxnx.length() - 2)
                xcrxrcbl[key] = jumctxnx
                                                                               

        if iyxmilil.size() < 3:
            return {}

        return {
            "type": "add_subresource",
            "node_name": iyxmilil[0],
            "scene_path": iyxmilil[1],
            "subresource_type": iyxmilil[2],
            "properties": xcrxrcbl
        }

    return {}
