                                                       
@tool
extends Node

                                                 
                                      
                                   

signal yivmaisp (validated : bool, error : String)

signal izldnmgc(update_available: bool, latest_version: String)
signal vmcxdzpr(error: String)

signal xpdubjyj (message : String, conv_id : int)
signal sfrwatqp (error : String)
signal mjucqjto (message : String)

signal fwvwuwle (data)
signal wnhzlvzc (error : String)

signal aegetfqt (data)
signal yzryaydo (error : String)

signal jaatnjss ()
signal dajltnan (error : String)

signal qhlbczki ()
signal jolgeqmg (error : String)

signal tyylnebm

const ocvsteuq = 30
const hfwsorry = 120
const jjzbtzfm = 60

var hhdbxfdb : bool 

              
signal zeqbitvq(content: String, conv_id: int, message_id: int)
signal ngabjzqt(conv_id: int, message_id: int)
signal eeanuqxm(conv_id: int, message_id: int)
signal kgrvsdiw(error: String)
var zmngtsor : HTTPClient
var frpkjprc = false
var egswltab = ""
var qjpytkqa = false

var yxkkqxkn : String
var wwpvdbyk : String
var ptoaxuka : String
var lniuisgu : String
var tsrjkorb : String
var uhqxsamx : String
var xhvabqbw : String
var crhkdnoz : String

var egkgeqev : String:
    get:
        var wrxvwtzy = EditorInterface.get_editor_settings()
        var ibrhcuhl = "null"
        hhdbxfdb = wrxvwtzy.has_setting("gamedev_assistant/development_mode") and wrxvwtzy.get_setting('gamedev_assistant/development_mode') == true
        
        if not hhdbxfdb and wrxvwtzy.has_setting("gamedev_assistant/token"):
            return wrxvwtzy.get_setting("gamedev_assistant/token")
        elif hhdbxfdb and wrxvwtzy.has_setting("gamedev_assistant/token_dev"):        
            return wrxvwtzy.get_setting("gamedev_assistant/token_dev")
                    
        return ibrhcuhl

var pqznipdy = ["Content-type: application/json", "Authorization: Bearer " + egkgeqev]

@onready var vfhamwig = $"../ConversationManager"

@onready var xpkaiolh : HTTPRequest = $ValidateToken
@onready var lzamtein : HTTPRequest = $SendMessage
@onready var gofxlmii : HTTPRequest = $GetConversationsList
@onready var oaombwkx : HTTPRequest = $GetConversation
@onready var ryzwviax : HTTPRequest = $DeleteConversation
@onready var dhmkfwxp : HTTPRequest = $ToggleFavorite
@onready var naxdxtie : HTTPRequest = $CheckUpdates
@onready var fwqxqlfy : HTTPRequest = $TrackAction
@onready var wtedfhfv : HTTPRequest = $RatingAction
@onready var slvjswyr : HTTPRequest = $EditScript

var aeuaasyg = []

var sigyzexh : Button = null

func _ready ():
                                      
    zmngtsor = HTTPClient.new()
    
    xpkaiolh.timeout = ocvsteuq                                         
    lzamtein.timeout = hfwsorry                                           
    gofxlmii.timeout = ocvsteuq                                 
    oaombwkx.timeout = ocvsteuq                                       
    ryzwviax.timeout = ocvsteuq                                    
    dhmkfwxp.timeout = ocvsteuq
    naxdxtie.timeout = ocvsteuq
    slvjswyr.timeout = jjzbtzfm
    
    xpkaiolh.request_completed.connect(yqlpixfk)
    lzamtein.request_completed.connect(gxlhwyhs)
    gofxlmii.request_completed.connect(qljjeema)
    oaombwkx.request_completed.connect(mcximdww)
    ryzwviax.request_completed.connect(noshqbur)
    dhmkfwxp.request_completed.connect(rwjgheiu)
    naxdxtie.request_completed.connect(wmaljuwq)
    slvjswyr.request_completed.connect(frofezja)
    
    tyylnebm.connect(jaizzqnv)  
    
    ssinfonk ()
    

