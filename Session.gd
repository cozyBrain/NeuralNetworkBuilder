extends Node

onready var newPlayer = preload("res://Player/Player.tscn")

# Declare member variables here. Examples:
# var a = 2
var players = []



# Called when the node enters the scene tree for the first time.
func _ready():
	var preloadedPlayer = newPlayer.instance()
	preloadedPlayer.set_name("P1")
	players.push_front(preloadedPlayer)
	add_child(players[0])
	pass # Replace with function body.

func close():
	print('close Session..')
	get_tree().quit()
	pass
