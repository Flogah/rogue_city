extends State

@export var player: Player
@export var hurtbox: HurtBox
@export var stamina_comp: StaminaComponent

var direction: Vector3
var roll_time: float

func enter_state(data: Dictionary = {}) -> void:
	if stamina_comp:
		if data.direction and stamina_comp.use(20.0):
			if data.direction is Vector3:
				direction = data.direction
			if hurtbox:
				hurtbox.monitorable = false
			roll_time = 0
			player.mesh.scale.y = 0.3
			return
	switch_state.emit("Moving")

func exit_state() -> void:
	player.mesh.scale.y = 1.0
	if hurtbox:
		hurtbox.monitorable = true

func update(delta: float) -> void:
	player.velocity = direction * player.speed * 1.8
	roll_time += delta
	if roll_time >= player.roll_duration:
		switch_state.emit("Moving")