func ssinfonk ():
    var yqcnkmbu = EditorInterface.get_editor_settings()            
    if yqcnkmbu.has_setting("gamedev_assistant/endpoint"):          
        yxkkqxkn = yqcnkmbu.get_setting("gamedev_assistant/endpoint")    
        wwpvdbyk = yxkkqxkn + "/token/validate"                
        ptoaxuka = yxkkqxkn + "/chat/message"                         
        lniuisgu = yxkkqxkn + "/chat/conversations"        
        tsrjkorb = yxkkqxkn + "/chat/conversation/"
        uhqxsamx = yxkkqxkn + "/chat/checkForUpdates"
        xhvabqbw = yxkkqxkn + "/chat/track-action"
        crhkdnoz = yxkkqxkn + "/chat/track-rating"

func pqfcxytq ():
    return ["Content-type: application/json", "Authorization: Bearer " + egkgeqev]

func upztlela ():
    var vwdvtndl = xpkaiolh.request(wwpvdbyk, pqfcxytq(), HTTPClient.METHOD_GET)

func kgmbijzb(zimakryt: String, irzqqoqi: bool, aoadcdgd: String) -> void:
    
    lzamtein.timeout = ocvsteuq
    
                           
    frpkjprc = false
    qjpytkqa = false
    egswltab = ""
    
                                
    var snqqfkdx = yxkkqxkn.begins_with("https://")
    var yylfyfrv = yxkkqxkn.replace("http://", "").replace("https://", "")
    
                                       
    var ejrfkghd = -1
    if yylfyfrv.begins_with("localhost:"):
        var bmclpqpq = yylfyfrv.split(":")
        yylfyfrv = bmclpqpq[0]
        ejrfkghd = int(bmclpqpq[1])
        
    var ujpkvgos: Error
    if snqqfkdx:
        ujpkvgos = zmngtsor.connect_to_host(yylfyfrv, ejrfkghd, TLSOptions.client())
    else:
        ujpkvgos = zmngtsor.connect_to_host(yylfyfrv, ejrfkghd)
        
    if ujpkvgos != OK:
        kgrvsdiw.emit("Failed to connect: " + str(ujpkvgos))
        return

    frpkjprc = true
    
                             
    var tidsmkqs = EditorInterface.get_editor_settings()
    var cgmcoqob = tidsmkqs.get_setting("gamedev_assistant/version_identifier")
    
    var ofktwyvq = Engine.get_version_info()
    var fhfibrwf = "%d.%d" % [ofktwyvq.major, ofktwyvq.minor]
    
                                           
    var mehipvxi = ""
    if tidsmkqs.has_setting("gamedev_assistant/custom_instructions"):
        mehipvxi = tidsmkqs.get_setting("gamedev_assistant/custom_instructions")
    
    
                              
    var uzowmabm = { 
        "content": zimakryt, 
        "useThinking": irzqqoqi,
        "releaseUniqueIdentifier": cgmcoqob,
        "godotVersion": fhfibrwf,
        "mode": aoadcdgd,
        "customInstructions": mehipvxi
    }
    
    var wcoaftrw = vfhamwig.srlihurr()
    
    if wcoaftrw and wcoaftrw.id > 0:
        uzowmabm["conversationId"] = wcoaftrw.id
        
                                                            
    
                                                
    mfzxvdwn(uzowmabm)
    
    mjucqjto.emit(zimakryt)

func eovxkoya ():
    var fnuoenxg = gofxlmii.request(lniuisgu, pqfcxytq(), HTTPClient.METHOD_GET)

func get_conversation (gfcjtzwf : int):
    var kmjpqphb = tsrjkorb + str(gfcjtzwf)
    var jmonnjhg = oaombwkx.request(kmjpqphb, pqfcxytq(), HTTPClient.METHOD_GET)

func jfwrevby (hjqeydem : int):
    var vwvrmmac = tsrjkorb + str(hjqeydem)
    var wkgfeyjb = ryzwviax.request(vwvrmmac, pqfcxytq(), HTTPClient.METHOD_DELETE)

