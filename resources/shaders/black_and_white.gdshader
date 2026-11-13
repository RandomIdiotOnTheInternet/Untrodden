shader_type canvas_item;

// This allows you to control the 'color' from GDScript (0.0 = B&W, 1.0 = Color)
uniform float saturation : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    // Get the color of the screen behind this ColorRect
    vec4 tex = texture(screen_texture, SCREEN_UV);
    
    // Calculate the greyscale value (standard luminance formula)
    float grey = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    vec3 greyscale = vec3(grey);
    
    // Mix the greyscale and original color based on the saturation variable
    COLOR.rgb = mix(greyscale, tex.rgb, saturation);
}
