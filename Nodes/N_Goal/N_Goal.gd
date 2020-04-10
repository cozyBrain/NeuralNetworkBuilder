class_name N_Goal
extends StaticBody

var Osynapses : Array
var Isynapses : Array
var Output : float  # Output is Goal
var BOutput : float 
const Type : int = G.N_Types.N_Goal

func getInfo() -> Dictionary:
	return {"Type":Type, "Description":"OutputIsGoal", "Output":Output, "BOutput":BOutput, "Isynapses":Isynapses, "Osynapses":Osynapses}
	
func _ready():
	$CollisionShape/MeshInstance.set_surface_material(0, $CollisionShape/MeshInstance.get_surface_material(0).duplicate(4))
	
func addOutput(x:float) -> void:
	Output += x
	updateEmissionByOutput()
	
func setOutput(x:float) -> void:
	Output = x
	updateEmissionByOutput()
	
func prop() -> void:
	pass
	
func bprop() -> void:  # back-propagation
	BOutput = 0
	# < From MapBasedNeuralNetwork Project > #
	# preErr := square32(n.O-N.G) / BI
	# aftErr := square32((n.O-dx)-N.G) / BI
	# N.BO = ((preErr - aftErr) / dx) * 0.5
	
	#for synapse in Osynapses:
	#	for node in synapse.Onodes:
	#		BOutput += node.BOutput * synapse.Weight
	for synapse in Isynapses:
		for node in synapse.Inodes:
			var preErr = G.square(node.Output - Output)
			var aftErr = G.square((node.Output-G.dx) - Output)
			BOutput += ((preErr - aftErr) / G.dx)
	BOutput /= Isynapses.size()
		
	
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
