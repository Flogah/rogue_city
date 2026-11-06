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
