extends Node

const ID : int = G.ID.S

export (String) var selectionIndicatorResource = "res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
onready var pointer = get_node("../Pointer")

var shapes : Dictionary = {
	"voxel" : [1, [TYPE_VECTOR3], ""],  # min arguments, [arguments types], stacked arguments
	"box" : [2, [TYPE_VECTOR3, TYPE_VECTOR3], ""],
	"sphere" : [2, [TYPE_VECTOR3, TYPE_REAL], ""]
}

var hotbar : Array = ["voxel", "box"]
var hotbarSelection : int

var selectionGroups : Dictionary = {
	"_default" : ["",[]]  # [selection, selectionIndicatingObjects]
}
var groupSelection : String = "_default"

# Tool Selector -shape hotbarSelection voxel 0,0,2  -> default: "voxel 0,0,2\n"
# Tool Selector -g group1 -shape voxel 0,0,2        -> group1 : "voxel 0,0,2\n"  
# Tool Selector -g group2 -shape box   0,0,2 0,0,4  -> group2 : "box 0,0,2 0,0,4\n"
# Tool Selector -g merged -merge group1 group2      -> merged : "voxel 0,0,2\nbox 0,0,2 0,0,4\n"
# not recommended to use merge, shape flags at the same line.
func handle(arg : String):
	var output : String
	var argParser = ArgParser.new(arg)
	groupSelection = argParser.getString("g", groupSelection, false)  # flag group
	var listArguments = argParser.getStrings(["list", "ls"])  # flag list
	var eraseArguments = argParser.getStrings(["erase", "e"])  # flag erase
	var shapeArguments = argParser.getStrings(["shape", "s"])  # flag shape
	var mergeArguments = argParser.getStrings(["merge", "m"])  # flag merge
	
	var selection : String  # "voxel 0,0,2\n"
	
	if not selectionGroups.has(groupSelection):
		selectionGroups[groupSelection] = ["", []]
	
	if listArguments == null:  # flag is detected but no arguments
		output += "No list arguments!\n"
	else:
		if listArguments.size() > 0:
			listArguments[0] = listArguments[0].to_lower()
			match listArguments[0]:
				"g", "group":
					if listArguments.size() >= 2:
						for argIndex in range(1, listArguments.size()):
							var group = selectionGroups.get(listArguments[argIndex], null)
							if group == null:
								output += "selectionGroup \""+listArguments[argIndex]+"\" doesn't exist"
							else:
								output += "selectionGroup <"+listArguments[argIndex]+">:\n" + "       "+group[0].replace("\n", "\n       ")
							output += "\n"
					else:
						output += "<selection groups>:\n"
						var groups = selectionGroups.keys()
						for group in groups:
							output += "       " + group + "\n"
				_:
					output += "Unknown list argument!\n"
	
	if eraseArguments == null:
		output += "No erase arguments!\n"
	else:
		if eraseArguments.size() > 0:
			eraseArguments[0] = eraseArguments[0].to_lower()
			match eraseArguments[0]:
				"g", "group":
					if eraseArguments.size() >= 2:
						for argIndex in range(1, eraseArguments.size()):
							if eraseArguments[argIndex] == "_default":
								output += eraseArguments[argIndex]+" can't be erased!"
							if not eraseGroup(eraseArguments[argIndex]):
								output += "selectionGroup \""+eraseArguments[argIndex]+"\" doesn't exist"
					else:
						output += "No group argument!\n"
				_:
					output += "Unknown erase argument!\n"
	
	if shapeArguments == null:
		output += "No shape arguments!\n"
	else:  # only flag is detected
		var numOfShapeArguments = shapeArguments.size()
		# print(numOfShapeArguments, shapeArguments)
		if numOfShapeArguments >= 1:
			shapeArguments[0] = shapeArguments[0].to_lower()  # VoXeL -> voxel
			if shapeArguments[0] == "hotbarselection":
				shapeArguments[0] = hotbar[hotbarSelection]
			var shape = shapes.get(shapeArguments[0])
			if shape == null:  # if ("box")shapeArguments[0] is unknown
				output += "Unknown shape!\n"
			else:
				if numOfShapeArguments-1 >= shape[0] or shape[2] == "":
					selection = shapeArguments[0]  # ex) selection status: voxel
					
				var validForm : bool = true  # valid arguments?
				
				if not numOfShapeArguments > 1:  # does any arg exists after voxel? "voxel 0,0,2"
					output += "No arguments of shape!\n"
				else:
					# verify arguments
					for shapeArgumentIndex in range(1, clamp(numOfShapeArguments, 1, shape[0]+1)):  # voxel 0,0,2 0,0,4 -> voxel 0,0,2 : ignore needless arguments
						var shapeTypeArgOffset : int = shape[2].split(" ", false).size()
						if numOfShapeArguments-1 >= shape[0]:
							shapeTypeArgOffset = 0
						else:
							if shapeTypeArgOffset > 0:
								shapeTypeArgOffset -= 1
						if shapeTypeArgOffset+shapeArgumentIndex-1 > shape[0]-1:
							break
						if shapeArguments[shapeArgumentIndex].to_lower() == "pointerposition":
							shapeArguments[shapeArgumentIndex] = str(pointer.getPointerPosition()).replace(" ", "")
						match shape[1][shapeTypeArgOffset+shapeArgumentIndex-1]:
							TYPE_VECTOR3:
								if not G.isValidVector3(shapeArguments[shapeArgumentIndex]):
									validForm = false
							TYPE_REAL:
								if not shapeArguments[shapeArgumentIndex].is_valid_float():
									validForm = false
							_:
								validForm = false
						if not validForm:
							output += "Invalid shape argument!\n"
							break
						selection += " "+shapeArguments[shapeArgumentIndex]  # selection status: voxel 0,0,2
						
					if validForm:  # indicate selection
						if numOfShapeArguments-1 >= shape[0]:  # if enough shape arguments to get it done at once
							selection += "\n"
							addSelection(selection)
							output += "selectionGroup <"+groupSelection+">:\n" + "       "+selectionGroups[groupSelection][0].replace("\n", "\n       ")
						else:
							if shape[2].split(" ", false).size()-1 < shape[0]:
								shape[2] += selection
							if shape[2].split(" ", false).size()-1 >= shape[0]:
								shape[2] += "\n"
								addSelection(shape[2])
								shape[2] = ""
								output += "selectionGroup <"+groupSelection+">:\n" + "       "+selectionGroups[groupSelection][0].replace("\n", "\n       ")
	
	if mergeArguments != null:
		if mergeArguments.size() > 0 :
			var merged : String
			for toM in mergeArguments:
				merged += selectionGroups.get(toM, "")[0]
			addSelection(merged)
			output += "selectionGroup <"+groupSelection+">:\n" + "       "+selectionGroups[groupSelection][0].replace("\n", "\n       ")
	else:
		output+="No merge arguments!\n"
	
	if output == "":
		return null
	return output

