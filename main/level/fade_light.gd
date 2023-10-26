class_name FadeLight extends OmniLight3D

func _ready() -> void:
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	visible = false

func _on_body_entered(body: PhysicsBody3D) -> void:
	if body.is_player:
		visible = true

func _on_body_exited(body: PhysicsBody3D) -> void:
	if body.is_player:
		visible = false
