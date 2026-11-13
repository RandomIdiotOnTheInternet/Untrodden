shader_type spatial;

// --- COLOR & TEXTURE UNIFORMS ---
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;

// --- SHAKING UNIFORMS ---
/** Use this from the editor for interpolation. */
uniform float progress : hint_range(0.0, 1.0) = 1.0;
/** How many times it shakes per second. */
uniform float frequency : hint_range(0.0, 60.0, 0.1) = 12.0;
/** Shaking bounds. */
uniform vec3 max_offset = vec3(0.1);

// --- SHAKING FUNCTIONS ---
float hash(float x) {
    return fract(sin(x * 127.1) * 43758.5453123);
}

float smooth_noise(float t) {
    float i = floor(t);
    float f = fract(t);
    // smoothstep curve
    f = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), f);
}

vec3 shake3(float t) {
    return vec3(
        smooth_noise(t),
        smooth_noise(t + 37.0),
        smooth_noise(t + 91.0)
    ) * 2.0 - 1.0;
}

// --- VERTEX PROGRAM (Movement) ---
void vertex() {
    // Applies the shaking calculation to the mesh's geometry
    VERTEX += progress * shake3(TIME * frequency) * max_offset;
}

// --- FRAGMENT PROGRAM (Color & Texture) ---
void fragment() {
    // Reads the color from your assigned texture
    vec4 tex_color = texture(albedo_texture, UV);
    
    // Applies both the texture and the base albedo color to the mesh
    ALBEDO = albedo_color.rgb * tex_color.rgb;
    ALPHA = albedo_color.a * tex_color.a;
}