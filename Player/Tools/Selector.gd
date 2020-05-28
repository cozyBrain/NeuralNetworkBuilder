extends Node

const ID : int = G.ID.S

export (String) var pointerResource = "res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
var pointer
var pointerPosition : Vector3
var prevPointerPosition : Vector3

var distance : float = 2

var shapes : Dictionary = {
	"voxel" : [1, [TYPE_VECTOR3], ""],  # min arguments, [arguments types], stacked arguments
	"box" : [2, [TYPE_VECTOR3, TYPE_VECTOR3], ""],
	#"sphere" : [2, TYPE_VECTOR3, TYPE_REAL], ""]
}

var hotbar : Array = ["voxel", "box"]
var hotbarSelection : int

var selectionGroups : Dictionary
var groupSelection : String = "default"

# Tool Selector -shape hotbarSelection voxel 0,0,2  -> default: "voxel 0,0,2\n"
# Tool Selector -g group1 -shape voxel 0,0,2        -> group1 : "voxel 0,0,2\n"  
# Tool Selector -g group2 -shape box   0,0,2 0,0,4  -> group2 : "box 0,0,2 0,0,4\n"
# Tool Selector -g merged -merge group1 group2      -> merged : "voxel 0,0,2\nbox 0,0,2 0,0,4\n"
# not recommended to use merge, shape flags at the same line.
func handle(arg : String):
	var output : String
	var argParser = ArgParser.new(arg)
	
	var selection : String  # "voxel 0,0,2\n"
	groupSelection = argParser.getString("g", groupSelection, false)  # flag group
	
	var listOption = argParser.getString("list", null)
	if listOption != null:
		match listOption:
			"groups":
				output += "<selection groups>:\n"
				var groups = selectionGroups.keys()
				for group in groups:
					output += "       " + group + "\n"
			true:
				output += "Unknown list option\n"
	
	var shapeArguments = argParser.getStrings("shape")  # flag shape
	if shapeArguments != null:
		var numOfShapeArguments = shapeArguments.size()
		print(numOfShapeArguments, shapeArguments)
		if numOfShapeArguments >= 1:
			shapeArguments[0] = shapeArguments[0].to_lower()  # VoXeL -> voxel
			var shape = shapes.get(shapeArguments[0])
			if shape != null:  # if ("box")shapeArguments[0] is known
				if numOfShapeArguments-1 >= shape[0] or shape[2] == "":
					selection = shapeArguments[0]  # ex) selection status: voxel
					
				if shapeArguments[0] == "hotbarSelection":
					shapeArguments[0] = hotbar[hotbarSelection][0]
				var validForm : bool = true  # valid arguments?
				
				if numOfShapeArguments > 1:  # does any arg exists after voxel? "voxel 0,0,2"
					# verify arguments
					for shapeArgumentIndex in range(1, numOfShapeArguments):
						match shape[1][shapeArgumentIndex-1]:
							TYPE_VECTOR3:
								if not G.isValidVector3(shapeArguments[shapeArgumentIndex]):
									validForm = false
							_:
								validForm = false
						if not validForm:
							output += "Invalid shape argument!\n"
							break
						selection += " "+shapeArguments[shapeArgumentIndex]  # selection status: voxel 0,0,2
					
					if numOfShapeArguments-1 >= shape[0]:  # if enough shape arguments to get it done at once
						selection += "\n"
						if validForm:
							selectionGroups[groupSelection] = selectionGroups.get(groupSelection, "") + selection
							output += "selectionGroup <"+groupSelection+">:\n"
							output += "       "+selectionGroups[groupSelection].replace("\n", "\n       ")
					else:
						if shape[2].split(" ", false).size()-1 < shape[0]:
							shape[2] += selection
						
						if shape[2].split(" ", false).size()-1 == shape[0]:
							shape[2] += "\n"
							if validForm:
								selectionGroups[groupSelection] = selectionGroups.get(groupSelection, "") + shape[2]
								output += "selectionGroup <"+groupSelection+">:\n"
								output += "       "+selectionGroups[groupSelection].replace("\n", "\n       ")
						print(shape[2])
				else:
					output += "No arguments of shape!\n"
			else:
				output += "Unknown shape!\n"
	else:  # only flag is detected
		output += "No shape arguments!\n"
	
	var toMerge = argParser.getStrings("merge")  # flag merge
	if toMerge.size() > 0 :
		var merged : String
		for toM in toMerge:
			merged += selectionGroups.get(toM, "")
		selectionGroups[groupSelection] = selectionGroups.get(groupSelection, "") + merged
		output += "selectionGroup <"+groupSelection+">:\n"
		output += "       "+selectionGroups[groupSelection].replace("\n", "\n       ")
	
	if output == "":
		return null
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