func rfvbxjfp (xnozomwr : int):
    var xzoyljnj = tsrjkorb + str(xnozomwr) + "/toggle-favorite"
    var evfrltjp = dhmkfwxp.request(xzoyljnj, pqfcxytq(), HTTPClient.METHOD_POST)

func yqlpixfk(ehbaxadp: int, mdvixgso: int, mdmcjovf: PackedStringArray, kgqhtfkg: PackedByteArray):
                                
    if ehbaxadp != HTTPRequest.RESULT_SUCCESS:
        yivmaisp.emit(false, "Network error (Code: " + str(ehbaxadp) + ")")
        return
        
    var aouzjlwd = obimremq(kgqhtfkg)
    if not aouzjlwd is Dictionary:
        yivmaisp.emit(false, "Response error (Code: " + str(mdvixgso) + ")")
        return
        
    var kcvfvewa = aouzjlwd.get("success", false)
    var etbnpabr = aouzjlwd.get("error", "Response code: " + str(mdvixgso))
    
    yivmaisp.emit(kcvfvewa, etbnpabr)

                                                     
func gxlhwyhs(skndgnaw, pvtappgn, puisouje, ibqetinh):
    
    if skndgnaw != HTTPRequest.RESULT_SUCCESS:
        sfrwatqp.emit("Network error (Code: " + str(skndgnaw) + ")")
        return
        
    var wwfffsam = obimremq(ibqetinh)
    if not wwfffsam is Dictionary:
        sfrwatqp.emit("Response error (Code: " + str(pvtappgn) + ")")
        return
    
    if pvtappgn == 201:
        var lvejdbfg = wwfffsam.get("content", "")
        var qwvpswwa = int(wwfffsam.get("conversationId", -1))
        xpdubjyj.emit(lvejdbfg, qwvpswwa)
    else:
        sfrwatqp.emit(wwfffsam.get("error", "Response code: " + str(pvtappgn)))

                                                                    
func qljjeema(rukpsnkg, wfilwjvq, hgfhkaiy, dlbwmxph):
    if rukpsnkg != HTTPRequest.RESULT_SUCCESS:
        wnhzlvzc.emit("Network error (Code: " + str(rukpsnkg) + ")")
        return
        
    var lkunynyu = obimremq(dlbwmxph)
    
    if wfilwjvq == 200:
        fwvwuwle.emit(lkunynyu)
    else:
        if lkunynyu is Dictionary:
            wnhzlvzc.emit(lkunynyu.get("error", "Response code: " + str(wfilwjvq)))
        else:
            wnhzlvzc.emit("Response error (Code: " + str(wfilwjvq) + ")")

                                                                
func mcximdww(eacdxigf, ekuheibi, pwtkiwmy, mwnpjkci):
    if eacdxigf != HTTPRequest.RESULT_SUCCESS:
                                                              
        printerr("[GameDev Assistant] Get conversation network error (Code: " + str(eacdxigf) + ")")
        return
        
    var xfjxslju = obimremq(mwnpjkci)
    if not xfjxslju is Dictionary:
        printerr("[GameDev Assistant] Get conversation response error (Code: " + str(ekuheibi) + ")")
        return
        
    aegetfqt.emit(xfjxslju)

                                                                                         
func noshqbur(urbxrfxa, tcscvfqe, ubmolqfg, pckrkcnt):
    if urbxrfxa != HTTPRequest.RESULT_SUCCESS:
                                                                          
        printerr("[GameDev Assistant] Delete conversation network error (Code: " + str(urbxrfxa) + ")")
        return
        
    if tcscvfqe == 204:
        jaatnjss.emit()
    else:
        var nlwlbcsp = obimremq(pckrkcnt)
        var gzftywaf = "[GameDev Assistant] Response code: " + str(tcscvfqe)
        if nlwlbcsp is Dictionary:
            gzftywaf = nlwlbcsp.get("error", gzftywaf)
        dajltnan.emit(gzftywaf)

                                                                                                       
