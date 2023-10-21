shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;

uniform sampler2D noise;
instance uniform vec2 offset = vec2(1.0, 1.0);

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	float a = texture(noise, offset + UV / 24.0 + vec2(TIME / 12.0, TIME / 8.0)).r * texture(noise, UV / 16.0 - vec2(TIME * offset.x / 8.0, 0.0)).r;
	ALPHA = min(0.9, max(0.0, a - 0.35));
	
	float dist = max(0.0, 1.0 - length(UV - vec2(0.5, 0.5)) / .5);
	if (ALPHA < 0.02 && ALPHA > 0.0) {
		ALPHA = 1.0;
	} else {
		ALPHA = 0.0;
	}
	
	ALPHA *= pow(dist, 2.0);
	
	ALBEDO = vec3(16.0);
	

}
