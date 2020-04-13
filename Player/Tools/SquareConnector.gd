extends Node
class_name SquareConnector

var Aarea = []
var Barea = []
var AareaDetector : Object
var BareaDetector : Object

func selectAarea(rayCastDetectedObject : Object) -> void:
	if Aarea.size() == 0:
		print("A area begin point:", rayCastDetectedObject.translation)
		Aarea.push_back(rayCastDetectedObject)
	elif Aarea.size() == 1:
		print("A area end point:", rayCastDetectedObject.translation)
		Aarea.push_back(rayCastDetectedObject)
		self.AareaDetector = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()
		var xScale = abs(Aarea[0].translation.x - Aarea[1].translation.x) + 1
		var yScale = abs(Aarea[0].translation.y - Aarea[1].translation.y) + 1
		var zScale = abs(Aarea[0].translation.z - Aarea[1].translation.z) + 1
		var sv = Vector3(xScale, yScale, zScale)
		print(sv)
		AareaDetector.resize(sv)
		self.AareaDetector.translation = (Aarea[0].translation + Aarea[1].translation) / 2
		add_child(self.AareaDetector)
	else:
		print("A area already selected.")
func selectBarea(rayCastDetectedObject : Object) -> void:
	if Barea.size() == 0:
		print("B area begin point:", rayCastDetectedObject.translation)
		Barea.push_back(rayCastDetectedObject)
	elif Barea.size() == 1:
		print("B area end point:", rayCastDetectedObject.translation)
		Barea.push_back(rayCastDetectedObject)
		self.BareaDetector = load("res://Nodes/N_OverlappingBodyDetectorNode/N_OverlappingBodyDetectorNode.tscn").instance()
		var xScale = abs(Barea[0].translation.x - Barea[1].translation.x) + 1
		var yScale = abs(Barea[0].translation.y - Barea[1].translation.y) + 1
		var zScale = abs(Barea[0].translation.z - Barea[1].translation.z) + 1
		var sv = Vector3(xScale, yScale, zScale)
		print(sv)
		BareaDetector.resize(sv)
		self.BareaDetector.translation = (Barea[0].translation + Barea[1].translation) / 2
		add_child(self.BareaDetector)
	else:
		print("B area already selected.")
func initiate() -> void:
	var Aselected = true
	var Bselected = true
	if Aarea.size() != 2:
		print("A area isn't selected")
		Aselected = false
	else:
		print("A area: ", Aarea[0].translation, " to ", Aarea[1].translation)
	if Barea.size() != 2:
		print("B area isn't selected")
		Bselected = false
	else:
		print("B area: ", Barea[0].translation, " to ", Barea[1].translation)
		
	if Aselected and Bselected:
		var Abodies = AareaDetector.get_overlapping_bodies()
		var Bbodies = BareaDetector.get_overlapping_bodies()

		for Abody in Abodies:
			for Bbody in Bbodies:
				var newSynapse = get_parent().get_node("PointConnector").use2(Abody, Bbody)
				if newSynapse != null:
					G.default_session.add_child(newSynapse)

		Aarea.clear()
		AareaDetector.queue_free()
		Barea.clear()
		BareaDetector.queue_free()
