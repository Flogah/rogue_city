extends State

@export var player: Player
#@export var hurtbox: HurtBox
#@export var stamina_comp: StaminaComponent

var direction: Vector3
var roll_time: float

func enter_state(data: Dictionary = {}) -> void:
	if data.direction is Vector3:
		direction = data.direction
	roll_time = 0
	player.mesh.scale.y = 0.3

func exit_state() -> void:
	player.mesh.scale.y = 1.0

func update(delta: float) -> void:
	player.velocity = direction * player.speed * 1.8
	roll_time += delta
	if roll_time >= player.roll_duration:
		switch_state.emit("Moving")
