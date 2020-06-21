class_name N_Goal
extends StaticBody

var Olinks : Array
var Ilinks : Array
var Output : float  # Output is Goal
var BOutput : float 
const ID : String = "N_Goal"

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
	for link in Ilinks:
		var preErr = G.square(link.getOutput() - Output)  # Output == Goal
		var aftErr = G.square((link.getOutput()-G.dx) - Output)
		BOutput += ((preErr - aftErr) / G.dx)
	BOutput /= Ilinks.size()
	BOutput *= 0.001

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
