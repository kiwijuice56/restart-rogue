class_name FadeLight extends OmniLight3D

var tween: Tween
var l: float 

func _ready() -> void:
	l = light_energy
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	light_energy = 0

func _on_body_entered(body: PhysicsBody3D) -> void:
	if body.is_player:
		if tween != null and tween.is_running():
			tween.stop()
		tween = get_tree().create_tween()
		tween.tween_property(self, "light_energy", l, 0.3)

func _on_body_exited(body: PhysicsBody3D) -> void:
	if body.is_player:
		if tween != null and tween.is_running():
			tween.stop()
		tween = get_tree().create_tween()
		tween.tween_property(self, "light_energy", 0, 0.3)
