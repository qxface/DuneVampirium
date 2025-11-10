                                                              
@tool
class_name MarkdownToBBCode
extends RefCounted

const vvfnkudy = [
    "b", "i", "u", "s", "code", "char", "p", "center", "left", "right", "fill",
    "indent", "url", "hint", "img", "font", "font_size", "dropcap",
    "opentype_features", "lang", "color", "bgcolor", "fgcolor", "outline_size",
    "outline_color", "table", "cell", "ul", "ol", "lb", "rb", "lrm", "rlm",
    "lre", "rle", "lro", "rlo", "pdf", "alm", "lri", "rli", "fsi", "pdi",
    "zwj", "zwnj", "wj", "shy"
]


                                                                    
                              
                                                                
                                                                    
static func xuyjifge(glqixprc: Array, ctyyygmx: String) -> String:
    var wjmexqhq = ""
    for i in range(glqixprc.size()):
        if i > 0:
            wjmexqhq += ctyyygmx
        wjmexqhq += str(glqixprc[i])
    return wjmexqhq


                                                                    
                                     
 
                                
                                                              
                                                                         
                                                                    
static func rcrlccwv(ymrgbely: String) -> String:
    var wjsrclth = ymrgbely.split("\n")
    var yrhquuaz = []
    var mtdxxupk = false
    var qaowspvt = []
    var krurbiki = []

    for line in wjsrclth:
        var aomvrkhh = line.strip_edges(true, false)                       

        if aomvrkhh.begins_with("```"):
            if mtdxxupk:
                                
                var vptajwbp = xuyjifge(qaowspvt, "\n")
                vptajwbp = exbodwiv(vptajwbp)

                                                       
                if krurbiki.size() > 0:
                    var awqocahc = xuyjifge(krurbiki, "\n")
                    awqocahc = exbodwiv(awqocahc)
                    awqocahc = rjvcowrz(awqocahc)
                    yrhquuaz.append(awqocahc)
                    krurbiki.clear()

                yrhquuaz.append("\n[table=1]\n[cell bg=#000000]\n[code]" + vptajwbp + "[/code]\n[/cell]\n[/table]\n")
                qaowspvt.clear()
                mtdxxupk = false
            else:
                                  
                if krurbiki.size() > 0:
                    var ctszfkdp = xuyjifge(krurbiki, "\n")
                    ctszfkdp = exbodwiv(ctszfkdp)
                    ctszfkdp = rjvcowrz(ctszfkdp)
                    yrhquuaz.append(ctszfkdp)
                    krurbiki.clear()
                mtdxxupk = true
        elif mtdxxupk:
            qaowspvt.append(line)
        else:
            krurbiki.append(line)

                                 
    if mtdxxupk and qaowspvt.size() > 0:
                             
        var djqpydnx = xuyjifge(qaowspvt, "\n")
        djqpydnx = exbodwiv(djqpydnx)
        var gxpvsnjr = plyiwbnm(djqpydnx)
        yrhquuaz.append("[p][/p][table=1]\n[cell bg=#000000]\n[code]" + gxpvsnjr + "[/code]\n[/cell]\n[/table]")
    elif krurbiki.size() > 0:
        var yvqbhvef = xuyjifge(krurbiki, "\n")
        yvqbhvef = exbodwiv(yvqbhvef)
        yvqbhvef = rjvcowrz(yvqbhvef)
        yrhquuaz.append(yvqbhvef)

    return xuyjifge(yrhquuaz, "\n")


                                                                    
                                         
 
                                                    
                                                                                  
                                                                            
                                                                    
static func naehoovr(yomcjjbd: String) -> Array:
    var fxolbnnn = []
    var ezdlqhmm = yomcjjbd.split("\n")

    var bwwhpzmx = false
    var wsboiotk = []
    var mdcxgedr = []

    for line in ezdlqhmm:
        var tfebijcx = line.strip_edges()

        if tfebijcx.begins_with("```"):
            if bwwhpzmx:
                                    
                var sbdprnjl = xuyjifge(mdcxgedr, "\n")
                fxolbnnn.append({ "type": "code", "content": sbdprnjl })
                mdcxgedr.clear()
                bwwhpzmx = false
            else:
                                    
                if wsboiotk.size() > 0:
                    var agrfbcnv = xuyjifge(wsboiotk, "\n")
                    fxolbnnn.append({ "type": "text", "content": agrfbcnv })
                    wsboiotk.clear()
                bwwhpzmx = true
        elif bwwhpzmx:
            mdcxgedr.append(line)
        else:
            wsboiotk.append(line)

                                      
    if wsboiotk.size() > 0:
        var xqucdqub = xuyjifge(wsboiotk, "\n")
        fxolbnnn.append({ "type": "text", "content": xqucdqub })
    elif bwwhpzmx and mdcxgedr.size() > 0:
        var wzarhgdi = xuyjifge(mdcxgedr, "\n")
        fxolbnnn.append({ "type": "code", "content": wzarhgdi })

    return fxolbnnn


                             
                           
                             