func rwjgheiu(mackojpg, kslorzuu, zwjnvwec, iupocfcv):
    if mackojpg != HTTPRequest.RESULT_SUCCESS:
                                                                      
        printerr("[GameDev Assistant] Toggle favorite network error (Code: " + str(mackojpg) + ")")
        return
        
    if kslorzuu == 200:
        qhlbczki.emit()
    else:
        var gdtmjnmy = obimremq(iupocfcv)
        var nibeogjh = "[GameDev Assistant] Response code: " + str(kslorzuu)
        if gdtmjnmy is Dictionary:
            nibeogjh = gdtmjnmy.get("error", nibeogjh)
        jolgeqmg.emit(nibeogjh)

func obimremq (dneqvnaj):
    var jzmtgebz = JSON.new()
    var gqiblqil = jzmtgebz.parse(dneqvnaj.get_string_from_utf8())
    if gqiblqil != OK:
        return null
    return jzmtgebz.get_data()

func mfzxvdwn(dydfbwcb: Dictionary) -> void:
    while frpkjprc:
        zmngtsor.poll()
        
        match zmngtsor.get_status():
            HTTPClient.STATUS_CONNECTION_ERROR:
                kgrvsdiw.emit("Connection error")
                jaizzqnv()
                return
            HTTPClient.STATUS_DISCONNECTED:
                kgrvsdiw.emit("Disconnected")
                jaizzqnv()
                return
            
            HTTPClient.STATUS_CONNECTED:
                if not qjpytkqa:
                    cwwrzwop(dydfbwcb)
                
            HTTPClient.STATUS_BODY:
                qbrjhzno()
        
        await get_tree().process_frame

func cwwrzwop(gvfgdbmo: Dictionary) -> void:
    if qjpytkqa:
        return
    qjpytkqa = true
    
    var hggwlsmh = JSON.new()
    var jobepwdc = hggwlsmh.stringify(gvfgdbmo)
    var gtlipbor = PackedStringArray([
        "Content-Type: application/json",
        "Authorization: Bearer " + egkgeqev
    ])
    
    var hdluxcph = zmngtsor.request(
        HTTPClient.METHOD_POST,
        ptoaxuka.replace(yxkkqxkn, ""),                                        
        gtlipbor,
        jobepwdc
    )
    
    if hdluxcph != OK:
        kgrvsdiw.emit("Failed to send request: " + str(hdluxcph))
        frpkjprc = false
        qjpytkqa = false

func qbrjhzno() -> void:
    while zmngtsor.get_status() == HTTPClient.STATUS_BODY:
        var kebxgvpo = zmngtsor.read_response_body_chunk()
        if kebxgvpo.size() == 0:
            break
            
        egswltab += kebxgvpo.get_string_from_utf8()
        
        whuoxyza()

