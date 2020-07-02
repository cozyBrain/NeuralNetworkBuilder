extends Node

const ID : String = "Selector"

export (String) var selectionIndicatorResource = "res://Components/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn"
onready var pointer = get_node("../Pointer")

var SHAPES : Dictionary = {
	"voxel" : [1, [TYPE_VECTOR3], ""],  # min num of arguments, [arguments types], stacked arguments
	"box" : [2, [TYPE_VECTOR3, TYPE_VECTOR3], ""],
	"sphere" : [2, [TYPE_VECTOR3, TYPE_REAL], ""]
}

var hotbar : Array = ["voxel", "box"]
var hotbarSelection : int

const groupComponent = ["",[]]  # [selection, selectionIndicatingObjects]
var selectionGroups : Dictionary = {G.defaultGroupName : groupComponent.duplicate(true)}
var groupSelection : String = G.defaultGroupName

# Tool Selector -shape hotbarSelection voxel 0,0,2  -> default: "voxel 0,0,2\n"
# Tool Selector -g group1 -shape voxel 0,0,2        -> group1 : "voxel 0,0,2\n"  
# Tool Selector -g group2 -shape box   0,0,2 0,0,4  -> group2 : "box 0,0,2 0,0,4\n"
# Tool Selector -g merged -merge group1 group2      -> merged : "voxel 0,0,2\nbox 0,0,2 0,0,4\n"
# not recommended to use merge, shape flags at the same line.
func handle(arg : String):
	var output : String
	var argParser = ArgParser.new(arg)
	groupSelection = argParser.getString(["group", "g"], groupSelection)  # flag group
	var listArguments = argParser.getStrings(["list", "ls"])  # flag list
	var eraseArguments = argParser.getStrings(["erase", "e"])  # flag erase
	var shapeArguments = argParser.getStrings(["shape", "s"])  # flag shape
	var mergeArguments = argParser.getStrings(["merge", "m"])  # flag merge
	
	var selection : String  # "voxel 0,0,2\n"
	
	# group
	if not selectionGroups.has(groupSelection):
		selectionGroups[groupSelection] = groupComponent.duplicate(true)
	
	# shape
	if shapeArguments == null:
		output += "No shape arguments!\n"
	else:  # only flag is detected
		var numOfShapeArguments = shapeArguments.size()
		# print(numOfShapeArguments, shapeArguments)
		if numOfShapeArguments >= 1:
			shapeArguments[0] = shapeArguments[0].to_lower()  # VoXeL -> voxel
			if shapeArguments[0] == "hotbarselection":
				shapeArguments[0] = hotbar[hotbarSelection]
			var SHAPE = SHAPES.get(shapeArguments[0])
			if SHAPE == null:  # if ("box")shapeArguments[0] is unknown
				output += "Unknown SHAPE!\n"
			else:
				if numOfShapeArguments-1 >= SHAPE[0] or SHAPE[2] == "":
					selection = shapeArguments[0]  # ex) selection status: voxel
					
				var validForm : bool = true  # valid arguments?
				
				if not numOfShapeArguments > 1:  # does any arg exists after voxel? "voxel 0,0,2"
					output += "No arguments of SHAPE!\n"
				else:
					# verify arguments
					for shapeArgumentIndex in range(1, clamp(numOfShapeArguments, 1, SHAPE[0]+1)):  # voxel 0,0,2 0,0,4 -> voxel 0,0,2 : ignore needless arguments
						var shapeTypeArgOffset : int = SHAPE[2].split(" ", false).size()
						if numOfShapeArguments-1 >= SHAPE[0]:
							shapeTypeArgOffset = 0
						else:
							if shapeTypeArgOffset > 0:
								shapeTypeArgOffset -= 1
						if shapeTypeArgOffset+shapeArgumentIndex-1 > SHAPE[0]-1:
							break
						if shapeArguments[shapeArgumentIndex].to_lower() == "pointerposition":
							shapeArguments[shapeArgumentIndex] = str(pointer.getPointerPosition()).replace(" ", "")
						match SHAPE[1][shapeTypeArgOffset+shapeArgumentIndex-1]:
							TYPE_VECTOR3:
								if not G.isValidVector3(shapeArguments[shapeArgumentIndex]):
									validForm = false
							TYPE_REAL:
								if not shapeArguments[shapeArgumentIndex].is_valid_float():
									validForm = false
							_:
								validForm = false
						if not validForm:
							output += "Invalid SHAPE argument!\n"
							break
						selection += " "+shapeArguments[shapeArgumentIndex]  # selection status: voxel 0,0,2
						
					if validForm:  # indicate selection
						if numOfShapeArguments-1 >= SHAPE[0]:  # if enough SHAPE arguments to get it done at once
							selection += "\n"
							addSelection(selection)
							output += "selectionGroup <"+groupSelection+">:\n" + "       "+selectionGroups[groupSelection][0].replace("\n", "\n       ")
						else:
							if SHAPE[2].split(" ", false).size()-1 < SHAPE[0]:
								SHAPE[2] += selection
								output += selection
							if SHAPE[2].split(" ", false).size()-1 >= SHAPE[0]:
								SHAPE[2] += "\n"
								addSelection(SHAPE[2])
								SHAPE[2] = ""
								output += "selectionGroup <"+groupSelection+">:\n" + "       "+selectionGroups[groupSelection][0].replace("\n", "\n       ")
	
	# merge
	if mergeArguments == null:
		output+="No merge arguments!\n"
	elif mergeArguments.size() > 0 :
		var merged : String
		for toM in mergeArguments:
			merged += selectionGroups.get(toM, groupComponent.duplicate(true))[0]
		addSelection(merged)
		output += "selectionGroup <"+groupSelection+">:\n" + "       "+selectionGroups[groupSelection][0].replace("\n", "\n       ")
	
	# erase
	if eraseArguments == null:
		output += "No erase arguments!\n"
	elif eraseArguments.size() > 0:
		eraseArguments[0] = eraseArguments[0].to_lower()
		match eraseArguments[0]:
			"g", "group":
				if eraseArguments.size() >= 2:
					for argIndex in range(1, eraseArguments.size()):
						if not eraseGroup(eraseArguments[argIndex]):
							output += "selectionGroup \""+eraseArguments[argIndex]+"\" doesn't exist"
				else:
					output += "No group argument!\n"
			_:
				output += "Unknown erase argument!\n"
	
	# list
	if listArguments == null:  # only flag is detected no arguments
		output += "No list arguments!\n"
	elif listArguments.size() > 0:
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
	
	if output == "":
		return null
	return output

