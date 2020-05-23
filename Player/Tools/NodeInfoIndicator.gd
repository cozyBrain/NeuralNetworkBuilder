extends Spatial
class_name NodeInfoIndicator

export (NodePath) var session_path = G.default_session_path
var overlappingBodyDetector = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()

func handle(position) -> String:
	position = position.split_floats(",", false)
	if position.size() != 3:
		return "Invalid argument"
	position = Vector3(position[0], position[1], position[2])
	overlappingBodyDetector.translation = position
	add_child(overlappingBodyDetector)
	overlappingBodyDetector._physics_process(0)
	var obj = overlappingBodyDetector.get_overlapping_bodies()
	print(obj)
	obj = obj[0]

	var output : String = ""
	if null == obj:
		output += str(self.name, ": No Object Detected.\n")
	else:
		output += str(self.name,": < ", obj, "  ", obj.translation, " >\n")
		if not obj.has_method("getInfo"):
			output += str(self.name, ": could not get info as the object doesn't have method getInfo()\n")
		else:
			var infoDict = obj.getInfo()
			for key in infoDict:
				if typeof(infoDict[key]) == TYPE_INT and key == "Type":
					output += str(key, " : ", infoDict[key], " : ", G.IDtoString[infoDict[key]], '\n')
					continue
				output += str(key, " : ", infoDict[key], '\n')
	return output
