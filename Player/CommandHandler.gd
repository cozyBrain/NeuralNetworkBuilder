extends Node

func _ready():
	pass

const validCommands = {
	"Tool" : "Use console compatible tools.\nUsage: Tool (Tool you want) (arguments).\nPress shift+T to access selected tool quickly.",
}

const toolPath = "../../Tools/"
const playerPath = "../../../Player"

func Tool(arg : String) -> String:
	var output : String
	var splittedArg = arg.split(" ", false, 1)  # [command, arguments]
	while splittedArg.size() < 2:
		splittedArg.push_back("")

	var Tool = get_node_or_null(toolPath + splittedArg[0])
	if Tool != null:
		pass
	else:
		output += str(splittedArg[0], " doesn't exist!\n")
		
	return output

func NII(arg : String) -> String:
	if arg == "Null":
		return "No object detected."
	var Tool = get_parent().get_node_or_null(toolPath+"NodeInfoIndicator")
	return Tool.use1(instance_from_id(str2var(arg)))

func PC(arg : String):
	return arg