func addSelection(selection : String) -> String:
	var output : String = selection
	selectionGroups[groupSelection][0] = selectionGroups.get(groupSelection, groupComponent.duplicate(true))[0] + selection
	# parse selection to indicate selection area
	var shapeArguments = selection.replace("\n", "").split(" ", false)  # remove \n and split
	var selectionIndicator = load(selectionIndicatorResource).instance()
	match shapeArguments[0]:
		"voxel":
			selectionIndicator.translation = G.str2vector3(shapeArguments[1])
			G.default_world.overlapNode(selectionIndicator)
			selectionGroups[groupSelection][1].append(selectionIndicator)
		"box":  # boxAddNode(node, from, to)
			var from : Vector3 = G.str2vector3(shapeArguments[1])
			var to   : Vector3 = G.str2vector3(shapeArguments[2])
			var xScale = abs(from.x - to.x) + 1
			var yScale = abs(from.y - to.y) + 1
			var zScale = abs(from.z - to.z) + 1
			selectionIndicator.resize(Vector3(xScale, yScale, zScale))
			selectionIndicator.translation = (from + to) / 2
			G.default_world.overlapNode(selectionIndicator)
			selectionGroups[groupSelection][1].append(selectionIndicator)
		var exception:
			print("Exception in Selector func addSelection: ", exception)
	return output

func getNodesFromSelectionGroup(groupName2parse : String = G.defaultGroupName) -> Array:
	var selections = selectionGroups.get(groupName2parse, groupComponent.duplicate(true))[0].split("\n", false)
	
	var nodes : Array
	for selection in selections:
		var shapeArguments = selection.replace("\n", "").split(" ", false)  # remove \n and split
		match shapeArguments[0]:
			"voxel":
				nodes.append(G.default_world.getNode(G.str2vector3(shapeArguments[1])))
			"box":  # box 0,0,0 -2,0,2
				var from : Vector3 = G.str2vector3(shapeArguments[1])
				var to   : Vector3 = G.str2vector3(shapeArguments[2])
				var dvec : Vector3
				var ivec : Vector3 = from
				dvec.x = 1 if from.x < to.x else -1
				dvec.y = 1 if from.y < to.y else -1
				dvec.z = 1 if from.z < to.z else -1
				# iteration
				for z in range(from.z, to.z+dvec.z, dvec.z):
					for y in range(from.y, to.y+dvec.y, dvec.y):
						for x in range(from.x, to.x+dvec.x, dvec.x):
							#print(Vector3(x,y,z))
							var node = G.default_world.getNode(Vector3(x,y,z))
							if node != null:
								nodes.append(node)
			var exception:
				print("Exception in Selector func getNodesFromSelectionGroup: ", exception)
	
	return nodes

func eraseGroup(groupName):
	var sg = selectionGroups.get(groupName)
	if sg == null:
		return false
	for selectionIndicator in sg[1]:
		selectionIndicator.queue_free()
	selectionGroups.erase(groupName)
	return true
