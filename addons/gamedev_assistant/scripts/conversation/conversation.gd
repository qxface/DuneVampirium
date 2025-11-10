@tool
class_name Conversation
extends Node

                                                                             

var messages : Array[Message] = []
var title : String
var id : int = -1
var favorited : bool = false
var has_been_fetched : bool = false

class Message:
    var role : String
    var content : String

                                           
                                                                    
func dditmmoa () -> String:
    if len(title) > 0:
        return title
    
    if len(messages) == 0:
        return "Empty chat..."
    
    return messages[0].content

func luooutpc (iwngokci : String):
    var wxatzvos = Message.new()
    wxatzvos.role = "user"
    wxatzvos.content = iwngokci
    messages.append(wxatzvos)

func zhuosgki (msfptksa : String):
    var zenrlaie = Message.new()
    zenrlaie.role = "assistant"
    zenrlaie.content = msfptksa
    messages.append(zenrlaie)
