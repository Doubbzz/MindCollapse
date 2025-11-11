shader_type canvas_item;

uniform float vignette_softness : hint_range(0.1, 1.0) = 0.6;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.75;
uniform float noise_amount : hint_range(0.0, 0.5) = 0.08;
uniform float scanline_density : hint_range(100.0, 800.0) = 320.0;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    float vignette = smoothstep(vignette_strength, vignette_strength - vignette_softness, distance(uv, vec2(0.5)));
    float noise = (hash(uv * (TIME * 60.0 + 1.0)) - 0.5) * noise_amount;
    float scan = sin(uv.y * scanline_density + TIME * 12.0) * 0.04;
    float alpha = clamp(vignette + noise + scan, 0.0, 0.85);
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
