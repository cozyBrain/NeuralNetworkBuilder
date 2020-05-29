# related with Global.gd
extends Node

onready var newPlayer = preload("res://Player/Player.tscn")
var players = []

func _ready():
	updateNodeMap()
	var preloadedPlayer = newPlayer.instance()
	preloadedPlayer.set_name("P1")
	players.push_front(preloadedPlayer)
	add_child(players[0])


var nodeMap : Dictionary

func updateNodeMap() -> void:
	var nodes = $nodes.get_children()
	for node in nodes:
		nodeMap[node.translation] = node

func addLink(link : Node) -> void:
	$links.add_child(link)
func eraseLink(link : Node) -> void:
	link.queue_free()

func addNode(node : Node) -> void:
	nodeMap[node.translation] = node
	add_child(node)
func eraseNode(node : Node) -> void:
	nodeMap.erase(node.translation)
	node.queue_free()
func getNode(position : Vector3) -> Node:
	return nodeMap.get(position)
func boxGetNode(begin:Vector3, end:Vector3) -> Array:
	var nodes : Array
	var dvec : Vector3
	var ivec : Vector3 = begin

	dvec.x = 1 if begin.x < end.x else -1
	dvec.y = 1 if begin.y < end.y else -1
	dvec.z = 1 if begin.z < end.z else -1

	# iteration
	for z in range(begin.z, end.z+dvec.z, dvec.z):
		for y in range(begin.y, end.y+dvec.y, dvec.y):
			for x in range(begin.x, end.x+dvec.x, dvec.x):
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
