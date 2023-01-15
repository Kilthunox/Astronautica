extends Node

@onready var world = get_node("../World")


func get_actor_by_coord(coord: Vector2i):
	var results = get_tree().get_nodes_in_group(str(coord))
	if results:
		return results[0]
		

func get_origin(keys):
	var origin: Vector2i = Vector2i(INF, INF)
	for coords in keys:
		origin = min(coords, origin)
	return origin

func get_neighbors(coords: Vector2i) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2i(coords.x - 1, coords.y - 1),
		Vector2i(coords.x + 0, coords.y - 1),
		Vector2i(coords.x + 1, coords.y - 1),
		Vector2i(coords.x - 1, coords.y + 0),
		Vector2i(coords.x + 1, coords.y + 0),
		Vector2i(coords.x - 1, coords.y + 1),
		Vector2i(coords.x + 0, coords.y + 1),
		Vector2i(coords.x + 1, coords.y + 1),
	])
	
func normalize_recipe(recipe: Dictionary):
	var origin = get_origin(recipe.keys())
	var result: Dictionary = {}
	for coord in recipe.keys():
		result[abs(coord - origin)] = recipe[coord]
		
	return result

func get_recipe(coords: Vector2i, recipe: Dictionary={}):
	if coords not in recipe.keys():
		var actor = get_actor_by_coord(coords)
		if actor:
			recipe[actor.coords] = actor.id
			for neighbor_coords in get_neighbors(actor.coords):
				get_recipe(neighbor_coords, recipe)
	return recipe
	
	

func _on_player_assembly_placed(coords):
	var original_recipe = get_recipe(coords)
	var assembly = normalize_recipe(original_recipe)
	for recipe in Runtime.RECIPE.keys():
		if recipe == assembly:
			compile_assembly(original_recipe.keys(), Runtime.RECIPE[recipe])
			break
	
func compile_assembly(resources, structure_id: String):
	var structure_node = Runtime.call("make_%s_node" % structure_id)
	structure_node.set_collision_layer_value(1, 1)
	structure_node.set_collision_mask_value(1, 1)
	structure_node.snap_to_grid(get_origin(resources) * Runtime.GRID_SIZE, Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
	var x_coord = int(structure_node.position.x) / int(Runtime.GRID_SIZE.x)
	var y_coord = int(structure_node.position.y) / int(Runtime.GRID_SIZE.y)
	structure_node.coords = Vector2i(x_coord, y_coord)
	structure_node.add_to_group(str(structure_node.coords))
	for resource_coords in resources:
		get_actor_by_coord(resource_coords).queue_free()
	world.add_child(structure_node)

