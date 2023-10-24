class_name FreeControlState extends State
# https://github.com/rbarongr/GodotFirstPersonController

@export_category("Player")

@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var look_dir: Vector2 # Input direction for look/aim

func input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		_rotate_camera()
	if Input.is_action_just_pressed("ui_accept"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("exit"): get_tree().quit()

func process(delta: float) -> void:
	controller.jumping = Input.is_action_pressed("jump")
	controller.move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	
	# can't be done in input, does not detect held presses
	if Input.is_action_pressed("shoot"):
		controller.shoot()
	
	_handle_joypad_camera_rotation(delta)

func _rotate_camera(sens_mod: float = 1.0) -> void:
	controller.camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	controller.camera.rotation.x = clamp(controller.camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		controller.look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		controller.look_dir = Vector2.ZERO
