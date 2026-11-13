extends State

@export var player: Player

func update(delta: float) -> void:
	if player:
		var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var forward: Vector3 = -player.camera_arm.global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
		
		var right: Vector3 = player.camera_arm.global_transform.basis.x.normalized()
		
		var move_vector: Vector3 = right * input_vector.x - forward * input_vector.y
		player.velocity.x = move_vector.x * player.speed
		player.velocity.z = move_vector.z * player.speed
		
		if move_vector.length_squared() > 0.001:
			var target_angle := atan2(-move_vector.x, -move_vector.z)
			player.mesh.rotation.y = lerp_angle(player.mesh.rotation.y, target_angle, player.rotation_speed * delta)
		
		if Input.is_action_just_pressed("roll") and player.is_on_floor():
			switch_state.emit("Rolling", { direction = move_vector })
			#print(input_vector)
