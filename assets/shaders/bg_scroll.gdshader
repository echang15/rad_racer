shader_type canvas_item;

uniform float scroll_speed = 0.05;

void fragment() {
    vec2 uv = UV;
    uv.x += TIME * scroll_speed;
    COLOR = texture(TEXTURE, uv);
}
