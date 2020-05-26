extends Spatial
class_name NodeInfoIndicator

export (NodePath) var session_path = G.default_session_path
var overlappingBodyDetector = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()

const ID : int = G.ID.NII

func handle(position) -> String:
	position = G.str2vector3(position)
	if position == null:
		return "Invalid argument"
	var node = G.default_session.getNode(position)
	if null == node:
		return "No node detected"

	
	var output : String = ""	
	output += str(self.name,": < ", node, "  ", node.translation, " >\n")
	if not node.has_method("getInfo"):
		output += str(self.name, ": could not get info as the node doesn't have method getInfo()\n")
	else:
		var infoDict = node.getInfo()
		for key in infoDict:
			if typeof(infoDict[key]) == TYPE_INT and key == "ID":
				output += str(key, " : ", infoDict[key], " : ", G.IDtoString[infoDict[key]], '\n')
				continue
			output += str(key, " : ", infoDict[key], '\n')
	return output
