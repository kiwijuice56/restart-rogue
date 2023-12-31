class_name Projectile extends Node3D
# Base class for all attacks

@export var speed: float = 12.0
@export var gravity: float = -6.0
@export var damage: float = 1.0
@export var mass: float = 0.6
@export var cost: float = 0.01
@export var cooldown: float = 0.5
@export var lifetime: float = 5.0
@export var can_crit: bool = true
@export var game_name: String
@export var bloom: float = 1.0

var momentum: Vector3
var sender: Person
var velocity: Vector3
var dir: Vector3
var exploding: bool = false

func _ready() -> void:
	set_physics_process(false)
	$Area3D.body_entered.connect(_on_collision)
	$Area3D.area_entered.connect(_on_collision_area)
	$Timer.timeout.connect(queue_free)
	$Timer.start(lifetime)

func start() -> void:
	$AnimationPlayer.play("charge")
	
	await $AnimationPlayer.animation_finished
	velocity = dir * speed
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity.y += gravity * delta
	momentum = velocity * mass

func _on_collision(body: PhysicsBody3D) -> void:
	if body is Person and body.dead:
		return
	if not exploding:
		explode()

func _on_collision_area(area: Area3D) -> void:
	if area.get_parent() == sender or exploding:
		return
	explode()

func explode() -> void:
	exploding = true
	set_physics_process(false)
	$AnimationPlayer.play("explode")
	await $AnimationPlayer.animation_finished
	call_deferred("queue_free")
