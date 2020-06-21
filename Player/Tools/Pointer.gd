extends Node
class_name Pointer

const ID : String = "Pointer"

export (String) var pointerResource = "res://Components/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
onready var rayCast = get_node("../../Yaxis/Camera/RayCast")
var rayCastDetectedObject : Object
var pointer
var prevPointerPosition : Vector3
var pointerPosition : Vector3 setget ,getPointerPosition
var distance : float = 2 setget setDistance
enum mode {
	pointer, rayCast,
}
var selectedMode : int = mode.pointer

func getPointerPosition():
	if selectedMode == mode.pointer:
		return pointerPosition
	else:
		if rayCastDetectedObject != null:
			return rayCastDetectedObject.translation
		else:
			return null
func setDistance(dist):
	if selectedMode == mode.pointer:
		distance = dist

func switchMode(translation, aim : Basis):
	if selectedMode == mode.pointer:
		selectedMode = mode.rayCast
		deactivatePointer()
		$rayCastPointer.show()
	else:
		selectedMode = mode.pointer
		activatePointer(translation, aim)
		$rayCastPointer.hide()

func update(translation : Vector3, aim : Basis, delta : float):
	if selectedMode == mode.pointer:
		pointerPosition = translation
		pointerPosition -= aim.z * distance
	
		pointerPosition = pointerPosition.round()
		if prevPointerPosition != pointerPosition:
			prevPointerPosition = pointerPosition
			pointer.translation = pointerPosition
		return G.default_world.getNode(pointerPosition)
	else:
		rayCastDetectedObject = rayCast.get_collider()
		return rayCastDetectedObject
	return null

func activatePointer(translation, aim : Basis):
	var pointerPosition = translation
	pointerPosition -= aim.z*distance
	pointerPosition = pointerPosition.round()
	pointer = load("res://Components/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()
	pointer.translation = pointerPosition
	prevPointerPosition = pointer.translation
	add_child(pointer)

func deactivatePointer():
	pointer.queue_free()
