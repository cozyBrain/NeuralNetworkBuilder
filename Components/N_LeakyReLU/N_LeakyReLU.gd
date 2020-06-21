class_name N_LeakyReLU
extends StaticBody  # don't consume any CPU resources as long as they don't move. (from docs)

var Olinks : Array
var Ilinks : Array
var Output : float
var BOutput : float 
const ID : String = "N_LeakyReLU"
const leakage : float = .1

func _ready():
	$CollisionShape/MeshInstance.set_surface_material(0, $CollisionShape/MeshInstance.get_surface_material(0).duplicate(4))

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
	if x < 0:
		return x * leakage
	return x
static func derivateActivationFunc(x:float) -> float:
	if x < 0:
		return leakage
	return 1.0
	
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
	return 0

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
