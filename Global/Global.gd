# related with Session.gd
# Global.gd: many stuffs that most others need.

extends Node
#enum ID {
#	None, Player,
#	OII, LC, BC, H, NC, S, P, C, SLT
#	N_LeakyReLU, N_NetworkController, N_Input, N_Tanh, N_Goal,
#	L_SCWeight, L_SCSharedWeight,
#	Port_Inode, Port_Onode, Port_Wnode,
#}
#const IDtoString = [
#	"None", "Player",
#	"ObjectInfoIndicator", "LinkCreator", "BoxConnector", "Hand", "NodeCreator", "Selector", "Pointer", "Copier", "SupervisedLearningTrainer",
#	"N_LeakyReLU", "N_NetworkController", "N_Input", "N_Tanh", "N_Goal",
#	"L_SCWeight", "L_SCSharedWeight",
#	"Port_Inode", "Port_Onode", "Port_Wnode",
#]
const VERSION = "0.0-b"
const dx = 0.0001
const default_world_path = "/root/World"
onready var default_world = get_node(default_world_path)

const defaultGroupName="_default"

func _ready():
	print("Program Version: ", VERSION)
	pass

static func isValidVector3(vector : String) -> bool:
	# trim needless characters.  often when arg="(0,0,0,)"
	vector = vector.replace("(", "")
	vector = vector.replace(")", "")
	vector = vector.replace(" ", "")
	var xyz = vector.split(",", false, 2)
	if xyz.size() != 3:
		return false
	for p in xyz:
		if not p.is_valid_float():
			return false
	return true
static func str2vector3(position : String):
	position = position.replace("(", "")
	position = position.replace(")", "")
	position = position.replace(" ", "")

	var xyz = position.split(",", false, 2)
	if xyz.size() != 3:
		return null
	for p in xyz:
		if not p.is_valid_float():
			return null
	return Vector3(xyz[0], xyz[1], xyz[2])
static func unsafe_str2vector3(position : String) -> Vector3:
	var xyz = position.split_floats(",", false)
	return Vector3(xyz[0], xyz[1], xyz[2])

static func square(x:float) -> float:
	return x*x

func copyVariables(source, dest):  # deep duplicate ARRAY and DICTIONARY
	for property in source.get_property_list():
		if(property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE): 
			if typeof(source[property.name]) == TYPE_ARRAY or typeof(source[property.name]) == TYPE_DICTIONARY:
				dest[property.name] = source[property.name].duplicate(true)
			else:
				dest[property.name] = source[property.name]
