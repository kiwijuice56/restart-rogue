class_name HUD extends CanvasLayer


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_copy"):
		restart()

func restart() -> void:
	$AnimationPlayer.play("restart")
