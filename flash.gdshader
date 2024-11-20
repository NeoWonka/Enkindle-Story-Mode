shader_type canvas_item;

uniform bool enable = false;
uniform float sensitivity : hint_range(0.0, 1.0) = .0;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 438.5453);
}

void vertex() {
	// Called for every vertex the material is visible on.
	
}

void fragment() {
	// Get size of texture in pixels
	float size_x = float(textureSize(TEXTURE, 0).x);
	float size_y = float(textureSize(TEXTURE, 0).y);
	// 
	vec4 pixelColor = texture(TEXTURE, UV);
	// Create a new "UV" which remaps every UV value to a snapped pixel value
	vec2 UVr = vec2(floor(UV.x*size_x)/size_x, floor(UV.y*size_y)/size_y);
	// Determine whether pixel should be visible or not
	float visible = step(sensitivity, random(UVr));
	
	// Called for every pixel the material is visible on.
	if (enable == true) {
		pixelColor.r = 1.0;
		pixelColor.g = 1.0;
		pixelColor.b = 1.0;
	}
	COLOR = vec4(pixelColor.r, pixelColor.g, pixelColor.b, min(visible, pixelColor.a));
}


//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
