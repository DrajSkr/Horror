extends Camera3D

@export var period = 0.3
@export var magnitude = 0.1

func apply_shake():
	var initial_transform = global_position 
	var elapsed_time = 0.0
	
	while elapsed_time < period:
		var offset = Vector3(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
			0.0
		)
	
		global_position = initial_transform + offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame
	
	global_position = initial_transform
