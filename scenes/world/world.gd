extends Node2D

@export var building_scene: PackedScene

@onready var buildings = $Buildings

var BUILDING_CELL_HEIGHT: int = 16
var BUILDING_CELL_WIDTH: int = 32

func snap_to_cell(position: Vector2):
	var map_position = $TerrainTileMap.local_to_map(position)
	var cell_offset =  $TerrainTileMap.map_to_local(map_position-Vector2i(0,2))
	return cell_offset*0.5 + $TerrainTileMap.map_to_local(map_position)*0.5

func place_building(building_blueprint: BuildingBlueprint, mouse_position: Vector2):
	var building_data: BuildingData = building_blueprint.building_data
	var building: Building = building_scene.instantiate()
	building.data = building_data
	building.rotated = building_blueprint.rotated
	building.position = snap_to_cell(mouse_position)
	print(mouse_position, building.position)
	buildings.add_child(building)
