class_name PlasmaEffect extends MeshInstance3D


func _ready() -> void:
	set_instance_shader_parameter("offset", Vector2(randf(), randf()))
