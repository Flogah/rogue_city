extends Node

var tween: Tween

func transition_camera(old_cam: Camera3D, new_cam: Camera3D, transition_time:float):
	var transcam: Camera3D = Camera3D.new()
	add_child(transcam)
	transcam.global_transform = old_cam.global_transform
	transcam.make_current()
	
	if tween:
		tween.kill()
	
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC) 
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(
		transcam, 
		"global_transform", 
		new_cam.global_transform, 
		transition_time
	)
	
	tween.finished.connect(func(): new_cam.make_current())

# assumes that the city is a featureless plane
func get_projected_mouse_position_flat() -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var current_camera = get_viewport().get_camera_3d()
	var ray_origin: Vector3 = current_camera.project_ray_origin(mouse_pos)
	var ray_direction: Vector3 = current_camera.project_ray_normal(mouse_pos)
	var plane = Plane(Vector3.UP, 0.0)
	var intersection = plane.intersects_ray(ray_origin, ray_direction)
	if intersection:
		return intersection
	return Vector3.ZERO

# assumes varied terrain
func get_projected_mouse_position() -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var current_camera = get_viewport().get_camera_3d()
	var ray_origin: Vector3 = current_camera.project_ray_origin(mouse_pos)
	var ray_direction: Vector3 = current_camera.project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_direction * 1000.0
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var collision = get_viewport().get_camera_3d().get_world_3d().direct_space_state.intersect_ray(query)
	return collision.position
