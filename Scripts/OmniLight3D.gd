extends OmniLight3D


@export var distance_from_camera: float =.9

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera = $"../SubViewportContainer/SubViewport/Camera3D"
	if camera:
		var mouse_position = get_viewport().get_mouse_position()

		# Get the ray origin and direction from the camera through the mouse position
		var from = camera.project_ray_origin(mouse_position)
		var direction = camera.project_ray_normal(mouse_position)

		# Calculate the target position on the plane at a constant distance from the camera
		var target_position = from + direction * distance_from_camera

		# Update the object's position to the target position
		global_transform.origin = target_position
