shader_type canvas_item;

uniform sampler2D noise_img;

void fragment() {
	
	if (COLOR.a == 1.0 && texture(noise_img, UV).g > 0.49) {
		COLOR.a = 0.0;
	}
}