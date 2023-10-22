shader_type spatial;
render_mode unshaded;


uniform sampler2D noise_texture;
instance uniform vec4 color: source_color;
instance uniform vec2 offset = vec2(1.0, 1.0);
instance uniform float threshold = 0.04;
instance uniform float scale = 1.0;

// Billboard effect
void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	float strength = texture(noise_texture, offset + scale * UV / 16.0 + vec2(TIME / 12.0, TIME / 8.0)).r * texture(noise_texture, scale * UV / 16.0 - vec2(TIME * offset.x / 8.0, 0.0)).r;
	ALPHA = strength - 0.35;
	if (ALPHA < threshold && ALPHA > 0.0) {
		ALPHA = 1.0;
	} else {
		ALPHA = 0.0;
	}
	float dist = max(0.0, 1.0 - 2.0 * length(UV - vec2(0.5, 0.5)));
	ALPHA *= pow(dist, 2.0);
	ALBEDO = color.rgb * vec3(16.0);
}
