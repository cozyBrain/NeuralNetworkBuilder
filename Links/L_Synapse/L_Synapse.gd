class_name L_Synapse
extends StaticBody

var Weight : float = 1  # default value of Weight should be 1 for several reasons. for instance) when N_Goal bprop()
var Onode : Node
var Inode : Node
const ID : int = G.ID.L_Synapse

func setLength(length : float) -> void:
	var cs = get_node("CollisionShape")
	cs.transform = cs.transform.scaled(Vector3(1,1,length))

func connectFrom(target:Node) -> int:
	var ID = target.get("ID")
	if ID == null:
		return -1
	match ID:
		G.ID.N_LeakyReLU, G.ID.N_Input, G.ID.N_Tanh, G.ID.N_Goal, G.ID.N_NetworkController:
			Inode = target
		var _unknownID:
			return -1
	return 0
func connectTo(target:Node) -> int:
	var ID = target.get("ID")
	if ID == null:
		return -1
	match ID:
		G.ID.N_LeakyReLU, G.ID.N_Input, G.ID.N_Tanh, G.ID.N_Goal:
			Onode = target
		var _unknownID:
			return -1
	return 0
	
func disconnectFrom(target:Node) -> void:
	Inode = null
func disconnectTo(target:Node) -> void:
	Onode = null
