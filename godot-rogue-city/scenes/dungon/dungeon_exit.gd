extends Area3D

@export var target_scene: PackedScene = load("res://scenes/town/town_main.tscn")


func _on_body_entered(body: Node3D) -> void:
	if true: #TODO: change to if body == player
		get_tree().change_scene_to_packed(target_scene)
