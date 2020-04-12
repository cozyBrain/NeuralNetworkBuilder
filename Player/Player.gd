class_name Player
extends KinematicBody
var camera_angle = 0
var mouse_sensitivity = 0.3
var keyboard_sensitivity = 0.3
var FLY_SPEED = 10
var FLY_ACCEL = 40
var velocity = Vector3()
var rayCastDetectedObject
var session_path = G.default_session_path
var Output : float = 0.5
var Type : int = G.N_Types.Player

var hotbarSelection : int  # 0 ~ 9
const toolcode = {
	NII="NodeInfoIndicator", SC="SquareConnector", PC="PointConnector",
	H="Hand", n="none"
}
var hotbar = [toolcode.NII,toolcode.PC,toolcode.SC,toolcode.H,toolcode.n,toolcode.n,toolcode.n,toolcode.n,toolcode.n,toolcode.n]  # size:10  hotbar lol! Korean people will see why

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	rayCastDetectedObject = $Yaxis/Camera/RayCast.get_collider()
	
	var direction = Vector3()
	var aim = $Yaxis/Camera.get_camera_transform().basis
	
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
		FLY_SPEED = 40
	else:
		FLY_SPEED = 10 
	if Input.is_key_pressed(KEY_1):
		hotbarSelection = 0
	elif Input.is_key_pressed(KEY_2):
		hotbarSelection = 1
	elif Input.is_key_pressed(KEY_3):
		hotbarSelection = 2
	elif Input.is_key_pressed(KEY_4):
		hotbarSelection = 3
	elif Input.is_key_pressed(KEY_5):
		hotbarSelection = 4
	elif Input.is_key_pressed(KEY_6):
		hotbarSelection = 5
	elif Input.is_key_pressed(KEY_7):
		hotbarSelection = 6
	elif Input.is_key_pressed(KEY_8):
		hotbarSelection = 7
	elif Input.is_key_pressed(KEY_9):
		hotbarSelection = 8
	elif Input.is_key_pressed(KEY_0):
		hotbarSelection = 9
	if Input.is_action_just_pressed("KEY_E"):
		var Tool = get_node("Tools/"+hotbar[hotbarSelection])
		if Tool != null: 
			match hotbar[hotbarSelection]:
				toolcode.NII:
					Tool.use1(rayCastDetectedObject)
				toolcode.PC:
					Tool.use1(rayCastDetectedObject)
				toolcode.SC:
					Tool.initiate()
				toolcode.H:  # Hand
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
					print("the tool couldn't be recognized")
		else:
			print("the tool couldn't be found")
	if Input.is_action_just_pressed("KEY_C"):
		pass
	if Input.is_key_pressed(KEY_O):
		Engine.time_scale = clamp(Engine.time_scale+0.02,0,2)
		print("Engine.time_scale: ", Engine.time_scale)
	elif Input.is_key_pressed(KEY_P):
		Engine.time_scale = clamp(Engine.time_scale-0.02,0,1)
		print("Engine.time_scale: ", Engine.time_scale)
	if Input.is_action_just_pressed("fullscreen"):  # but there's an issue that crosshair move away from center..
		OS.window_fullscreen = !OS.window_fullscreen
		
	if Input.is_key_pressed(KEY_ESCAPE):
		var session = get_node(session_path)
		if session.has_method("close"):
			session.close()
		else:
			print("session doesn't have close method")
	
	direction = direction.normalized()
	var target = direction * FLY_SPEED
	velocity = velocity.linear_interpolate(target, FLY_ACCEL * delta)
	move_and_slide(velocity)

func _input(event):  # _unhandled_input
	# cam movement
	if event is InputEventMouseMotion:
		$Yaxis.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var change = -event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Yaxis/Camera.rotate_x(deg2rad(change))
			camera_angle += change
	elif event is InputEventMouseButton:
		if event.is_pressed():
			var Tool = get_node("Tools/"+hotbar[hotbarSelection])
			if Tool != null: 
				match hotbar[hotbarSelection]:
					toolcode.NII:
						Tool.use1(rayCastDetectedObject)
					toolcode.PC:
						Tool.use1(rayCastDetectedObject)
					toolcode.SC:
						if rayCastDetectedObject == null:
							print(Tool.name, ": No Object Detected")
						elif event.button_index == BUTTON_LEFT:
							Tool.selectAarea(rayCastDetectedObject)
						elif event.button_index == BUTTON_RIGHT:
							Tool.selectBarea(rayCastDetectedObject)
					toolcode.H:  # Hand
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
											for i in range(count):
												rayCastDetectedObject.wave()
											print(Tool.name, ": learned for ", count, " times")
									G.N_Types.N_Input, G.N_Types.N_Goal:
										if event.button_index == BUTTON_LEFT:
											rayCastDetectedObject.addOutput(0.25)
										elif event.button_index == BUTTON_RIGHT:
											rayCastDetectedObject.addOutput(-0.25)
									_:
										print(Tool.name, ": no interaction with ", G.N_TypeToString[type])
					_:
						print("the tool couldn't be recognized")
			else:
				print("the tool couldn't be found")