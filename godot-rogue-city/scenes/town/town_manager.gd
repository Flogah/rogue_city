class_name TownManager
extends Node

@export var structures_parent: Node3D
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

func build_structure(target_structure:Structure, target_transform: Transform3D):
	var struct_instance:Node3D = target_structure.model.instantiate()
	structures_parent.add_child(struct_instance)
	struct_instance.transform = target_transform
	built_structures_dict[struct_instance] = target_structure

func demolish_structure(target_structure:Node3D):
	if built_structures_dict.has(target_structure):
		built_structures_dict.erase(target_structure)
	target_structure.queue_free()

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
