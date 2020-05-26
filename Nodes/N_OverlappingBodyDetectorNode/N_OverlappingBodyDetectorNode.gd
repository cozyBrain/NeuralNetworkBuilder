extends Area

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func resize(s : Vector3) -> void:
	var cs = get_node("CollisionShape")
	cs.transform = cs.transform.scaled(s)
