extends Node
class_name NodeCreator

export (NodePath) var session_path = G.default_session_path
export (String) var pointPositionIndicatorResource = "res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
var pointPositionIndicator
var pointPosition

var prevPointPosition : Vector3 = Vector3(0.001, 0.002, 0.003)
var distance : float = 2

func add():
	if len(pointPositionIndicator.get_overlapping_bodies()) == 0:
		var t = load("res://Nodes/N_LeakyReLU/N_LeakyReLU.tscn").instance()
		t.translation = pointPosition
		add_child(t)
func remove():
	for body in pointPositionIndicator.get_overlapping_bodies():
		if body.Type == G.N_Types.N_Synapse:
			continue
		print("remove ", body)
		body.queue_free()

func update(translation, aim : Basis):
	pointPosition = translation
	pointPosition -= aim.z*distance

	pointPosition = pointPosition.round()
	if prevPointPosition != pointPosition:
		prevPointPosition = pointPosition
		pointPositionIndicator.translation = pointPosition

func activate(translation, aim : Basis):
	var pointPosition = translation
	pointPosition -= aim.z*distance

	#pointPosition = pointPosition.round()
	if prevPointPosition != pointPosition:
		prevPointPosition = pointPosition
		pointPositionIndicator = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()
		pointPositionIndicator.translation = pointPosition
	add_child(pointPositionIndicator)

func deactivate():
	pointPositionIndicator.queue_free()
