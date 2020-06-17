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
		Output += link.getOutput()
	Output = activationFunc(Output)

func bprop() -> void:  # back-propagation
	BOutput = 0
	for link in Olinks:
		BOutput += link.getBOutput()
	BOutput *= derivateActivationFunc(Output)
	for link in Ilinks:
		link.updateWeight(BOutput)

static func activationFunc(x:float) -> float:
	return tanh(x)
	#return 1 / (1 + exp(x))
static func derivateActivationFunc(x) -> float:
	return (activationFunc(x + dx) - activationFunc(x)) / dx

func connectTo(target:Node) -> int:
	var id = target.get("ID")
	if id == null:
		return -1
	match id:
		G.ID.L_SCWeight:
			Olinks.push_front(target)
		_:
			return -1
	return 0
func connectFrom(target:Node) -> int:
	var id = target.get("ID")
	if id == null:
		return -1
	match id:
		G.ID.L_SCWeight:
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

func getSaveData() -> Dictionary:
	return {
		"ID" : ID,
		"Output" : Output,
		"BOutput" : BOutput,
		"translation" : translation,
	}
func loadSaveData(sd:Dictionary):
	for propertyName in sd:
		set(propertyName, sd[propertyName])
	updateEmissionByOutput()
