                                                       
@tool
extends CodeEdit

@onready var xywfediv: Button = $CopyButton

func _ready():
    xywfediv.connect("pressed",bfzgbesh)

func bfzgbesh():
    var vmpeizne = text
    if vmpeizne:
        DisplayServer.clipboard_set(vmpeizne)
