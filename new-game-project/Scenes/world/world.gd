extends Node2D
class_name World

@onready var tile_map: TileMapLayer = $Terrain

# zero based index NONE:0, WATER:1, etc.
# correlates with 'tyle_type' a TileMapLayer Custom Data Type painted onto the tileset.
enum TILE_TYPES { NONE, WATER, DIRT, GRASS }

# define the different types of color textures to use in a particle system
# for each type of tile.
@export var water_color: GradientTexture1D
@export var dirt_color: GradientTexture1D
@export var grass_color: GradientTexture1D
# now the color gradients need to be defined in the 'World' Inspector.
# in Inspector: create 'new' 'Gradient1D'
# make one for 'water', 'drit', 'grass'.
# make them unique.
# once the gradient colors are set up in the Inspector,
# we want to map these gradients based off the enumerator, using a dictionary.
@onready var tile_particle_ramps = {
	TILE_TYPES.NONE: null,
	TILE_TYPES.WATER: water_color,
	TILE_TYPES.DIRT: dirt_color,
	TILE_TYPES.GRASS: grass_color,
}
# next create a static function that will get the gradient at our position.
# see 'static' func get_gradient_at' below.

static var _instance : World = null

func _ready():
	_instance = self if _instance == null else _instance
	
static func get_tile_data_at(the_position: Vector2) -> TileData:
	var local_position: Vector2i = _instance.tile_map.local_to_map(the_position)
	return _instance.tile_map.get_cell_tile_data(local_position)
	
static func get_custom_data_at(the_position: Vector2, custom_data_name: String) -> Variant:
	var data = get_tile_data_at(the_position)
	return data.get_custom_data(custom_data_name)
	
# get our gradient at our position 
static func get_gradient_at(the_position: Vector2) -> GradientTexture1D:
	# get our tile type using our 'get_custom_data_at',
	# pass in our position and check the tile type at that position.
		var tile_type = get_custom_data_at(the_position, "tile_type")
		# return by checking our instance 'tile_particle_ramps'
		# and use our 'get' function to look for our tile type
		# and if none exists, return default of  null.
		return _instance.tile_particle_ramps.get(tile_type, null)
		
	
	
	
 
