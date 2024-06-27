shader_type canvas_item;
uniform float cutoff = 0.5;
uniform vec4 color : source_color = vec4(1,0,0,1);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	vec2 orig_uv = uv;
	uv -= 0.5;
	float d  = length(uv);
	float c = 0.0;
	if(d<0.5 && orig_uv.y > (1.0 -cutoff)) c = 1.0;
	vec4 new_color = c * color;
	COLOR = vec4(new_color.xyz,c);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
