# related with Global.gd
extends Node

var newPlayer = preload("res://Player/Player.tscn")
var players = []

func _ready():
	updateNodeMap()
	var preloadedPlayer = newPlayer.instance()
	preloadedPlayer.set_name("P1")
	players.push_front(preloadedPlayer)
	add_child(players[0])

var nodeMap : Dictionary  # register only nodes

func updateNodeMap() -> void:
	for node in get_tree().get_nodes_in_group("node"):
		nodeMap[node.translation] = node

func addLink(link : Node) -> void:
	$components.add_child(link)
func eraseLink(link : Node) -> void:
	link.queue_free()

func overlapNode(node : Node):
	$components.add_child(node)
func addNode(node : Node, override = false) -> bool:  # true if did add_child
	if nodeMap.has(node.translation):
		if override:
			nodeMap[node.translation].queue_free()
			nodeMap.erase(node.translation)
			nodeMap[node.translation] = node
			$components.add_child(node)
			return true
		return false
	
	nodeMap[node.translation] = node
	$components.add_child(node)
	return true

func eraseNode(node : Node) -> void:
	nodeMap.erase(node.translation)
	node.queue_free()
func getNode(position : Vector3) -> Node:
	return nodeMap.get(position)
func boxGetNode(from:Vector3, to:Vector3) -> Array:
	var nodes : Array
	var dvec : Vector3
	var ivec : Vector3 = from
	
	dvec.x = 1 if from.x < to.x else -1
	dvec.y = 1 if from.y < to.y else -1
	dvec.z = 1 if from.z < to.z else -1
	
	# iteration
	for z in range(from.z, to.z+dvec.z, dvec.z):
		for y in range(from.y, to.y+dvec.y, dvec.y):
			for x in range(from.x, to.x+dvec.x, dvec.x):
				#print(Vector3(x,y,z))
				var node = getNode(Vector3(x,y,z))
				if node != null:
					nodes.push_front(node)
	return nodes
#func boxAddNode(node, begin:Vector3, end:Vector3):
#	var nodes : Array
#	var dvec : Vector3
#	var ivec : Vector3 = begin
#
#	dvec.x = 1 if begin.x < end.x else -1
#	dvec.y = 1 if begin.y < end.y else -1
#	dvec.z = 1 if begin.z < end.z else -1
#
#	# iteration
#	for z in range(begin.z, end.z+dvec.z, dvec.z):
#		for y in range(begin.y, end.y+dvec.y, dvec.y):
#			for x in range(begin.x, end.x+dvec.x, dvec.x):
#				node.translation = Vector3(x,y,z)
#				addNode(node)


func close():
	print('close Session..')
	get_tree().quit()
	pass
