class_name StructureButton
extends Button

@export var structure_group: SuperStructure

@export var structure_preview_image: TextureRect
@export var structure_label: Label

#func _init(new_structure: Structure) -> void:
	#structure = new_structure

func _ready() -> void:
	if !structure_group:
		return
	
	structure_preview_image.texture = structure_group.ui_image
	structure_label.text = structure_group.group_name
