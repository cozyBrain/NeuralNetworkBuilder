extends Node

const ID : String = "SupervisedLearningTrainer"

onready var selector = get_node("../Selector")

enum gi {  # group index
	NetworkController, InputLayer, GoalLayer, DataSetsGroups
}

const groupComponent = ["_SLT_networkController", "_SLT_inputLayer", "_SLT_goalLayer", {}]  # [NetworkControllerSelection, InputLayerSelection, GoalLayerSelection, IL&GL_dataSetsGroupsForTraining{}]
var networkGroups : Dictionary = {G.defaultGroupName : groupComponent.duplicate(true)}
var groupSelection : String = G.defaultGroupName  # networkGroupSelection
var dataSetsGroupSelection : String = G.defaultGroupName

# Tool SupervisedLearningTrainer -add  # add DataSet into IL&GL_DataSets{"_default":[]}
# Tool SupervisedLearningTrainer -train 7 -shuffle  # -g _default -nc _SLT_NetworkController -il _SLT_InputLayer -ol _SLT_GoalLayer
# Tool SupervisedLearningTrainer -train 77 -i 20 -v
# Tool SupervisedLearningTrainer -ds dog -add  # add DataSet into IL&GL_DataSets{"dog":[]}

func handle(arg : String):
	var output : String
	var argParser = ArgParser.new(arg)
	groupSelection = argParser.getString(["group", "g"], groupSelection)
	dataSetsGroupSelection = argParser.getString(["dataSetsGroupSelection", "ds"], dataSetsGroupSelection)
	var listArguments = argParser.getStrings(["list", "ls"])
	var eraseArguments = argParser.getStrings(["erase", "e"])
	var addArguments = argParser.getStrings(["add", "a"])
	var trainArgument = argParser.getString(["train", "t"])
	var visualizeProgress = argParser.getBool(["visualizeProgress", "v"])
	var iterationPerDataSet = argParser.getString(["iterationPerDataSet", "i"], "20")
	if iterationPerDataSet.is_valid_integer():
		iterationPerDataSet = int(iterationPerDataSet)
	else:
		iterationPerDataSet = 20
	
	# group
	if not networkGroups.has(groupSelection):
		networkGroups[groupSelection] = groupComponent.duplicate(true)
	
	networkGroups[groupSelection][gi.NetworkController] = argParser.getString(["networkController", "nc"], networkGroups[groupSelection][gi.NetworkController])
	networkGroups[groupSelection][gi.InputLayer] = argParser.getString(["inputLayer", "il"], networkGroups[groupSelection][gi.InputLayer])
	networkGroups[groupSelection][gi.GoalLayer] = argParser.getString(["goalLayer", "gl"], networkGroups[groupSelection][gi.GoalLayer])
	
	var addArgumentsSize : int
	if addArguments != null:
		addArgumentsSize = addArguments.size()
		if addArgumentsSize > 0:
			dataSetsGroupSelection = addArguments[0]
	if addArguments == null or addArgumentsSize > 0:
		# get nodes from selection group
		var inputLayerNodes = selector.getNodesFromSelectionGroup(networkGroups[groupSelection][gi.InputLayer])
		var goalLayerNodes = selector.getNodesFromSelectionGroup(networkGroups[groupSelection][gi.GoalLayer])
		
		if not networkGroups[groupSelection][gi.DataSetsGroups].has(dataSetsGroupSelection):
			networkGroups[groupSelection][gi.DataSetsGroups][dataSetsGroupSelection] = []  # dataSets
		var dataSet = []
		for node2scan in inputLayerNodes+goalLayerNodes:
			dataSet.append([node2scan.translation, node2scan.get("Output")])
		# dataSet: [[t,o],[t,o],[t,o]]
		networkGroups[groupSelection][gi.DataSetsGroups][dataSetsGroupSelection].append(dataSet)
		output += "Added\n"
	
	if trainArgument != null:
		if not trainArgument.is_valid_integer():
			output += "Invalid train argument\n"
		else:
			var networkControllerNodes = selector.getNodesFromSelectionGroup(networkGroups[groupSelection][gi.NetworkController])
			for _i in range(int(trainArgument)):
				for dataSet in networkGroups[groupSelection][gi.DataSetsGroups][dataSetsGroupSelection]:  # for dataSet in dataSets
					for data2applyIndex in range(dataSet.size()):  # data2apply:[t, o],  dataSet:[[t,o],[t,o],[t,o]]
						var node2set = G.default_world.getNode(dataSet[data2applyIndex][0])
						if node2set == null:
							dataSet.remove(data2applyIndex)
							continue
						node2set.set("Output", dataSet[data2applyIndex][1])
					for networkControllerNode in networkControllerNodes:
						for _j in range(iterationPerDataSet):
							networkControllerNode.propagate()
							networkControllerNode.backpropagate()
							networkControllerNode.visualize()
							if visualizeProgress:
								yield(get_tree(), "physics_frame")
	
	# erase
	if eraseArguments == null:
		output += "No erase arguments!\n"
	elif eraseArguments.size() > 0:
		eraseArguments[0] = eraseArguments[0].to_lower()
		match eraseArguments[0]:
			"g", "group":
				if eraseArguments.size() >= 2:
					for argIndex in range(1, eraseArguments.size()):
						if not networkGroups.erase(eraseArguments[argIndex]):
							output += "networkGroups \""+eraseArguments[argIndex]+"\" doesn't exist\n"
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
					var groups = networkGroups.keys()
					for group in groups:
						output += "       " + group + "\n"
			_:
				output += "Unknown list argument!\n"
	
	print(networkGroups[groupSelection][gi.DataSetsGroups])
	
	if output == "":
		return null
	return output
