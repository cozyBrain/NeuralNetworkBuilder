class_name N_Input
extends StaticBody

var Osynapses : Array
var Isynapses : Array
var Output : float
const Type : int = G.N_Types.N_Input

func getInfo() -> Dictionary:
	return {"Type":Type, "Output":Output, "Isynapses":Isynapses, "Osynapses":Osynapses}
	
func _ready():
	$CollisionShape/MeshInstance.set_surface_material(0, $CollisionShape/MeshInstance.get_surface_material(0).duplicate(4))
	
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
	var type = target.get("Type")
	if type == null:
		return -1
	match type:
		G.N_Types.N_Synapse:
			Osynapses.push_front(target)
		_:
			return -1
	return 0
func connectFrom(target:Node) -> int:
	var type = target.get("Type")
	if type == null:
		return -1
	match type:
		G.N_Types.N_Synapse:
			Isynapses.push_front(target) 
		_:
			return -1
	return 0
	
func disconnectTo(target:Node) -> void:
	var index = Osynapses.find(target)
	if index >= 0:
		Osynapses.remove(index)
func disconnectFrom(target:Node) -> void:
	var index = Isynapses.find(target)
	if index >= 0:
		Isynapses.remove(index)
		
func updateEmissionByOutput() -> void:
	$CollisionShape/MeshInstance.get_surface_material(0).emission_energy = Output