func whuoxyza() -> void:
    
    var zbwnxout
    var qrzglpbl
    var nvmqusbi
    
    if zmngtsor.get_response_code() != 200:
        frpkjprc = false
        
        zbwnxout = JSON.new()
        qrzglpbl = zbwnxout.parse(egswltab)
        
        if qrzglpbl == OK:
            nvmqusbi = zbwnxout.get_data()
            if nvmqusbi.has("error"):                
                kgrvsdiw.emit(nvmqusbi["error"])
            elif nvmqusbi.has("message"):                
                kgrvsdiw.emit(nvmqusbi["message"])
            else:
                kgrvsdiw.emit("Unknown server error, please try again later")
        else: 
            kgrvsdiw.emit("Could not parse server response. Received from server: " + egswltab)
    
    var shanafxd = egswltab.split("\n\n")
    
                                                                                 
    for i in range(shanafxd.size() - 1):
        var uqqnlktj: String = shanafxd[i]
        if uqqnlktj.find("data:") != -1:
            var hedwrwku = uqqnlktj.split("\n")
            for line in hedwrwku:
                if line.begins_with("data:"):
                    var efjgnkra = line.substr(5).strip_edges()
                                                               
                    
                    zbwnxout = JSON.new()
                    qrzglpbl = zbwnxout.parse(efjgnkra)
                    
                    if qrzglpbl == OK:
                        nvmqusbi = zbwnxout.get_data()
                        
                        if nvmqusbi is Dictionary:
                            if nvmqusbi.has("error"):
                                printerr("Server error: ", nvmqusbi["error"])
                                kgrvsdiw.emit(nvmqusbi["error"])
                                jaizzqnv()
                                return
                            
                            if nvmqusbi.has("done") and nvmqusbi["done"] == true:
                                frpkjprc = false
                                                                
                                ngabjzqt.emit(
                                    int(nvmqusbi.get("conversationId", -1)),
                                    int(nvmqusbi.get("messageId", -1))
                                )
                                jaizzqnv()
                                
                            elif nvmqusbi.has("beforeActions"):
                                eeanuqxm.emit(
                                    int(nvmqusbi.get("conversationId", -1)),
                                    int(nvmqusbi.get("messageId", -1))
                                )
                                
                            elif nvmqusbi.has("content"):
                                
                                if (typeof(nvmqusbi.get("messageId")) != TYPE_INT and typeof(nvmqusbi.get("messageId")) != TYPE_FLOAT) or (typeof(nvmqusbi.get("conversationId")) != TYPE_INT and typeof(nvmqusbi.get("conversationId")) != TYPE_FLOAT):
                                    kgrvsdiw.emit("Invalid data coming from the server")
                                    jaizzqnv()
                                    return                                   
                            
                                zeqbitvq.emit(
                                    str(nvmqusbi["content"]),
                                    int(nvmqusbi.get("conversationId", -1)),
                                    int(nvmqusbi.get("messageId", -1))
                                )
                        
                                               
    egswltab = shanafxd[shanafxd.size() - 1]
    
func jaizzqnv():  
    frpkjprc = false  
    zmngtsor.close()            

                                                                  
func nwmgpvao(cvcxywbn: bool = false):
    var dohotbwf = EditorInterface.get_editor_settings()       
    var ariniejv = dohotbwf.get_setting("gamedev_assistant/version_identifier")
    
    var oqpvcwku = {
        "releaseUniqueIdentifier": ariniejv,
        "isInit": cvcxywbn
    }
    var jyjfaart = JSON.new()
    var lqwvqjcg = jyjfaart.stringify(oqpvcwku)
    var ofdhwqwi = naxdxtie.request(uhqxsamx, pqfcxytq(), HTTPClient.METHOD_POST, lqwvqjcg)

                                            
func wmaljuwq(fvvlduum, owodanng, jzhogxmc, rahanwtu):
    if fvvlduum != HTTPRequest.RESULT_SUCCESS:
        vmcxdzpr.emit("[GameDev Assistant] Network error when checking for updates (Code: " + str(fvvlduum) + ")")
        return
        
    var ixgzakek = obimremq(rahanwtu)
    if not ixgzakek is Dictionary:
        vmcxdzpr.emit("[GameDev Assistant] Response error when checking for updates (Code: " + str(owodanng) + ")")
        return
    
    if owodanng == 200:
        var prrrnfrl = ixgzakek.get("updateAvailable", false)
        var sywebemy = ixgzakek.get("latestVersion", "")
        
        izldnmgc.emit(prrrnfrl, sywebemy)
    else:
        vmcxdzpr.emit(ixgzakek.get("error", "Response code: " + str(owodanng)))

func kevulpbh(irbrchln: int, pouexvwf: bool, rhefgriz: String, zumzqngn: String, ghvwghjp: String, rbkyztry: String):
    var ejrofaoc = {
        "messageId": irbrchln,
        "success": pouexvwf,
        "action_type": rhefgriz,
        "node_type": zumzqngn,
        "subresource_type": ghvwghjp,
        "error_message": rbkyztry
    }
    aeuaasyg.append(ejrofaoc)
    xauzccyd()

                             
