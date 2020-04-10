class_name N_Tanh
extends StaticBody

var Osynapses : Array
var Isynapses : Array
var Output : float
var BOutput : float 
const Type : int = G.N_Types.N_Tanh
const dx = G.dx

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
	Output = tanh(Output)
func derivateActivationFunc() -> void:
	BOutput *= (tanh(Output + dx) - Output) / dx
	
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
	# WOW FINALLY I CAN DO SET EMISSION_ENERGYYYYYYYYYYYYYYYYY!!! but This change applies to others too

