@tool
extends Node

                                        
                             
                               

signal uyaqprfw (conversation : Conversation)

                                                                    
signal utgflqdv
signal hgyhkthb

var itxkkpui : Array[Conversation]
var iohizbqm : Conversation

@onready var irdtojte = $"../APIManager"
@onready var dtjttbkm = $".."
@onready var jnjtzvbd = $"../Screen_Conversations"

func _ready ():
    irdtojte.mjucqjto.connect(pmyzsdue)
    irdtojte.xpdubjyj.connect(_on_send_message_received)
    
    irdtojte.fwvwuwle.connect(dwphheqp)
    irdtojte.aegetfqt.connect(tcxueqxh)

func fzbbjphk () -> Conversation:
    nnyutcvt()                                            

    var xabnqxyb = Conversation.new()
    xabnqxyb.id = -1                                       
    itxkkpui.append(xabnqxyb)
    iohizbqm = xabnqxyb
    return xabnqxyb

func nnyutcvt ():
    if iohizbqm != null:
        if iohizbqm.id == -1:                                    
            itxkkpui.erase(iohizbqm)
    
    iohizbqm = null

func psxfxker (igzuznfo : Conversation):
    iohizbqm = igzuznfo
    hgyhkthb.emit()

                                                                    
                                                                              
func dwphheqp (lsattnqy):
    itxkkpui.clear()
    
    for conv_data in lsattnqy:
        var uquhbhfm = Conversation.new()
        uquhbhfm.id = int(conv_data["id"])
        uquhbhfm.title = conv_data["title"]
        uquhbhfm.favorited = conv_data["isFavorite"]
        itxkkpui.append(uquhbhfm)
    
    utgflqdv.emit()

                                   
func pmyzsdue(xbaxxurt: String):
    if iohizbqm == null:
                                           
        fzbbjphk()
    
                                                     
                                                    
                           
       
    iohizbqm.luooutpc(xbaxxurt)

func _on_send_message_received(fdsdobpj: String, gcbryacx: int):
    print("Received assistant message: ", {
        "conversation_id": gcbryacx,
        "current_conv_id": iohizbqm.id if iohizbqm else "none",
        "content": fdsdobpj
    })
    if iohizbqm:
        if iohizbqm.id == -1:
                                                                    
            iohizbqm.id = gcbryacx
        iohizbqm.zhuosgki(fdsdobpj)

                                                                                      
                                                                     
func ytvlehxr (zyhretii : int):
    irdtojte.get_conversation(zyhretii)

                                                            
                                                 
func tcxueqxh (pheaqita):
    var txgeoprb : Conversation
    var qzukkusq = pheaqita["id"]
    qzukkusq = int(qzukkusq)
    
                                                
    for c in itxkkpui:
        if c.id == qzukkusq:
            txgeoprb = c
            break
    
                                              
    if txgeoprb == null:
        txgeoprb = Conversation.new()
        txgeoprb.id = qzukkusq
        txgeoprb.title = pheaqita["title"]
        itxkkpui.append(txgeoprb)
    
    txgeoprb.messages.clear()
    
                                                    
    for message in pheaqita["messages"]:
        if message["role"] == "user":
            txgeoprb.luooutpc(message["content"])
        elif message["role"] == "assistant":
            txgeoprb.zhuosgki(message["content"])
    
    txgeoprb.has_been_fetched = true
    psxfxker(txgeoprb)

func cxevubez (ulsvtiqu : Conversation, enyllexg : bool):
    irdtojte.rfvbxjfp(ulsvtiqu.id)
    
    if enyllexg:
        jnjtzvbd.izkkdhjn("Adding favorite...")
    else:
        jnjtzvbd.izkkdhjn("Removing favorite...")

func pzmtslvl():
    return itxkkpui
    
func srlihurr():
    return iohizbqm
    
func uhclkmsr(ifmjftcj: int):
    iohizbqm.id = ifmjftcj
