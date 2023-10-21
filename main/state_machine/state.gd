class_name State extends Node

@onready var state_machine: StateMachine = get_parent()
@onready var controller: CharacterBody3D = state_machine.controller

func enter(from: String, data: Dictionary = {}) -> void:
	return

func exit(to: String, data: Dictionary = {}) -> void:
	return

func process(delta: float) -> void:
	pass

func input(event: InputEvent) -> void:
	pass
