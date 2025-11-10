                                                       
@tool
extends GDAScreenBase

signal hmflmgwe

var ecclpgck : RichTextLabel = null

@onready var gkmeqqjg : TextEdit = $Footer/PromptInput
@onready var pzwmnuui : Button = $Footer/SendPromptButton
@onready var kuusqhfm : Control = $Footer
@onready var tilbhicu : Control = $Body

@onready var advccbjl = $"../APIManager"
@onready var adxxbihq = $"../ActionManager"

var fgcrrelc = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_UserPrompt.tscn")
var ddnlyhzm = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_ServerResponse.tscn")
var ekwohscp = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_ErrorMessage.tscn")
const tiaiaeom = preload("res://addons/gamedev_assistant/scripts/chat/markdown_to_bbcode.gd")
var oibtmokk = preload("res://addons/gamedev_assistant/scripts/chat/message_tagger.gd").new()
var rzbhoprz = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_CodeBlockResponse.tscn")
var sxjnqnxd = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_CodeBlockUser.tscn")
var tgkqotbb = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_Spacing.tscn")

var viejzfkt := false
var awdciply: String = ""

                                                   
var rxvcguqx : String = ""
var zjqgxpzh : String = ""
var fviotzrz  : String = ""
var prnksxtj : String = ""
var ydyhzesj  : String = ""

var loshxijd : int = -1

@onready var azzhgcuh = $Body/MessagesContainer
@onready var yvnflayx = $Body/MessagesContainer/ThinkingLabel
@onready var ewaxhhdk = $Bottom/AddContext
@onready var irvynlml : CheckButton = $Bottom/ReasoningToggle
@onready var sxdrbbmq = $Body/MessagesContainer/RatingContainer
@onready var iazahhjv = $Bottom/Mode

@onready var ulkiqljt = preload("res://addons/gamedev_assistant/dock/icons/stop.png")  
@onready var vzkfrpkr = preload("res://addons/gamedev_assistant/dock/icons/arrowUp.png")  

var gbiysgdn = [
    "",
    " @OpenScripts ",
    " @Output ",
    " @Docs ",
    " @GitDiff ",
    " @ProjectSettings"
]

@onready var mcesucae = $"../ConversationManager"

var waiting_nonthinking = "Thinking ⚡"
var waiting_thinking = "Reasoning ⌛ This could take multiple minutes"

var notice_actions_nonthinking = "Generating one-click actions ⌛ To skip, press ■"
var notice_actions_thinking = "Generating one-click actions ⌛ To skip, press ■"


func _ready ():
    advccbjl.xpdubjyj.connect(khvsreux)
    advccbjl.sfrwatqp.connect(trqhmtww)
    
    mcesucae.hgyhkthb.connect(sxoosjxc)
    gkmeqqjg.gcivoxej.connect(xxrmjkct)
    
                       
    advccbjl.zeqbitvq.connect(uddncbvb)
    advccbjl.ngabjzqt.connect(aiunpzwr)
    advccbjl.eeanuqxm.connect(iczfnjvd)
    advccbjl.kgrvsdiw.connect(lnmaezsx)

    ewaxhhdk.item_selected.connect(mwiiwivk)    
    pzwmnuui.pressed.connect(ufoecmju)   
    
    sxdrbbmq.get_node("UpButton").pressed.connect(ugfrznij)
    sxdrbbmq.get_node("DownButton").pressed.connect(wljlfxin)
    sxdrbbmq.visible = false 

func _on_open ():
    gkmeqqjg.text = ""
    yvnflayx.visible = false
    sxdrbbmq.visible = false 
    xeidstiu(false)
    kiyemvod()
    ewaxhhdk.selected = 0
    awdciply = ''
    

                                                            
func nfxknjao ():
    viejzfkt = true
    xeidstiu(true)
    loshxijd = -1
    sxdrbbmq.visible = false
    oibtmokk.dhwyisqo()
    
                    
    zjqgxpzh = ""
    fviotzrz  = ""
    prnksxtj = ""
    ydyhzesj  = ""
    rxvcguqx = ""

func uddncbvb(egfqhsgh: String, bbxcapht: int, arnxkcdg: int) -> void:
    if ecclpgck == null:
        ecclpgck = ddnlyhzm.instantiate()
        ecclpgck.bbcode_enabled = true
        azzhgcuh.add_child(ecclpgck)
        var vkrfwdtl = tgkqotbb.instantiate()
        azzhgcuh.add_child(vkrfwdtl)
        yvnflayx.visible = false
        awdciply = egfqhsgh
        
        if arnxkcdg != -1:
            loshxijd = arnxkcdg
    else:
        awdciply += egfqhsgh
        
                                                  
    ecclpgck.text = tiaiaeom.rcrlccwv(awdciply)
    
                                                                     
    if not ecclpgck.meta_clicked.is_connected(lentdndo):  
        ecclpgck.meta_clicked.connect(lentdndo)  
    
    if bbxcapht > 0:
        mcesucae.uhclkmsr(bbxcapht)

