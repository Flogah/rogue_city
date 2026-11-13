extends State

@export var nav_agent: NavigationAgent3D

var random_timer: Timer

var target_pos

func enter_state(_data: Dictionary = {}) -> void:
	randomize_target_position()
	
	if !random_timer:
		random_timer = Timer.new()
		random_timer.one_shot = true
		add_child(random_timer)
		
	random_timer.timeout.connect(randomize_target_position)
	nav_agent.velocity_computed.connect(on_velocity_computed)

func physics_update(_delta: float) -> void:
	nav_agent.target_position = target_pos
	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	var dir = actor.global_position.direction_to(next_path_pos)
	var new_velocity = dir * actor.speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		on_velocity_computed(new_velocity)
	
	if nav_agent.is_navigation_finished():
		switch_state.emit("attack")
	
	var rot_speed = 4.0
	var target_rot = dir.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
	if  abs(target_rot - actor.rotation.y) > deg_to_rad(60):
		rot_speed = 20.0
	actor.rotation.y = move_toward(actor.rotation.y, target_rot, _delta * rot_speed)
	
	actor.move_and_slide()

func exit_state() -> void:
	nav_agent.velocity_computed.disconnect(on_velocity_computed)
	random_timer.timeout.disconnect(randomize_target_position)

func random_vector3(bound: Vector3) -> Vector3:
	var rand_vec:Vector3 = Vector3.ZERO
	rand_vec.x = randf_range(-bound.x, bound.x)
	rand_vec.y = randf_range(-bound.y, bound.y)
	rand_vec.z = randf_range(-bound.z, bound.z)
	return rand_vec

func on_velocity_computed(safe_velocity: Vector3) -> void:
	actor.velocity = safe_velocity

func randomize_target_position():
	target_pos = random_vector3(Vector3(10.0, 0.0, 10.0))
