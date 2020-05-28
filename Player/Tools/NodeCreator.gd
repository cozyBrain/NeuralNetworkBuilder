extends Node
class_name NodeCreator

const ID : int = G.ID.NC

export (NodePath) var session_path = G.default_session_path
export (String) var pointerResource = "res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
var pointer
var pointerPosition : Vector3
var prevPointerPosition : Vector3

var distance : float = 2

var hotbar : Array = [G.ID.N_LeakyReLU, G.ID.N_Input, G.ID.N_Goal, G.ID.N_Tanh, G.ID.N_NetworkController]
var hotbarSelection : int

func create():
#	if len(pointPositionIndicator.get_overlapping_bodies()) == 0:
#		var body = load("res://Nodes/" + G.IDtoString[hotbar[hotbarSelection]] + "/" + G.IDtoString[hotbar[hotbarSelection]] + ".tscn").instance()
#		body.translation = pointPosition
#		G.default_session.add_child(body)
#		print("create ", body)
	var obj = G.default_session.getNode(pointerPosition)
	if obj == null:
		var body = load("res://Nodes/" + G.IDtoString[hotbar[hotbarSelection]] + "/" + G.IDtoString[hotbar[hotbarSelection]] + ".tscn").instance()
		body.translation = pointerPosition
		G.default_session.addNode(body)
		print("create ", body)

func erase():
#	for body in pointPositionIndicator.get_overlapping_bodies():
#		if body.Type == G.ID.N_Synapse:
#			continue
#		print("delete ", body)
#		body.queue_free()
	var obj = G.default_session.getNode(pointerPosition)
	if obj != null:
		G.default_session.eraseNode(obj)
		print("erase ", obj)

func update(translation : Vector3, aim : Basis, delta : float):
	pointerPosition = translation
	pointerPosition -= aim.z * distance

	pointerPosition = pointerPosition.round()
	if prevPointerPosition != pointerPosition:
		prevPointerPosition = pointerPosition
		pointer.translation = pointerPosition


func activate(translation, aim : Basis):
	var pointerPosition = translation
	pointerPosition -= aim.z*distance
	pointerPosition = pointerPosition.round()
	pointer = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()
	pointer.translation = pointerPosition
	prevPointerPosition = pointer.translation
	add_child(pointer)

func deactivate():
	pointer.queue_free()
