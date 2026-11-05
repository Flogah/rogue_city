extends Node3D

@export var camera: Camera3D
var camera_position: Vector3
var camera_rotation: Vector3

func _ready():
	camera_rotation = rotation_degrees # Initial rotation

func _process(delta: float) -> void:
	if !camera.current:
		return
	
	var input := Vector3.ZERO
	input.x = Input.get_axis("camera_pan_left", "camera_pan_right")
	input.z = Input.get_axis("camera_pan_up", "camera_pan_down")
	camera_position += input.rotated(Vector3.UP, rotation.y).normalized()
	
	#position = position.lerp(camera_position, delta * 2)
	#rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 2)
	position = camera_position
	rotation_degrees = camera_rotation

func _input(event):
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_rotation_toggle"):
			camera_rotation += Vector3(-event.relative.y, -event.relative.x, 0)

func get_current_mouse_position() -> Vector3:
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
