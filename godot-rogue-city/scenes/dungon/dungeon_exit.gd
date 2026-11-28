
extends Area3D

@export var target_scene: PackedScene = load("res://scenes/town/town_main.tscn")
@onready var mesh: Node3D = $mesh

@export var hover_height: float = 0.3
@export var hover_duration: float = 0.8

func _ready() -> void:
	var start_position = mesh.position

	var tween = create_tween()
	tween.set_loops()

	tween.tween_property(
		mesh,
		"position:y",
		start_position.y + hover_height,
		hover_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		mesh,
		"position:y",
		start_position.y,
		hover_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		get_tree().change_scene_to_packed(target_scene)
