extends Node
class_name BoxConnector

const ID : String = "BoxConnector"

var areas = [[], []]  # A[beginPoint, endPoint], B[begin, end]

onready var AreaIndicator = preload("res://Components/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn")
var areaIndicators = [null, null]

func handle(arg : String) -> String:  # [AorB, pointPosition]
	var output : String
	var argParser = ArgParser.new(arg)
	if argParser.getBool(["reset", "r"]):
		reset()
		return "reset done.\n"
	
	var splitted = arg.split(" ", false, 1)
	# AorB
	var AorB
	if splitted[0] == "A":
		AorB = 0
	elif splitted[0] == "B":
		AorB = 1
	elif splitted[0] == "initiate":
		return initiate()
	else:
		return "Invalid argument"
	
	var aORb = "A" if AorB == 0 else "B"
	
	# pointPosition
	var pointPosition = G.str2vector3(splitted[1])
	if pointPosition == null:
		return "Invalid argument"
	
	if areas[AorB].size() == 0:
		output += str(aORb+" area begin point:", pointPosition)
		areas[AorB].push_back(pointPosition)
	elif areas[AorB].size() == 1:
		output += str(aORb+" area end point:", pointPosition)
		areas[AorB].push_back(pointPosition)
		areaIndicators[AorB] = AreaIndicator.instance()
		var xScale = abs(areas[AorB][0].x - areas[AorB][1].x) + 1
		var yScale = abs(areas[AorB][0].y - areas[AorB][1].y) + 1
		var zScale = abs(areas[AorB][0].z - areas[AorB][1].z) + 1
		areaIndicators[AorB].resize(Vector3(xScale, yScale, zScale))
		areaIndicators[AorB].translation = (areas[AorB][0] + areas[AorB][1]) / 2
		add_child(areaIndicators[AorB])
	else:
		output += str(aORb+" area already selected.")
	
	return output

func initiate() -> String:
	var output : String
	var Aselected = true
	var Bselected = true
	if areas[0].size() != 2:
		print("A area isn't selected")
		Aselected = false
	else:
		print("A area: ", areas[0][0], " to ", areas[0][1])
	if areas[1].size() != 2:
		print("B area isn't selected")
		Bselected = false
	else:
		print("B area: ", areas[1][0], " to ", areas[1][1])
		
	if not Aselected or not Bselected:
		return "not selected"
	
	var Anodes = G.default_world.boxGetNode(areas[0][0], areas[0][1])
	var Bnodes = G.default_world.boxGetNode(areas[1][0], areas[1][1])
	
	var linkCreator = get_parent().get_node("LinkCreator")
	
	for Anode in Anodes:
		for Bnode in Bnodes:
			linkCreator.handle("-l L_SCWeight -hotbarLinkSelection -data "+str(Anode.translation).replace(" ","")+ " "+str(Bnode.translation).replace(" ",""))
#			var newSynapse = linkCreator.create(Anode, Bnode)
#			if newSynapse != null:
#					G.default_world.addLink(newSynapse)
	
	reset()
	
	print(output)
	return "done"

func reset():
	areas = [[], []]
#	if areaIndicators[0] != null:
	if is_instance_valid(areaIndicators[0]):
		areaIndicators[0].queue_free()
#	if areaIndicators[1] != null:
#		areaIndicators[1].queue_free()
	if is_instance_valid(areaIndicators[1]):
		areaIndicators[1].queue_free()
