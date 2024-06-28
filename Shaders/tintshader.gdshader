shader_type canvas_item;
uniform sampler2D pallete;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float grayscale = (COLOR.r + COLOR.g + COLOR.b) / 3.0 ;

	COLOR = vec4(vec3(grayscale),1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
