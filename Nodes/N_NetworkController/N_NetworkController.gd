class_name N_NetworkController
extends StaticBody

var Osynapses : Array
var propSequence : Array
var bpropSequence : Array
var propOnly : bool = false

const Type : int = G.ID.N_NetworkController  # TypeData.N_NetworkController

func getInfo() -> Dictionary:
	return {"Type":Type, "Osynapses":Osynapses, "propSequence":propSequence, "bpropSequence":bpropSequence}

func prop() -> void:
	pass
func bprop() -> void:
	pass

func initialize() -> void:
	randomize()  # reseeds using a number based on time.

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
			var objType = keyAKAobject.get("Type")
			if objType != null:

				# init weights
				match objType:
					G.ID.N_Goal:
						pass
					_:
						var objIsynapses = keyAKAobject.get("Isynapses")
						if objIsynapses != null:
							var numOfObjIsynapses = objIsynapses.size()
							for synapse in objIsynapses:  # init weight
								synapse.Weight = lerp(-1, 1, randf()) / sqrt(numOfObjIsynapses)
								print("initialize weight:", synapse.Weight)

				var objOsynapses = keyAKAobject.get("Osynapses")
				if objOsynapses == null:
					continue
				for synapse in objOsynapses:
					for node in synapse.Onodes:
						nextLayer[node] = true

		if not nextLayer.empty():
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
	print("backpropagation sequence starting point: ", bpropSequence)
	layerIndex = 0  # bpropSequence
	while layerIndex < bpropSequence.size():
		var nextLayer : Dictionary
		for keyAKAobject in bpropSequence[layerIndex]:
			var objIsynapses = keyAKAobject.get("Isynapses")
			if objIsynapses == null:
				continue
			for synapse in objIsynapses:
				for node in synapse.Inodes:
					nextLayer[node] = true
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
	
func wave() -> void:
	for layer in propSequence:
		for node in layer:
			node.prop()
	if not propOnly:
		for layer in bpropSequence:
			for node in layer:
				node.bprop()
	
func connectTo(target:Node) -> int:
	# U can cancel Onodes.push if target is not compatible by using has_meta, has_method, has_node, if not etc..
	var type = target.get("Type")
	if type == null:
		return -1
	match type:
		G.ID.N_Synapse:
			Osynapses.push_front(target) #  target
		var unknownType:
			return -1
	return 0
	
func disconnectTo(target:Node) -> void:
	var index = Osynapses.find(target)
	if index >= 0:
		Osynapses.remove(index)
