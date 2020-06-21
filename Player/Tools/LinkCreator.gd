extends Node
class_name LinkCreator

const ID : String = "LinkCreator"

var linkSelection = "L_SCWeight"  # default link
var Link = load("res://Components/"+linkSelection+"/"+linkSelection+".tscn")
var prevLink = Link
var hotbarSelectedLink = Link

var hotbar : Array = ["L_SCWeight", "L_SCSharedWeight"]
var hotbarSelection : int setget setHotbarSelection
func setHotbarSelection(selection : int):
	hotbarSelection = selection
	hotbarSelectedLink = load("res://Components/"+hotbar[hotbarSelection]+"/"+hotbar[hotbarSelection] + ".tscn")
	linkSelection = hotbar[hotbarSelection]

# create link using saveData loading system
enum {NumOfArgs, ArgTypes, NumOfQueuedArg, SaveDataNames, ArgSaveDataQueue}
var LINKS : Dictionary = {
	"L_SCWeight" : [2, [TYPE_VECTOR3, TYPE_VECTOR3], 0, ["Inode", "Onode"], {}],
	"L_SCSharedWeight" : [3, [TYPE_VECTOR3, TYPE_VECTOR3, TYPE_VECTOR3], 0, ["Inode", "Onode", "Wnode"], {}],
}

# Tool LinkCreator -h -d 1,-2,3
# Tool LinkCreator -l L_SCSharedWeight -d 0,0,3 -2,0,3 -1,0,0

func handle(arg : String):
	print(arg)
	
	var output : String
	var argParser = ArgParser.new(arg)
	
	linkSelection = argParser.getString(["link", "l"], linkSelection)
	if linkSelection: 
		Link = load("res://Components/" + linkSelection + "/" + linkSelection + ".tscn")
	else: 
		Link = prevLink
	if argParser.getBool(["hotbarLinkSelection", "h"]):
		Link = hotbarSelectedLink
	
	var linkDatas = argParser.getStrings(["data", "d"])
	if linkDatas == null:
		output += "no -data arguments!\n"
	elif linkDatas.size() > 0:
		var numOfQueuedArg = LINKS[linkSelection][NumOfQueuedArg]
		var argSaveDataQueue = LINKS[linkSelection][ArgSaveDataQueue]
		if numOfQueuedArg + linkDatas.size() > LINKS[linkSelection][NumOfArgs]:
			if numOfQueuedArg > 0: output += "-data: too many arguments to create link. some queued linkData exist: "+str(argSaveDataQueue)+"\n"
			else: output += "-data: too many arguments to create link.\n"
		else:
			for i in range(linkDatas.size()):
				var LINK = LINKS[linkSelection]
				var saveDataNames = LINKS[linkSelection][SaveDataNames]
				var linkData = null
				# if valid, convert.
				match LINK[ArgTypes][numOfQueuedArg+i]:
					TYPE_VECTOR3:
						if G.isValidVector3(linkDatas[i]):
							linkData = G.str2vector3(linkDatas[i])
					TYPE_REAL:
						if linkDatas[i].is_valid_float():
							linkData = float(linkDatas[i])
					
				if linkData:  # if linkData is valid
					argSaveDataQueue[saveDataNames[numOfQueuedArg+i]] = linkData
					LINK[NumOfQueuedArg] += 1
					if LINK[NumOfQueuedArg] == LINK[NumOfArgs]:
						# create
						var newLink = Link.instance()
						newLink.loadSaveData(argSaveDataQueue)
						G.default_world.addLink(newLink)
						# reset SaveDataQueue & numOfQueuedArg
						for port in argSaveDataQueue:
							argSaveDataQueue[port] = null
						LINK[NumOfQueuedArg] = 0
				else:
					output += "-data: invalid argument!\n"
					break
	
	prevLink = Link
	if output == "":
		return null
	return output
