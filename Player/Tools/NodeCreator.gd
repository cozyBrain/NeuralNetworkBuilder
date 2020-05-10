# <todo>
# change appearence of pointPositionIndicator when it overlaps with some node.

extends Node
class_name NodeCreator

export (NodePath) var session_path = G.default_session_path
export (String) var pointPositionIndicatorResource = "res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
var pointPositionIndicator
var pointPosition : Vector3
var prevPointPosition : Vector3 = Vector3(0.001, 0.002, 0.003)

var leftClickCheckInterval : float = 2  # this should be >1 to prevent adding multiple object at one click. but I'm not sure that this way is right to solve the problem.
var leftClickCheckTick : float

var distance : float = 2

var hotbar : Array = [G.N_Types.N_LeakyReLU, G.N_Types.N_Input, G.N_Types.N_Goal, G.N_Types.N_Tanh, G.N_Types.N_NetworkController]
var hotbarSelection : int

func add():
	if len(pointPositionIndicator.get_overlapping_bodies()) == 0:
		var body = load("res://Nodes/" + G.N_TypeToString[hotbar[hotbarSelection]] + "/" + G.N_TypeToString[hotbar[hotbarSelection]] + ".tscn").instance()
		body.translation = pointPosition
		G.default_session.add_child(body)
		print("add ", body)
func remove():
	for body in pointPositionIndicator.get_overlapping_bodies():
		if body.Type == G.N_Types.N_Synapse:
			continue
		print("remove ", body)
		body.queue_free()

func update(translation : Vector3, aim : Basis, delta : float):
	leftClickCheckTick += 1
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		remove()
	elif Input.is_mouse_button_pressed(BUTTON_LEFT):
		if leftClickCheckTick >= leftClickCheckInterval:
			leftClickCheckTick = 0
			add() 

	pointPosition = translation
	pointPosition -= aim.z * distance

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
