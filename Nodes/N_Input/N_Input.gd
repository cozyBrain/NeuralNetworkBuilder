class_name N_Input
extends StaticBody

var Olinks : Array
var Ilinks : Array
var Output : float
const ID : int = G.ID.N_Input

func _ready():
	$CollisionShape/MeshInstance.set_surface_material(0, $CollisionShape/MeshInstance.get_surface_material(0).duplicate(4))
	updateEmissionByOutput()

func addOutput(x:float) -> void:
	Output += x
	updateEmissionByOutput()

func setOutput(x:float) -> void:
	Output = x
	updateEmissionByOutput()

func prop() -> void:
	updateEmissionByOutput()
func bprop() -> void:  # back-propagation
	pass

func connectTo(target:Node) -> int:
	var id = target.get("ID")
	if id == null:
		return -1
	match id:
		G.ID.L_Synapse:
			Olinks.push_front(target)
		_:
			return -1
	return 0
func connectFrom(target:Node) -> int:
	var id = target.get("ID")
	if id == null:
		return -1
	match id:
		G.ID.L_Synapse:
			Ilinks.push_front(target) 
		_:
			return -1
	return 0

func disconnectTo(target:Node) -> void:
	var index = Olinks.find(target)
	if index >= 0:
		Olinks.remove(index)
func disconnectFrom(target:Node) -> void:
	var index = Ilinks.find(target)
	if index >= 0:
		Ilinks.remove(index)


func updateEmissionByOutput() -> void:
	$CollisionShape/MeshInstance.get_surface_material(0).emission_energy = Output
