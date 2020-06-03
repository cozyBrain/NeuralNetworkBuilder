extends Node

# how to duplicate inside variables too?

const ID : int = G.ID.C

onready var pointer = get_node("../Pointer")
onready var selector = get_node("../Selector")

var copyGroups : Dictionary = {G.defaultGroupName : []}
var groupSelection : String = G.defaultGroupName

# Tool Copier -g _default -copy _default                         # copy selection(_default) to copyGroups(_default)
# Tool Copier -g _default -paste                                 # paste _default copyGroup
# Tool Copier -g _default -paste 7 -link 0    					 # stride=7(frontDirectionAsDefault) linkDepth=0

func handle(arg : String):
	var output : String
	var argParser = ArgParser.new(arg)
	groupSelection = argParser.getString("g", groupSelection, false)
	var listArguments = argParser.getStrings(["list", "ls"])
	var eraseArguments = argParser.getStrings(["erase", "e"])
	
	var copyArguments = argParser.getStrings(["copy", "c"]) 
	var pasteArguments = argParser.getStrings(["paste", "p"])
	# override
	var overrideArguments = argParser.getStrings(["override", "o"])  # -override node : override only node
	var overrideNode : bool = false
	var overrideLink : bool = false
	if overrideArguments == null:
		overrideNode = true
		overrideLink = true
	elif overrideArguments.size() > 0:
		overrideArguments[0] = overrideArguments[0].to_lower()
		if overrideArguments[0] == "node" or overrideArguments[0] == "n":
			overrideNode = true
		elif overrideArguments[0] == "link" or overrideArguments[0] == "l":
			overrideLink = true
	
	var linkArguments = argParser.getStrings(["link", "l"])
	# var linkDepthArgument = argParser.getString()
	
	# group
	if not copyGroups.has(groupSelection):
		copyGroups[groupSelection] = []
	
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
			for node in nodes2copy:
				# stance of pointer
				var pointerPosition = pointer.getPointerPosition()
				if pointerPosition == null:
					output += "No pointer position detected!\nIf your pointer mode is rayCast please aim at detectable node.\n"
				else:
					if not copyGroups.has(groupSelection):
						output += "CopyGroup \""+groupSelection+"\" doesn't exist!\n"
					else:
						copyGroups[groupSelection].clear()
						var copiedNode = node.duplicate(DUPLICATE_GROUPS|DUPLICATE_SIGNALS|DUPLICATE_SCRIPTS)
						copiedNode.translation -= pointerPosition
						output += str("Copied ", copiedNode.translation, "\n")
						copyGroups[groupSelection].append(copiedNode)
	
	if pasteArguments == null:
		if copyGroups.has(groupSelection):
			var copies2add = copyGroups[groupSelection]
			var pointerPosition = pointer.getPointerPosition()
			for copy in copies2add:
				copy = copy.duplicate(DUPLICATE_GROUPS|DUPLICATE_SIGNALS|DUPLICATE_SCRIPTS)
				if pointerPosition == null:
					output += "No pointer position detected!\nIf your pointer mode is rayCast please aim at detectable node.\n"
				else:
					copy.translation += pointerPosition
					G.default_session.addNode(copy)
					output += str("Pasted ", copy.translation, "\n")
	else:
		pass
	
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

func eraseGroup(groupName):
	var cg = copyGroups.get(groupName)
	if cg == null:
		return false
	copyGroups.erase(groupName)
	return true
