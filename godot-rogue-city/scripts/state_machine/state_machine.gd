class_name StateMachine extends Node

@export var initial_state:State
@onready var actor: CharacterBody3D = owner

var active_state: State

var states:Dictionary[String, Node] = {}

## Stores a requested transition if the current state is locked (`can_exit() == false`).
var _pending_transition: Dictionary = {}

func _ready() -> void:
	for child_state:State in get_children():
		var id: StringName = child_state.state_id if child_state.state_id != &"" else StringName(child_state.name)
		var key := StringName(id.to_lower())
		
		if states.has(key):
			push_warning("StateMachine: Duplicate state key '%s' found." % key)
		
		states[key] = child_state
		child_state.switch_state.connect(change_state)
		child_state.statemachine = self
		child_state.actor = actor
		
		child_state.set_process(false)
		child_state.set_physics_process(false)
		child_state.set_process_unhandled_input(false)
	
	if initial_state:
		active_state = initial_state
		active_state.enter_state()

func _process(delta: float) -> void:
	if active_state:
		active_state.update(delta)
	_check_pending_transition()

func _physics_process(delta: float) -> void:
	if active_state:
		active_state.physics_update(delta)
	_check_pending_transition()

func _unhandled_input(event: InputEvent) -> void:
	if active_state:
		active_state.handle_input(event)

func change_state(new_state_name: StringName, _data: Dictionary = {}) -> void:
	var key:= String(new_state_name.to_lower())
	
	var new_state: State = states.get(key)
	if not new_state:
		push_warning("StateMachine: State '%s' does not exist." % new_state_name)
		return
	
	if active_state and not active_state.can_exit():
		_pending_transition = {"key": key, "data": _data}
		return
	
	_execute_transition(new_state, _data)


## Checks if a queued transition can now execute because the state unlocked.
func _check_pending_transition() -> void:
	if _pending_transition.is_empty():
		return

	if active_state and active_state.can_exit():
		var next_key: StringName = _pending_transition["key"]
		var next_msg: Dictionary = _pending_transition["data"]
		_pending_transition.clear()

		var next_state: State = states.get(next_key)
		if next_state:
			_execute_transition(next_state, next_msg)


## Internal helper to handle clean switching and self-transitions.
func _execute_transition(new_state: State, data: Dictionary) -> void:
	if active_state == new_state:
		active_state.exit_state()
		active_state.enter_state(data)
		return

	if active_state:
		active_state.exit_state()

	active_state = new_state
	new_state.enter_state(data)
