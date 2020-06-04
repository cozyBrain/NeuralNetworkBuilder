class_name N_Tanh
extends StaticBody

var Olinks : Array
var Ilinks : Array
var Output : float
var BOutput : float 
const ID : int = G.ID.N_Tanh
const dx = G.dx

func _ready():
	$CollisionShape/MeshInstance.set_surface_material(0, $CollisionShape/MeshInstance.get_surface_material(0).duplicate(4))
	updateEmissionByOutput()

func prop() -> void:
	Output = 0
	for link in Ilinks:
		for node in link.Inodes:
			Output += node.Output * link.Weight
	activation()
	updateEmissionByOutput()
	
func bprop() -> void:  # back-propagation
	BOutput = 0
	for link in Olinks:
		for node in link.Onodes:
			BOutput += node.BOutput * link.Weight
	derivateActivationFunc()
	for link in Ilinks:
		for node in link.Inodes:
			link.Weight -= BOutput * node.Output * G.learningRate
		
func activation() -> void:
	Output = tanh(Output)
func derivateActivationFunc() -> void:
	BOutput *= (tanh(Output + dx) - Output) / dx
	
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
	# WOW FINALLY I CAN DO SET EMISSION_ENERGYYYYYYYYYYYYYYYYY!!! but This change applies to others too

