#<NodeCreator>  # is somewhere weird?
#An expected bug found: rightClick(create)+fastMovement overlaps already placed node!!
#part of doc of get_overlapping_bodies() (this list is modified once during the physics step, not immediately after objects are moved. Consider using signals instead.
#and signals doesn't look like a right solution.
#How to get overlapping object immediately? in other words, how to get an object by its translation?
#If I make this program with godot engineer!

extends Node
class_name NodeCreator

export (NodePath) var session_path = G.default_session_path
export (String) var pointPositionIndicatorResource = "res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
var pointPositionIndicator
var pointPosition : Vector3
var prevPointPosition : Vector3

var leftClickCheckInterval : float = 5  # because of the issue described above. but this doesn't seem right to solve it.
var leftClickCheckTick : float

var distance : float = 2

var hotbar : Array = [G.ID.N_LeakyReLU, G.ID.N_Input, G.ID.N_Goal, G.ID.N_Tanh, G.ID.N_NetworkController]
var hotbarSelection : int

func create():
	if len(pointPositionIndicator.get_overlapping_bodies()) == 0:
		var body = load("res://Nodes/" + G.IDtoString[hotbar[hotbarSelection]] + "/" + G.IDtoString[hotbar[hotbarSelection]] + ".tscn").instance()
		body.translation = pointPosition
		G.default_session.add_child(body)
		print("create ", body)
func delete():
	for body in pointPositionIndicator.get_overlapping_bodies():
		if body.Type == G.ID.N_Synapse:
			continue
		print("delete ", body)
		body.queue_free()

func update(translation : Vector3, aim : Basis, delta : float):
	leftClickCheckTick += 1
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		delete()
	elif Input.is_mouse_button_pressed(BUTTON_LEFT):
		if leftClickCheckTick >= leftClickCheckInterval:
			leftClickCheckTick = 0
			create() 

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
	pointPositionIndicator = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()
	pointPositionIndicator.translation = pointPosition
	prevPointPosition = pointPositionIndicator.translation
	add_child(pointPositionIndicator)

func deactivate():
	pointPositionIndicator.queue_free()
