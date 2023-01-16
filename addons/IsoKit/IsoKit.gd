extends Node

var tilemap_node
var tileset_node
var tileatlas_node

@onready var actor_packed_scene: PackedScene = preload("res://addons/IsoKit/actor.tscn")

enum RADIALS {
	E,
	SE,
	S,
	SW,
	W,
	NW,
	N,
	NE
}

const NORTH_RADIANS: float = PI / 2.0

var cache: Dictionary = {
	"textures": {}
}

func build_frame(dir: String, index: int, columns: int, size: Vector2, source: String, state_radial: String) -> AtlasTexture:
	var external_texture: Texture
	var texture: AtlasTexture
	if cache.textures.has(source):
		external_texture = cache.textures[source]
	else:
		external_texture = load(dir + source)
		cache.textures[source] = external_texture
	texture = AtlasTexture.new()
	texture.set_atlas(external_texture)
	texture.set_region(Rect2(Vector2((index % columns) * size.x, (index / columns) * size.y), size))
	return texture

func make_actor(dir, data: Dictionary, threat: int = 0):
	var actor_node = actor_packed_scene.instantiate()
	if data.get("id"):
		actor_node.id = data.get("id", "")
	if data.get("name"):
		actor_node.name = data.get("name")
	var position = Vector2(data.get("position", [0])[0], data.get("position", [0, 0])[1])
	if position:
		actor_node.position = position
	elif data.get("spawn") and data.get("zone"):
		var zone = load_zone(dir, data.get("zone"))
		for actor in zone.get("actors", []):
			if actor.get("id") == data.get("spawn"):
				actor_node.position = Vector2(actor.get("position", [0])[0], actor.get("position", [0, 0])[1])
				break
				# TODO - Find a better way to set spawn. 
				
	actor_node.threat = data.get("threat", 0)
	actor_node.speed = data.get("speed", 0)
	actor_node.size.x = data.get("size", [0, 0])[0]
	actor_node.size.y = data.get("size", [0, 0])[1]
	var sprite_source = data.get("sprite")
	if sprite_source:
		var sprite_file = FileAccess.open(dir + sprite_source, FileAccess.READ)
		var sprite_data = JSON.parse_string(sprite_file.get_as_text())
		var sprite_frames: SpriteFrames = SpriteFrames.new()
		actor_node.size = Vector2(sprite_data.get("size", [0])[0], sprite_data.get("size", [0, 0])[1])
		actor_node.margin = Vector2(sprite_data.get("margin", [0])[0], sprite_data.get("margin", [0, 0])[1])
		var sprite_vertical_offset: float = (actor_node.size.y / 2) - actor_node.margin.y
		actor_node.get_node("Sprite").offset.y -= sprite_vertical_offset
		actor_node.build_rect()
		if sprite_data.get("polygon"):
			var points: PackedVector2Array = PackedVector2Array([])
			for vertex in sprite_data.get("polygon", []):
				points.append(Vector2(vertex[0], vertex[1]))
			actor_node.polygon = points
			actor_node.build_collision_shapes()
			
		for state in sprite_data.get('animations', {}).keys():
			for radial in RADIALS.keys():
				sprite_frames.add_animation('%s:%s' % [state, radial])

		for state in sprite_data.get('animations', {}).keys():
			for radial in sprite_data.animations[state].keys():
				for index in sprite_data.animations[state][radial]:
					var state_radial: String = '%s:%s' % [state, radial]
					sprite_frames.add_frame(
						state_radial, 
						build_frame(
							dir,
							index, 
							sprite_data.get('columns', 1),
							Vector2(sprite_data.size[0], sprite_data.size[1]),
							sprite_data.get('source'),
							state_radial
						)
					)
		actor_node.set_sprite_frames(sprite_frames)
		if sprite_frames.get_animation_names():
			actor_node.get_node("Sprite").set_animation(sprite_frames.get_animation_names()[0])
	
	return actor_node

func load_zone(dir, path):
	var zone_file = FileAccess.open(dir + path, FileAccess.READ)
	var zone_data = JSON.parse_string(zone_file.get_as_text())
	return zone_data
	

func isometric_factor(radians: float) -> float:
	radians = abs(radians)
	if radians > NORTH_RADIANS:
		radians = NORTH_RADIANS - (radians - NORTH_RADIANS)
	return 1.0 - ((radians / (NORTH_RADIANS) / 2))

func snap_radial(radians: float) -> int:
	return wrapi(int(snapped(radians, PI/4) / (PI/4)), 0, 8)
	
func snap_to_grid(position, at: Vector2, grid_size: Vector2i, offset: Vector2i):
	position.x = snapped(at.x, grid_size.x) - offset.x
	position.y = snapped(at.y, grid_size.y) + offset.y
