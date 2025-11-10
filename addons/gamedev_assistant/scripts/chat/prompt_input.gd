														
@tool                                                                                         
extends TextEdit                                                                              
																								
signal gcivoxej    

const fipgdgke = 50000                                                                    
																								
var zrbvthtx : bool = false                                                              
var izdycvys : Control                                                                          
						 
																					
func _ready():                                                                                
																							  
	izdycvys = get_parent()       
	
					   
	tooltip_text = "Type your message here (Enter to send, Shift+Enter for new line)\nTo include scripts you need to either paste the code here, use @OpenScripts,\n or select the code in the editor + right click for contextual menu \"Add to Chat\"\nThe file tree and open scene nodes are automatically included"
																								
																							  
	connect("focus_entered", Callable(self, "mahcqohp"))                
	connect("text_changed", Callable(self, "mzzkhvux")) 
	connect("focus_exited", Callable(self, "gmfbsnvh"))            
	
	var lgabxbpa = get_parent().get_parent()                                                    
	if lgabxbpa.has_signal("hmflmgwe"):  
		lgabxbpa.connect("hmflmgwe", Callable(self, "ulzybahd"))  
				
																								
func _input(eiyvfmfh):
	if has_focus():
		if eiyvfmfh is InputEventKey and eiyvfmfh.is_pressed():
			if eiyvfmfh.keycode == KEY_ENTER:
				if eiyvfmfh.shift_pressed:
					insert_text_at_caret("\n")
																
					znaxllwb(1)
					get_viewport().set_input_as_handled()
				else:                                                                         
																			 
					var suchqonc = get_parent().get_node("SendPromptButton")  
					if suchqonc and suchqonc.disabled == false:  
						gcivoxej.emit()                                                       
						get_viewport().set_input_as_handled()
						ulzybahd()    

func znaxllwb(wyvumzba: int = 0):
	var yrhffobd = get_theme_font("font")
	var bjxeqmps = get_theme_font_size("font_size")
	var awuaxewf = yrhffobd.get_char_size('W'.unicode_at(0), bjxeqmps).x * 0.6
	var skdyszld = int(size.x / awuaxewf)
	var ktipvoqy = yrhffobd.get_height(bjxeqmps) + 10
	var fofunnkd = ktipvoqy * 10        
	var zorprehw = ktipvoqy*2
	var mhdnixok = -zorprehw*2
	
	var fcrnatzs = 0
	for i in get_line_count():
		var sbatwirb = get_line(i)
		var gcdqkcwj = sbatwirb.length()
		var lqsgehkz = ceili(float(gcdqkcwj) / float(skdyszld))
		fcrnatzs += max(lqsgehkz, 1)                         
		
											 
	fcrnatzs += wyvumzba
	
	var llzvnxsy = fcrnatzs * ktipvoqy + zorprehw
	llzvnxsy = clamp(llzvnxsy, zorprehw, fofunnkd)
	izdycvys.offset_top = -llzvnxsy


func oinanidi():
	znaxllwb()                                                                        
																								
func mahcqohp():                                                        
	oinanidi()                                                                     
																								
func mzzkhvux():                                                         
	oinanidi()
	
																					 
	if text.length() > fipgdgke:                                               
		text = text.substr(0, fipgdgke)                                        
		set_caret_column(fipgdgke)                                                                                                        
																								
func ulzybahd():                                                                    
	oinanidi()

func gmfbsnvh(): 
	if text.length() == 0:                                                        
		ulzybahd()
