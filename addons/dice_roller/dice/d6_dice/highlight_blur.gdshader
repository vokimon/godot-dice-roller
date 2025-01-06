shader_type spatial;
uniform float density = 100;
uniform float frequency = 5;

void fragment() {
	ALPHA = 0.3
		+ 0.2 * cos(frequency * PI * TIME + density * UV.x) * cos(density * UV.y)
		+ 0.2 * cos(-frequency * PI * TIME + density * UV.x) * cos(density * UV.y)
	;
}
