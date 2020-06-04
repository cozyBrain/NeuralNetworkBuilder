extends Node
class_name NodeInfoIndicator


export (NodePath) var session_path = G.default_session_path
var overlappingBodyDetector = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()

const ID : int = G.ID.OII

func handle(position) -> String:
	var output : String = ""	
	var object
	if position.is_valid_integer():  # is this an instance?
		object = instance_from_id(int(position))
	else:
		position = G.str2vector3(position)
		if position == null:
			return "Invalid argument\n"
		object = G.default_session.getNode(position)
		if null == object:
			return "No object detected\n"

	output += str("< ", object, "  ", object.translation, " >\n")
	var objID = object.get("ID")
	if objID != null:
		output += str("ID : ", objID, " : ", G.IDtoString[objID], '\n')
	for property in object.get_property_list():
		if(property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE): 
			output += property.name + ": " + str(object[property.name]) + "\n"

	return output
