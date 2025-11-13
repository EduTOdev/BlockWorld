shader_type canvas_item;

uniform float scroll_speed = 2.0;

void fragment() {
    vec2 uv = UV;
    uv.x -= (TIME / 4.0) * scroll_speed;
    COLOR = texture(TEXTURE, uv);
}