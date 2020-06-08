extends Node
class_name NodeCreator

const ID : int = G.ID.NC

onready var pointer = get_node("../Pointer")

var hotbar : Array = [G.ID.N_LeakyReLU, G.ID.N_Input, G.ID.N_Goal, G.ID.N_Tanh, G.ID.N_NetworkController]
var hotbarSelection : int

func create():
	var pointerPosition = pointer.getPointerPosition()
	if pointerPosition != null:
		var obj = G.default_session.getNode(pointerPosition)
		if obj == null:
			var body = load("res://Nodes/" + G.IDtoString[hotbar[hotbarSelection]] + "/" + G.IDtoString[hotbar[hotbarSelection]] + ".tscn").instance()
			body.translation = pointer.pointerPosition
			G.default_session.addNode(body)
			print("create ", body)

func erase():
	var pointerPosition = pointer.getPointerPosition()
	if pointerPosition != null:
		var obj = G.default_session.getNode(pointerPosition)
		if obj != null:
			G.default_session.eraseNode(obj)
			print("erase ", obj)