func xauzccyd():
    var client_status = fwqxqlfy.get_http_client_status()
                                                                                      
    if (client_status == HTTPClient.STATUS_DISCONNECTED or 
        client_status == HTTPClient.STATUS_CANT_RESOLVE or 
        client_status == HTTPClient.STATUS_CANT_CONNECT or 
        client_status == HTTPClient.STATUS_CONNECTION_ERROR or 
        client_status == HTTPClient.STATUS_TLS_HANDSHAKE_ERROR) and aeuaasyg.size() > 0:
        
        var irzrogck = aeuaasyg.pop_front()
        var qmquhmpn = JSON.new()
        var cdxwposf = qmquhmpn.stringify(irzrogck)
        var stinoisc = pqfcxytq()
        var zbodjlzu = fwqxqlfy.request(xhvabqbw, stinoisc, HTTPClient.METHOD_POST, cdxwposf)
        if zbodjlzu != OK:
            printerr("Failed to start track action request:", zbodjlzu)
            xauzccyd()                                  

func kxrgdjql(sbvzlfjf, mrpsviai, sedlnqbu, slaihxbh):
    xauzccyd()                                      
    if sbvzlfjf != HTTPRequest.RESULT_SUCCESS:
        printerr("[GameDev Assistant] Track action failed:", sbvzlfjf)
        return
        
    var sqkwdhqf = obimremq(slaihxbh)
    if not sqkwdhqf is Dictionary:
        printerr("[GameDev Assistant] Invalid track action response")

func goknswzz(fabpjavp: int, wbvhzdpv: int) -> void:
    var ijihbkjb = {
        "messageId": fabpjavp,
        "rating": wbvhzdpv
    }
    var tmbzjtdf = JSON.new()
    var olywnaal = tmbzjtdf.stringify(ijihbkjb)
    var oxcnkrtc = pqfcxytq()
    var vtndpjdf = wtedfhfv.request(crhkdnoz, oxcnkrtc, HTTPClient.METHOD_POST, olywnaal)
    if vtndpjdf != OK:
        printerr("[GameDev Assistant] Failed to track rating:", vtndpjdf)

                                          
func rhzjufxb(dwnynujg, ltypfgal, dblphthh, brmzjtfb):
    if dwnynujg != HTTPRequest.RESULT_SUCCESS:
        printerr("[GameDev Assistant] Rating action failed:", dwnynujg)
        return
        
    var amnflkvb = obimremq(brmzjtfb)
    if not amnflkvb is Dictionary:
        printerr("[GameDev Assistant] Invalid rating response")
        return

func lzgpswvj():
    return frpkjprc
func emgmyucb(ucdkmpsx: Object) -> void:
    print("=== Methods ===")
    for method in ucdkmpsx.get_method_list():
        print(method["name"])
    
    print("\n=== Properties ===")
    for property in ucdkmpsx.get_property_list():
        print(property["name"])
    
    print("\n=== Signals ===")
    for signal_info in ucdkmpsx.get_signal_list():
        print(signal_info["name"])
        
func fzcguaqa(vtkupxyl: String, xlbstkhl: int, mcmvkytw: String, dlikflwj: Button) -> void:
                                         
    sigyzexh = dlikflwj
    
                                                                  
    var wwybkhhf = $"../ActionManager"
    wwybkhhf.cdsrnkbh.emit("edit_script", true)
    dlikflwj.text = "⌛Editing file %s" % vtkupxyl

    var gxwjxvpt = {
        "path": vtkupxyl,
        "message_id": xlbstkhl,
        "content": mcmvkytw
    }
    
    var vohnwkyl = JSON.new()
    var xdeuoixf = vohnwkyl.stringify(gxwjxvpt)
    var ssylfshx = pqfcxytq()
                                                     
    
    var vzxlexga = yxkkqxkn + "/editScript"
    var yygtrzit = slvjswyr.request(vzxlexga, ssylfshx, HTTPClient.METHOD_POST, xdeuoixf)
    
    if yygtrzit != OK:
        var fersapdc = "Failed to start edit_script request: " + str(yygtrzit)
        push_error(fersapdc)
                                   
                                                      
        wwybkhhf.axiebdny.emit("edit_script", false,fersapdc, "", "", dlikflwj)
        
