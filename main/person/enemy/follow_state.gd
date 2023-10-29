class_name FollowState extends State

@export var detection_area: Area3D
@export var equilibrium_distance: float = 4.0

var player: Player
var offset: Vector3 = Vector3(randf(), 0, randf()).normalized()
var delay: float = 0.0
var x:float = 0.0

func _ready() -> void:
	randomize()
	detection_area.area_entered.connect(_on_area_entered)
	detection_area.area_exited.connect(_on_area_exited)
	$Timer.start(randf() * 4.0)
	$Timer.timeout.connect(_switch)

func _switch() -> void:
	offset = 3.0 * Vector3(randf() * 2.0 - 1.0, 0, randf() * 2 - 1.0)
	if player == null and randf() < 0.5:
		offset = Vector3()
	$Timer.start(1.0 + randf() * 3.0)

func _on_area_exited(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	player = null

func _on_area_entered(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	x = 0.0
	delay = randf()
	
	$Timer.start(2.0 + randf() * 3.0)
	player = area.get_parent()

func process(delta: float) -> void:
	if player:
		controller.camera.look_at(player.global_position + Vector3(0, 1.0, 0))
		if x >= delay:
			controller.shoot(false)
		x += delta
		if player.global_position.distance_to(controller.global_position + offset) > equilibrium_distance:
			var dir: Vector3 = controller.global_position.direction_to(player.global_position + offset)
			controller.move_dir = controller.move_dir.move_toward(Vector2(dir.x, dir.z).normalized(), delta * 8)
		else:
			controller.move_dir = controller.move_dir.move_toward(Vector2(), delta)
		if controller.will_fall():
			controller.move_dir = Vector2()
	elif controller.speed > 0:
		if offset.length() > 0.01:
			controller.camera.look_at(offset * 32 + controller.global_position)
		controller.move_dir = Vector2(offset.x, offset.z).normalized() / 1.5
		if controller.will_fall():
			controller.move_dir = Vector2()
