extends Node

const ID : int = G.ID.S

export (String) var pointerResource = "res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
var pointer
var pointerPosition : Vector3
var prevPointerPosition : Vector3

var distance : float = 2

var shapesDefinitions : Dictionary = {
	"voxel" : [1, TYPE_VECTOR3],  # min parameters, parameters types
	"box" : [2, TYPE_VECTOR3, TYPE_VECTOR3],
	#"sphere" : [2, TYPE_VECTOR3, TYPE_REAL]
}

var hotbar : Array = ["voxel", "box"]
var hotbarSelection : int

var selectionGroups : Dictionary
var groupSelection : String = "default"

func handle(arg : String):
	var output : String
	# Tool Selector -g group1 -shape voxel -pos 0,0,2        -> group1 : "voxel 0,0,2\n"  
	# Tool Selector -g group2 -shape box   -pos 0,0,2 0,0,4  -> group2 : "box 0,0,2 0,0,4\n"
	# Tool Selector -g merged -merge group1 group2           -> merged : "voxel 0,0,2\nbox 0,0,2 0,0,4\n"
	# not recommended to use merge, shape flags at the same line.
	var argParser = ArgParser.new(arg)
	
	var selection : String  # "voxel 0,0,2\n"
	groupSelection = argParser.getString("g", groupSelection, false)  # flag group
	
	var listOption = argParser.getString("list", null)
	if listOption != null:
		match listOption:
			"group":
				output += "<selection groups>:\n"
				var groups = selectionGroups.keys()
				for group in groups:
					output += "       " + group + "\n"
			true:
				output += "Unknown list option"
	
	# form
	var shape = argParser.getStrings("shape")  # flag shape
	if shape.size() > 0:
		shape[0] = shape[0].to_lower()
		var shapesDef = shapesDefinitions.get(shape[0])
		if shapesDef != null:
			if shape.size()-1 >= shapesDef[0]:  # enough shape arguments?
				selection = shape[0]  # selection status: voxel
				var validForm : bool = true
				for shapeArgument in range(1, shape.size()):
					match shapesDef[shapeArgument]:
						TYPE_VECTOR3:
							if not G.isValidVector3(shape[shapeArgument]):
								validForm = false
						_:
							validForm = false
							output += "Unknown argument type!\n"
					if not validForm:
						output += "Invalid shape argument!\n"
						break
					selection += " "+shape[shapeArgument]  # selection status: voxel 0,0,2
				selection += "\n"
				if validForm:
					selectionGroups[groupSelection] = selectionGroups.get(groupSelection, "") + selection
					output += "selectionGroup <"+groupSelection+">:\n"
					output += "       "+selectionGroups[groupSelection].replace("\n", "\n       ")
			else:
				output += "Require more arguments for the shape!\n"
		else:
			output += "Unknown shape!\n"
	
	var toMerge = argParser.getStrings("merge")  # flag merge
	if toMerge.size() > 0 :
		var merged : String
		for toM in toMerge:
			merged += selectionGroups.get(toM, "")
		selectionGroups[groupSelection] = selectionGroups.get(groupSelection, "") + merged
		output += "selectionGroup <"+groupSelection+">:\n"
		output += "       "+selectionGroups[groupSelection].replace("\n", "\n       ")
	
	return output

func update(translation : Vector3, aim : Basis, delta : float):
	pointerPosition = translation
	pointerPosition -= aim.z * distance

	pointerPosition = pointerPosition.round()
	if prevPointerPosition != pointerPosition:
		prevPointerPosition = pointerPosition
		pointer.translation = pointerPosition


func activate(translation, aim : Basis):
	var pointerPosition = translation
	pointerPosition -= aim.z*distance
	pointerPosition = pointerPosition.round()
	pointer = load(pointerResource).instance()
	pointer.translation = pointerPosition
	prevPointerPosition = pointer.translation
	add_child(pointer)

func deactivate():
	pointer.queue_free()
