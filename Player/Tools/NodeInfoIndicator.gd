extends Node
class_name NodeInfoIndicator

export (NodePath) var session_path = G.default_session_path

func use1(rayCastDetectedObject : Object) -> String:
	var output : String = ""
	if null == rayCastDetectedObject:
		output += str(self.name, ": No Object Detected.\n")
	else:
		output += str(self.name,": < ", rayCastDetectedObject, "  ", rayCastDetectedObject.translation, " >\n")
		if not rayCastDetectedObject.has_method("getInfo"):
			output += str(self.name, ": could not get info as the object doesn't have method getInfo()\n")
		else:
			var infoDict = rayCastDetectedObject.getInfo()
			for key in infoDict:
				if typeof(infoDict[key]) == TYPE_INT and key == "Type":
					output += str(key, " : ", infoDict[key], " : ", G.IDtoString[infoDict[key]], '\n')
					continue
				output += str(key, " : ", infoDict[key], '\n')
	return output
