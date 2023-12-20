shader_type canvas_item;

const float speed = 0.5;
const float amplitude = 5.0;

void vertex() {
	if (VERTEX.y < 0.0) {
		float rnd_factor = VERTEX.x + VERTEX.y;
		VERTEX += vec2(sin(TIME * speed + rnd_factor) * amplitude, 0.0);
	}
}