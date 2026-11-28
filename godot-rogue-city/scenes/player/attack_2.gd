extends State


var combo_over:bool = false

@export var animation_player: AnimationPlayer

func enter_state(_data: Dictionary = {}) -> void:
	animation_player.play("attack_2")
	animation_player.animation_finished.connect(end_combo)

func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("attack") and !combo_over:
		animation_player.animation_finished.disconnect(end_combo)
		animation_player.animation_finished.connect(continue_combo)

func end_combo(_str):
	combo_over = true
	animation_player.animation_finished.disconnect(end_combo)
	switch_state.emit("moving")

func continue_combo(_str):
	combo_over = false
	animation_player.animation_finished.disconnect(continue_combo)
	switch_state.emit("attack3")
