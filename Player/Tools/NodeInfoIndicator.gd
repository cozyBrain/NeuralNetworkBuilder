extends Spatial
class_name NodeInfoIndicator

export (NodePath) var session_path = G.default_session_path
var overlappingBodyDetector = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()

func handle(position) -> String:
	position = position.split_floats(",", false)
	if position.size() != 3:
		return "Invalid argument"
	position = Vector3(position[0], position[1], position[2])
	
	var node = G.getNode(position)
	var output : String = ""
	if null == node:
		output += str(self.name, ": No node detected.\n")
	else:
		output += str(self.name,": < ", node, "  ", node.translation, " >\n")
		if not node.has_method("getInfo"):
			output += str(self.name, ": could not get info as the node doesn't have method getInfo()\n")
		else:
			var infoDict = node.getInfo()
			for key in infoDict:
				if typeof(infoDict[key]) == TYPE_INT and key == "Type":
					output += str(key, " : ", infoDict[key], " : ", G.IDtoString[infoDict[key]], '\n')
					continue
				output += str(key, " : ", infoDict[key], '\n')
	return output