func addSelection(selection : String):
	selectionGroups[groupSelection][0] = selectionGroups.get(groupSelection, "")[0] + selection
	# parse selection to add to for indication
	var shapeArguments = selection.replace("\n", "").split(" ", false)  # remove \n and split
	var selectionIndicator = load(selectionIndicatorResource).instance()
	match shapeArguments[0]:  # box? voxel? or what?
		"voxel":
			selectionIndicator.translation = G.str2vector3(shapeArguments[1])
			G.default_session.addNode(selectionIndicator)
			selectionGroups[groupSelection][1].append(selectionIndicator)
		"box":  # boxAddNode(node, from, to)
			var from : Vector3 = G.str2vector3(shapeArguments[1])
			var to   : Vector3 = G.str2vector3(shapeArguments[2])
			var xScale = abs(from.x - to.x) + 1
			var yScale = abs(from.y - to.y) + 1
			var zScale = abs(from.z - to.z) + 1
			selectionIndicator.resize(Vector3(xScale, yScale, zScale))
			selectionIndicator.translation = (from + to) / 2
			G.default_session.addNode(selectionIndicator)
			selectionGroups[groupSelection][1].append(selectionIndicator)
		_:
			pass
func eraseGroup(groupName):
	var sg = selectionGroups.get(groupName)
	if sg == null:
		return false
	for selectionIndicator in sg[1]:
		selectionIndicator.queue_free()
	selectionGroups.erase(groupName)
	return true
