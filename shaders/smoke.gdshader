shader_type canvas_item;

const float scale = 50.0;
const float speed = 0.1;

void vertex() {
	if (VERTEX.y < 0.0 && VERTEX.x < 0.0) {
		float factor = cos(TIME * speed);
		//if (factor > 0.0) {
			VERTEX.x += scale * (1.0 - factor);
			VERTEX.y += scale * factor;
		//}
	}
}
