class_name N_NetworkController
extends StaticBody

var Olinks : Array
var propSequence : Array
var bpropSequence : Array
var propOnly : bool = false

const ID : int = G.ID.N_NetworkController  # IDData.N_NetworkController

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
			if objID != null:
	
				# init weights
				match objID:
					G.ID.N_Goal:
						pass
					_:
						var objIlinks = keyAKAobject.get("Ilinks")
						if objIlinks != null:
							var numOfObjIlinks : float = objIlinks.size()
							for link in objIlinks:  # init weight
								link.Weight = rng.randfn() / sqrt(numOfObjIlinks/2)
								print("initialize weight:", link.Weight)
	
				var objOlinks = keyAKAobject.get("Olinks")
				if objOlinks == null:
					continue
				for link in objOlinks:
					nextLayer[link.Onode] = true
#					for node in link.Onodes:
#						nextLayer[node] = true
	
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
	var id = target.get("ID")
	if id == null:
		return -1
	match id:
		G.ID.L_Synapse:
			Olinks.push_front(target) #  target
		var _unknownID:
			return -1
	return 0

func disconnectTo(target:Node) -> void:
	var index = Olinks.find(target)
	if index >= 0:
		Olinks.remove(index)