static func plyiwbnm(qwttewbg: String) -> String:
    var tdvokgrh = qwttewbg.split("\n")
    var bniemozl = 0
    
                           
    for line in tdvokgrh:
        bniemozl = max(bniemozl, line.length())
    
                                    
    for i in range(tdvokgrh.size()):
        var jolaasme = "  "
        var zettgjrr = "  "
        tdvokgrh[i] = jolaasme + tdvokgrh[i] + zettgjrr
    
    return xuyjifge(tdvokgrh, "\n") + "\n"


static func rjvcowrz(mfenoaiu: String) -> String:
    var ivibfsix = mfenoaiu
    var klfvcnal = ivibfsix.split("\n")
    var snnvznyt = []

    for line in klfvcnal:
                        
        if line.begins_with("## "):
            line = "[font_size=22][b]" + line.substr(3) + "[/b][/font_size]"
        elif line.begins_with("### "):
            line = "[font_size=18][b]" + line.substr(4) + "[/b][/font_size]"
        elif line.begins_with("#### "):
            line = "[font_size=16][b]" + line.substr(4) + "[/b][/font_size]"
        
               
        line = phwofzrj(line)
        snnvznyt.append(line)

    ivibfsix = xuyjifge(snnvznyt, "\n")

                               
    var gwnlkrph = ivibfsix.split("***")
    ivibfsix = ""
    for i in range(gwnlkrph.size()):
        ivibfsix += gwnlkrph[i]
        if i < gwnlkrph.size() - 1:
            if i % 2 == 0:
                ivibfsix += "[b][i]"
            else:
                ivibfsix += "[/i][/b]"

                           
    var ijbhxzoh = ivibfsix.split("**")
    var nuwwnoey = ""
    for i in range(ijbhxzoh.size()):
        nuwwnoey += ijbhxzoh[i]
        if i < ijbhxzoh.size() - 1:
            if i % 2 == 0:
                nuwwnoey += "[b]"
            else:
                nuwwnoey += "[/b]"
    ivibfsix = nuwwnoey

                           
    var xhmugcja = RegEx.new()
    xhmugcja.compile("(?<![\\s])(\\*)(?![\\s])([^\\*]+?)(?<![\\s])\\*(?![\\s])")
    ivibfsix = xhmugcja.sub(ivibfsix, "[i]$2[/i]", true)
    
    return ivibfsix

static func gpgumkqx(pvoloool: String, icrfbvfr: String, vaeesaxf: int) -> bool:
    var vocynrau = vaeesaxf + pvoloool.length()
    while vocynrau < icrfbvfr.length():
        var ieqwmaqz = icrfbvfr[vocynrau]
        if ieqwmaqz == "(":
            return true
        elif ieqwmaqz == " " or ieqwmaqz == "\t":
            vocynrau += 1
        else:
            return false
    return false


static func dbetmgrr(xtwnctmf: String, swdurrtl: Color) -> String:
    return "[swdurrtl =#" + swdurrtl.to_html(false) + "]" + xtwnctmf + "[/color]"


static func exbodwiv(rczozbub: String) -> String:
    var fshwyrnb = rczozbub
    var feriwpwy = RegEx.new()
    feriwpwy.compile("\\[(/?)(\\w+)((?:[= ])[^\\]]*)?\\]")

    var dpwggjto = feriwpwy.search_all(fshwyrnb)
    dpwggjto.reverse()
    for match in dpwggjto:
        var ejkivvcr = match.get_string()
        var futovryw = match.get_string(2).to_lower()
        if futovryw in vvfnkudy:
            var fmpmhmqh = match.get_start()
            var vrbcirer = match.get_end()
            var dvqcsdud = ""
            for c in ejkivvcr:
                if c == "[":
                    dvqcsdud += "[lb]"
                elif c == "]":
                    dvqcsdud += "[rb]"
                else:
                    dvqcsdud += c
            fshwyrnb = fshwyrnb.substr(0, fmpmhmqh) + dvqcsdud + fshwyrnb.substr(vrbcirer)

    return fshwyrnb


static func phwofzrj(zbpklogu: String) -> String:
    var mgzmcuvh = RegEx.new()
                                      
    mgzmcuvh.compile("\\[(.+?)\\]\\((.+?)\\)")
    var rurothfa = zbpklogu
    var yezdkfhf = mgzmcuvh.search_all(zbpklogu)
    yezdkfhf.reverse()
    for match in yezdkfhf:
        var owmrsmxh = match.get_string()
        var plusgjsm = match.get_string(1)
        var ayflmzvn = match.get_string(2)
                             
        var iqsbpoxv = "[url=%s]%s[/url]" % [ayflmzvn, plusgjsm]
        rurothfa = rurothfa.substr(0, match.get_start()) + iqsbpoxv + rurothfa.substr(match.get_end())
    return rurothfa
