extends Node2D
class_name World

@onready var tile_map: TileMapLayer = $Terrain

static var _instance : World = null

func _ready():
	_instance = self if _instance == null else _instance
	
static func get_tile_data_at(the_position: Vector2) -> TileData:
	var local_position: Vector2i = _instance.tile_map.local_to_map(the_position)
	return _instance.tile_map.get_cell_tile_data(local_position)
	
static func get_custom_data_at(the_position: Vector2, custom_data_name: String) -> Variant:
	var data = get_tile_data_at(the_position)
	return data.get_custom_data(custom_data_name)
	
	
 