func iczfnjvd(esoozonm: int, wbngsoiu: int) -> void:
    if ecclpgck:
        ecclpgck.visible = false

                                                                
    rryuvbrl(awdciply, ddnlyhzm, azzhgcuh, rzbhoprz)
    
                              
    azzhgcuh.move_child(yvnflayx, azzhgcuh.get_child_count() - 1)
    yvnflayx.visible = true
    yvnflayx.text = notice_actions_nonthinking

func aiunpzwr(gxxqetbq: int, edhahmho: int) -> void:
                                         
    if ecclpgck:
        ecclpgck.queue_free()
        ecclpgck = null
        
    yvnflayx.visible = false
    
                                                    
    azzhgcuh.move_child(sxdrbbmq, azzhgcuh.get_child_count() - 1)
    sxdrbbmq.visible = edhahmho > 0
    
                          
    var krkorvhh = adxxbihq.rcrmbsak(awdciply, edhahmho)
    adxxbihq.eqfdbevf(krkorvhh, azzhgcuh)

    awdciply = ""
    xeidstiu(true)
    yvnflayx.visible = false
    pzwmnuui.icon = vzkfrpkr

func lnmaezsx(xmarzkha: String):
    fqfvgjue(xmarzkha)
    xeidstiu(true)
    yvnflayx.visible = false
    ecclpgck = null
    pzwmnuui.icon = vzkfrpkr

func ufoecmju():  
    if advccbjl.lzgpswvj():  
                                         
        advccbjl.tyylnebm.emit()  
        
                                             
        if ecclpgck:
            ecclpgck.queue_free()
            ecclpgck = null
        
        xeidstiu(true)  
        pzwmnuui.icon = vzkfrpkr  
        
        if not yvnflayx.visible:
                                                                        
            rryuvbrl(awdciply, ddnlyhzm, azzhgcuh, rzbhoprz)
        
        yvnflayx.visible = false  
        
                                                   
        azzhgcuh.move_child(sxdrbbmq, azzhgcuh.get_child_count() - 1)
        sxdrbbmq.visible = loshxijd > 0

    else:  
                                             
        duuhanhp()  

func duuhanhp():
                                                        
    adxxbihq.ccumjrwb()
    
    sxdrbbmq.visible = false
    
    loshxijd = -1
    
    if len(gkmeqqjg.text) < 1:
        return
    
    var ofqjgytg = gkmeqqjg.text

                                                        
    var eflzhzhk := false
    if viejzfkt:
        var fplgtham = Engine.get_singleton("EditorInterface") if Engine.is_editor_hint() else null
        prnksxtj = oibtmokk.yijkksyp("", fplgtham)
        ydyhzesj  = oibtmokk.lmwlhiys("", fplgtham)
        rxvcguqx = "[gds_context]Current project context:[/gds_context]\n" \
            + prnksxtj + "\n" + ydyhzesj
        eflzhzhk = true
    else:
        eflzhzhk = bqrwprds()

    if eflzhzhk and rxvcguqx != "":
        ofqjgytg += rxvcguqx
                          
        zjqgxpzh = prnksxtj
        fviotzrz  = ydyhzesj

    viejzfkt = false

    if Engine.is_editor_hint():
        var fplgtham = Engine.get_singleton("EditorInterface")
        ofqjgytg = oibtmokk.swsmygoy(ofqjgytg, fplgtham)
        
    var vskrxdec = irvynlml.button_pressed
    var mwnpfniw : int = iazahhjv.selected
    var rdniqnzb : String
    
    if mwnpfniw == 0:
        rdniqnzb = "CHAT"
    else:
        rdniqnzb = "AGENT"        
    
    advccbjl.kgmbijzb(ofqjgytg, vskrxdec, rdniqnzb)
    qcciwnig(gkmeqqjg.text)                               
    xeidstiu(false)
    gkmeqqjg.text = ""
    
    if vskrxdec:
        yvnflayx.text = waiting_thinking
    else:
        yvnflayx.text = waiting_nonthinking
        
    yvnflayx.visible = true
    azzhgcuh.move_child(yvnflayx, azzhgcuh.get_child_count() - 1)
    
                                               
    hmflmgwe.emit()
    
func xeidstiu (kvoxktlo : bool):
    if kvoxktlo:  
        pzwmnuui.icon = vzkfrpkr  
    else:  
        pzwmnuui.icon = ulkiqljt  

func khvsreux (wibupdyb : String, njjwbnaf : int):
    mnpyvrkm(wibupdyb)
    xeidstiu(true)
    yvnflayx.visible = false

func trqhmtww (uljivche : String):
    fqfvgjue(uljivche)
    xeidstiu(true)
    yvnflayx.visible = false

func qcciwnig(gkrridhs: String):
                                                                               
    rryuvbrl(gkrridhs, fgcrrelc, azzhgcuh, sxjnqnxd)
    
    var cvvkbsfk = tgkqotbb.instantiate()
    azzhgcuh.add_child(cvvkbsfk)


