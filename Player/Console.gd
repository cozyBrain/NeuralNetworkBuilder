extends Control


func _ready():
	pass

const validCommands = {
	"Tool" : "Use console compatible tools.\n	Usage: Tool (Tool you want) (arguments).\n	Press shift+T to access selected tool quickly.",
}

onready var player = get_parent()
onready var inputBox = get_node("VBoxContainer/HBoxContainer/Input")
onready var outputBox = get_node("VBoxContainer/Output")

const toolsPath = "../Tools/"

func processCommand(text):
	var words = text.split(" ", false, 1)  # [command, arguments]
	while words.size() < 2:
		words.push_back("")

	if validCommands.has(words[0]):
		var output = call(words[0], words[1])
		println(output)
		return output
	else:
		println("invalid command")

func Tool(arg : String) -> String:
	var splittedArg = arg.split(" ", false, 1)  # [command, arguments]
	while splittedArg.size() < 2:
		splittedArg.push_back("")

	var Tool = get_node_or_null(toolsPath + splittedArg[0])
	if Tool == null:  # when the tool doesn't exist
		return str("Tool \"", splittedArg[0], "\" doesn't exist!\n")
		
	var output = Tool.handle(splittedArg[1])
	if typeof(output) == TYPE_STRING:
		return output
	return ""

func println(text):
	outputBox.text = str(outputBox.text, "\n", text)

func grab_focus():
	inputBox.grab_focus()
