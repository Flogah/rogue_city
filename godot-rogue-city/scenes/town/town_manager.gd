class_name TownManager
extends Node

@export var town_data:TownData
@export var structures_parent: Node3D

# a list of the actually built structures as a dictionary
# listed by Node3D (every structure has a unique node) and underlying structure.res
# this should make it possible to access all relevant gameplay code of existing structures
var built_structures_dict: Dictionary[Node3D, Structure]

func _ready() -> void:
	reload_structures()

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

func backup_structures():
	town_data.clear_town_data()
	for key in built_structures_dict.keys():
		town_data.save_structure(built_structures_dict.get(key), key.transform)
	town_data.save_town()

func reload_structures():
	for child:Node in structures_parent.get_children():
		structures_parent.remove_child(child)
		if built_structures_dict.has(child): built_structures_dict.erase(child)
		child.queue_free()
	town_data.load_town()
	for struct_data:StructureData in town_data.structures:
		build_structure(struct_data.structure, struct_data.transform)

func get_resources() -> Dictionary:
	return town_data.town_resources

func spend_resource(supstruct: SuperStructure, amount: int) -> bool:
	if !town_data.town_resources.has(supstruct):
		return false
	var result: int = town_data.town_resources.get(supstruct)
	result -= amount
	if result < 0:
		return false
	town_data.town_resources.set(supstruct, result)
	return true

func add_resource(supstruct: SuperStructure, amount: int) -> bool:
	if !town_data.town_resources.has(supstruct):
		return false
	var result: int = town_data.town_resources.get(supstruct)
	result += amount
	town_data.town_resources.set(supstruct, result)
	return true
	
