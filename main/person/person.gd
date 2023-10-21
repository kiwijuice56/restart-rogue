class_name Person
extends CharacterBody3D

@export var max_health: int = 10

@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2
@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var health: int = max_health

# The statea machine can manipulate these vectors to control the person
var grav_vel: Vector3 
var jump_vel: Vector3 
var walk_vel: Vector3 
var move_dir: Vector2 # Input direction for movement

var jumping: bool = false

@onready var camera: Camera3D = $Camera3D
@onready var state_machine: StateMachine = $StateMachine

func _ready() -> void:
	$MainHitbox.area_entered.connect(_on_hurt.bind([1.0]))
	$HeadHitbox.area_entered.connect(_on_hurt.bind([2.0]))

func _on_hurt(area: Area3D, damage_multiplier: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	state_machine.process(delta)
	
	velocity = _gravity(delta) + _jump(delta) + _walk(delta)
	move_and_slide()
	
	$Manikin.rotation.y = $Camera3D.rotation.y

func _input(event: InputEvent) -> void:
	state_machine.input(event)

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func _walk(delta: float) -> Vector3:
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel
