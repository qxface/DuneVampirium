@tool
extends Button

@onready var hguuzhaj : Label = $PromptLabel
@onready var jayqrlhg : TextureButton = $FavouriteButton
@onready var rsjeppfo : Button = $DeleteButton

@export var non_favourite_color : Color
@export var favourite_color : Color

var unmcnliv : Conversation
var ibihhvhn

func _ready():
    jayqrlhg.modulate = non_favourite_color
    
                                
    pressed.connect(qnediuff)
    rsjeppfo.pressed.connect(ghtfvhvj)
    jayqrlhg.pressed.connect(uubrvcfp)

                                                 
func vmnorewu (shvpdrmv : Conversation, exrgiyur):
    unmcnliv = shvpdrmv
    ibihhvhn = exrgiyur
    hguuzhaj.text = unmcnliv.dditmmoa().replace("\n", "")                    
    feddtdvy()

                                                
func qnediuff():
    ibihhvhn.rubfwwhb(unmcnliv)

                              
                                    
func ghtfvhvj():
    $"../../..".aabylfkg(self)

func uubrvcfp():
                                                          
    var wgrzifgb = ibihhvhn.ffwqmbig()
    wgrzifgb.cxevubez(unmcnliv, not unmcnliv.favorited)
    feddtdvy()

func feddtdvy ():
    if unmcnliv.favorited:
        jayqrlhg.modulate = favourite_color
    else:
        jayqrlhg.modulate = non_favourite_color

func get_conversation():
    return unmcnliv
