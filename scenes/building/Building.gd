@tool
class_name Building
extends Node2D

@export var data: BuildingData:
	set(value):
		data = value
		update_building()
@export var rotated: bool = false:
	set(value):
		rotated = value
		update_building()

var map_position: Vector2i
var footprint: Vector2i

func _ready():
	update_building()

func update_building():
	if not is_node_ready():
		return

	if data:
		var w: int = data.width
		var h: int = data.height
		footprint = Vector2i(h,w) if rotated else Vector2i(w,h)
		$Sprite2D.texture = data.texture
		$footprint.polygon = [
			Vector2i(0,0),
			Vector2i(16*footprint.x, -8*footprint.x),
			Vector2i(16*(footprint.x+footprint.y), -8*(footprint.x-footprint.y)),
			Vector2i(16*footprint.y,8*footprint.y),
			]
		var tex_h = data.texture.get_height()
		$Sprite2D.position.x = 0
		$Sprite2D.position.y = -tex_h + 8*footprint.y
	$Sprite2D.flip_h = rotated
