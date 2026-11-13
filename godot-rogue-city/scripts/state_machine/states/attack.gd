extends State

@onready var attack_anim_player: AnimationPlayer = %AttackAnimPlayer

func enter_state(_data: Dictionary = {}) -> void:
	attack_anim_player.play("attack")
	attack_anim_player.animation_finished.connect(on_end_attack)

func on_end_attack(_anim_name):
	switch_state.emit("idle")

func exit_state() -> void:
	attack_anim_player.animation_finished.disconnect(on_end_attack)
