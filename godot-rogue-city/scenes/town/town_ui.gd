extends CanvasLayer

signal snapping_toggled(new_value)

signal structure_selected(structure: Structure)

@export var struct_button_container: HBoxContainer
@export var test_button_struct:  Structure
@export var button_template: PackedScene
@export var grid_label: Label
@export var preview_node: Node3D
@export var preview_container: Node3D

@export var town_manager: TownManager

var selected_struct: Structure
var current_preview_struct: StructureCollision
var snapping = false

func _ready() -> void:
	load_structure_inventory()
	snapping_toggled.connect(on_snapping_toggled)

func _process(delta: float) -> void:
	if selected_struct:
		var mouse_pos = CameraHelper.get_projected_mouse_position_flat()
		if snapping:
			position_preview_snapped(mouse_pos)
		else:
			position_preview(mouse_pos)
		
		if Input.is_action_just_pressed("cancel"):
			update_preview()
		
		if snapping:
			if Input.is_action_just_pressed("rotate_structure_left"):
				rotate_preview_snapped(45.0)
			if Input.is_action_just_pressed("rotate_structure_right"):
				rotate_preview_snapped(-45.0)
		else:
			if Input.is_action_pressed("rotate_structure_left"):
				rotate_preview(1.5)
			if Input.is_action_pressed("rotate_structure_right"):
				rotate_preview(-1.5)

func _input(event: InputEvent) -> void:
	if selected_struct:
		if event.is_action_pressed("confirm") and !current_preview_struct.can_place():
			town_manager.build_structure(selected_struct, preview_node.transform)
			update_preview()
		if event.is_action_pressed("toggle_snapping"):
			snapping = !snapping
			snapping_toggled.emit(snapping)
	else:
		if event.is_action_pressed("confirm"):
			var collider = CameraHelper.get_projected_mouse_collider()
			if town_manager.built_structures_dict.has(collider.get_parent()):
				town_manager.demolish_structure(collider.get_parent())

func load_structure_inventory():
	for struct in town_manager.structure_inventory:
		create_button(struct)

func create_button(structure: Structure):
	var new_button:StructureButton = button_template.instantiate()
	new_button.structure = structure
	struct_button_container.add_child(new_button)
	#new_button.pressed.connect(func(): structure_selected.emit(structure))
	new_button.pressed.connect(on_structure_selected.bind(structure))

func on_structure_selected(structure: Structure) -> void:
	selected_struct = structure
	current_preview_struct = update_preview(structure)

func on_snapping_toggled(new_value: bool) -> void:
	if new_value:
		grid_label.text = "GRID : AN"
		grid_label.set("theme_override_colors/font_color", Color.RED)
	else:
		grid_label.text = "GRID : AUS"
		grid_label.set("theme_override_colors/font_color", Color.YELLOW)

func update_preview(struct: Structure = null) -> Node3D:
	for child in preview_container.get_children():
		preview_container.remove_child(child)
		child.queue_free()
	if !struct:
		selected_struct = null
		return
	var new_preview:StructureCollision = struct.model.instantiate()
	new_preview.start_hinting()
	preview_container.add_child(new_preview)
	return new_preview

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
