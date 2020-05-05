class_name N_LeakyReLU
extends StaticBody  # don't consume any CPU resources as long as they don't move. (from docs)


var Osynapses : Array
var Isynapses : Array
var Output : float
var BOutput : float 
const Type : int = G.N_Types.N_LeakyReLU

func getInfo() -> Dictionary:
	return {"Type":Type, "Output":Output, "BOutput":BOutput, "Isynapses":Isynapses, "Osynapses":Osynapses}
	
func _ready():
	$CollisionShape/MeshInstance.set_surface_material(0, $CollisionShape/MeshInstance.get_surface_material(0).duplicate(4))
	
func prop() -> void:
	Output = 0
	for synapse in Isynapses:
		for node in synapse.Inodes:
			Output += node.Output * synapse.Weight
	activation()
	updateEmissionByOutput()
	
func bprop() -> void:  # back-propagation
	BOutput = 0
	for synapse in Osynapses:
		for node in synapse.Onodes:
			BOutput += node.BOutput * synapse.Weight
	derivateActivationFunc()
	for synapse in Isynapses:
		for node in synapse.Inodes:
			synapse.Weight -= BOutput * node.Output * G.learningRate
		
func activation() -> void:
	if Output < 0:
		Output *= 0.1
func derivateActivationFunc() -> void:
	if BOutput < 0:
		BOutput *= 0.1
	
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
