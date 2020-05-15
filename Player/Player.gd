class_name Player
extends KinematicBody
var cameraAngle = 0
var mouseSensitivity = 0.3
var keyboardsensitivity = 0.3
var flySpeed = 10
var flyAccel = 40
var velocity = Vector3()
var rayCastDetectedObject
var session_path = G.default_session_path
var Type : int = G.ID.Player
var aim : Basis
var Tool

onready var consoleInputBox = get_node("Console/VBoxContainer/HBoxContainer/Input")
onready var consoleOutputBox = get_node("Console/VBoxContainer/Output")
var typingMode : bool = false

var hotbarSelection : int  # 0 ~ 9
var prevHotbarSelection : int = -1
var hotbarSubSelection : bool = false
var ToolHotbar

var hotbar = [G.ID.NII,G.ID.PC,G.ID.SC,G.ID.H,G.ID.NC,G.ID.None,G.ID.None,G.ID.None,G.ID.None,G.ID.None]  # size:10  hotbar lol! Korean people will see why

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	consolePrintln(str("PlayerHotbar: ", hotbar))

func _process(delta):
	rayCastDetectedObject = $Yaxis/Camera/RayCast.get_collider()
	#rayCastDetectedObject = instance_from_id(rayCastDetectedObject.get_instance_id())
	
	if Tool != null: 
		if Tool.has_method("update"):
			match hotbar[hotbarSelection]:
				G.ID.NC:
					Tool.update(translation, aim, delta)
	if Input.is_key_pressed(KEY_ESCAPE):
		var session = get_node(session_path)
		if session.has_method("close"):
			session.close()
		else:
			print("session doesn't have close method")
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

	if typingMode:
		return

	if Input.is_action_just_pressed("KEY_F"):
		if Tool != null: 
			match hotbar[hotbarSelection]:
				G.ID.SC:
					Tool.initiate()
				G.ID.H:  # Hand
					if null == rayCastDetectedObject:
						print("Hand: No Object Detected")
					else:
						print("Hand: < ", rayCastDetectedObject, " >")
						var type = rayCastDetectedObject.get("Type")
						if type == null:
							print("Hand: could not interact")
						else:
							match type:
								G.N_Types.N_NetworkController:
									rayCastDetectedObject.propOnly = !rayCastDetectedObject.propOnly
									print("propOnly: ", rayCastDetectedObject.propOnly)
								_:
									print("Hand: no interaction with ", G.N_TypeToString[type])
				_:
					print("no action")
		else:
			print("the tool couldn't be found")
	if Input.is_action_just_pressed("KEY_T"):
		typingMode = true
		consoleInputBox.grab_focus()
		return
	if Input.is_action_just_pressed("KEY_C"):
		pass
	if Input.is_key_pressed(KEY_O):
		Engine.time_scale = clamp(Engine.time_scale+0.02,0,2)
		print("Engine.time_scale: ", Engine.time_scale)
	elif Input.is_key_pressed(KEY_P):
		Engine.time_scale = clamp(Engine.time_scale-0.02,0,1)
		print("Engine.time_scale: ", Engine.time_scale)

func _physics_process(delta):
	if typingMode:
		return
		
	var direction = Vector3()
	aim = $Yaxis/Camera.get_camera_transform().basis
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

func _input(event):
	if event is InputEventMouseMotion:  # cam movement
		$Yaxis.rotate_y(deg2rad(-event.relative.x * mouseSensitivity))
		
		var change = -event.relative.y * mouseSensitivity
		if change + cameraAngle < 90 and change + cameraAngle > -90:
			$Yaxis/Camera.rotate_x(deg2rad(change))
			cameraAngle += change

	if typingMode:
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
						print("subSelection:", subSelection)
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
							if Tool.has_method("activate"):
								match hotbar[hotbarSelection]:
									G.ID.NC:
										Tool.activate(translation, aim)
										ToolHotbar = Tool.get("hotbar")
										if ToolHotbar != null:
											print("ToolHotbar: ", ToolHotbar)
											# display on ui
											
					else:  # when you select selected one again
						if ToolHotbar != null:
							print("hotbarSubSelection. 0 to escape.")
							hotbarSubSelection = true
	
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if Tool != null: 
				match hotbar[hotbarSelection]:
					G.ID.NII:
						Tool.use1(rayCastDetectedObject)
					G.ID.PC:
						Tool.use1(rayCastDetectedObject)
					G.ID.SC:
						if rayCastDetectedObject == null:
							print(Tool.name, ": No Object Detected")
						elif event.button_index == BUTTON_LEFT:
							Tool.selectAarea(rayCastDetectedObject)
						elif event.button_index == BUTTON_RIGHT:
							Tool.selectBarea(rayCastDetectedObject)
					G.ID.H:  # Hand
						if null == rayCastDetectedObject:
							print(Tool.name, ": No Object Detected")
						else:
							print(Tool.name, ": < ", rayCastDetectedObject, " >")
							var type = rayCastDetectedObject.get("Type")
							if type == null:
								print(Tool.name, ": could not interact")
							else:
								match type:
									G.N_Types.N_NetworkController:
										if event.button_index == BUTTON_RIGHT:
											rayCastDetectedObject.initialize()
										elif event.button_index == BUTTON_LEFT:
											var count = 100
											for _i in range(count):
												rayCastDetectedObject.wave()
											print(Tool.name, ": iterated for ", count, " times")
									G.N_Types.N_Input, G.N_Types.N_Goal:
										if event.button_index == BUTTON_LEFT:
											rayCastDetectedObject.addOutput(0.25)
										elif event.button_index == BUTTON_RIGHT:
											rayCastDetectedObject.addOutput(-0.25)
									_:
										print(Tool.name, ": no interaction with ", G.N_TypeToString[type])
					G.ID.NC:
						if event.button_index == BUTTON_WHEEL_UP:
							Tool.distance += 0.5
						elif event.button_index == BUTTON_WHEEL_DOWN:
							Tool.distance -= 0.5
					_:
						print("the tool couldn't be recognized")
			else:
				print("the tool couldn't be found. maybe programmer missed something.")

func consolePrintln(text):
	consoleOutputBox.text = str(consoleOutputBox.text, "\n", text)
func _on_Input_text_entered(text):
	typingMode = false
	consoleInputBox.release_focus()
	consoleInputBox.clear()
	if text != "":
		processCommand(text)

func processCommand(text):
	var words = text.split(" ", false)
	words = Array(words)
	
	consolePrintln(text)
	
