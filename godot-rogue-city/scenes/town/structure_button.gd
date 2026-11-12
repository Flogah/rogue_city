class_name StructureButton
extends Button

@export var structure: Structure

@export var structure_preview_image: TextureRect
@export var structure_label: Label

#func _init(new_structure: Structure) -> void:
	#structure = new_structure

func _ready() -> void:
	if !structure:
		return
	
	structure_preview_image.texture = structure.ui_image
	structure_label.text = structure.s_name
