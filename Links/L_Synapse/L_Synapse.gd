# Nodes getBOutput after updateWeight, so not that precise. may causes issue later..
class_name L_Synapse
extends StaticBody

var Weight : float = 1
var Onode : Node
var Inode : Node
const ID : int = G.ID.L_Synapse

func setLength(length : float) -> void:
	var cs = get_node("CollisionShape")
	cs.transform = cs.transform.scaled(Vector3(1,1,length))

func connectFrom(target:Node) -> int:
	match target.get("ID"):
		G.ID.N_LeakyReLU, G.ID.N_Input, G.ID.N_Tanh, G.ID.N_Goal, G.ID.N_NetworkController:
			Inode = target
		var _unknownID:
			print("Invalid ID:", ID)
			return -1
	return 0
func connectTo(target:Node) -> int:
	match target.get("ID"):
		G.ID.N_LeakyReLU, G.ID.N_Input, G.ID.N_Tanh, G.ID.N_Goal:
			Onode = target
		var _unknownID:
			print("Invalid ID:", ID)
			return -1
	return 0
	
func disconnectFrom(target:Node) -> void:
	Inode = null
func disconnectTo(target:Node) -> void:
	Onode = null

func updateWeight(BOutput:float):
	Weight -= BOutput * Inode.Output

func getOutput() -> float:
	if Inode == null:
		return .0
	return Inode.get("Output") * Weight
func getBOutput() -> float:
	if Onode == null:
		return .0
	return Onode.get("BOutput") * Weight
