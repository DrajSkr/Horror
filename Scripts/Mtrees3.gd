extends MGrass

@onready var terrain := $".."
@export var frequency = 0.015
@export var normal_y_should_be_greater_than = 0.96
@export var min_noise_white_value = 0.17
@export var max_noise_white_value = 0.17
@export var seeds = 1001

func _on_grass_is_ready():
	#var f_noise = FastNoiseLite.new()
	#f_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	#f_noise.fractal_gain = 0.9
	#f_noise.frequency = frequency
	#f_noise.seed = 1002
	
	#var grad = Gradient.new()
	#grad.add_point(0.0,Color.BLACK)
	#grad.add_point(0.5,Color.WHITE)
	for x in range(get_width()):
		for y in range(get_height()):
			var tpx = grass_px_to_grid_px(x,y)
			var normal = terrain.get_normal_accurate_by_pixel(tpx.x,tpx.y)
			#terrain.get_closest_pixel()
			var has_grass:bool = normal.y > normal_y_should_be_greater_than
			#var n = abs(f_noise.get_noise_2d(x,y) * 2 - 1)
			#n = smoothstep(0.0,0.01,n)
			#has_grass = has_grass and n > 0.0 and n < 0.33
			has_grass = has_grass and terrain.ran_arr[Vector2i(x,y)] == 2
			
			set_grass_by_pixel(x,y,has_grass)
	
	save_grass_data()
	update_dirty_chunks()
