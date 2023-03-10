extends Node2D

var staged_node

@onready var ResourceAudio = preload("res://src/resource_audio.tscn")

func _ready():
	populate_zone(Cache.zone)
	var tilemap_node = IsoKit.load_tilemap(Runtime.ASSETS, Cache.tilemap)
	add_child(tilemap_node)



func populate_zone(path: String):
	var zone_data = IsoKit.load_zone(Runtime.ASSETS, path)
	for actor_data in zone_data.get("actors", []):
		if actor_data.get("id") in Runtime.STATIC_ACTORS:  ### Make the runtime attrrs inclusive
			var actor_node = Runtime.call("make_%s_node" % actor_data.get("id"))
			if actor_data.get("text"):
				actor_node.set_text(actor_data.text)
			actor_node.set_collision_layer_value(2, 1)
			actor_node.set_collision_layer_value(3, 1)
			actor_node.set_collision_layer_value(4, 1)
			var x = actor_data.get("position", [0, 0])[0]
			var y = actor_data.get("position", [0, 0])[1]
			actor_node.snap_to_grid(Vector2i(x, y), Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
			actor_node.add_to_group(actor_data.get("id"))
			actor_node.add_to_group("resource")
			var x_coord = int(actor_node.position.x) / int(Runtime.GRID_SIZE.x)
			var y_coord = int(actor_node.position.y) / int(Runtime.GRID_SIZE.y)	
			actor_node.coords = Vector2i(x_coord, y_coord)
			actor_node.add_to_group(str(actor_node.coords))
			actor_node.add_child(ResourceAudio.instantiate())
			actor_node.connect("tree_exiting", $"../Player".get_player_actor().get_node("PlayerActorMixer/BlockRemoved").play)
			add_child(actor_node)
