@tool
extends Node2D

@export var Size_X: int = 100:
	set(value):
		Size_X = value
		_update_world_borders()
@export var Size_Y: int = 100:
	set(value):
		Size_Y = value
		_update_world_borders()

@export var building_scene: PackedScene

@onready var buildings = $Buildings

var X_CELL_SIZE: int = 32

var Y_CELL_SIZE: int = 16 

func _ready() -> void:
	_update_world_borders()

func _update_world_borders():
	if is_node_ready():
		$WorldBorders.custom_minimum_size = Vector2i(Size_X*X_CELL_SIZE, Size_Y*Y_CELL_SIZE)
		$camera.limit_max = Vector2i(Size_X*X_CELL_SIZE, Size_Y*Y_CELL_SIZE)

func snap_to_cell(position: Vector2):
	var map_position = $TerrainTileMap.local_to_map(position)
	# var cell_offset =  $TerrainTileMap.map_to_local(map_position-Vector2i(0,2))
	var cell_offset =  $TerrainTileMap.map_to_local(map_position-Vector2i(1,1))
	return cell_offset*0.5 + $TerrainTileMap.map_to_local(map_position)*0.5

func get_building_position(map_coord: Vector2i):
	var cell_offset =  $TerrainTileMap.map_to_local(map_coord-Vector2i(1,1))
	return cell_offset*0.5 + $TerrainTileMap.map_to_local(map_coord)*0.5

func place_building(building_blueprint: BuildingBlueprint, map_coord: Vector2i):
	var building_data: BuildingData = building_blueprint.building_data
	var building: Building = building_scene.instantiate()
	building.data = building_data
	building.rotated = building_blueprint.rotated
	building.position = get_building_position(map_coord)
	building.map_position = map_coord
	buildings.add_child(building)

	for x in range(building.footprint.x):
		for y in range(building.footprint.y):
			$TerrainTileMap.set_cell(building.map_position+Vector2i(x,y),
			0,
			Vector2i(3,0))
