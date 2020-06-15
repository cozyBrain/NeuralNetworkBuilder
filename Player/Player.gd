class_name Player
extends KinematicBody
var cameraAngle = 0
var mouseSensitivity = 0.3
var keyboardsensitivity = 0.3
var flySpeed = 10
var flyAccel = 40
var velocity = Vector3()
var detectedObject
var ID : int = G.ID.Player
var aim : Basis
var Tool

onready var pointer = $Tools/Pointer
onready var console = $Console
var consoleInputModes = ["command", "chat"]
var consoleInputModeSelection : int = 0
var typingMode : bool = false

var hotbarSelection : int  # 0 ~ 9
var prevHotbarSelection : int = -1
var hotbarSubSelection : bool = false
var ToolHotbar

var hotbar = [G.ID.OII, G.ID.LC, G.ID.BC, G.ID.H, G.ID.NC, G.ID.S, G.ID.C, G.ID.SLT,G.ID.None,G.ID.None]  # size:10  hotbar lol! Korean people will see why

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var playerHotbarIndication = str("PlayerHotbar: [")
	for item in hotbar:
		playerHotbarIndication += str(" "+G.IDtoString[item]+" ")
	playerHotbarIndication += "]"
	console.println(playerHotbarIndication)
	pointer.activatePointer(translation, aim)

func _process(delta):
	
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if typingMode:
		if Input.is_action_just_pressed("KEY_TAB"):
			consoleInputModeSelection += 1
			if consoleInputModes.size() <= consoleInputModeSelection:
				consoleInputModeSelection = 0
			print(consoleInputModes[consoleInputModeSelection])
		if Input.is_action_just_pressed("ui_up"):
				console.crawlHistory(+1)
		elif Input.is_action_just_pressed("ui_down"):
				console.crawlHistory(-1)
		elif Input.is_action_just_pressed("KEY_ESC"):
			typingMode = false
			console.inputBox.release_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	
	if Input.is_action_just_pressed("KEY_ESC"):
		if G.default_world.has_method("close"):
			G.default_world.close()
		else:
			print("session doesn't have close method")
	if Input.is_action_just_pressed("KEY_F"):
		if Tool != null: 
			match hotbar[hotbarSelection]:
				G.ID.BC:
					console.processCommand(str("Tool BoxConnector initiate"))
				G.ID.H:  # Hand
					if null == detectedObject:
						print("Hand: No Object Detected")
					else:
						print("Hand: < ", detectedObject, " >")
						var id = detectedObject.get("ID")
						if id == null:
							print("Hand: could not interact")
						else:
							match id:
								G.ID.N_NetworkController:
									detectedObject.propOnly = !detectedObject.propOnly
									print("propOnly: ", detectedObject.propOnly)
								_:
									print("Hand: no interaction with ", G.IDtoString[id])
				_:
					print("no action")
		else:
			print("the tool couldn't be found")
	if Input.is_action_just_pressed("SHIFT+T"):
		typingMode = true
		console.inputBox.grab_focus()
		var inputText = str("Tool ", G.IDtoString[hotbar[hotbarSelection]], " ")
		console.inputBox.set_text(inputText)
		console.inputBox.set_cursor_position(inputText.length())
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	if Input.is_action_just_pressed("KEY_T"):
		typingMode = true
		console.inputBox.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	if Input.is_action_just_pressed("SHIFT+L"):
		G.default_world.toggleHideLinks()
	if Input.is_key_pressed(KEY_O):
		Engine.time_scale = clamp(Engine.time_scale+0.02,0,2)
		print("Engine.time_scale: ", Engine.time_scale)
	elif Input.is_key_pressed(KEY_P):
		Engine.time_scale = clamp(Engine.time_scale-0.02,0,1)
		print("Engine.time_scale: ", Engine.time_scale)

func _physics_process(delta):
	if Input.is_action_just_pressed("KEY_TAB"):
		pointer.switchMode(translation, aim)
	
	aim = $Yaxis/Camera.get_camera_transform().basis
	detectedObject = pointer.update(translation, aim, delta)
	#print(aim.z.round())
	#pointerPosition -= aim.z*distance
	#pointerPosition = pointerPosition.round()
	
	if Tool != null: 
		if Tool.has_method("update"):
			match hotbar[hotbarSelection]:
				G.ID.NC:
					Tool.update(translation, aim, delta)
				G.ID.S:
					Tool.update(translation, aim, delta)
	
	if typingMode:
		return
	
	var direction = Vector3()
	if Input.is_key_pressed(KEY_W):
		direction -= aim.z
	if Input.is_key_pressed(KEY_S):
		direction += aim.z
	if Input.is_key_pressed(KEY_A):
		direction -= aim.x
	if Input.is_key_pressed(KEY_D):
		direction += aim.x
	if Input.is_key_pressed(KEY_SPACE):
		direction += aim.y
	if Input.is_key_pressed(KEY_CONTROL):
		direction -= aim.y
	if Input.is_key_pressed(KEY_SHIFT):
		flySpeed = 40
	else:
		flySpeed = 10 
	direction = direction.normalized()
	var target = direction * flySpeed
	velocity = velocity.linear_interpolate(target, flyAccel * delta)
	move_and_slide(velocity)
	
	# check continuously unlike _input
	if Tool != null: 
		match hotbar[hotbarSelection]:
			G.ID.NC:
				if Input.is_mouse_button_pressed(BUTTON_RIGHT):
					Tool.erase()
				elif Input.is_mouse_button_pressed(BUTTON_LEFT):
					Tool.create() 

