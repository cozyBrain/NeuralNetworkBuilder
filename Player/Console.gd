extends Control

func _ready():
	pass

const validCommands = {
	"Tool" : "Use console compatible tools.\n	Usage: Tool (Tool you want) (arguments).\n	Press shift+T to access selected tool quickly.",
	"saveWorld" : "Save data\n",
	"loadWorld" : "Load data\n",
}
const toolsPath = "../Tools/"

onready var player = get_parent()
onready var inputBox = get_node("VBoxContainer/HBoxContainer/Input")
onready var outputBox = get_node("VBoxContainer/Output")

var history : Array
var historyIndex : int

func processCommand(text):
	history.push_front(text)
	historyIndex = -1
	var words = text.split(" ", false, 1)  # [command, arguments]
	while words.size() < 2:
		words.push_back("")

	if validCommands.has(words[0]):
		var output = call(words[0], words[1])
		if output != null:
			println(output)
	else:
		println("invalid command")

func saveWorld(fileName : String):
	var sd = saveData.new()
	
	for saveLayerIndex in range(sd.saveLayerRangeBegin, sd.saveLayerRangeEnd):
		var saveLayerGroupName = "saveLayer"+str(saveLayerIndex)
		var saveLayer : Dictionary = {}
		sd.data[saveLayerGroupName] = saveLayer
		sd.data[saveLayerGroupName]["nodes"] = []
		sd.data[saveLayerGroupName]["links"] = []
		for component in get_tree().get_nodes_in_group(saveLayerGroupName):
			if component.has_method("getSaveData"):
				var componentSaveData = component.getSaveData()
				if component.is_in_group("node"):
					saveLayer["nodes"].append(componentSaveData)
				elif component.is_in_group("link"):
					saveLayer["links"].append(componentSaveData)
	ResourceSaver.save("res://saves/"+fileName+".res", sd, ResourceSaver.FLAG_COMPRESS)

func loadWorld(fileName : String):
	#load sd(SaveData)
	var sdDir = Directory.new()
	if not sdDir.file_exists("res://saves/"+fileName+".res"):
		return "failed to load world: file \""+fileName+"\" doesn't exist!\n"
	var sd = load("res://saves/"+fileName+".res")
	
	#free all components in group save
	for saveLayerIndex in range(sd.saveLayerRangeBegin, sd.saveLayerRangeEnd):
		var saveLayerGroupName = "saveLayer"+str(saveLayerIndex)
		for component in get_tree().get_nodes_in_group(saveLayerGroupName):
			if component.is_in_group("node"):
				G.default_world.eraseNode(component)
			elif component.is_in_group("link"):
				G.default_world.eraseLink(component)
	
	#load all components from saveData
	for saveLayerIndex in range(sd.saveLayerRangeBegin, sd.saveLayerRangeEnd):
		var saveLayerGroupName = "saveLayer"+str(saveLayerIndex)
		var saveLayer = sd.data.get(saveLayerGroupName)
		if saveLayer:
			#load nodes fist  ah ha.. networkControllerNodeNeedToBeLoadedLater. hmm
			for componentData in saveLayer["nodes"]:
				var componentData_ID = componentData.get("ID")
				if componentData_ID:
					var loadedComponent = load("res://Components/" + componentData_ID + "/" + componentData_ID + ".tscn").instance()
					#set translation before addNode then, loadSaveData from componentData
					loadedComponent.set("translation", componentData["translation"])
					componentData.erase("translation")
#					addNode before loadSaveData
#					because loadSaveData before addNode causes issue on networkControllerNode: can't analyze itself
					G.default_world.addNode(loadedComponent)
					loadedComponent.loadSaveData(componentData)
			#load links
			for componentData in saveLayer["links"]:
				var componentData_ID = componentData.get("ID")
				if componentData_ID:
					var loadedComponent = load("res://Components/" + componentData_ID + "/" + componentData_ID + ".tscn").instance()
					loadedComponent.loadSaveData(componentData)
					G.default_world.addLink(loadedComponent)


func Tool(arg : String):
	var splittedArg = arg.split(" ", false, 1)  # [command, arguments]
	while splittedArg.size() < 2:
		splittedArg.push_back("")

	var Tool = get_node_or_null(toolsPath + splittedArg[0])
	if Tool == null:  # when the tool doesn't exist
		return str("Tool \"", splittedArg[0], "\" doesn't exist!\n")
		
	var output = Tool.handle(splittedArg[1])
	return output

func crawlHistory(step : int) -> void:
	if history.size() > 0:
		historyIndex = clamp(historyIndex+step, -1, history.size()-1)
		if historyIndex < 0:
			inputBox.text = ""
		else:
			inputBox.text = history[historyIndex]
			inputBox.set_cursor_position(inputBox.text.length())
	pass

func println(text):
	outputBox.text = str(outputBox.text, "\n", text)

func grab_focus():
	inputBox.grab_focus()
