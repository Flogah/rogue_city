class_name StructureCollision
extends Node3D

@export var positioning_area: Area3D
@export var visual: Node3D
@export var static_collision: StaticBody3D
@export var influence_area: Area3D

var hint_mat:StandardMaterial3D

var hinting:bool = false

func _ready() -> void:
	hint_mat = StandardMaterial3D.new()
	var meshes = visual.get_children()
	for mesh:MeshInstance3D in meshes:
		mesh.set_surface_override_material(0, hint_mat)

func _physics_process(delta: float) -> void:
	if hinting:
		hint_positioning()

func start_hinting():
	hinting = true

func can_place() -> bool:
	return is_overlapping()

func is_overlapping() -> bool:
	if !positioning_area:
		return false
	var overlapping_areas = positioning_area.get_overlapping_areas()
	if overlapping_areas.is_empty():
		return false
	return true

func hint_positioning():
	if is_overlapping():
		hint_mat.albedo_color = Color.RED
	else:
		hint_mat.albedo_color = Color.WHITE