func frofezja(cqgswour: int, sqiwofrg: int, orrfemqn: PackedStringArray, xykdscgz: PackedByteArray) -> void:
    var ofdgjcvh = $"../ActionManager"
    var vljxzoer = sigyzexh

                                                                
    if cqgswour != HTTPRequest.RESULT_SUCCESS:
        var ngddhxhh = "EditScript network request failed. Code: " + str(cqgswour)
        push_error(ngddhxhh)
        ofdgjcvh.axiebdny.emit("edit_script", false, ngddhxhh, "", "", vljxzoer)
        return

                                                      
    var hdbowgaw = obimremq(xykdscgz)
    if not hdbowgaw is Dictionary:
        var ngddhxhh = "Invalid response from server (not valid JSON)."
        push_error(ngddhxhh)
        ofdgjcvh.axiebdny.emit("edit_script", false, ngddhxhh, "", "", vljxzoer)
        return

                                                         
    if hdbowgaw.has("error"):
        var ngddhxhh = "Server returned an error: " + str(hdbowgaw["error"])
        push_error(ngddhxhh)
        ofdgjcvh.axiebdny.emit("edit_script", false, ngddhxhh, "", "", vljxzoer)
        return

    var ggqwrmkx = hdbowgaw.get("path", "")
    var fsgrvflj = hdbowgaw.get("content", "")

                                                  
    if ggqwrmkx.is_empty():
        var ngddhxhh = "Incomplete data in EditScript response (path or content missing)."
        push_error(ngddhxhh)
        ofdgjcvh.axiebdny.emit("edit_script", false, ngddhxhh, "", "", vljxzoer)
        return

                                                         
    var vhyhdydj = FileAccess.open(ggqwrmkx, FileAccess.WRITE)
    if vhyhdydj:
        vhyhdydj.store_string(fsgrvflj)
        vhyhdydj.close()

                                                        
        var scduufcz = ResourceLoader.load(ggqwrmkx, "Script", ResourceLoader.CACHE_MODE_IGNORE)
        await get_tree().process_frame
        
                                                                          
                                                                                 
        var gigonchr = vljxzoer.get_meta("action")
        vljxzoer.text = "Edit {path}".format({"path": gigonchr.path})

        var fwawjemp = Engine.get_singleton("EditorInterface")
        var alyelguh = fwawjemp.get_script_editor()
        
                                                                                  
        var xurbbxeg = false
        for open_script in alyelguh.get_open_scripts():
            if open_script.resource_path == ggqwrmkx:
                xurbbxeg = true
                break
        
                                                                                 
        fwawjemp.edit_script(scduufcz)
        await get_tree().process_frame                                   
        
                                                                   
                                                                
        var xehhmrah = alyelguh.get_current_script()
        if xehhmrah and xehhmrah.resource_path == ggqwrmkx:
            alyelguh.get_current_editor().get_base_editor().set_text(fsgrvflj)
            if xurbbxeg:
                push_warning("[GameDev Assistant] File updated: " + ggqwrmkx + " (due to a Godot API limitation, it will appear as unsaved, but it has been saved to disk!)")
            else:
                print("[GameDev Assistant] File updated: " + ggqwrmkx)
        else:
                                                                             
            push_error("[GameDev Assistant] Could not update the editor view for " + ggqwrmkx + ", but the file has been saved to disk.")

        fwawjemp.get_resource_filesystem().scan()
        
        await get_tree().process_frame
        fwawjemp.edit_script(scduufcz)                           

                                 
        ofdgjcvh.axiebdny.emit("edit_script", true, "", "", "", vljxzoer)
    else:
                                                         
        var xwjhlopw = FileAccess.get_open_error()
        var ngddhxhh = "Failed to write to script '%s'. Error: %s" % [ggqwrmkx, error_string(xwjhlopw)]
        push_error("[GameDev Assistant] " + ngddhxhh)
        ofdgjcvh.axiebdny.emit("edit_script", false, ngddhxhh, "", "", vljxzoer)
