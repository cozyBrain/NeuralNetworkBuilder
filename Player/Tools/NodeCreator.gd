extends Node
class_name NodeCreator

export (NodePath) var session_path = G.default_session_path
export (String) var pointPositionIndicatorResource = "res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
var pointPositionIndicator

var prevPointPosition : Vector3 = Vector3(0.001, 0.002, 0.003)
var distance : float = 2

func use1(rayCastDetectedObject : Object):
	pass
func update(translation, aim : Basis):
	var pointPosition = translation
	pointPosition -= aim.z*distance

	pointPosition = pointPosition.round()
	if prevPointPosition != pointPosition:
		prevPointPosition = pointPosition
		pointPositionIndicator.translation = pointPosition

func activate(translation, aim : Basis):
	var pointPosition = translation
	pointPosition -= aim.z*distance

	pointPosition = pointPosition.round()
	if prevPointPosition != pointPosition:
		prevPointPosition = pointPosition
		pointPositionIndicator = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()
		pointPositionIndicator.translation = pointPosition
	add_child(pointPositionIndicator)

func deactivate():
	pointPositionIndicator.queue_free()
