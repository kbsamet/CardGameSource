shader_type canvas_item;
uniform float time : hint_range(0, 1);
uniform vec4 hit_color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb = (hit_color.rgb * (1.0-time) )+ (COLOR.rgb * time);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
