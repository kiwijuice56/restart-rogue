class_name Main extends Node

@export var player: Player

func shift(enemy: Person) -> void:
	player.health = enemy.health
	player.projectile = enemy.projectile
	enemy.get_node("CollisionShape3D").call_deferred("set", "disabled", true)
	enemy.model.get_node("GameAnimationPlayer").set_process_mode(PROCESS_MODE_ALWAYS)
	enemy.model.get_node("GameAnimationPlayer").play("death")
	
	var stupidugh: Projectile = player.projectile.instantiate()
	$HUD.restart(stupidugh.game_name)
	stupidugh.queue_free()
	
	get_tree().paused = true
	
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	var stupid_tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	tween = tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	stupid_tween.tween_property(player.camera, "fov", 90, 0.4)
	
	tween.tween_property(player, "global_transform", enemy.global_transform, 0.7)
	tween.tween_property(player.camera, "rotation", enemy.camera.rotation, 1.3)
	
	await tween.finished
	
	stupid_tween = get_tree().create_tween()
	stupid_tween.tween_property(player.camera, "fov", 75, 0.2)
	
	enemy.queue_free()
	
	get_tree().paused = false
