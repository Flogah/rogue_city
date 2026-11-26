class_name SuperStructure
extends Resource

@export var group_name: String = &""
@export var structures: Array[Structure]
@export var adapt_structures_to_collider:bool = false

@export_subgroup("UI")
@export var ui_image: Texture2D

func get_structure(collision:Dictionary):
	if structures.size() == 1:
		return structures[0]
	
	#if collision.collider.get_parent() is StructureCollision:
		#return structures[1]
	#else:
		#return structures[0]
	
	var normal:Vector3 = collision.normal
	var dot = normal.dot(Vector3.UP)
	print(dot)
	if dot > 0.99:
		return structures[0]
	else:
		return structures[1]
