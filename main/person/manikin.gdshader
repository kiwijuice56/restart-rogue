shader_type spatial;

instance uniform vec3 color: source_color;
instance uniform float alpha = 1.0;

void fragment() {
	ALBEDO = color;
	ALPHA = alpha;
}
