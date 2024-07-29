shader_type spatial;

uniform vec4 colr : source_color;
uniform sampler2D alpha_grad;
uniform sampler2D alpha_grad_2d;
uniform float gradient_slider;
uniform float gradient_slider2;
varying vec2 uv1;
varying vec2 uv2;
uniform sampler2D alpha;

void vertex() {
	uv1 = UV * vec2(0.8,0.0) + gradient_slider * TIME;
	uv2 = UV * vec2(1.0,1.0) + gradient_slider2 * TIME;
}

void fragment() {
	vec4 enter = texture(alpha,UV);
	vec4 alpha_h = texture(alpha_grad,uv1);
	vec4 alpha_v = texture(alpha_grad_2d,uv2);
	ALPHA = (alpha_h * alpha_v * enter).r;
	ALBEDO = colr.rgb;
	EMISSION = colr.rgb * 10.0;
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
