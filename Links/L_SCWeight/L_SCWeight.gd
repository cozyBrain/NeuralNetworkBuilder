# Nodes getBOutput() after updateWeight(), so not that precise. may causes issue later..
class_name L_SCWeight
extends StaticBody

var Weight : float = 1
var Onode : Node
var Inode : Node
const ID : String = "L_SCWeight"

#func _ready():
#	$CollisionShape.set_disabled(true)  # optimize

func setLength(length : float) -> void:
	var cs = get_node("CollisionShape")
	cs.transform = cs.transform.scaled(Vector3(1,1,length))

func connectPort(target:Node, port:String) -> int:
	var target_ID = target.get("ID")
	match port:
		"Inode":
			match target_ID:
				"N_LeakyReLU", "N_Input", "N_Tanh", "N_Goal", "N_NetworkController":
					Inode = target
				var _unknownID:
					print("Invalid ID:", ID)
					return -1
		"Onode":
			match target_ID:
				"N_LeakyReLU", "N_Input", "N_Tanh", "N_Goal":
					Onode = target
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

func getSaveData() -> Dictionary:
	return {
		"ID" : ID,
		"Weight" : Weight,
		"Onode" : Onode.translation,
		"Inode" : Inode.translation,
		"transform" : transform,
	}

func loadSaveData(sd : Dictionary):
	var A = G.default_world.getNode(sd["Inode"])
	var B = G.default_world.getNode(sd["Onode"])
	if A == null or B == null:
		return null
	sd.erase("Inode")
	sd.erase("Onode")
	
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
