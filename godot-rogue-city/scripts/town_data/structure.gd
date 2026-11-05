class_name Structure
extends Resource

@export_subgroup("Model")
@export var model: PackedScene

@export_subgroup("Gameplay")
# list of applicable uprades to this structure
# not sure yet if upgrades need to be individual or shared
# ex can two houses share a windmill?
@export var upgrades:Array[Structure]
