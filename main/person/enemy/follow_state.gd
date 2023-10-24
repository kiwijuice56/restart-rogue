class_name FollowState extends State

@export var detection_area: Area3D

var player: Player

func _ready() -> void:
	detection_area.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	player = area.get_parent()

func process(delta: float) -> void:
	if player:
		controller.shoot()
		if player.global_position.distance_to(controller.global_position) > 4.0:
			var dir: Vector3 = controller.global_position.direction_to(player.global_position)
			controller.move_dir = controller.move_dir.move_toward(Vector2(dir.x, dir.z).normalized(), delta * 8)
		else:
			controller.move_dir = controller.move_dir.move_toward(Vector2(), delta )
		controller.camera.look_at(player.global_position + Vector3(0, 1.0, 0))
