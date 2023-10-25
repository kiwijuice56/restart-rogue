class_name Main extends Node

@export var player: Player

func shift(enemy: Person) -> void:
	player.health = enemy.health
	player.projectile = enemy.projectile
	player.global_transform = enemy.global_transform
	
	$HUD.restart()
	
	enemy.queue_free()
