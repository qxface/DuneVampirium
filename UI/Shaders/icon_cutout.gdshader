// Edit file: res://UI/Shaders/icon_cutout.gdshader
shader_type canvas_item;

uniform sampler2D base_texture;
uniform sampler2D tag_left_texture;
uniform sampler2D tag_right_texture;
uniform bool tag_l = false;
uniform bool tag_r = false;

void fragment() {
	vec4 base_color = texture(base_texture, UV);
	vec4 tag_left_color = texture(tag_left_texture, UV);
	vec4 tag_right_color = texture(tag_right_texture, UV);
	
	bool should_cutout = false;
	
	// Only use tag_left as mask if tag_l is true
	if (tag_l && tag_left_color.a > 0.0) {
		should_cutout = true;
	}
	
	// Only use tag_right as mask if tag_r is true
	if (tag_r && tag_right_color.a > 0.0) {
		should_cutout = true;
	}
	
	// If either enabled tag has non-transparent pixels at this position, make base transparent
	if (should_cutout) {
		COLOR = vec4(0.0); // Fully transparent
	} else {
		COLOR = base_color; // Keep original base texture
	}
}