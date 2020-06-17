# Nodes getBOutput() after updateWeight(), so not that precise. may causes issue later..
class_name L_SCSharedWeight
extends StaticBody

var Wnode : Node
var Onode : Node
var Inode : Node
const ID : int = G.ID.L_SCSharedWeight

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
	Wnode.Output -= BOutput * Inode.Output

func getOutput() -> float:
	if Inode == null:
		return .0
	return Inode.get("Output") * Wnode.Output
func getBOutput() -> float:
	if Onode == null:
		return .0
	return Onode.get("BOutput") * Wnode.Output

func getSaveData() -> Dictionary:
	return {
		"ID" : ID,
		"Wnode" : Wnode.translation,
		"Onode" : Onode.translation,
		"Inode" : Inode.translation,
		"transform" : transform,
	}

func loadSaveData(sd : Dictionary):
	var A = G.default_world.getNode(sd["Inode"])
	var B = G.default_world.getNode(sd["Onode"])
	if A == null or B == null:
		return null
	# config synapse
	var distance = A.translation.distance_to(B.translation)
	var position = (A.translation + B.translation) / 2
	var direction = A.translation.direction_to(B.translation)
	setLength(distance)
	var d = direction
	d.x = 1 if d.x == 0 else 0
	d.y = 1 if d.y == 0 else 0
	d.z = 1 if d.y == 0 else 0
	look_at_from_position(position, A.translation, d)
	connectFrom(A)
	connectTo(B)
	
	A.connectTo(self)
	B.connectFrom(self)
	
	sd.erase("Inode")
	sd.erase("Onode")
	
	for propertyName in sd:
		set(propertyName, sd[propertyName])
