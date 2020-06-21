extends Node
class_name NodeCreator

const ID : String = "NodeCreator"

onready var pointer = get_node("../Pointer")

var hotbar : Array = ["N_LeakyReLU", "N_Input", "N_Goal", "N_Tanh", "N_NetworkController"]
var hotbarSelection : int

func create():
	var pointerPosition = pointer.getPointerPosition()
	if pointerPosition != null:
		var obj = G.default_world.getNode(pointerPosition)
		if obj == null:
			var body = load("res://Components/" + hotbar[hotbarSelection] + "/" + hotbar[hotbarSelection] + ".tscn").instance()
			body.translation = pointer.pointerPosition
			G.default_world.addNode(body)
			print("create ", body)

func erase():
	var pointerPosition = pointer.getPointerPosition()
	if pointerPosition != null:
		var obj = G.default_world.getNode(pointerPosition)
		if obj != null:
			G.default_world.eraseNode(obj)
			print("erase ", obj)
