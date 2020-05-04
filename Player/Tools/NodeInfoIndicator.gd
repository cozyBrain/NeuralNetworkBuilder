extends Node
class_name NodeInfoIndicator

export (NodePath) var session_path = G.default_session_path

func use1(rayCastDetectedObject : Object):
	if null == rayCastDetectedObject:
		print(self.name, ": No Object Detected")
	else:
		print(self.name,": < ", rayCastDetectedObject, "  ", rayCastDetectedObject.translation, " >")
		if not rayCastDetectedObject.has_method("getInfo"):
			print(self.name, ": could not get info as the object doesn't have method getInfo()")
		else:
			var infoDict = rayCastDetectedObject.getInfo()
			for key in infoDict:
				if typeof(infoDict[key]) == TYPE_INT and key == "Type":
					print(key, " : ", infoDict[key], " : ", G.N_TypeToString[infoDict[key]])
					continue
				print(key, " : ", infoDict[key])
