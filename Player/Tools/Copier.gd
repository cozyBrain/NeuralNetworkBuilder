extends Node

const ID : String = "Copier"

onready var pointer = get_node("../Pointer")
onready var selector = get_node("../Selector")

const groupComponent = []
var copyGroups : Dictionary = {G.defaultGroupName : groupComponent.duplicate(true)}
var groupSelection : String = G.defaultGroupName

# Tool Copier -g _default -copy _default                         # copy selection(_default) to copyGroups(_default)
# Tool Copier -g _default -paste                                 # paste _default copyGroup
# Tool Copier -g _default -paste 7 0,0,2 -link 0    			 # n=7,stride=0,0,2(frontDirectionAsDefault) linkDepth=0

func handle(arg : String):
#	https://godotengine.org/qa/16647/copy-and-saving-nodes
#	var new_node = source_node.duplicate()
#	for property in source_node.get_property_list():
#   	 # Script only properties/vars
#    	if(property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE): 
#       	 new_node[property.name] = source_node[property.name]
	var output : String
	var pointerPosition = pointer.getPointerPosition()
	var argParser = ArgParser.new(arg)
	groupSelection = argParser.getString(["group", "g"], groupSelection)
	var listArguments = argParser.getStrings(["list", "ls"])
	var eraseArguments = argParser.getStrings(["erase", "e"])
	
	var copyArguments = argParser.getStrings(["copy", "c"]) 
	var deepCopy = argParser.getBool(["deep", "d"])  # copy variables too.
	var pasteArguments = argParser.getStrings(["paste", "p"])
	var strideArguments = argParser.getStrings(["stride", "s"])
	var linkArguments = argParser.getStrings(["link", "l"])  # -link <Ilink:-1:IlinkDepthOrOlinkDepth> <Olink:2:IlinkDepthOrOlinkDepth>
	var createNodeOverLink = argParser.getBool(["createNodeOverLink", "createOverLink", "col"])  # not yet
	
	var overrideArguments = argParser.getStrings(["override", "o"])  # -override node : override only node
	var overrideNode : bool = false
	var overrideLink : bool = false
	if overrideArguments == null:
		overrideNode = true
		overrideLink = true
	elif overrideArguments.size() > 0:
		for arg in overrideArguments:
			arg = arg.to_lower()
			if arg == "node" or arg == "n":
				overrideNode = true
			elif arg == "link" or arg == "l":
				overrideLink = true
	# get link depth; not_yet: use linkDepth when copy
	var IlinkDepth : int = 0
	var OlinkDepth : int = 0
	if linkArguments == null:
		output += "No link arguments!\nusage: -link <Ilink:-1:IlinkDepthOrOlinkDepth> <Olink:2:IlinkDepthOrOlinkDepth>"
	elif linkArguments.size() > 0:
		for arg in linkArguments:
			if not arg.is_valid_integer():
				output += "Invalid arguments!\n"
				break
			arg = int(arg)
			if arg > 0:
				OlinkDepth = arg
			elif arg < 0:
				IlinkDepth = arg
	
	
	# group
	if not copyGroups.has(groupSelection):
		copyGroups[groupSelection] = groupComponent.duplicate(true)
	
	var selectionGroup2copy : String = G.defaultGroupName
	var copyArgumentsSize : int
	if copyArguments != null:
		copyArgumentsSize = copyArguments.size()
		if copyArgumentsSize > 0:
			selectionGroup2copy = copyArguments[0]
	if copyArguments == null or copyArgumentsSize > 0:
		# get nodes from selection group
		if not selector.selectionGroups.has(selectionGroup2copy):
			output += "SelectionGroup \""+selectionGroup2copy+"\" doesn't exist!\n"
		else:
			var nodes2copy = selector.getNodesFromSelectionGroup(selectionGroup2copy)
			# copiedNode.translation = copiedNode.translation - pointerPosition
			if pointerPosition == null:
				output += "No pointer position detected!\nIf your pointer mode is rayCast please aim at detectable node.\n"
			else:
				copyGroups[groupSelection].clear()
				for node2copy in nodes2copy:
					if not copyGroups.has(groupSelection):
						output += "CopyGroup \""+groupSelection+"\" doesn't exist!\n"
					else:
						var copiedNode = node2copy.duplicate(DUPLICATE_GROUPS|DUPLICATE_SIGNALS|DUPLICATE_SCRIPTS)
						copiedNode.translation -= pointerPosition
						if deepCopy:
							G.copyVariables(node2copy, copiedNode)  # deep copy such as Output Ilinks DictionaryVar
						copyGroups[groupSelection].append(copiedNode)
				output += "Copied\n"
	
	if pasteArguments == null:
		if copyGroups.has(groupSelection):
			var copies2add = copyGroups[groupSelection]
			if pointerPosition == null:
				output += "No pointer position detected!\nIf your pointer mode is rayCast please aim at detectable node.\n"
			else:
				for copy2add in copies2add:
					var copy = copy2add.duplicate(DUPLICATE_GROUPS|DUPLICATE_SIGNALS|DUPLICATE_SCRIPTS)
					G.copyVariables(copy2add, copy)
					if pointerPosition == null:
						output += "No pointer position detected!\nIf your pointer mode is rayCast please aim at detectable object.\n"
					else:
						copy.translation += pointerPosition
						G.default_world.addNode(copy, overrideNode)
						output += "Pasted\n"
	elif pasteArguments.size() > 0:
		if not pasteArguments.size() >= 2:
			output += "Yet, doesn't support default stride. more arguments required: -paste <3:howManyTimesToCopy> <0,0,1:stride>\n"
		else:
			if not pasteArguments[0].is_valid_integer() or not G.isValidVector3(pasteArguments[1]):
				output += "Invalid arguments!\nusage: -paste <6:howManyTimesToCopy> <0,0,-11:stride>\n"
			else:
				if pointerPosition == null:
					output += "No pointer position detected!\nIf your pointer mode is rayCast please aim at detectable node.\n"
				else:
					var pasteCount = int(pasteArguments[0])
					var stride = G.str2vector3(pasteArguments[1])
					var copies2add = copyGroups[groupSelection]
					# paste Nodes first #######################################
					for step in range(1, pasteCount+1):
						for copy2add in copies2add:
							var copy = copy2add.duplicate(DUPLICATE_GROUPS|DUPLICATE_SIGNALS|DUPLICATE_SCRIPTS)
							if deepCopy:
								G.copyVariables(copy2add, copy)
							copy.translation += pointerPosition + step*stride
							G.default_world.addNode(copy, overrideNode)
					output += "pasted nodes\n"
					# create links ############################################
					var linkCreator = get_parent().get_node("LinkCreator")
					for step in range(1, pasteCount+1):
						for copy2add in copies2add:
							var node2link = G.default_world.getNode(copy2add.translation + pointerPosition + step*stride)
							var Olinks = copy2add.get("Olinks")
							if Olinks != null:
								for Olink in Olinks:
									var newSynapse = linkCreator.create(node2link, G.default_world.getNode(Olink.Onodes[0].translation + step*stride))
									if newSynapse != null:
										G.default_world.addLink(newSynapse)
							var Ilinks = copy2add.get("Ilinks")
							if Ilinks != null:
								for Ilink in Ilinks:
									var newSynapse = linkCreator.create(G.default_world.getNode(Ilink.Inodes[0].translation + step*stride), node2link)
									if newSynapse != null:
											G.default_world.addLink(newSynapse)
						output += "Linked\n"
	
	# erase
	if eraseArguments == null:
		output += "No erase arguments!\n"
	elif eraseArguments.size() > 0:
		eraseArguments[0] = eraseArguments[0].to_lower()
		match eraseArguments[0]:
			"g", "group":
				if eraseArguments.size() >= 2:
					for argIndex in range(1, eraseArguments.size()):
						if not copyGroups.erase(eraseArguments[argIndex]):
							output += "copyGroups \""+eraseArguments[argIndex]+"\" doesn't exist\n"
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
#						for argIndex in range(1, listArguments.size()):
					pass
				else:
					output += "<selection groups>:\n"
					var groups = copyGroups.keys()
					for group in groups:
						output += "       " + group + "\n"
			_:
				output += "Unknown list argument!\n"
	
	if output == "":
		return null
	return output
