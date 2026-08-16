extends MenuButton

signal building_selected(building_data)

@export var building_list: Array[BuildingData]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_popup().id_pressed.connect(self.set_building)
	for building in building_list:
		get_popup().add_icon_item(building.texture, building.name)

func set_building(id: int):
	building_selected.emit(building_list[id])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
