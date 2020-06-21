class_name N_Tanh
extends StaticBody

var Olinks : Array
var Ilinks : Array
var Output : float
var BOutput : float 
const ID : String = "N_Tanh"
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

func connectPort(target:Node, port:String) -> int:
	match port:
		"Olinks":
			match target.get("ID"):
				"L_SCWeight", "L_SCSharedWeight":
					Olinks.push_front(target)
				_:
					return -1
		"Ilinks":
			match target.get("ID"):
				"L_SCWeight", "L_SCSharedWeight":
					Ilinks.push_front(target)
				_:
					return -1
	return 00

func disconnectPort(target:Node, port:String) -> void:
	match port:
		"Olinks":
			var index = Olinks.find(target)
			if index >= 0:
				Olinks.remove(index)
		"Ilinks":
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
