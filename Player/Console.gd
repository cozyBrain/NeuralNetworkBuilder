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
	sd.data["nodes"] = []
	sd.data["links"] = []
	#var save = File.new()
	#save.open("user://bob", File.WRITE)
	for component in get_tree().get_nodes_in_group("save"):
		if component.has_method("getSaveData"):
			var componentSaveData = component.getSaveData()
			if component.is_in_group("node"):
				sd.data["nodes"].append(componentSaveData)
			elif component.is_in_group("link"):
				sd.data["links"].append(componentSaveData)
	ResourceSaver.save("res://saves/"+fileName+".res", sd, ResourceSaver.FLAG_COMPRESS)

func loadWorld(fileName : String):
	#free all components in group save
	for component in get_tree().get_nodes_in_group("save"):
		component.queue_free()
	
	#load sd(SaveData)
	var sdDir = Directory.new()
	if not sdDir.file_exists("res://saves/"+fileName+".res"):
		return "failed to load world: file \""+fileName+"\" doesn't exist!\n"
	var sd = load("res://saves/"+fileName+".res")
	
	#load nodes fist
	for componentData in sd.data["nodes"]:
		var componentDataID = componentData.get("ID")
		if componentDataID:
			var loadedComponent = load("res://Nodes/" + G.IDtoString[componentDataID] + "/" + G.IDtoString[componentDataID] + ".tscn").instance()
			loadedComponent.loadSaveData(componentData)
			G.default_world.addNode(loadedComponent)
	G.default_world.updateNodeMap()
	
	#load links
	for componentData in sd.data["links"]:
		var componentDataID = componentData.get("ID")
		if componentDataID:
			var loadedComponent = load("res://Links/" + G.IDtoString[componentDataID] + "/" + G.IDtoString[componentDataID] + ".tscn").instance()
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
