extends CanvasLayer

signal snapping_toggled(new_value)

signal structure_selected(structure: Structure)

@export var struct_button_container: HBoxContainer
@export var test_button_struct:  Structure
@export var button_template: PackedScene
@export var grid_label: Label

@export var town_manager: TownManager

var selected_struct: Structure
var snapping = false

func _ready() -> void:
	load_structure_inventory()
	snapping_toggled.connect(on_snapping_toggled)

func _process(delta: float) -> void:
	if selected_struct:
		var mouse_pos = CameraHelper.get_projected_mouse_position_flat()
		if snapping:
			town_manager.position_preview_snapped(mouse_pos)
		else:
			town_manager.position_preview(mouse_pos)
		
		if Input.is_action_just_pressed("cancel"):
			town_manager.update_preview()
			selected_struct = null
		
		if snapping:
			if Input.is_action_just_pressed("rotate_structure_left"):
				town_manager.rotate_preview_snapped(45.0)
			if Input.is_action_just_pressed("rotate_structure_right"):
				town_manager.rotate_preview_snapped(-45.0)
		else:
			if Input.is_action_pressed("rotate_structure_left"):
				town_manager.rotate_preview(1.5)
			if Input.is_action_pressed("rotate_structure_right"):
				town_manager.rotate_preview(-1.5)

func _input(event: InputEvent) -> void:
	if selected_struct:
		if event.is_action_pressed("confirm"):
			town_manager.build_structure(selected_struct)
			selected_struct = null
		if event.is_action_pressed("toggle_snapping"):
			snapping = !snapping
			snapping_toggled.emit(snapping)

func load_structure_inventory():
	for struct in town_manager.structure_inventory:
		create_button(struct)

func create_button(structure: Structure):
	var new_button = button_template.instantiate()
	struct_button_container.add_child(new_button)
	#new_button.pressed.connect(func(): structure_selected.emit(structure))
	new_button.pressed.connect(on_structure_selected.bind(structure))

func on_structure_selected(structure: Structure) -> void:
	selected_struct = structure
	town_manager.update_preview(structure)

func on_snapping_toggled(new_value: bool) -> void:
	if new_value:
		grid_label.text = "GRID : AN"
		grid_label.set("theme_override_colors/font_color", Color.RED)
	else:
		grid_label.text = "GRID : AUS"
		grid_label.set("theme_override_colors/font_color", Color.YELLOW)
