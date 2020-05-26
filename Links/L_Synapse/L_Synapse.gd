class_name L_Synapse
extends StaticBody

var Weight : float = 1  # default value of Weight should be 1 for several reasons. for instance) when N_Goal bprop()
var Onodes : Array
var Inodes : Array
const ID : int = G.ID.L_Synapse

func getInfo() -> Dictionary:
	return {"ID":ID, "Weight":Weight, "Inodes":Inodes, "Onodes":Onodes}

func setLength(length : float) -> void:
	var cs = get_node("CollisionShape")
	cs.transform = cs.transform.scaled(Vector3(1,1,length))

func connectFrom(target:Node) -> int:
	var ID = target.get("ID")
	if ID == null:
		return -1
	match ID:
		G.ID.N_LeakyReLU, G.ID.N_Input, G.ID.N_Tanh, G.ID.N_Goal, G.ID.N_NetworkController:
			Inodes.push_front(target)
		var _unknownID:
			return -1
	return 0
func connectTo(target:Node) -> int:
	var ID = target.get("ID")
	if ID == null:
		return -1
	match ID:
		G.ID.N_LeakyReLU, G.ID.N_Input, G.ID.N_Tanh, G.ID.N_Goal:
			Onodes.push_front(target)
		var _unknownID:
			return -1
	return 0
	
func disconnectFrom(target:Node) -> void:
	var index = Inodes.find(target)
	if index >= 0:
		Inodes.remove(index)
func disconnectTo(target:Node) -> void:
	var index = Onodes.find(target)
	if index >= 0:
		Onodes.remove(index)
