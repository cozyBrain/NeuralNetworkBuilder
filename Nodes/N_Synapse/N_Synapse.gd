class_name N_Synapse
extends StaticBody

var Weight : float = 1  # default value of Weight should be 1 for several reasons. for instance) when N_Goal bprop()
var Onodes : Array
var Inodes : Array
const Type : int = G.N_Types.N_Synapse

func getInfo() -> Dictionary:
	return {"Type":Type, "Weight":Weight, "Inodes":Inodes, "Onodes":Onodes}

func setLength(length : float) -> void:
	var cs = get_node("CollisionShape")
	cs.transform = cs.transform.scaled(Vector3(1,1,length))

func connectFrom(target:Node) -> int:
	var type = target.get("Type")
	if type == null:
		return -1
	match type:
		G.N_Types.N_LeakyReLU, G.N_Types.N_Input, G.N_Types.N_Tanh, G.N_Types.N_Goal, G.N_Types.N_NetworkController:
			Inodes.push_front(target)
		var unknownType:
			return -1
	return 0
func connectTo(target:Node) -> int:
	var type = target.get("Type")
	if type == null:
		return -1
	match type:
		G.N_Types.N_LeakyReLU, G.N_Types.N_Input, G.N_Types.N_Tanh, G.N_Types.N_Goal:
			Onodes.push_front(target)
		var unknownType:
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
