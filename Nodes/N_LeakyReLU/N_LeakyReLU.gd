class_name N_LeakyReLU
extends StaticBody  # don't consume any CPU resources as long as they don't move. (from docs)


var Olinks : Array
var Ilinks : Array
var Output : float
var BOutput : float 
const ID : int = G.ID.N_LeakyReLU

func getInfo() -> Dictionary:
	return {"ID":ID, "Output":Output, "BOutput":BOutput, "Ilinks":Ilinks, "Olinks":Olinks}
	
func _ready():
	$CollisionShape/MeshInstance.set_surface_material(0, $CollisionShape/MeshInstance.get_surface_material(0).duplicate(4))
	
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
	if Output < 0:
		Output *= 0.1
func derivateActivationFunc() -> void:
	if BOutput < 0:
		BOutput *= 0.1
	
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
