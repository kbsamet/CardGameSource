shader_type canvas_item;
render_mode blend_mix;

uniform vec4 color : source_color = vec4(1.0);
uniform vec4 daze_color : source_color = vec4(1.0);
uniform vec4 hit_color : source_color = vec4(1.0);
uniform float time = 0;

uniform bool outline = false;
uniform bool dazed = false;
uniform bool hit = false;


void vertex() {
	float width = 1.0;
	if (outline){
		VERTEX += (UV * 2.0 - 1.0) * width;
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	float width = 1.0;
	int pattern = 0; // diamond, circle, square
	bool inside = false;
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;

		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a <= 0.0) == inside) {
				return true;
			}
		}
	}

	return false;
}

void fragment() {
	vec2 uv = UV;
	float width = 1.0;

	bool inside = false;
	bool add_margins = true; // only useful when inside is false
	if (outline){
		if (add_margins) {
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0));

		uv = (uv - texture_pixel_size * width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

		if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
			COLOR.a = 0.0;
		} else {
			COLOR = texture(TEXTURE, uv);
		}
		} else {
			COLOR = texture(TEXTURE, uv);
		}

		if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
			COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
			COLOR.a += (1.0 - COLOR.a) * color.a;
		}
	}

	if(dazed){
		COLOR *= daze_color;
	}
	if(hit){
		COLOR.rgb = (hit_color.rgb * (1.0-time) )+ (COLOR.rgb * time);
	}
}