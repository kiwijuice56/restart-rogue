class_name Person
extends CharacterBody3D
# Base class for all characters
# Includes basic interface for movement, health, shooting

@export var max_health: float = 10

@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2
@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m

@export var projectile_spawn: Marker3D
@export var projectile: PackedScene

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# The state machine can manipulate these variables to control the person
var move_dir: Vector2 # Input direction for movement
var jumping: bool = false

var grav_vel: Vector3 
var jump_vel: Vector3 
var walk_vel: Vector3 
var shove: Vector3

@onready var camera: Camera3D = $Camera3D
@onready var model: Node3D = $Manikin
@onready var state_machine: StateMachine = $StateMachine

@onready var health: float = max_health

func _ready() -> void:
	$MainHitbox.area_entered.connect(_on_hurt.bind(1.0))
	$HeadHitbox.area_entered.connect(_on_hurt.bind(2.0))

func _on_hurt(area: Area3D, damage_multiplier: float) -> void:
	if not area.get_parent() is Projectile:
		return
	var p: Projectile = area.get_parent() as Projectile
	
	if p.sender == self:
		return
	
	health -= p.damage * damage_multiplier
	
	walk_vel += p.momentum
	
	if health <= 0:
		die()
	else:
		model.get_node("GameAnimationPlayer").play("hurt")

func _physics_process(delta: float) -> void:
	state_machine.process(delta)
	velocity = _gravity(delta) + _jump(delta) + _walk(delta, camera.current)
	
	_animate()
	move_and_slide()

func _input(event: InputEvent) -> void:
	state_machine.input(event)

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor():
			jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
			$JumpStreamPlayer.play()
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

# Player moves along camera direction, while enemies move along global axes for 
# ease of coding
func _walk(delta: float, camera_basis: bool = false) -> Vector3:
	var walk_dir: Vector3 
	
	if camera_basis: 
		var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
		walk_dir = Vector3(_forward.x, 0, _forward.z).normalized()
	else:
		walk_dir = Vector3(move_dir.x, 0, move_dir.y)
	
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _animate() -> void:
	var run_strength: float = velocity.length() / speed
	run_strength *= (1.0 + Vector3(move_dir.x, 0, move_dir.y).dot(-camera.transform.basis.z)) / 2.0
	if move_dir.length() > 0:
		run_strength = max(0.1, run_strength)
	
	model.rotation.y = camera.rotation.y
	model.get_node("AnimationTree").set("parameters/Normal/run_amount/blend_amount", run_strength)

func shoot(shoot_dir: Vector3 = -camera.basis.z) -> void:
	var new_projectile: Projectile = projectile.instantiate()
	new_projectile.sender = self
	
	projectile_spawn.add_child(new_projectile)
	
	new_projectile.global_position = projectile_spawn.global_position
	new_projectile.dir = shoot_dir
	
	await new_projectile.start()
	
	projectile_spawn.remove_child(new_projectile)
	get_tree().get_root().add_child(new_projectile)
	new_projectile.global_position =  projectile_spawn.global_position

func die() -> void:
	$MainHitbox/CollisionShape3D.call_deferred("set", "disabled", true)
	
	# Visuals
	model.get_node("Top/Skeleton3D").physical_bones_start_simulation()
	model.get_node("Bottom/Skeleton3D").physical_bones_start_simulation()
	model.get_node("%Blood").emitting = true
	model.get_node("GameAnimationPlayer").play("death")
	
	var timer: SceneTreeTimer = get_tree().create_timer(2.0)
	await timer.timeout
	queue_free()
