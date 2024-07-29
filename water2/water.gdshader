shader_type spatial; 
#include "res://$lib/funcs/normals.gdshaderinc"
#include "res://$lib/funcs/utils.gdshaderinc"
#include "res://$lib/funcs/colour.gdshaderinc"
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture,repeat_disable,filter_linear; 
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,repeat_disable,filter_linear; 
uniform vec3 surface_color:source_color;
uniform vec3 depth_color:source_color;
uniform float opacity:hint_range(0.0, 1.0)=0.5; 
uniform sampler2D _foam:source_color,filter_linear; 
uniform sampler2D normal_map:source_color,filter_linear; 
uniform float normal_scale:hint_range(-16.0, 16.0)=1.0;
uniform float beer_factor:hint_range(0.0, 10.0)=0.1; 
uniform float _roughness:hint_range(0.0, 1.0); 
uniform float _refraction:hint_range(0.00, 0.20); 
uniform float _uv_scale:hint_range(0.0, 3.0)=1.0; 
uniform float _foam_strength: hint_range(0.0, 1.0); 
uniform float _foam_size: hint_range(0.0, 0.4); 

uniform float wave_speed = 0.5;
uniform vec4 wave_a = vec4(1.0, 1.0, 0.35, 3.0); 
uniform	vec4 wave_b = vec4(1.0, 0.6, 0.30, 1.55);
uniform	vec4 wave_c = vec4(1.0, 1.3, 0.25, 0.9);

varying float  vertex_height;
varying vec3  vertex_normal;
varying vec3  vertex_binormal;
varying vec3  vertex_tangent;

uniform vec2  sampler_scale = vec2(0.25, 0.25);
uniform vec2 sampler_direction = vec2(0.05, 0.04);

vec4 wave(vec4 parameter, vec2 position, float time, inout vec3 tangent, inout vec3 binormal)
{
	float	wave_steepness	 = parameter.z;
	float	wave_length		 = parameter.w;

	float	k				 = 2.0 * 3.14159265359 / wave_length;
	float 	c 				 = sqrt(9.8 / k);
	vec2	d				 = normalize(parameter.xy);
	float 	f 				 = k * (dot(d, position) - c * time);
	float 	a				 = wave_steepness / k;
	
			tangent			+= normalize(vec3(1.0-d.x * d.x * (wave_steepness * sin(f)), d.x * (wave_steepness * cos(f)), -d.x * d.y * (wave_steepness * sin(f))));
			binormal		+= normalize(vec3(-d.x * d.y * (wave_steepness * sin(f)), d.y * (wave_steepness * cos(f)), 1.0-d.y * d.y * (wave_steepness * sin(f))));

	return vec4(d.x * (a * cos(f)), a * sin(f) * 0.25, d.y * (a * cos(f)), 0.0);
}

void vertex()
{
	float	time			 = TIME * wave_speed;
	
	vec4	vertex			 = vec4(VERTEX, 1.0);
	vec3	vertex_position  = (MODEL_MATRIX * vertex).xyz;
	
	vec3 tang = vec3(0.0, 0.0, 0.0);
	vec3 bin = vec3(0.0, 0.0, 0.0);
	
	vertex 			+= wave(wave_a, vertex_position.xz, time, tang, bin);
	vertex 			+= wave(wave_b, vertex_position.xz, time, tang, bin);
	vertex 			+= wave(wave_c, vertex_position.xz, time, tang, bin);

	vertex_tangent 	 = tang;
	vertex_binormal  = bin;

	vertex_position  = vertex.xyz;

	vertex_height	 = (PROJECTION_MATRIX * MODELVIEW_MATRIX * vertex).z;

	TANGENT			 = vertex_tangent;
	BINORMAL		 = vertex_binormal;
	vertex_normal	 = normalize(cross(vertex_binormal, vertex_tangent));
	NORMAL			 = vertex_normal;

	UV				 = vertex.xz * sampler_scale;

	VERTEX			 = vertex.xyz;
}

void fragment() {
	vec3 vw = (INV_VIEW_MATRIX * vec4(VERTEX,1.0)).xyz; 
	 
	vec2 uv_scale = vw.xz * _uv_scale / 10.0; 
 	vec3 n = texture(normal_map,uv_scale+TIME *(-10.0)* 0.04).rgb;
	vec3 n2 = texture(normal_map,uv_scale-TIME*2.0 * 0.06).rgb;
	vec3 n3 = texture(normal_map,uv_scale*0.3 +vec2(TIME * 0.02,TIME*5.0 * -0.04)).rgb; 
	float _depth_linear = depth_linear(DEPTH_TEXTURE,SCREEN_UV,INV_PROJECTION_MATRIX);
	float d = depth_proximity_z(3.0,_depth_linear,VERTEX);
	float d2 = depth_proximity_z(0.2,_depth_linear,VERTEX); 
	
	
	d2 = 1.0-pow(d2,0.07); 
	d = exp(-d * beer_factor); 
	d +=fresnel(4.0,NORMAL,VIEW); 
	ROUGHNESS = _roughness; 	
	ALPHA = clamp(opacity+1.0-d-d2,0.0,1.0);
	vec3 n_out = normal_blend2(n3,normal_blend(n,n2)); 
	NORMAL_MAP = n_out;  
	NORMAL_MAP_DEPTH = normal_scale; 
	vec2 n_distortion = (mat3(TANGENT,BINORMAL,NORMAL) * n_out ).rg * 2.0 - 1.0; 
	vec3 color_out = mix(depth_color, surface_color,d);
	vec3 _screen = texture(SCREEN_TEXTURE,SCREEN_UV+n_distortion*_refraction).rgb; 
	float depthfoam = depth_proximity_z(abs(n_distortion.r+n_distortion.g) * _foam_size *5.0 ,_depth_linear,VERTEX); 
	depthfoam = pow(depthfoam,_foam_strength); 
	vec3 foam = texture(_foam,uv_scale + n_distortion).rgb; 
	ALBEDO = mix(foam,soft_light(_screen,color_out),depthfoam);
}
