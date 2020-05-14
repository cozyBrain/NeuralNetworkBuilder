extends Node
enum ID {
	None, Player,
	NII, PC, SC, H, NC,
	N_LeakyReLU, N_Synapse, N_NetworkController, N_Input, N_Tanh, N_Goal,
}
const IDtoString = [
	"None", "Player",
	"NodeInfoIndicator", "PointConnector", "SquareConnector", "Hand", "NodeCreator",
	"N_LeakyReLU", "N_Synapse", "N_NetworkController", "N_Input", "N_Tanh", "N_Goal",
]
const dx = 0.001
const learningRate = 0.001
const default_session_path = "/root/session"
var default_session

func _ready():
	default_session = get_node(default_session_path)

func square(x:float) -> float:
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
