@tool
extends GDAScreenBase

@onready var rnhfewnz : ConfirmationDialog = $DeleteConfirmation
@onready var ypbjyizo = $ScrollContainer/VBoxContainer
@onready var jfozirkv = $"../ConversationManager"

@onready var njtjivbu = $ScrollContainer/VBoxContainer/ErrorMessage
@onready var eemlfwws = $ScrollContainer/VBoxContainer/ProcessMessage
@onready var xkqbpqpm = $ScrollContainer/VBoxContainer/AllConversationsHeader
@onready var nwmhjlcq = $ScrollContainer/VBoxContainer/FavouritesHeader

var sxyndrda = preload("res://addons/gamedev_assistant/dock/scenes/ConversationSlot.tscn")

var awzoptrd
@onready var vnwcbjyh = $".."

@onready var ccnydxak = $"../APIManager"

var csssjipk : bool = false

func _ready ():
    jfozirkv.utgflqdv.connect(nolycewj)
    ccnydxak.wnhzlvzc.connect(htlkqjhl)
    ccnydxak.jaatnjss.connect(_on_delete_conversation_received)
    ccnydxak.dajltnan.connect(htlkqjhl)
    ccnydxak.jolgeqmg.connect(htlkqjhl)
    ccnydxak.qhlbczki.connect(_on_toggle_favorite_received)
    rnhfewnz.confirmed.connect(sqgfiavt)
    
func _on_open ():
    lcktuhnm()
    ccnydxak.eovxkoya()
    
                               
    
                                      
                                         
                                     

func lcktuhnm ():
    for node in ypbjyizo.get_children():
        if node is RichTextLabel:
            continue
        
        node.queue_free()
    
    njtjivbu.visible = false
    eemlfwws.visible = false

func nolycewj ():
    lcktuhnm()
    
    var wijuumev = jfozirkv.pzmtslvl()
    
    var iugjoigl : Array[Conversation] = []
    var arsflngi : Array[Conversation] = []
    
    for conv in wijuumev:
        if conv.favorited:
            iugjoigl.append(conv)
        else:
            arsflngi.append(conv)
    
    var fnxgbauc = 2
    ypbjyizo.move_child(nwmhjlcq, 1)
    
    for fav in iugjoigl:
        var xulpvehd = cdizrchp(fav, vnwcbjyh)
        ypbjyizo.move_child(xulpvehd, fnxgbauc)
        fnxgbauc += 1
    
    ypbjyizo.move_child(xkqbpqpm, fnxgbauc)
    fnxgbauc += 1
    
    for other in arsflngi:
        var xulpvehd = cdizrchp(other, vnwcbjyh)
        ypbjyizo.move_child(xulpvehd, fnxgbauc)
        fnxgbauc += 1

func cdizrchp (jfbhqvmp, gxcbowvk) -> Control:
    var gibnewzj = sxyndrda.instantiate()
    ypbjyizo.add_child(gibnewzj)
    gibnewzj.vmnorewu(jfbhqvmp, gxcbowvk)
    return gibnewzj

                                            
                                        
func aabylfkg (aifhmwht):
    awzoptrd = aifhmwht
    rnhfewnz.popup()

                                                        
func sqgfiavt():
    if awzoptrd == null or awzoptrd.get_conversation() == null:
        return
    
    var vabkwibq = awzoptrd.get_conversation()
    ccnydxak.jfwrevby(vabkwibq.id)
    
    izkkdhjn("Deleting conversation...")

func _on_toggle_favorite_received ():
    ccnydxak.eovxkoya()

func _on_delete_conversation_received ():
    ccnydxak.eovxkoya()

func izkkdhjn (fwvwmwij : String):
    return
    
    ypbjyizo.move_child(eemlfwws, 1)
    njtjivbu.visible = false
    eemlfwws.visible = true
    eemlfwws.text = fwvwmwij

func htlkqjhl (ymfppdvu : String):
    ypbjyizo.move_child(njtjivbu, 0)
    eemlfwws.visible = false
    njtjivbu.visible = true
    njtjivbu.text = ymfppdvu
