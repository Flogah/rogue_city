extends State

@export var nav_agent: NavigationAgent3D
var target: Node3D
var target_location: Vector3

func enter_state(_data: Dictionary = {}) -> void:
	nav_agent.velocity_computed.connect(on_velocity_computed)
	
	if _data.has("target"):
		target = _data.get("target")
		nav_agent.target_position = target.global_position
		owner.target_lost.connect(lose_target)
	elif _data.has("target_location"):
		target_location = _data.get("target_location")
		nav_agent.target_position = target_location
	elif target_location:
		nav_agent.target_position = target_location
	else:
		switch_state.emit("idle")

func physics_update(_delta: float) -> void:
	if target:
		nav_agent.target_position = target.global_position
	else:
		nav_agent.target_position = target_location
	
	if nav_agent.is_navigation_finished():
		if target:
			switch_state.emit("attack")
		else:
			switch_state.emit("idle")
	
	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	var dir = actor.global_position.direction_to(next_path_pos)
	var new_velocity = dir * actor.speed

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		on_velocity_computed(new_velocity)
	
	var rot_speed = 4.0
	var target_rot = dir.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
	if  abs(target_rot - actor.rotation.y) > deg_to_rad(60):
		rot_speed = 20.0
	actor.rotation.y = move_toward(actor.rotation.y, target_rot, _delta * rot_speed)
	
	actor.move_and_slide()

func lose_target(body: Node3D):
	target_location = body.global_position
	target = null

func exit_state() -> void:
	nav_agent.velocity_computed.disconnect(on_velocity_computed)
	owner.target_lost.disconnect(lose_target)

func on_velocity_computed(safe_velocity: Vector3) -> void:
	actor.velocity = safe_velocity