func mnpyvrkm(gdakwvsw: String):
                                                                                
    rryuvbrl(gdakwvsw, ddnlyhzm, azzhgcuh, rzbhoprz)
    
    var bkcawqqp = tgkqotbb.instantiate()
    azzhgcuh.add_child(bkcawqqp)

func fqfvgjue (vcxbokyt : String):
    var vkeceqhz = ekwohscp.instantiate()
    azzhgcuh.add_child(vkeceqhz)
    vkeceqhz.text = vcxbokyt

func kiyemvod ():
    for node in azzhgcuh.get_children():
        if node == yvnflayx or node == sxdrbbmq:
            continue
        node.queue_free()
    azzhgcuh.custom_minimum_size = Vector2.ZERO
    
    hmflmgwe.emit()
    
                  
    oibtmokk.dhwyisqo()
    
                            
    zjqgxpzh = ""
    fviotzrz  = ""
    prnksxtj = ""
    ydyhzesj  = ""
    rxvcguqx = ""

func sxoosjxc ():
    var dtknsawj = mcesucae.srlihurr()
    kiyemvod()
    
    for msg in dtknsawj.messages:
        if msg.role == "user":
            qcciwnig(msg.content)
        elif msg.role == "assistant":
            mnpyvrkm(msg.content)
    
    xeidstiu(true)

func mwiiwivk(skkybkdy: int):
    if skkybkdy >= 0 and skkybkdy < gbiysgdn.size():
        gkmeqqjg.text += " " + gbiysgdn[skkybkdy]
        ewaxhhdk.select(0)

func lentdndo(hnsxuhng):
    OS.shell_open(str(hnsxuhng))

                                                
func amipepnz(osfitkym: String) -> String:
    
    var komvjriy = RegEx.new()
                                 
    komvjriy.compile("\\[gds_context\\](.|\\n)*?\\[/gds_context\\]")
    osfitkym = komvjriy.sub(osfitkym, "", true)
    
                                       
    komvjriy.compile("<internal_tool_use>(.|\\n)*?</internal_tool_use>")
    return komvjriy.sub(osfitkym, "", true)
    
                                                
func dpbixstu(lhduufav: String) -> String:
        
    var ruiatbtd = RegEx.new()
    ruiatbtd.compile("\\[gds_actions\\](.|\\n)*?\\[/gds_actions\\]")
    return ruiatbtd.sub(lhduufav, "", true)

func ecwhtqef(wsvrbpep: String):
    wsvrbpep = wsvrbpep.replace(notice_actions_nonthinking, '').replace(notice_actions_thinking, '').strip_edges()
    return wsvrbpep
    
func rryuvbrl(ouojnvdd: String, jdxgwezx: PackedScene, rigbtnpb: Node, edvqowhi: PackedScene) -> void:
    
    ouojnvdd = ouojnvdd.strip_edges()
    ouojnvdd = amipepnz(ouojnvdd)
    
                       
    var jgwmaoev = tiaiaeom.naehoovr(ouojnvdd)

    for block in jgwmaoev:
        if block["type"] == "text":
            var nxjuqgrd = jdxgwezx.instantiate()
            nxjuqgrd.bbcode_enabled = true
            rigbtnpb.add_child(nxjuqgrd)
            
            var qnmohacm = block["content"]
            
                                                      
            qnmohacm = tiaiaeom.exbodwiv(qnmohacm)
            qnmohacm = tiaiaeom.rjvcowrz(qnmohacm)
            qnmohacm = qnmohacm.strip_edges()
            
            nxjuqgrd.text = qnmohacm

                                 
            if not nxjuqgrd.meta_clicked.is_connected(lentdndo):
                nxjuqgrd.meta_clicked.connect(lentdndo)

        elif block["type"] == "code":
            var kogzztvo = edvqowhi.instantiate()
            rigbtnpb.add_child(kogzztvo)
            kogzztvo.text = block["content"]

                           
func bqrwprds() -> bool:
    var vcodpedg = Engine.get_singleton("EditorInterface") if Engine.is_editor_hint() else null
    prnksxtj = oibtmokk.yijkksyp("", vcodpedg)
    ydyhzesj  = oibtmokk.lmwlhiys("", vcodpedg)

    var jzajzlwy = prnksxtj != zjqgxpzh
    var xivxpple  = ydyhzesj  != fviotzrz

    var btqmawbc = []
    if jzajzlwy:
        btqmawbc.append(prnksxtj)
    if xivxpple:
        btqmawbc.append(ydyhzesj)

    rxvcguqx = ""
    if btqmawbc.size() > 0:
        rxvcguqx = "[gds_context]Current project context:[/gds_context]\n" + "\n".join(btqmawbc)

    return jzajzlwy or xivxpple

                               
func xxrmjkct() -> void:
    var dvytfvex = not advccbjl.lzgpswvj()
    if dvytfvex:
        duuhanhp()
        
func ugfrznij():
    if loshxijd > 0:
        advccbjl.goknswzz(loshxijd, 5)
        sxdrbbmq.visible = false                     

func wljlfxin():
    if loshxijd > 0:
        advccbjl.goknswzz(loshxijd, 1)
        sxdrbbmq.visible = false
