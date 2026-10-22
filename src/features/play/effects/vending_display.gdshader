shader_type canvas_item;
render_mode unshaded;

uniform int unlocked_slots = 3;
uniform sampler2D empty_body : source_color, filter_nearest;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	vec2 pixel = UV * vec2(445.0, 524.0);
	for (int row = 0; row < 3; row++) {
		for (int col = 0; col < 5; col++) {
			int slot = row * 5 + col;
			vec2 cell = vec2(62.56 + float(col) * 40.8, 82.078 + float(row) * 80.0);
			if ((unlocked_slots & (1 << slot)) == 0 && all(greaterThanEqual(pixel, cell))
				&& all(lessThan(pixel, cell + vec2(40.8, 80.0)))) {
				original = texture(empty_body, UV);
			}
		}
	}
	COLOR = original;
}
