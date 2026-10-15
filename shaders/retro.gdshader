shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float strength = 0.52;

// RGB555 quantization with the 4x4 offset pattern documented for the PS1 GPU.
const float offsets[16] = float[16](-4.0, 0.0, -3.0, 1.0, 2.0, -2.0, 3.0, -1.0, -3.0, 1.0, -4.0, 0.0, 3.0, -1.0, 2.0, -2.0);

void fragment() {
	vec3 original = texture(screen_texture, SCREEN_UV).rgb;
	vec2 pixel = floor(FRAGCOORD.xy);
	int index = int(mod(pixel.x, 4.0)) + int(mod(pixel.y, 4.0)) * 4;
	vec3 banded = floor(clamp(original * 255.0 + offsets[index], 0.0, 255.0) / 8.0) / 31.0;
	vec2 centered = SCREEN_UV * 2.0 - 1.0;
	float vignette = 1.0 - dot(centered * vec2(0.62, 0.75), centered * vec2(0.62, 0.75)) * 0.23;
	COLOR = vec4(mix(original, banded, strength) * vignette, 1.0);
}
