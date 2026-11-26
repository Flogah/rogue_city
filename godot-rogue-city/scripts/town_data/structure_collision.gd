class_name StructureCollision
extends Node3D

@export var positioning_area: Area3D
@export var visual: Node3D
@export var static_collision: StaticBody3D
@export var influence_area: Area3D

var hinting:bool = false

func can_place() -> bool:
	return is_overlapping()

func is_overlapping() -> bool:
	if !positioning_area:
		return false
	var overlapping_areas = positioning_area.get_overlapping_areas()
	if overlapping_areas.is_empty():
		return false
	return true
