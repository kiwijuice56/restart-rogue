class_name Projectile extends Node3D

@export var speed: float = 12.0
@export var gravity: float = -6.0

var velocity: Vector3
var dir: Vector3

func _ready() -> void:
	set_physics_process(false)
	$Area3D.body_entered.connect(_on_collision)

func start() -> void:
	$AnimationPlayer.play("charge")
	
	await $AnimationPlayer.animation_finished
	velocity = dir * speed
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity.y += gravity * delta

func _on_collision(body: PhysicsBody3D):
	set_physics_process(false)
	$AnimationPlayer.play("explode")
	await $AnimationPlayer.animation_finished
	call_deferred("queue_free")
