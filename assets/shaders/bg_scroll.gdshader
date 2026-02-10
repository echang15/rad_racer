shader_type canvas_item;

uniform float scroll_speed = 0.0;

void fragment() {
	vec2 uv = UV;
	// User requested top-to-bottom scrolling (similar to road)
	// Positive adds to Y, moving texture up (content moves down? or texture coordinates move down?)
	// If we add to UV.y, the texture reads from lower down. 
	// To make texture "move down" (visual flow top to bottom), we usually SUBTRACT time.
	// But let's just apply the speed to Y.
	uv.y += scroll_speed;
	COLOR = texture(TEXTURE, uv);
}
