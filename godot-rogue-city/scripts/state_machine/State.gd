class_name State extends Node

# must be called to switch to a different state.
signal switch_state(new_state_name: StringName, data: Dictionary)

@export var state_id: StringName = &""

# a reference set by the statemachine so the state knows what to affect
var actor: CharacterBody3D
var statemachine: StateMachine

func enter_state(_data: Dictionary = {}) -> void:
	# always happens first when entering the state
	pass

func exit_state() -> void:
	# always happens after the state is done, right before the new state enters
	pass

func update(_delta: float) -> void:
	# replaces process
	pass

func physics_update(_delta: float) -> void:
	# replaces physics_process
	pass

func handle_input(_event: InputEvent) -> void:
	# for handling input handed down by the state machine
	pass

func can_exit() -> bool:
	# for checking if a state cant be canceled, like an incible frame dodge roll
	return true
