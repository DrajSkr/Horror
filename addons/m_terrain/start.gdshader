shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;


uniform sampler2D mterrain_heightmap:filter_nearest;
uniform sampler2D mterrain_normals:filter_nearest;

uniform vec4 ground1 : source_color;
uniform vec4 ground2 : source_color;
uniform vec4 rock : source_color;
uniform sampler2D ground1_ah : source_color,filter_linear_mipmap_anisotropic;
uniform sampler2D ground2_ah : source_color,filter_linear_mipmap_anisotropic;
uniform sampler2D rock_ah : source_color,filter_linear_mipmap_anisotropic;
uniform sampler2D ground1_nr : source_color,filter_linear_mipmap_anisotropic;
uniform sampler2D ground2_nr : source_color,filter_linear_mipmap_anisotropic;
uniform sampler2D rock_nr : source_color,filter_linear_mipmap_anisotropic;
uniform sampler2D rock_noise;

uniform sampler2D detail;
uniform sampler2D leaf_a;
uniform sampler2D leaf_nr;
uniform sampler2D leaf_noise;

varying float mask_ground;
varying float mask_rock;

uniform vec3 region_world_position;
uniform float region_size;
uniform float region_a;
uniform float region_b;
uniform int min_lod;
varying vec3 world_pos;
varying vec2 region_uv;

varying vec3 my_pos;
varying vec3 my_normal;

uniform sampler2D mterrain_splatmap;

const float close_dist = 30.0;
const float close_blend_amount = 10.0;
const float close_uv_scale = 1.0;
const float far_uv_scale = 0.1;
varying float close_mask;

varying vec3 uv1_triplanar_pos;
uniform float uv1_blend_sharpness;
varying vec3 uv1_power_normal;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

void vertex(){
	world_pos = (NODE_POSITION_WORLD + VERTEX);
	region_uv = (world_pos.xz - region_world_position.xz)/region_size;
	region_uv = region_uv*region_a + region_b;
	VERTEX.y = texture(mterrain_heightmap, region_uv).r;
	world_pos.y = VERTEX.y;
	vec3 n = texture(mterrain_normals, region_uv).rgb;
	n.rb=fma(n.rb,vec2(2.0),vec2(-1.0));
	NORMAL = n;
	
	float dis = length(CAMERA_POSITION_WORLD - world_pos);
	close_mask = smoothstep(close_dist +close_blend_amount,close_dist,dis);
	
	float nxz = abs(n.x) + abs(n.z);
	mask_ground = step(0.3,nxz);
	mask_rock = step(0.7,nxz);
	//Scale world uv for terrain texture
	world_pos /= 5.0;
	
	my_pos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
	my_normal = abs(normalize(MODEL_NORMAL_MATRIX * NORMAL));
	
	uv1_power_normal=pow(abs(NORMAL),vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
}

vec4 distance_texture(sampler2D _tex, vec2 _uv){
	vec4 final = texture(_tex,_uv*far_uv_scale);
	final = mix(final,texture(_tex,_uv*close_uv_scale),close_mask);
	return final;
}

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos, vec2 _uv) {
	vec4 samp=vec4(0.0);
	samp = texture(p_sampler, _uv*far_uv_scale);
	samp = mix(samp,texture(p_sampler,_uv*close_uv_scale),close_mask);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

void fragment(){
	vec2 base_uv = mix(my_pos.xy,my_pos.zy,round(my_normal.x));
	base_uv = mix(base_uv,my_pos.xz,round(my_normal.y));
	//base_uv = mix(base_uv,my_pos.xy,round(my_normal.z));
	base_uv /= 5.0;
	
	vec4 ah = texture(ground1_ah,world_pos.xz / 2.0) * ground1;
	ah = mix(ah,texture(ground2_ah,world_pos.xz) * ground2,mask_ground);
	vec4 rock_color_variation = texture(rock_noise,base_uv/10.0);
	vec4 actual_rock_ah = distance_texture(rock_ah,base_uv);
	//vec4 actual_rock_ah = triplanar_texture(rock_ah,uv1_power_normal,uv1_triplanar_pos,base_uv);
	ah = mix(ah,mix(actual_rock_ah,texture(rock_ah,base_uv) * 0.1,rock_color_variation) * rock,mask_rock);
	
	vec4 nr = texture(ground1_nr,world_pos.xz / 2.0);
	nr.a *= 1.4;
	nr = mix(nr,texture(ground2_nr,world_pos.xz),mask_ground);
	vec4 actual_rock_nr = distance_texture(rock_nr,base_uv);
	//vec4 actual_rock_nr = triplanar_texture(rock_nr,uv1_power_normal,uv1_triplanar_pos,base_uv);
	nr = mix(nr,actual_rock_nr,mask_rock);
	
	vec4 detail_tex = texture(detail,base_uv * 10.0);
	ah.rgb *= detail_tex.a * 4.0;
	nr.rgb = nr.rgb + detail_tex.rgb - 0.5;
	
	//splatmaps
	vec4 splatmap = texture(mterrain_splatmap,region_uv);
	ah = mix(ah, texture(ground2_ah,world_pos.xz) * ground2, splatmap.r);
	nr = mix(nr,texture(ground2_nr,world_pos.xz),splatmap.r);
	
	ALBEDO = ah.rgb;
	//ALBEDO = detail_tex.rgb;
	float noise = texture(leaf_noise, world_pos.xz * 0.02).r;
	vec4 leaf = texture(leaf_a,base_uv * 6.0) * 1.0 * ground1;
	vec4 leaf_normal = texture(leaf_nr, base_uv * 6.0);
	leaf.a *= noise * (1.0 - mask_rock) * (1.0 - mask_ground);
	ALBEDO = mix(ALBEDO,leaf.rgb,leaf.a * (1.0-splatmap.r));
	
	//ALBEDO = splatmap.rgb;
	
	NORMAL_MAP = nr.rgb;
	NORMAL_MAP = mix(NORMAL_MAP, leaf_normal.rgb * 2.0, leaf.a * (1.0-splatmap.r));
	ROUGHNESS = nr.a;
	ROUGHNESS = mix(ROUGHNESS, leaf_normal.a * 3.0, leaf.a);
}
