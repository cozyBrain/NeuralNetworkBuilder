# Nodes getBOutput() after updateWeight(), so not that precise. may causes issue later..
class_name L_SCSharedWeight
extends StaticBody

var Wnode : Node
var Onode : Node
var Inode : Node
const ID : String = "L_SCSharedWeight"

func setLength(length : float) -> void:
	var cs = get_node("CollisionShape")
	cs.transform = cs.transform.scaled(Vector3(1,1,length))

func connectPort(target:Node, port:String) -> int:
	match port:
		"Inode":
			match target.get("ID"):
				"N_LeakyReLU", "N_Input", "N_Tanh", "N_Goal", "N_NetworkController":
					Inode = target
				var _unknownID:
					print("Invalid ID:", ID)
					return -1
		"Onode":
			match target.get("ID"):
				"N_LeakyReLU", "N_Input", "N_Tanh", "N_Goal":
					Onode = target
				var _unknownID:
					print("Invalid ID:", ID)
					return -1
		"Wnode":
			match target.get("ID"):
				"N_LeakyReLU", "N_Input", "N_Tanh", "N_Goal":
					Wnode = target
				var _unknownID:
					print("Invalid ID:", ID)
					return -1
	return 0


func disconnectPort(target:Node, port:String) -> void:
	match port:
		"Inode":
			Inode = null
		"Onode":
			Onode = null
		"Wnode":
			Wnode = null

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
	var W = G.default_world.getNode(sd["Wnode"])
	if A == null or B == null or W == null:
		return null
	sd.erase("Inode")
	sd.erase("Onode")
	sd.erase("Wnode")
	
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
	# connectPort
	connectPort(A, "Inode")
	connectPort(B, "Onode")
	connectPort(W, "Wnode")
	# connectNode
	match A.get("ID"):
		"N_LeakyReLU", "N_Goal", "N_Input", "N_Tanh", "N_NetworkController":
			A.connectPort(self, "Olinks")
	match B.get("ID"):
		"N_LeakyReLU", "N_Goal", "N_Input", "N_Tanh":
			B.connectPort(self, "Ilinks")
	# set other saveData
	for propertyName in sd:
		set(propertyName, sd[propertyName])
