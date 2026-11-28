extends State

func enter_state(_data: Dictionary = {}) -> void:
	# very hacky, my god
	# but it works
	if owner.target != null:
		switch_state.emit("follow", {"target": owner.target})
	
	actor.velocity = Vector3.ZERO
	actor.move_and_slide()

func physics_update(_delta: float) -> void:
	if !actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta
	
	actor.move_and_slide()
