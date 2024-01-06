shader_type canvas_item;

uniform float value: hint_range(0,1);
uniform sampler2D noise_texture;

void fragment() {
	if (COLOR.a == 1.0 && texture(noise_texture, UV).r > value) {
		COLOR.a = max(value - 0.5, 0.1);
	}
}