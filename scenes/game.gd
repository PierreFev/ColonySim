extends Node

var selected_building_to_build: BuildingBlueprint = null


func _on_menu_button_building_selected(building_data: Variant) -> void:
	selected_building_to_build = BuildingBlueprint.new()
	selected_building_to_build.building_data = building_data
	

func _input(event):
	if event is InputEventMouseMotion:
		var position = $world.get_global_mouse_position()
		var cursor: Cursor = $world.get_node("cursor")
		cursor.position = $world.snap_to_cell(position)
		if selected_building_to_build == null:
			cursor.set_to_select_mode()
		else:
			cursor.set_to_building_mode(selected_building_to_build)
		
func _unhandled_input(event):
	if event.is_action_pressed("rotate_building"):
		if selected_building_to_build:
			selected_building_to_build.rotated = !selected_building_to_build.rotated
			$world.get_node("cursor").update(selected_building_to_build)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if selected_building_to_build != null:
				$world.place_building(selected_building_to_build, $world.get_global_mouse_position())
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			selected_building_to_build = null
			
