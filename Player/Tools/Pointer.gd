extends Node
class_name Pointer

#const ID : int = G.ID.NC

export (String) var pointerResource = "res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
var pointer
var pointerPosition : Vector3
var prevPointerPosition : Vector3

enum mode {
	pointer, rayCast,
}
var selectedMode : int = mode.pointer

var distance : float = 2

func update(translation : Vector3, aim : Basis, delta : float):
	if selectedMode == mode.pointer:
		pointerPosition = translation
		pointerPosition -= aim.z * distance
	
		pointerPosition = pointerPosition.round()
		if prevPointerPosition != pointerPosition:
			prevPointerPosition = pointerPosition
			pointer.translation = pointerPosition
		return G.default_session.getNode(pointerPosition)
	else:
		return get_parent().get_parent().get_node("Yaxis/Camera/RayCast").get_collider()
		
	return null


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
