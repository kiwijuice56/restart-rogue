class_name RestartPill extends Projectile

func _on_collision_area(area: Area3D) -> void:
	if area.get_parent() == sender or exploding:
		return
	explode()
	var enemy: Person = area.get_parent()
	get_tree().get_root().get_node("Main").shift(enemy)
