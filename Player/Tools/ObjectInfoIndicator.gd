extends Node
class_name NodeInfoIndicator


export (NodePath) var session_path = G.default_session_path
var overlappingBodyDetector = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()

const ID : int = G.ID.OII

func handle(position) -> String:
	var object
	if position.is_valid_integer():  # is this an instance?
		object = instance_from_id(int(position))
	else:
		position = G.str2vector3(position)
		if position == null:
			return "Invalid argument"
		object = G.default_session.getNode(position)
		if null == object:
			return "No object detected"


	var output : String = ""	
	output += str(self.name,": < ", object, "  ", object.translation, " >\n")
	if not object.has_method("getInfo"):
		output += str(self.name, ": could not get info as the object doesn't have method getInfo()\n")
	else:
		var infoDict = object.getInfo()
		for key in infoDict:
			if typeof(infoDict[key]) == TYPE_INT and key == "ID":
				output += str(key, " : ", infoDict[key], " : ", G.IDtoString[infoDict[key]], '\n')
				continue
			output += str(key, " : ", infoDict[key], '\n')
	return output
