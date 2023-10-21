class_name StateMachine extends Node

@export var controller: CharacterBody3D
@export var state: State 

func _ready() -> void:
	await state.enter("nil")

func switch(to: String, data: Dictionary = {}) -> void:
	await state.exit(to, data)
	var old_state: String = state.name
	state = get_node(to)
	await state.enter(old_state, data)

func process(delta: float) -> void:
	state.process(delta)

func input(event: InputEvent) -> void:
	state.input(event)
