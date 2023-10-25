class_name HUD extends CanvasLayer

@export var player: Player

func _ready() -> void:
	player.health_changed.connect(_on_health_changed)
	player.cooldown_started.connect(_on_cooldown_start)
	player.restart_changed.connect(_on_restart_changed)

func _on_health_changed(health: float, hurt: bool) -> void:
	%HealthLabel.text = "[shake rate=20.0 level=5 connected=1]HP " + str(round(100 * health / player.max_health)) + "%[/shake]"
	if hurt:
		$AnimationPlayer2.stop()
		$AnimationPlayer2.play("hurt")

func _on_restart_changed(val: int) -> void:
	%RestartLabel.text = "[shake rate=20.0 level=5 connected=1]" + str(val) + " RESTART[/shake]"

func _on_cooldown_start(cooldown: float) -> void:
	var tween: Tween = get_tree().create_tween()
	%CooldownProgress.value = 1.0
	tween.tween_property(%CooldownProgress, "value", 0.0, cooldown)

func restart(weapon_name: String) -> void:
	$AnimationPlayer.play("restart")
	%WeaponLabel.text = "[shake rate=20.0 level=5 connected=1]" + weapon_name + "[/shake]"
