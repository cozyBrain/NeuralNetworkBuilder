extends Node
class_name LinkCreator

const ID : int = G.ID.LC

onready var Link = preload("res://Links/L_Synapse/L_Synapse.tscn")

var Anode : Object
func handle(position) -> String:
	var output : String
	var node = G.default_session.getNode(G.str2vector3(position))
	if node == null:
		return "No node detected"
		
	if Anode == null:
		Anode = node
		output += str(self.name, ": From ", self.Anode)
	else:
		output += str(self.name, ": To ", node)
		G.default_session.addLink(create(Anode, node))
		Anode = null
	return output

func create(A : Object, B : Object) -> Object:
	var newLink = Link.instance()
	# config synapse
	var distance = A.translation.distance_to(B.translation)
	var position = (A.translation + B.translation) / 2
	var direction = A.translation.direction_to(B.translation)
	newLink.setLength(distance)
	var d = direction
	d.x = 1 if d.x == 0 else 0
	d.y = 1 if d.y == 0 else 0
	d.z = 1 if d.y == 0 else 0
	newLink.look_at_from_position(position, A.translation, d)
	if newLink.connectFrom(A) == -1:
		print(self.name, ": link failed: connectFrom ", A)
		return null
	if newLink.connectTo(B) == -1:
		print(self.name, ": link failed: connectTo ", B)
		return null
		
	var success : int = 0
	# connect both node with the newLink
	if A.has_method("connectTo"):
		if A.connectTo(newLink) == -1:
			print(self.name, ": failed to connect ", A, " to ", newLink)
		else:
			success += 1
	if B.has_method("connectFrom"):
		if B.connectFrom(newLink) == -1:
			print(self.name, ": failed to connect ", B, " from ", newLink)
		else:
			success += 1
	if not success >= 2:
		return null
	return newLink
