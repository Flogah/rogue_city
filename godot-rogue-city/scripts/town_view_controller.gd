extends Node3D

@export var mouse_sens: float = 0.005
@export_range(-90.0, 0.0,  0.1, "radians_as_degrees") var min_vertical_angle: float = -PI/2
@export_range(-30.0, 0.0,  0.1, "radians_as_degrees") var max_vertical_angle: float = PI/4

@export var camera: Camera3D
var camera_position: Vector3
var camera_rotation: Vector3
var camera_zoom: float

var reset_position: Vector3
var reset_rotation: Vector3
var reset_zoom: float

func _ready():
	reset_position = position
	reset_rotation = rotation
	reset_zoom = camera.position.z
	reset_camera()

func _process(delta: float) -> void:
	if !camera.current:
		return
	
	# this BS is to be cleaned up later in an input_handler, probably inside a FSM
	var input: Vector3 = Vector3.ZERO
	input.x = Input.get_axis("camera_pan_left", "camera_pan_right")
	input.z = Input.get_axis("camera_pan_up", "camera_pan_down")
	move_camera(input)
	
	update_camera_smooth(delta)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("camera_rotation_toggle") and event is InputEventMouseMotion:
		rotate_camera(event.relative)
	
	if event.is_action_pressed("camera_zoom_in"):
		zoom_camera(-1)
	if event.is_action_pressed("camera_zoom_out"):
		zoom_camera(1)

func rotate_camera(input:Vector2) -> void:
	# put in a check if it's via mouse or via controller, as wrapping only makes sense via controller
	camera_rotation.y -= input.x * mouse_sens
	#camera_rotation.y = wrapf(camera_rotation.y, 0.0, TAU)
	
	camera_rotation.x -= input.y * mouse_sens
	camera_rotation.x = clamp(camera_rotation.x, min_vertical_angle, max_vertical_angle)

func move_camera(input: Vector3):
	var raw_move: Vector3 = input.rotated(Vector3.UP, rotation.y).normalized()
	var scaled_move: Vector3 = raw_move * (camera_zoom/100.0)
	camera_position += scaled_move

func zoom_camera(input: float) -> void:
	camera_zoom += input * 2.0
	camera_zoom = clampf(camera_zoom, 0.0, 100.0)

func update_camera_smooth(delta:float):
	position = position.lerp(camera_position, delta * 18)
	rotation = rotation.lerp(camera_rotation, delta * 16)
	camera.position = camera.position.lerp(Vector3(0, 0, camera_zoom), delta * 28)

func get_plane_mouse_position() -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var current_camera = get_viewport().get_camera_3d()
	var ray_origin: Vector3 = current_camera.project_ray_origin(mouse_pos)
	var ray_direction: Vector3 = current_camera.project_ray_normal(mouse_pos)
	var plane = Plane(Vector3.UP, 0.0)
	var intersection = plane.intersects_ray(ray_origin, ray_direction)
	if intersection:
		return intersection
	return Vector3.ZERO

func get_terrain_mouse_position() -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var current_camera = get_viewport().get_camera_3d()
	var ray_origin: Vector3 = current_camera.project_ray_origin(mouse_pos)
	var ray_direction: Vector3 = current_camera.project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_direction * 1000.0
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var collision = get_viewport().get_camera_3d().get_world_3d().direct_space_state.intersect_ray(query)
	return collision.position

func activate_town_camera():
	camera.make_current()

func reset_camera():
	camera_position = reset_position
	camera_rotation = reset_rotation
	camera_zoom = reset_zoom
