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

@export var colliding_overlay_material: Material

var selected_struct: Structure
var current_preview_struct: StructureCollision
var snapping = false

func _ready() -> void:
	load_structure_inventory()
	snapping_toggled.connect(on_snapping_toggled)

func _process(delta: float) -> void:
	if selected_struct:
		hint_collision()
		var mouse_pos:Vector3 = Vector3.ZERO
		if selected_struct.align_with_surface_normal:
			mouse_pos = CameraHelper.get_projected_mouse_position()
		else:
			mouse_pos = CameraHelper.get_projected_mouse_position_flat()
		
		if Input.is_action_just_pressed("cancel"):
			update_preview()
		
		if snapping:
			position_preview_snapped(mouse_pos)
		else:
			position_preview(mouse_pos)
		
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

func create_button(super_struct: SuperStructure):
	var new_button:StructureButton = button_template.instantiate()
	new_button.super_structure = super_struct
	struct_button_container.add_child(new_button)
	#new_button.pressed.connect(func(): structure_selected.emit(structure))
	new_button.pressed.connect(on_structure_selected.bind(super_struct))

func on_structure_selected(super_struct: SuperStructure) -> void:
	selected_struct = super_struct.get_structure()
	current_preview_struct = update_preview(super_struct.get_structure())
	var meshes = get_meshes(current_preview_struct)
	for mesh:MeshInstance3D in meshes:
		apply_overlay_material(mesh)

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
		preview_node.global_transform = align_with_y(preview_node.global_transform, Vector3.UP)
		return
	var new_preview:StructureCollision = struct.model.instantiate()
	preview_container.add_child(new_preview)
	return new_preview

func position_preview(pos: Vector3):
	preview_node.global_position = pos
	if selected_struct.align_with_surface_normal:
		var normal = CameraHelper.get_mouse_collision().normal
		#Draw3d.line(CameraHelper.get_projected_mouse_position(), CameraHelper.get_projected_mouse_position() + normal * 2.0, Color.RED, 1)
		#print(normal)
		preview_node.global_transform = align_with_y(preview_node.global_transform, normal)

func position_preview_snapped(pos: Vector3):
	position_preview(pos)
	# wall positioning doesn't work properly if snapped
	# for future: create a new grid along the projected surface
	if !selected_struct.align_with_surface_normal:
		preview_node.global_position = preview_node.global_position.snapped(Vector3.ONE)

func rotate_preview(deg: float):
	# rotate around the up, so it works no matter where the structure is pointing
	preview_node.rotate(preview_node.global_transform.basis.y, deg_to_rad(deg))

func rotate_preview_snapped(deg: float):
	rotate_preview(deg)
	preview_node.rotation_degrees.y = snappedf(preview_node.rotation_degrees.y, 45.0)

# to extract just the meshinstances from a scene
# atm just to apply the preview shader
func get_meshes(model_node:StructureCollision):
	var mesh_instances:Array = []
	var model_node_children: Array = model_node.visual.get_children()
	for child in model_node_children:
		if child is MeshInstance3D:
			mesh_instances.append(child)
	return mesh_instances

func apply_overlay_material(mesh: MeshInstance3D):
	# same instance between all overlay materials
	mesh.set_material_overlay(colliding_overlay_material)

func hint_collision():
	if current_preview_struct.can_place():
		colliding_overlay_material.set("shader_parameter/Alpha", 0.6)
	else:
		colliding_overlay_material.set("shader_parameter/Alpha", 0.0)

func align_with_y(xform, new_y):
	# if new_y has length of 0, jolt will throw errors
	new_y = new_y.normalized()
	if new_y.is_zero_approx():
		return xform
	
	var ref_z = xform.basis.z.normalized()
	# if the new_y aligns with an axis (like with a straight wall), jolt throws errors
	# also if it is too close to the previous angle, it will throw errors
	if ref_z.is_zero_approx() or absf(ref_z.dot(new_y)) > 0.999:
		# is the basis close to 0.0 or almost the same as the new basis?
		if absf(Vector3.FORWARD.dot(new_y)) < 0.999:
			# if it's almost forward, make it forward
			ref_z = Vector3.FORWARD
		else:
			# default to pointing right
			Vector3.RIGHT
	
	xform.basis.y = new_y
	xform.basis.x = -ref_z.cross(new_y)
	xform.basis.z = xform.basis.x.cross(new_y)
	
	xform.basis = xform.basis.orthonormalized()
	return xform
