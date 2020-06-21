class_name N_Input
extends StaticBody

var Olinks : Array
var Ilinks : Array
var Output : float
const ID : String = "N_Input"

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
	pass

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
		"translation" : translation,
	}
func loadSaveData(sd:Dictionary):
	for propertyName in sd:
		set(propertyName, sd[propertyName])
	updateEmissionByOutput()
