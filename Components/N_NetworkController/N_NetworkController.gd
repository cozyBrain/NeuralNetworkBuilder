class_name N_NetworkController
extends StaticBody

const ID : String = "N_NetworkController"

var Olinks : Array
var propSequence : Array
var bpropSequence : Array

#var visualizedLearningCount : int = 0 setget setVisualizedLearningCount
#func setVisualizedLearningCount(count : int):
#	set_physics_process(true)
#	visualizedLearningCount = count
#
#
#func _ready():
#	set_physics_process(false)
#
## visualize learning progress
#func _physics_process(delta):
#	if visualizedLearningCount > 0:
#		propagate()
#		backpropagate()
#		visualize()
#		visualizedLearningCount -= 1
#	else:
#		set_physics_process(false)

func prop() -> void:
	pass
func bprop() -> void:
	pass

func initialize() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	# analyze for propSequence
	print("analyzing for propagation sequence....")
	propSequence.clear()
	propSequence.push_back({})
	bpropSequence.clear()
	propSequence[0][self] = true
	print("propagation sequence starting point: ", propSequence)
	var layerIndex : int = 0
	while layerIndex < propSequence.size():
		var nextLayer : Dictionary
		for keyAKAobject in propSequence[layerIndex]:  # iterating map of the layer
			var objID = keyAKAobject.get("ID")
			if objID:
				# init weights
				match objID:
					"N_Goal":
						pass
					_:
						var objIlinks = keyAKAobject.get("Ilinks")
						if objIlinks:
							var numOfObjIlinks : float = objIlinks.size()
							for link in objIlinks:  # init weight
								link.Weight = rng.randfn() / sqrt(numOfObjIlinks/2)
								print("initialize weight:", link.Weight)
				
				var objOlinks = keyAKAobject.get("Olinks")
				if not objOlinks:
					continue  # this is intended don't change. from past..
				else:
					for link in objOlinks:
						nextLayer[link.Onode] = true
	#					for node in link.Onodes:
	#						nextLayer[node] = true
	
		if not nextLayer.empty():  # if detect next connection
			propSequence.push_back(nextLayer)
		layerIndex += 1
		
	# Convert Dictionary to Array
	layerIndex = 0
	for layer in propSequence:
		propSequence[layerIndex] = []
		for keyAKAobject in layer:  # iterating map
			propSequence[layerIndex].push_back(keyAKAobject)
		layerIndex += 1
	print("analyzed for propagation sequence!")

	# analyze for bpropSequence
	print("analyzing for backpropagation sequence....")
	#for i in range(10, 0, -1):
	#	pass
	bpropSequence.push_back({})
	layerIndex = propSequence.size() - 1  # last layer
	for node in propSequence[layerIndex]:
		bpropSequence[0][node] = true
	print("backpropagation sequence starting points: ", bpropSequence)
	layerIndex = 0  # bpropSequence
	while layerIndex < bpropSequence.size():
		var nextLayer : Dictionary
		for keyAKAobject in bpropSequence[layerIndex]:
			var objIlinks = keyAKAobject.get("Ilinks")
			if objIlinks == null:
				continue
			for link in objIlinks:
				nextLayer[link.Inode] = true
#				for node in link.Inodes:
#					nextLayer[node] = true
		if not nextLayer.empty():
			bpropSequence.push_back(nextLayer)
		layerIndex += 1
	# Convert Dictionary to Array
	layerIndex = 0
	for layer in bpropSequence:
		bpropSequence[layerIndex] = []
		for keyAKAobject in layer:  # iterating map
			bpropSequence[layerIndex].push_back(keyAKAobject)
		layerIndex += 1
	print("analyzed for backpropagation sequence!")

func propagate() -> void:
	for layer in propSequence:
		for node in layer:
			node.prop()
			
func backpropagate() -> void:
	for layer in bpropSequence:
		for node in layer:
			node.bprop()
			
func visualize() -> void:
	# visualize
	for layer in propSequence:
		for node in layer:
			if node.has_method("updateEmissionByOutput"):
				node.call("updateEmissionByOutput")

func connectPort(target:Node, port:String) -> int:
	match port:
		"Olinks":
			match target.get("ID"):
				"L_SCWeight", "L_SCSharedWeight":
					Olinks.push_front(target)
				_:
					return -1
	return 00

func disconnectPort(target:Node, port:String) -> void:
	match port:
		"Olinks":
			var index = Olinks.find(target)
			if index >= 0:
				Olinks.remove(index)

func getSaveData() -> Dictionary:
	var sd : Dictionary = {
		"ID" : ID,
		"translation" : translation,
	}
	sd["propSequence"] = convertPropSequence2Translation(propSequence)
	sd["bpropSequence"] = convertPropSequence2Translation(bpropSequence)
	return sd
	
func loadSaveData(sd:Dictionary):
	propSequence = convertTranslation2PropSequence(sd.get("propSequence", []))
	bpropSequence = convertTranslation2PropSequence(sd.get("bpropSequence", []))
	sd.erase("propSequence")
	sd.erase("bpropSequence")
	for propertyName in sd:
		set(propertyName, sd[propertyName])

func convertPropSequence2Translation(ps:Array) -> Array:
	var propSequenceData = []
	propSequenceData.resize(ps.size())
	for layerIndex in range(propSequenceData.size()):
		propSequenceData[layerIndex] = []
		propSequenceData[layerIndex].resize(ps[layerIndex].size())
		for nodeIndex in range(propSequenceData[layerIndex].size()):
			propSequenceData[layerIndex][nodeIndex] = ps[layerIndex][nodeIndex].translation  # save translation(vector) not instance(node)	
	return propSequenceData
func convertTranslation2PropSequence(ps:Array) -> Array:
	var propSequenceData = []
	propSequenceData.resize(ps.size())
	for layerIndex in range(propSequenceData.size()):
		propSequenceData[layerIndex] = []
		propSequenceData[layerIndex].resize(ps[layerIndex].size())
		for nodeIndex in range(propSequenceData[layerIndex].size()):
			print(ps[layerIndex][nodeIndex])
			propSequenceData[layerIndex][nodeIndex] = G.default_world.getNode(ps[layerIndex][nodeIndex])  # save translation(vector) not instance(node)	
	return propSequenceData
