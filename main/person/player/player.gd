class_name Player extends Person

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_sens_up", false):
		$StateMachine/FreeControl.camera_sens += 0.2
	if event.is_action_pressed("mouse_sens_down", false):
		$StateMachine/FreeControl.camera_sens -= 0.2
	$StateMachine/FreeControl.camera_sens = clamp($StateMachine/FreeControl.camera_sens, 0.3, 10.0)

func die() -> void:
	get_tree().paused = true
	get_tree().get_root().get_node("Main/SubViewportContainer/SubViewport/AudioStreamPlayer").playing = false
	get_tree().get_root().get_node("Main/HUD").die()