func _input(event):
	if event is InputEventMouseMotion:  # cam movement
		$Yaxis.rotate_y(deg2rad(-event.relative.x * mouseSensitivity))
		
		var change = -event.relative.y * mouseSensitivity
		if change + cameraAngle < 90 and change + cameraAngle > -90:
			$Yaxis/Camera.rotate_x(deg2rad(change))
			cameraAngle += change

	if typingMode:  # when you use console
		return
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				pointer.setDistance(pointer.distance + 0.5)
				return
			elif event.button_index == BUTTON_WHEEL_DOWN:
				pointer.setDistance(pointer.distance - 0.5)
				return
	
	if event is InputEventKey:
		if event.is_pressed():
			# hotBarSelection
			var scancode : int = event.get_scancode()
			if 48 <= scancode and scancode <= 57:  # 0 ~ 9
				if hotbarSubSelection:
					var subSelection = scancode - 49
					if subSelection == -1:
						subSelection = 9
					if subSelection == 9:  # key 0 to escape
						print("escape")
						hotbarSubSelection = false
					else:
						if ToolHotbar.size() > subSelection:
							print("subSelection:", subSelection, ":", ToolHotbar[subSelection])
							Tool.set("hotbarSelection", subSelection)
				else:
					hotbarSelection = scancode - 49
					if hotbarSelection == -1:
						hotbarSelection = 9
					# when you select another tool
					if prevHotbarSelection != hotbarSelection:  
						var prevTool = get_node_or_null("Tools/"+G.IDtoString[hotbar[prevHotbarSelection]])
						prevHotbarSelection = hotbarSelection
						if prevTool != null:
							if prevTool.has_method("deactivate"):
								prevTool.deactivate()
						Tool = get_node_or_null("Tools/"+G.IDtoString[hotbar[prevHotbarSelection]])
						if Tool != null:
							ToolHotbar = Tool.get("hotbar")
							if ToolHotbar != null:
								print("ToolHotbar: ", ToolHotbar)
											
					else:  # when you select selected one again
						if ToolHotbar != null:  # does the tool has hotbar?
							print("hotbarSubSelection. 0 to escape.")
							hotbarSubSelection = true
	
	if Tool != null: 
		match hotbar[hotbarSelection]:
			G.ID.OII:
				if event is InputEventMouseButton:
					if event.is_pressed():
						if event.button_index == BUTTON_LEFT:
							if detectedObject != null:
								console.processCommand(str("Tool ", G.IDtoString[G.ID.OII], " ", str(detectedObject.get_instance_id())))
							else:
								var additionalMessage : String
								if pointer.getPointerPosition() != null:
									additionalMessage = str(": ",pointer.getPointerPosition())
								console.println("No node detected!"+additionalMessage)
			G.ID.LC:
				if event is InputEventMouseButton:
					if event.is_pressed():
						if detectedObject != null:
							console.processCommand(str("Tool ", G.IDtoString[G.ID.LC], " ", str(detectedObject.get_instance_id())))
						else:
							console.println("No node detected!")
			G.ID.BC:
				if event is InputEventMouseButton:
					if event.is_pressed():
						if detectedObject == null:
							console.println("No node detected!")
						elif event.button_index == BUTTON_LEFT:
							console.processCommand(str("Tool ", G.IDtoString[G.ID.BC], " A ", str(detectedObject.translation)))
						elif event.button_index == BUTTON_RIGHT:
							console.processCommand(str("Tool ", G.IDtoString[G.ID.BC], " B ", str(detectedObject.translation)))
				elif event is InputEventKey:
					if event.is_pressed():
						if event.get_scancode() == KEY_C:
							console.processCommand(str("Tool ", G.IDtoString[G.ID.BC], " -reset"))
			G.ID.H:  # Hand
				if event is InputEventMouseButton:
					if event.is_pressed():
						if null == detectedObject:
							print(Tool.name, ": No Object Detected")
						else:
							print(Tool.name, ": < ", detectedObject, " >")
							var id = detectedObject.get("ID")
							if id == null:
								print(Tool.name, ": could not interact")
							else:
								match id:
									G.ID.N_NetworkController:
										if event.button_index == BUTTON_RIGHT:
											detectedObject.initialize()
										elif event.button_index == BUTTON_LEFT:
											var count = 100
											for _i in range(count):
												detectedObject.wave()
											print(Tool.name, ": iterated for ", count, " times")
									G.ID.N_Input, G.ID.N_Goal:
										if event.button_index == BUTTON_LEFT:
											detectedObject.addOutput(1)
										elif event.button_index == BUTTON_RIGHT:
											detectedObject.addOutput(-1)
									_:
										print(Tool.name, ": no interaction with ", G.IDtoString[id])
			G.ID.NC:
				pass
			G.ID.S:
				if event is InputEventMouseButton:
					if event.is_pressed():
						if event.button_index == BUTTON_LEFT:
							console.processCommand(str("Tool ", G.IDtoString[G.ID.S], " -s hotbarSelection pointerPosition"))
						#elif event.button_index == BUTTON_RIGHT:
						#	console.processCommand(str("Tool ", G.IDtoString[G.ID.OII], " ", str(detectedObject.translation)))
			_:
				print("The tool couldn't be recognized")

func _on_Input_text_entered(text):
	typingMode = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	console.inputBox.release_focus()
	console.inputBox.clear()
	if text == "":
		return
	console.println(text)	
	if consoleInputModes[consoleInputModeSelection] == "command":
		console.processCommand(text)
	elif consoleInputModes[consoleInputModeSelection] == "chat":
		pass
	else:
		console.consolePrintln("Unknown input mode")
