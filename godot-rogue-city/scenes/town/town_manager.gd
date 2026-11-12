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
# listed by Node3D (every structure has a unique node) and underlying structure.res
# this should make it possible to access all relevant gameplay code of existing structures
var built_structures_dict: Dictionary[Node3D, Structure]

func build_structure(target_structure:Structure, target_transform: Transform3D = preview_node.transform):
	var struct_instance:Node3D = target_structure.model.instantiate()
	structures_parent.add_child(struct_instance)
	struct_instance.transform = target_transform
	built_structures_dict[struct_instance] = target_structure
	update_preview()

func demolish_structure(target_structure:Node3D):
	if built_structures_dict.has(target_structure):
		built_structures_dict.erase(target_structure)
	target_structure.queue_free()

func update_preview(struct: Structure = null):
	for child in preview_container.get_children():
		preview_container.remove_child(child)
		child.queue_free()
	if !struct: return
	var new_preview:Node3D = struct.model.instantiate()
	preview_container.add_child(new_preview)

func position_preview(pos: Vector3):
	preview_node.global_position = pos

func position_preview_snapped(pos: Vector3):
	position_preview(pos)
	preview_node.global_position = preview_node.global_position.snapped(Vector3.ONE)

func rotate_preview(deg: float):
	preview_node.rotation_degrees.y += deg

func rotate_preview_snapped(deg: float):
	rotate_preview(deg)
	preview_node.rotation_degrees.y = snappedf(preview_node.rotation_degrees.y, 45.0)

# i want to be able to save the built_structures_dict and then build it
# probably needs a helper data structure

#func backup_structures():
	#for child:Node in structures_parent.get_children():
		# save it in external data

#func reload_structures():
	#for child:Node in structures_parent.get_children():
		#structures_parent.remove_child(child)
		#child.queue_free()
	# load up the external data
	# for struct in external data:
		# build_structure(struct)

# to extract just the mesh from a scene
# could be useful for preview stuff
# with a stylish shader on top
func get_mesh(packed_scene):
	var scene_state:SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if(scene_state.get_node_type(i) == "MeshInstance3D"):
			for j in scene_state.get_node_property_count(i):
				var prop_name = scene_state.get_node_property_name(i, j)
				if prop_name == "mesh":
					var prop_value = scene_state.get_node_property_value(i, j)
					
					return prop_value.duplicate()
