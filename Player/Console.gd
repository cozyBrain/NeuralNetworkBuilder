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
