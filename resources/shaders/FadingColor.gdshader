shader_type canvas_item;

uniform vec4 color_top : source_color = vec4(0.1, 0.1, 0.0, 1.0); // Near Black
uniform vec4 color_bottom : source_color = vec4(0.8, 0.7, 0.0, 1.0); // Dull Yellow
uniform float speed : hint_range(0.1, 2.0) = 0.5;

void fragment() {
    // Create a moving sine wave based on time to shift the gradient UV
    float shift = sin(TIME * speed) * 0.2;
    float uv_y = UV.y + shift;
    
    // Mix the two colors based on the shifted Y coordinate
    vec3 mixed_color = mix(color_top.rgb, color_bottom.rgb, uv_y);
    
    COLOR = vec4(mixed_color, 1.0);
}
