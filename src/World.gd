extends Node2D

var staged_node


func _ready():
	var tilemap_node = IsoKit.load_tilemap(Runtime.ASSETS, "prototype_tilemap.tilemap")


	add_child(tilemap_node)
	$"../Player".set_process_unhandled_input(true)
	
func _physics_process(_delta):
	staged_node = get_node_or_null(Runtime.STAGED)
	if staged_node:
#		get_node(Runtime.STAGED).snap_to_grid(Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
		pass
