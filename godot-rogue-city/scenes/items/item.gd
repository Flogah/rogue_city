extends Area3D
class_name Item

@onready var town_data: TownData = preload("res://scripts/town_data/town_data_1.tres")
@onready var mesh: Node3D = $mesh

func _ready() -> void:
	body_entered.connect(collect)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(
		mesh,
		"rotation:y",
		10+mesh.rotation.y,
		1.0
	)

func collect(body) -> void:
	if body is Player:
		if add_resource(load("res://scenes/town/example_structures/super_house.tres"), 1):
			town_data.save_town()
			queue_free()

func add_resource(supstruct: SuperStructure, amount: int = 1) -> bool:
	if !town_data.town_resources.has(supstruct):
		return false
	var result: int = town_data.town_resources.get(supstruct)
	result += amount
	town_data.town_resources.set(supstruct, result)
	return true
