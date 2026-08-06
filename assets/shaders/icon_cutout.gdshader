shader_type canvas_item;

uniform sampler2D left_mask : hint_default_transparent;
uniform sampler2D right_mask : hint_default_transparent;
uniform bool cut_left = false;
uniform bool cut_right = false;

void fragment() {
	// COLOR already contains texture(TEXTURE, UV) * modulate at this point — mutate it
	// in place rather than re-sampling TEXTURE and overwriting it, or the node's
	// modulate (e.g. Space's dim-when-unavailable tint) gets silently discarded.
	if (cut_left) {
		COLOR.a *= 1.0 - texture(left_mask, UV).a;
	}
	if (cut_right) {
		COLOR.a *= 1.0 - texture(right_mask, UV).a;
	}
}
