class_name N_LeakyReLU
extends StaticBody  # don't consume any CPU resources as long as they don't move. (from docs)


var Olinks : Array
var Ilinks : Array
var Output : float
var BOutput : float 
const ID : int = G.ID.N_LeakyReLU

func _ready():
	$CollisionShape/MeshInstance.set_surface_material(0, $CollisionShape/MeshInstance.get_surface_material(0).duplicate(4))
	updateEmissionByOutput()

func prop() -> void:
	Output = 0
	for link in Ilinks:
		Output += link.getOutput()
	Output = activationFunc(Output)
	updateEmissionByOutput()
	
func bprop() -> void:  # back-propagation
	BOutput = 0
	for link in Olinks:
		BOutput += link.getBOutput()
	BOutput *= derivateActivationFunc(BOutput)
	for link in Ilinks:
		link.updateWeight(BOutput)
	
static func activationFunc(x:float) -> float:
	if x < 0:
		return x * 0.1
	return x
static func derivateActivationFunc(x:float) -> float:
	if x < 0:
		return 0.1
	return 1.0
	
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
