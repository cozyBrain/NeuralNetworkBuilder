class_name N_Goal
extends StaticBody

var Olinks : Array
var Ilinks : Array
var Output : float  # Output is Goal
var BOutput : float 
const ID : int = G.ID.N_Goal

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
	var f : String
	for link in Ilinks:
		var preErr = G.square(link.getOutput() - Output)  # == link.Inode.Output - Goal
		var aftErr = G.square((link.getOutput()-G.dx) - Output)
		f = str(preErr," - ", aftErr, " / ", G.dx, "= ")
		BOutput += ((preErr - aftErr) / G.dx)
	BOutput /= Ilinks.size()
	BOutput *= 0.03
	print(f,BOutput)

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
