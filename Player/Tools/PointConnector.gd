extends Node
class_name PointConnector

onready var Loaded_N_Synapse = preload("res://Nodes/N_Synapse/N_Synapse.tscn")

var A : Object
func use1(rayCastDetectedObject : Object) -> void:
	if null == rayCastDetectedObject:
		print(self.name, ": No Object Detected")
		return
	if A == null:
		A = rayCastDetectedObject
		print(self.name, ": From ", self.A)
		return
	else:
		print(self.name, ": To ", rayCastDetectedObject)
		G.default_session.add_child(self.use2(self.A, rayCastDetectedObject))
		A = null
		
func use2(A : Object, B : Object) -> Object:
	var newSynapse = Loaded_N_Synapse.instance()
	# config synapse
	var distance = A.translation.distance_to(B.translation)
	var position = (A.translation + B.translation) / 2
	var direction = A.translation.direction_to(B.translation)
	newSynapse.setLength(distance)
	var d = direction
	d.x = 1 if d.x == 0 else 0
	d.y = 1 if d.y == 0 else 0
	d.z = 1 if d.y == 0 else 0
	newSynapse.look_at_from_position(position, A.translation, d)
	if newSynapse.connectFrom(A) == -1:
		print(self.name, ": synapse failed: connectFrom ", A)
		return null
	if newSynapse.connectTo(B) == -1:
		print(self.name, ": synapse failed: connectTo ", B)
		return null
		
	var success : int = 0
	# connect both node with the newSynapse
	if A.has_method("connectTo"):
		if A.connectTo(newSynapse) == -1:
			print(self.name, ": failed: ", A, " connectTo ", newSynapse)
		else:
			success += 1
	if B.has_method("connectFrom"):
		if B.connectFrom(newSynapse) == -1:
			print(self.name, ": failed: ", B, " connectFrom ", newSynapse)
		else:
			success += 1
	if success >= 2:
		return newSynapse
	return null
