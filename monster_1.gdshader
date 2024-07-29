shader_type spatial;

uniform float time_scale = 10;
uniform float side_to_side = 0.0;
uniform float pivot = 3;
uniform float wave = 0.01;
uniform float twist = 2;

void vertex() {
	//time_scale is a uniform float
	//set speed from 50% - 150% of regular speed
	float time = (TIME * (0.5 + INSTANCE_CUSTOM.y) * time_scale) + (6.28318 * INSTANCE_CUSTOM.x);
	
	//side_to_side is a uniform float
	VERTEX.x += cos(time) * side_to_side;
	
	//angle is scaled by 0.1 so that the fish only pivots and doesn't rotate all the way around
	//pivot is a uniform float
	float pivot_angle = cos(time) * 0.1 * pivot;
	mat2 rotation_matrix = mat2(vec2(cos(pivot_angle), -sin(pivot_angle)), vec2(sin(pivot_angle), cos(pivot_angle)));
	VERTEX.xy = rotation_matrix * VERTEX.xy;
	
	float body = VERTEX.y * 20.0; //for a fish centered at (0, 0) with a length of 2
	//wave is a uniform float
	VERTEX.x += cos(time*2.0 + body) * wave;
	
	//twist is a uniform float
	float twist_angle = cos(time + body) * 0.3 * twist;
	mat2 twist_matrix = mat2(vec2(cos(twist_angle), -sin(twist_angle)), vec2(sin(twist_angle), cos(twist_angle)));
	VERTEX.xz = twist_matrix * VERTEX.xz;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(0.0, 0.0, 0.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
