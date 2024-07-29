extends MGrass

@onready var terrain := $".."
var splatmap

func _on_grass_is_ready():
	var f_noise = FastNoiseLite.new()
	f_noise.fractal_gain = 0.9
	f_noise.frequency = 0.02
	#var grad = Gradient.new()
	#grad.add_point(0.0,Color.BLACK)
	#grad.add_point(0.5,Color.WHITE)
	for x in range(get_width()):
		for y in range(get_height()):
			var tpx = grass_px_to_grid_px(x,y)
			var normal = terrain.get_normal_accurate_by_pixel(tpx.x,tpx.y)
			#terrain.get_closest_pixel()
			var has_grass:bool = normal.y > 0.96
			splatmap = terrain.get_image_id("splatmap")
			has_grass = has_grass and (terrain.get_pixel(x,y,splatmap) != Color("ff0000"))
			has_grass = has_grass and (terrain.get_pixel(x,y,splatmap) != Color("0000ff"))
			var n = f_noise.get_noise_2d(x,y)
			#n = smoothstep(0.0,0.01,n)
			has_grass = has_grass and n > 0.001
			
			set_grass_by_pixel(x,y,has_grass)
	
	save_grass_data()
	update_dirty_chunks()
