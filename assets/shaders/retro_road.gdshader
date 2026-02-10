shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float speed = 0.0;
uniform float curve_strength = 0.0;
uniform sampler2D road_texture : filter_nearest;

void vertex() {
	// Simple curvature approximation
	// We bend the vertex.x based on how far z is from the camera (0)
	// In Godot -z is forward.
	float drive_z = VERTEX.z;
	float curve_amount = curve_strength * (drive_z * drive_z) * 0.001;
	
	VERTEX.x += curve_amount;
}

void fragment() {
	// Scroll the texture coordinates based on speed/time
	vec2 uv = UV;
	uv.y += TIME * speed;
	
	ALBEDO = texture(road_texture, uv).rgb;
}
