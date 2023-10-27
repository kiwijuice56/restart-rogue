class_name FollowState extends State

@export var detection_area: Area3D
@export var equilibrium_distance: float = 4.0

var player: Player
var offset: Vector3 

func _ready() -> void:
	randomize()
	detection_area.area_entered.connect(_on_area_entered)
	$Timer.timeout.connect(_switch)

func _switch() -> void:
	offset = 3.0 * Vector3(randf() * 2.0 - 1.0, 0, randf() * 2 - 1.0)
	$Timer.start(1.0 + randf() * 3.0)

func _on_area_entered(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	$Timer.start(2.0 + randf() * 3.0)
	player = area.get_parent()

func process(delta: float) -> void:
	if player:
		controller.camera.look_at(player.global_position + Vector3(0, 1.0, 0))
		controller.shoot(false)
		if player.global_position.distance_to(controller.global_position + offset) > equilibrium_distance:
			var dir: Vector3 = controller.global_position.direction_to(player.global_position + offset)
			controller.move_dir = controller.move_dir.move_toward(Vector2(dir.x, dir.z).normalized(), delta * 8)
		else:
			controller.move_dir = controller.move_dir.move_toward(Vector2(), delta)
		if controller.will_fall():
			controller.move_dir = Vector2()
