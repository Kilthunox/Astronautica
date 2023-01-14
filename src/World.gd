extends Node2D

var staged_node


func _ready():
	var tilemap_node = IsoKit.load_tilemap(Runtime.ASSETS, "prototype_tilemap.tilemap")
	add_child(tilemap_node)
