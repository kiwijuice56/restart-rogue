class_name Weapon extends Node3D



func _ready() -> void:
	$Plasma.set("instance_shader_parameters/offset", Vector2(randf(), randf()))
