extends Node

func _ready():
	pass

const validCommands = {
	"NII" : "NodeInfoIndicator  usage: NII (integer:instance_id)",
	"PC" : "PointConnector"
}

func NII(arg : String) -> String:
	if arg == "Null":
		return "No object detected."
	var Tool = get_parent().get_node_or_null("../Tools/NodeInfoIndicator")
	return Tool.use1(instance_from_id(str2var(arg)))

func PC(arg : String):
	return arg
