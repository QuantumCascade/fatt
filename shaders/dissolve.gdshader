shader_type canvas_item;

uniform float value: hint_range(0,1);
uniform sampler2D noise_texture;

void fragment() {
	if (COLOR.a == 1.0 && texture(noise_texture, UV).r > value) {
		COLOR.a = 0.0;
	}
}