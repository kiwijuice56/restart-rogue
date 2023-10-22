class_name Projectile extends Node3D

@export var speed: float = 10.0

var dir: Vector3

func _ready() -> void:
	set_physics_process(false)

func start() -> void:
	$AnimationPlayer.play("charge")
	
	await $AnimationPlayer.animation_finished
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	position += speed * dir * delta
