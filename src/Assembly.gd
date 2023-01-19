extends Node

@onready var world = get_node("../World")
@onready var player = get_node("../Player")


func get_actor_by_coord(coord: Vector2i):
	var results = get_tree().get_nodes_in_group(str(coord))
	if results:
		return results[0]
		

func get_origin(keys):
	var origin: Vector2i
	var sum_x: int = 0
	var sum_y: int = 0
	for coords in keys:
		sum_x += coords.x
		sum_y += coords.y
	origin = Vector2i(sum_x / keys.size(), sum_y / keys.size())
	return origin

func get_neighbors(coords: Vector2i) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2i(coords.x - 1, coords.y - 1),
		Vector2i(coords.x + 0, coords.y - 1),
		Vector2i(coords.x + 1, coords.y - 1),
		Vector2i(coords.x - 1, coords.y + 0),
		Vector2i(coords.x - 0, coords.y + 0),
		Vector2i(coords.x + 1, coords.y + 0),
		Vector2i(coords.x - 1, coords.y + 1),
		Vector2i(coords.x + 0, coords.y + 1),
		Vector2i(coords.x + 1, coords.y + 1),
	])
	
func normalize_recipe(recipe: Dictionary):
#	var origin = get_origin(recipe.keys())
#	var result: Dictionary = {}
#	for coord in recipe.keys():
#		result[coord - origin] = recipe[coord]
#	return result
	var result: Dictionary = {}
	var max_x: int = Runtime.INT64_LIMIT
	var max_y: int = Runtime.INT64_LIMIT
	for key in recipe.keys():
		max_x = max(key.x, max_x)
		max_y = max(key.y, max_y)
	for key in recipe.keys():
		result[Vector2i(key.x - max_x, key.y - max_y)] = recipe[key]
	return result
	
func get_recipe(coords: Vector2i, recipe: Dictionary={}, nloops: int = 0):
	nloops += 1
	if nloops > Runtime.RECIPE_RECURSION_LIMIT:
		return recipe
	if coords not in recipe.keys():
		var actor = get_actor_by_coord(coords)
		if actor:
			recipe[actor.coords] = actor.id
			for neighbor_coords in get_neighbors(actor.coords):
				get_recipe(neighbor_coords, recipe)
	return recipe
	
func compile_assembly(resources, structure_id: String):
	if !Cache.assembler_lock:
		Cache.assembler_lock = true
		var structure_node = Runtime.call("make_%s_node" % structure_id)
		structure_node.set_collision_layer_value(2, 1)
		structure_node.set_collision_layer_value(3, 1)
		structure_node.snap_to_grid(get_origin(resources) * Runtime.GRID_SIZE, Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
		var x_coord = int(structure_node.position.x) / int(Runtime.GRID_SIZE.x)
		var y_coord = int(structure_node.position.y) / int(Runtime.GRID_SIZE.y)
		structure_node.coords = Vector2i(x_coord, y_coord)
		structure_node.add_to_group(str(structure_node.coords))
		for resource_coords in resources:
			get_actor_by_coord(resource_coords).queue_free()
		structure_node.connect("tree_entered", func(): Cache.assembler_lock = false)
		player.new_transmission("+%s deployed" % {
				"oxygen_farm": "Oxygen Farm",
				"reactor": "Plasma Reactor",
				"solar_panel": "Solar Panel",
				"refinery": "Refinery",
				"fabricator": "Fabricator",
			}.get(structure_node.id), Runtime.COLOR_GRAY)
		world.call_deferred("add_child", structure_node)


func _on_player_assembly_query(coords):
	var original_recipe = get_recipe(coords)
	var assembly = normalize_recipe(original_recipe)

	
	###############################################################################
	var rstring = "\n"
	for k in assembly.keys():
		rstring += "\n\t\tVector2i(%s, %s): \"%s\"," % [k.x, k.y, assembly[k]]
	print(rstring)
	##############################################################################
	for recipe in Runtime.RECIPE.keys():
		if recipe == assembly:
			compile_assembly(original_recipe.keys(), Runtime.RECIPE[recipe])
			break
