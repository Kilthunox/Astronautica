extends Node2D


func _ready():
	var tilemap_node = IsoKit.load_tilemap(Runtime.ASSETS, "prototype_tilemap.tilemap")

	var player_actor_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": Runtime.PLAYER_ACTOR_ID,
		"sprite": "prototype_sprite.sprite",
		"zone": "prototype_zone.zone",
		"spawn": "spawn",
		"speed": Runtime.PLAYER_SPEED,
	})
	player_actor_node.camera_lock()
	add_child(player_actor_node)
	add_child(tilemap_node)
	$"../Player".set_process_unhandled_input(true)
