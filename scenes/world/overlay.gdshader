shader_type canvas_item;

varying vec2 world_position;

void vertex() {
	// Called for every vertex the material is visible on.
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;

	if(VERTEX_ID == 1){
		world_position[0] = world_position[0] - 16.;
		world_position[1] = world_position[1] - 8.;
	}
	else if(VERTEX_ID == 3){
		world_position[0] = world_position[0] - 16.;
		world_position[1] = world_position[1] + 8.;
	}
	else if(VERTEX_ID == 2 ){
		world_position[0] = world_position[0] - 32.;
	}
	// world_position = vec2(float(VERTEX_ID), 0.);
}

void fragment() {
	COLOR = COLOR * vec4(1., (world_position.y)/50., 1, 1);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
