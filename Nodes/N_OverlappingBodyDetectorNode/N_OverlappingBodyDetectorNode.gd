extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func resize(s : Vector3) -> void:
	var cs = get_node("CollisionShape")
	cs.transform = cs.transform.scaled(s)
#func detect(from : Vector3, to : Vector3) -> void:
	
#	# difference
#	var dX = from.x - to.x
#	var dY = from.y - to.y
#	var dZ = from.z - to.z
#	# count direction
#	var Xc = 1 if dX < 0 else -1
#	var Yc = 1 if dY < 0 else -1
#	var Zc = 1 if dZ < 0 else -1
#	# vector index
#	self.translation = from
#	# loop count
#	var fullyScanned = false
#	while not fullyScanned:
#		for body in self.get_overlapping_bodies():
#			print("o:", body.translation)
#		print(self.translation)
#		# count x,y,z in order
#		if self.translation.x != to.x:
#			self.translation.x += Xc
#		else:
#			self.translation.x = from.x
#			if self.translation.y != to.y:
#				self.translation.y += Yc
#			else:
#				self.translation.y = from.y
#				if self.translation.z != to.z:
#					self.translation.z += Zc
#				else:
#					fullyScanned = true
