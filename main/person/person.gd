class_name Person
extends CharacterBody3D
# Base class for all characters
# Includes basic interface for movement, health, shooting

@export var max_health: float = 10

@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2
@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export var is_player: bool = false
@export var score_give: float = 100

@export var projectile_spawn: Marker3D
@export var projectile: PackedScene
@export var restart_projectile: PackedScene = preload("res://main/projectile/restart_pill/restart_pill.tscn")
@export var cooldown_extra_max: float = 0.4

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# The state machine can manipulate these variables to control the person
var move_dir: Vector2 # Input direction for movement
var jumping: bool = false
var hurt: bool = false
var dead: bool = false
var on_ground: bool = false

var score: int = 0:
	set(s):
		score = s
		score_changed.emit(s)

var grav_vel: Vector3 
var jump_vel: Vector3 
var walk_vel: Vector3 
var shove: Vector3
var restart_pills: int = 3:
	set(v):
		restart_changed.emit(v)
		restart_pills = v

@onready var camera: Camera3D = $Camera3D
@onready var model: Node3D = $Manikin
@onready var state_machine: StateMachine = $StateMachine

@onready var health: float = max_health:
	set(h):
		health_changed.emit(h, hurt)
		hurt = false
		health = h

var last_collider: Projectile

signal cooldown_started(val)
signal health_changed(val, hurt)
signal restart_changed(val)
signal score_changed(val)

func _ready() -> void:
	$MainHitbox.area_entered.connect(_on_hurt.bind(1.0))
	$HeadHitbox.area_entered.connect(_on_hurt.bind(2.0))

func _on_hurt(area: Area3D, damage_multiplier: float) -> void:
	if not area.get_parent() is Projectile:
		return
	var p: Projectile = area.get_parent() as Projectile
	
	if p == last_collider:
		return
	if damage_multiplier > 1.0 and not p.can_crit:
		damage_multiplier = 1.0
	last_collider = p
	
	if p.sender == self:
		return
	
	if dead: 
		return
	
	if not is_player and not p.sender.is_player:
		return 
	
	hurt = true
	self.health -= p.damage * damage_multiplier * (0.5 if is_player else 1.0)
	
	walk_vel += p.momentum
	
	if health <= 0:
		if is_instance_valid(p.sender):
			p.sender.score += score_give 
		die()
	else:
		if not is_player:
			$HurtStreamPlayer.play()
			if damage_multiplier > 1.0:
				$HurtStreamPlayer2.play()
		model.get_node("GameAnimationPlayer").stop()
		model.get_node("GameAnimationPlayer").play("hurt")

func _physics_process(delta: float) -> void:
	state_machine.process(delta)
	velocity = _gravity(delta) + _jump(delta) + _walk(delta, is_player)
	
	if not is_on_floor():
		on_ground = false
	if is_on_floor() and not on_ground:
		on_ground = true
		if is_player:
			$FallStreamPlayer.play()
	
	_animate()
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
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

func shoot(restart: bool = false, shoot_dir: Vector3 = -camera.global_basis.z) -> void:
	if not $ShootTimer.is_stopped():
		return
	if not is_player and model.get_node("GameAnimationPlayer").is_playing():
		return
	
	var new_projectile: Projectile = restart_projectile.instantiate() if restart else projectile.instantiate()
	if restart and restart_pills <= 0:
		return
	if restart:
		restart_pills -= 1
	
	new_projectile.sender = self
	$ShootTimer.start(new_projectile.cooldown + (0 if is_player else randf() * cooldown_extra_max))
	cooldown_started.emit($ShootTimer.wait_time)
	
	if not is_instance_valid(projectile_spawn):
		return
	
	if is_player:
		self.health = max(0.1, health - new_projectile.cost)
	
	projectile_spawn.add_child(new_projectile)
	
	new_projectile.global_position = projectile_spawn.global_position
	if is_player: 
		var real_dir: Vector3 
		if $Camera3D/AimRayCast3D.is_colliding():
			real_dir = $Camera3D/AimRayCast3D.get_collision_point() - projectile_spawn.global_position
		else:
			var origin_r = $Camera3D/AimRayCast3D.to_global(Vector3.ZERO)
			var end_point = $Camera3D/AimRayCast3D.to_global($Camera3D/AimRayCast3D.target_position) 
			var end_point_global = end_point - origin_r
			real_dir = end_point - projectile_spawn.global_position 
		new_projectile.dir = real_dir.normalized().rotated(Vector3(1, 1, 0).normalized(), 0.1 * new_projectile.bloom * (randf() - 0.5))
	else: new_projectile.dir = shoot_dir
	await new_projectile.start()
	
	projectile_spawn.remove_child(new_projectile)
	get_tree().get_root().add_child(new_projectile)
	new_projectile.global_rotation = camera.global_rotation
	new_projectile.global_position =  projectile_spawn.global_position

func die() -> void:
	dead = true
	$DeadStreamPlayer.play()
	$HeadHitbox/CollisionShape3D.call_deferred("set", "disabled", true)
	$MainHitbox/CollisionShape3D.call_deferred("set", "disabled", true)
	call_deferred("set", "collision_layer", 0)
	set_physics_process(false)
	
	# Visuals
	model.get_node("Top/Skeleton3D").physical_bones_start_simulation()
	model.get_node("Bottom/Skeleton3D").physical_bones_start_simulation()
	model.get_node("%Blood").emitting = true
	model.get_node("GameAnimationPlayer").play("death")
	
	var timer: SceneTreeTimer = get_tree().create_timer(2.0)
	await timer.timeout
	queue_free()

func will_fall() -> bool:
	$FloorCast.position = walk_vel / 16
	$FloorCast.force_raycast_update()
	return not $FloorCast.is_colliding()
