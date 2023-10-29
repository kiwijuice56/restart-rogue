class_name Level extends Node3D

func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D and child.get_child_count() == 0:
			child.create_convex_collision()
