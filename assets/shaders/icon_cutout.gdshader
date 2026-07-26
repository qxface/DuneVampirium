shader_type canvas_item;

uniform sampler2D left_mask : hint_default_transparent;
uniform sampler2D right_mask : hint_default_transparent;
uniform bool cut_left = false;
uniform bool cut_right = false;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (cut_left) {
		col.a *= 1.0 - texture(left_mask, UV).a;
	}
	if (cut_right) {
		col.a *= 1.0 - texture(right_mask, UV).a;
	}
	COLOR = col;
}
