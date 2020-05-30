# related with Session.gd
# Global.gd: many stuffs that most others need.

extends Node
enum ID {
	None, Player,
	OII, LC, BC, H, NC, S, P,
	N_LeakyReLU, L_Synapse, N_NetworkController, N_Input, N_Tanh, N_Goal,
}
const IDtoString = [
	"None", "Player",
	"ObjectInfoIndicator", "LinkCreator", "BoxConnector", "Hand", "NodeCreator", "Selector", "Pointer",
	"N_LeakyReLU", "L_Synapse", "N_NetworkController", "N_Input", "N_Tanh", "N_Goal",
]
const dx = 0.001
const learningRate = 0.001
const default_session_path = "/root/session"
onready var default_session = get_node(default_session_path)
onready var default_session_nodes = default_session.get_node("nodes")
onready var default_session_links = default_session.get_node("links")


func _ready():
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
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
