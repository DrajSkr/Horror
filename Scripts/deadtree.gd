extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_child(0).get_child(0).visibility_range_begin = 0
	get_child(0).get_child(0).visibility_range_begin_margin=0
	get_child(0).get_child(0).visibility_range_end = 35
	get_child(0).get_child(0).visibility_range_end_margin = 10
	get_child(0).get_child(0).visibility_range_fade_mode = 1
