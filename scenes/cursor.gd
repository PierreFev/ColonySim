class_name Cursor
extends Node2D

enum CursorMode{
	SELECT,
	PLACE_BUILDING,
	BLOCKED,
}

var current_cursor_mode: CursorMode = CursorMode.SELECT
var _building_blueprint: BuildingBlueprint = null

func get_mode():
	return current_cursor_mode

func set_to_select_mode():
	set_mode(CursorMode.SELECT)

func set_to_building_mode(building_blueprint: BuildingBlueprint):
	set_mode(CursorMode.PLACE_BUILDING, building_blueprint)

func update(building_blueprint: BuildingBlueprint):
	if not building_blueprint:
		return
	_building_blueprint = building_blueprint
	var building_data = building_blueprint.building_data
	var building_size = Vector2(building_data.width, building_data.height)
	$build.scale = building_size
	$sprite2d.texture = building_data.texture
	$sprite2d.flip_h = building_blueprint.rotated
	
func set_mode(mode: CursorMode, building_blueprint: BuildingBlueprint = null):
	current_cursor_mode = mode
	for node in self.get_children():
		node.hide()
	if mode == CursorMode.SELECT:
		$select.show()
	if mode == CursorMode.BLOCKED:
		$blocked.show()
	if mode == CursorMode.PLACE_BUILDING:
		$build.show()
		update(building_blueprint)
		$sprite2d.show()
		
		
		
