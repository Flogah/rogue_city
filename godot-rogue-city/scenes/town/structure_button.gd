class_name StructureButton
extends Button

@export var super_structure: SuperStructure

@export var structure_preview_image: TextureRect
@export var structure_label: Label

#func _init(new_structure: Structure) -> void:
	#structure = new_structure

func _ready() -> void:
	if !super_structure:
		return
	
	structure_preview_image.texture = super_structure.ui_image
	structure_label.text = super_structure.group_name
