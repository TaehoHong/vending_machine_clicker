shader_type canvas_item;
render_mode unshaded;

uniform int unlocked_slots = 3;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	vec2 pixel = UV * vec2(1024.0, 1536.0);
	float lefts[5] = float[](185.0, 302.0, 422.0, 541.0, 660.0);
	float rights[5] = float[](292.0, 413.0, 531.0, 652.0, 777.0);
	float tops[3] = float[](269.0, 507.0, 766.0);
	float bottoms[3] = float[](435.0, 683.0, 919.0);
	for (int row = 0; row < 3; row++) {
		for (int col = 0; col < 5; col++) {
			int slot = row * 5 + col;
			if ((unlocked_slots & (1 << slot)) == 0 && pixel.x >= lefts[col] && pixel.x <= rights[col] && pixel.y >= tops[row] && pixel.y <= bottoms[row]) {
				vec4 a = texture(TEXTURE, vec2(298.0 / 1024.0, UV.y));
				vec4 b = texture(TEXTURE, vec2(416.0 / 1024.0, UV.y));
				original = mix(a, b, clamp((pixel.x - 298.0) / 486.0, 0.0, 1.0));
			}
		}
	}
	COLOR = original;
}
