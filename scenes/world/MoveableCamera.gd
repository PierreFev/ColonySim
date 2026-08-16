extends Camera2D

var limit_min: Vector2i = Vector2i(0,0)
var limit_max: Vector2i = Vector2i(1000,1000)

var dragSensitivity: float = 0.5

var zoom_values: Array[float] = [0.5,1,2]
var current_zoom_index: int = 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		position = (position - event.relative * dragSensitivity)
		_fix_position()

func _fix_position():
	var vp_size: Vector2i = get_viewport_rect().size / zoom_values[current_zoom_index]
	var lim_min = limit_min+(vp_size/2)
	var lim_max =  limit_max-(vp_size/2)
	var center = (limit_max-limit_min)/2
	if vp_size.x > (limit_max-limit_min).x:
		lim_min.x = center.x
		lim_max.x = center.x
	if vp_size.y > (limit_max-limit_min).y:
		lim_min.y = center.y
		lim_max.y = center.y
	position = position.clamp(lim_min, lim_max)

func zoom_in():
	current_zoom_index = clamp(current_zoom_index + 1, 0 , zoom_values.size()-1)
	zoom = Vector2(1,1) * zoom_values[current_zoom_index]
	_fix_position()

func zoom_out():
	current_zoom_index = clamp(current_zoom_index - 1, 0 , zoom_values.size()-1)
	zoom = Vector2(1,1) * zoom_values[current_zoom_index]
	_fix_position()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
