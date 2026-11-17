extends State

@export var animation_player: AnimationPlayer
var combo_over:bool = false

func enter_state(_data: Dictionary = {}) -> void:
	animation_player.play("attack_3")
	animation_player.animation_finished.connect(end_combo)

func end_combo(_str):
	combo_over = true
	animation_player.animation_finished.disconnect(end_combo)
	switch_state.emit("moving")
