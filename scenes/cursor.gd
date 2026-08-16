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
	var data = building_blueprint.building_data

	$sprite2d.texture = data.texture
	$sprite2d.flip_h = building_blueprint.rotated

	var w: int = data.width
	var h: int = data.height
	var footprint = Vector2i(h,w) if building_blueprint.rotated else Vector2i(w,h)
	$sprite2d.texture = data.texture
	$build.polygon = [
		Vector2i(0,0),
		Vector2i(16*footprint.x, -8*footprint.x),
		Vector2i(16*(footprint.x+footprint.y), -8*(footprint.x-footprint.y)),
		Vector2i(16*footprint.y,8*footprint.y),
		]
	var tex_h = data.texture.get_height()
	$sprite2d.position.x = 0
	$sprite2d.position.y = -tex_h + 8*footprint.y

	
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
		$sprite2d.show()
		update(building_blueprint)
		
		
		
		
