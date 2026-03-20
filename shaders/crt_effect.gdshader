shader_type canvas_item;

uniform float scanline_count : hint_range(50.0, 1000.0) = 300.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.35;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	vec2 uv = UV;

	// Scanlines: sin wave produces alternating dark/bright horizontal bands.
	// scanline_count controls density (higher = more lines).
	float wave = sin(uv.y * scanline_count * PI);
	// Map [-1,1] to [0,1], then invert so troughs are dark.
	float scanline_dark = (1.0 - (wave * 0.5 + 0.5)) * scanline_intensity;

	// Vignette: uv * (1 - uv) peaks at center and falls off toward edges.
	vec2 v = uv * (1.0 - uv.yx);
	float vignette = clamp(v.x * v.y * 16.0, 0.0, 1.0);
	vignette = pow(vignette, 0.25);
	float vignette_dark = (1.0 - vignette) * vignette_intensity;

	// Output a black layer whose alpha combines both effects.
	float alpha = clamp(scanline_dark + vignette_dark, 0.0, 1.0);
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
