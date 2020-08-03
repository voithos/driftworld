shader_type canvas_item;

uniform float activation : hint_range(0, 1.0);

uniform sampler2D displacementMask : hint_albedo;
uniform float displacement : hint_range(0, 0.1);
uniform float amplitude = .1;
uniform float speed = 5.0;

vec4 rgbShift(in vec2 p, in sampler2D tex, in vec4 shift) {
	shift *= 2.0 * shift.w - 1.0;
	vec2 rs = vec2(shift.x, -shift.y);
	vec2 gs = vec2(shift.y, -shift.z);
	vec2 bs = vec2(shift.z, -shift.x);
	
	float r = texture(tex, p+rs*activation).r;
	float g = texture(tex, p+gs*activation).g;
	float b = texture(tex, p+bs*activation).b;
	return vec4(r, g, b, texture(tex, p).a);
}

float rand(in vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

// Fair dice roll. Guaranteed to be random.
vec4 noise(in vec2 p) {
	return vec4(vec3(
		rand(p+183.234),
		rand(p+32.28),
		rand(p+161.837)
	) * rand(p), 1.0);
}

vec4 vec4pow(in vec4 v, in float p) {
	// Don't touch alpha (w), we use it to choose the direction of the shift
    // and we don't want it to go in one direction more often than the other.
	return vec4(pow(v.x, p), pow(v.y, p), pow(v.z, p), v.w);
}

void fragment() {
	vec4 c = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 shift = vec4pow(noise(vec2(speed * TIME, 2.0 * speed * TIME / 25.0)), 8.0)
	  * vec4(amplitude, amplitude, amplitude, 1.0);
	vec4 disp = texture(displacementMask, SCREEN_UV);
	vec2 newUV = SCREEN_UV + (disp.xy * displacement * vec4pow(noise(vec2(speed * TIME, 2.0 * speed * TIME / 25.0)), 9.0).xy) * activation;
	c += rgbShift(newUV, SCREEN_TEXTURE, shift);
	COLOR = c;
}