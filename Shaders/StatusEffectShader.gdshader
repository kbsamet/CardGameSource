shader_type canvas_item;
render_mode blend_add;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear, repeat_disable;
uniform vec4 block_color : source_color;
uniform vec4 overcharged_color : source_color;
uniform bool block_effect = false;
uniform bool overcharged_effect = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 ps = SCREEN_PIXEL_SIZE;
	vec2 ratio = (ps.x > ps.y) ? vec2(ps.y / ps.x, 1) : vec2(1, ps.x / ps.y);
	vec4 color = vec4(0);

	uv = uv - 0.5;
	uv.x += sin(uv.y * 12.56) * 0.01;
	//şiğğğ:İ;color = textureLod(SCREEN_TEXTURE,uv,0.0);
	vec2 d = (abs(uv) - 0.3)/ratio;
    d.x += sin(d.y * 100. * 100.)*0.03;
    d.y += sin(d.x * 100. * 100.)*0.03;
	float len = length(max(d,0.0)) + min(max(d.x,d.y),0.0);
	if(block_effect){
		color += block_color * max(len,0);//vec4(vec3(len),1.0);
	}
	if(overcharged_effect){
		color += overcharged_color * max(len,0);//vec4(vec3(len),1.0);
	}
	
	COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
