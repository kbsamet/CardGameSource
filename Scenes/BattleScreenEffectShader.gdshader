shader_type canvas_item;
render_mode blend_mix;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear, repeat_disable;
uniform float t : hint_range(-1.0, 10.0, 0.001) = 0;
uniform vec4 border_color : source_color;
uniform bool screen_shake = false;
uniform bool border_color_effect = false;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 ps = SCREEN_PIXEL_SIZE;
	vec2 ratio = (ps.x > ps.y) ? vec2(ps.y / ps.x, 1) : vec2(1, ps.x / ps.y);
	vec4 color = textureLod(SCREEN_TEXTURE,uv,0.0);
	COLOR = color;
	if(screen_shake){
		uv.x += sin(uv.y * 12.56 + t) * 0.01;
		color = textureLod(SCREEN_TEXTURE,uv*ratio,0.0);
		COLOR = color;
	}
	if(border_color_effect){
		uv = uv - 0.5;
		uv.x += sin(uv.y * 12.56) * 0.01;
		//şiğğğ:İ;color = textureLod(SCREEN_TEXTURE,uv,0.0);
		vec2 d = (abs(uv) - t)/ratio;
	    d.x += sin(d.y * 100. + t * 100.)*0.03;
	    d.y += sin(d.x * 100. + t * 100.)*0.03;
		float len = length(max(d,0.0)) + min(max(d.x,d.y),0.0);
		color = border_color * max(len,0);//vec4(vec3(len),1.0);
		COLOR = color;
	}
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
