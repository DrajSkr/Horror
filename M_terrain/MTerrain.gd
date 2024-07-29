extends MTerrain

var ran_arr
# Called when the node enters the scene tree for the first time.
func _ready():
	ran_arr = {}
	for i in 1024:
		for j in 1024:
			ran_arr[Vector2i(i,j)] = randi_range(0,2)
	create_grid()
