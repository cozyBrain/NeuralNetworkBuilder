extends Node
class_name NodeInfoIndicator

var overlappingBodyDetector = load("res://Components/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()

const ID : String = "ObjectInfoIndicator"

func handle(position) -> String:
	var output : String = ""	
	var object
	if position.is_valid_integer():  # is this an instance?
		object = instance_from_id(int(position))
	else:
		position = G.str2vector3(position)
		if position == null:
			return "Invalid argument\n"
		object = G.default_world.getNode(position)
		if null == object:
			return str(position, ": No object detected\n")

	output += str("< ", object, "  ", object.translation, " >\n")
	var objID = object.get("ID")
	if objID != null:
		output += str("ID : ", objID, '\n')
	for property in object.get_property_list():
		if(property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE): 
			if typeof(object[property.name]) == TYPE_REAL:
				output += property.name + ": " + var2str(object[property.name]) + "\n"
			else:
				output += property.name + ": " + str(object[property.name]) + "\n"
	print(output)
	return output
