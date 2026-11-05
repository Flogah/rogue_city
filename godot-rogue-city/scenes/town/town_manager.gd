class_name TownManager
extends Node

@export var structures_parent: Node3D
@export var preview_container: Node3D
@export var preview_node: Node3D
# a list of all available structures
# structure and amount of structures you have to build
# if amount = 0, the structure should be hidden in the UI maybe?
# otherwise, needs a setup so players don't get overwhelmed by options on first build
# ex: ANNO 1800 UI
@export var structure_inventory: Dictionary[Structure, int]

# a list of the actually built structures as a dictionary
# listed by position and individual structure
var built_structures_dict: Dictionary[Transform3D, Structure]

func _ready() -> void:
	reload_structures()

func build_structure(target_transform: Transform3D, target_structure:Structure):
	var struct_instance:Node3D = target_structure.model.instantiate()
	structures_parent.add_child(struct_instance)
	struct_instance.transform = target_transform
	built_structures_dict[target_transform] = target_structure

func demolish_structure(target_structure:Node3D):
	if built_structures_dict.has(target_structure.transform):
		built_structures_dict.erase(target_structure.transform)
	target_structure.queue_free()

func reload_structures():
	for child:Node in structures_parent.get_children():
		structures_parent.remove_child(child)
		child.queue_free()
	for trans:Transform3D in built_structures_dict:
		var target_structure: Structure = built_structures_dict.get(trans)
		build_structure(trans, target_structure)

func update_preview(struct: Structure):
	for child in preview_container.get_children():
		preview_container.remove_child(child)
		child.queue_free()
	var new_preview:Node3D = struct.model.instantiate()
	preview_container.add_child(new_preview)

func position_preview(pos: Vector3):
	preview_node.global_position = pos

func rotate_preview(deg: float):
	preview_container.rotation.y += deg

func get_mesh(packed_scene):
	var scene_state:SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if(scene_state.get_node_type(i) == "MeshInstance3D"):
			for j in scene_state.get_node_property_count(i):
				var prop_name = scene_state.get_node_property_name(i, j)
				if prop_name == "mesh":
					var prop_value = scene_state.get_node_property_value(i, j)
					
					return prop_value.duplicate()
