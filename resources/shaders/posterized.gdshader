shader_type spatial;

#include "texel_snap.gdshaderinc"

// https://godotshaders.com/shader/standard-lighting-shader-include/
#define DIFFUSE_LAMBERT
#define SPECULAR_SCHLICK_GGX
#include "standard_lighting.gdshaderinc"

uniform int posterize_levels = 16;
uniform sampler2D albedo_map : source_color, filter_nearest_mipmap;
uniform sampler2D normal_map : hint_normal, filter_nearest_mipmap;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform vec2 uv_tiling = vec2(1.0);
uniform vec2 uv_offset = vec2(0.0);

void vertex() {
	UV = (UV + uv_offset) * uv_tiling;
}

void fragment() {
	// Snap LIGHT_VERTEX and NORMAL for pixelated shadows
	vec2 delta = screen_delta(UV, albedo_map);
	LIGHT_VERTEX = texel_snap(VERTEX, delta);
	NORMAL = texel_snap(NORMAL, delta);

	// Snap TANGENT and BINORMAL to support normal mapping
	TANGENT = texel_snap(TANGENT, delta);
	BINORMAL = texel_snap(BINORMAL, delta);
	
	ALBEDO = texture(albedo_map, UV).rgb;
	NORMAL_MAP = texture(normal_map, UV).xyz;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}

void light() {
	vec3 d = vec3(0.0), s = vec3(0.0);
	STANDARD_LIGHTING(d, s);

	DIFFUSE_LIGHT += ALBEDO * d + s;
	float l = float(posterize_levels);
	SPECULAR_LIGHT = floor(DIFFUSE_LIGHT * l) / l;
	SPECULAR_LIGHT -= ALBEDO * DIFFUSE_LIGHT;
}