#	if position.x < at.x:
#		position.x = snapped(at.x, grid_size.x) - offset.x
#	else:
#		position.x = snapped(at.x, grid_size.x) + offset.x
#	if position.y < at.y:
#		position.y = snapped(at.y, grid_size.y) - offset.y
#	else:
#		position.y = snapped(at.y, grid_size.y) + offset.y
#
	return position

func map_radial(radians: float) -> String:
	return RADIALS.keys()[snap_radial(radians)]

func infer_footprint_from_polygon(polygon: Array[Vector2]) -> Vector2:
	var max_x: float
	var min_x: float
	var max_y: float
	var min_y: float
	for point in polygon:
		max_x = max(max_x, point[0])
		min_x = min(min_x, point[0])
		max_y = max(max_y, point[1])
		min_y = min(min_y, point[1])
	return Vector2((max_x - min_x), (max_y - min_y))


func get_user_dir() -> String:
	var result = ""
	var desktop_path_array = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).split("/")
	for dir in desktop_path_array.slice(0, desktop_path_array.size() - 1):
		result += "/%s" % dir
	result += "/"
	return result


func initialize_tileatlas(dir, path, size: Vector2i): 
	tileatlas_node = TileSetAtlasSource.new()	
	var texture = load(dir + path)
	tileatlas_node.set_texture(texture)
	tileatlas_node.set_texture_region_size(size)
	
	
func initalize_tileatlas_tiles(n_columns: int, tiles: Array): 
	for tile in tiles:
		var coords = Vector2i(int(tile.get("id")) % n_columns, int(tile.get("id")) / n_columns)
		tileatlas_node.set("%s:%s/0/y_sort_origin" % [coords.x, coords.y], tile.get("origin", 0))
		if tile.get("collision", []):
			var polygon_data = tile.get("collision")
			var tile_node = tileatlas_node.get_tile_data(coords, 0)
			tile_node.add_collision_polygon(0)
			var polygon_vectors: PackedVector2Array = PackedVector2Array([])
			for vertex in polygon_data:
				polygon_vectors.append(Vector2i(vertex[0], vertex[1]))
			tile_node.set("physics_layer_0/polygon_0/points", polygon_vectors)
			
	

func load_tileset(dir, path, size: Vector2i):
	var tileset_file = FileAccess.open(dir + path, FileAccess.READ)
	var tileset_data = JSON.parse_string(tileset_file.get_as_text())
	tileset_node = TileSet.new()
	initialize_tileatlas(
		dir,
		tileset_data.get("source"), 
		Vector2i(tileset_data.get("size")[0], tileset_data.get("size")[1]), 
	)
	tileset_node.add_source(tileatlas_node)
	tileset_node.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tileset_node.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	tileset_node.tile_size = size
	tileset_node.add_physics_layer()
################################################################################
	# TODO - Allow this to be set externally, -- hard coding this for the jam
	tileset_node.set_physics_layer_collision_layer(0, 2)
################################################################################
	initalize_tileatlas_tiles(
		tileset_data.get("columns"),
		tileset_data.get("tiles", [])
	)

	return [tileset_node, int(tileset_data.get("columns"))]
	
	
func load_tilemap(dir, path):
	var tilemap_file = FileAccess.open(dir + path, FileAccess.READ)
	var tilemap_data = JSON.parse_string(tilemap_file.get_as_text())
	tilemap_node = TileMap.new()
	tilemap_node.y_sort_enabled = true
	var tile_size = Vector2i(tilemap_data.size[0], tilemap_data.size[1])
	var tileset_result = load_tileset(dir, tilemap_data.get("tileset"), tile_size)
	tileset_node = tileset_result[0]
	var n_columns = tileset_result[1]
	tilemap_node.name = tilemap_data.get("name")
	tilemap_node.set_tileset(tileset_node)
	# Clear layers
	for i in range(0, tilemap_node.get_layers_count()):
		tilemap_node.remove_layer(i)
	
	for i in range(0, tilemap_data.get("layers", []).size()):
		var layer_data = tilemap_data.layers[i]
		tilemap_node.add_layer(-1)
		tilemap_node.set_layer_name(i, layer_data.get("name"))
		tilemap_node.set_layer_y_sort_enabled(i, layer_data.get("ysort", false))
		tilemap_node.set_layer_y_sort_origin(i, layer_data.get("origin", 0))
		for tile_data in layer_data.get("tiles", []):
			var coords = Vector2i(tile_data.get("position")[0], tile_data.get("position")[1])
			var id = tile_data.get("id")
			var row = (int(id) % n_columns) 
			var col = (int(id) / n_columns)
			tilemap_node.set_cell(i, coords, 0, Vector2i(row, col))		
	return tilemap_node
