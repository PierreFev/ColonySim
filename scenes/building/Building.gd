@tool
class_name Building
extends Node2D

@export var data: BuildingData:
	set(value):
		data = value
		update_building()
@export var rotated: bool = false

func _ready():
	update_building()

func update_building():
	if not is_node_ready():
		return

	if data:
		$Sprite2D.texture = data.texture
	$Sprite2D.flip_h = rotated
