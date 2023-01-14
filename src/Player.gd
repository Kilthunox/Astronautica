extends Node

@export var  WorldNodePath: NodePath
@onready var world: Node = get_node_or_null(WorldNodePath)

@onready var prototype_building_node = IsoKit.make_actor(Runtime.ASSETS, {
	"id": "prototype_building",
	"sprite": "prototype_building_sprite.sprite",
	"speed": 0.0,
})

@onready var prototype_object_node = IsoKit.make_actor(Runtime.ASSETS, {
	"id": "prototype_object",
	"sprite": "prototype_object_sprite.sprite",
	"speed": 0.0,
})

@onready var assemblies = {
	"prototype_building": prototype_building_node,
	"prototype_object": prototype_object_node,
}

func _ready():
	make_player_actor_node()
	
func _physics_process(_delta):
	handle_movement_input()
	
func _unhandled_input(_event):
	handle_action_input()

func make_player_actor_node():
	var player_actor_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": Runtime.PLAYER_ACTOR_ID,
		"sprite": "prototype_sprite.sprite",
		"zone": "prototype_zone.zone",
		"spawn": "spawn",
		"speed": Runtime.PLAYER_SPEED,
	})
	player_actor_node.camera_lock()
	world.add_child(player_actor_node)
	
func get_player_actor():
	return get_parent().get_node("World").get_node_or_null(Runtime.PLAYER_ACTOR_ID)
	
func place_node_in_front(node: Node2D):
	var pos = get_player_actor().get_front(node.size)
	var x_pos = snapped(pos.x, Runtime.GRID_SIZE.x) - Runtime.GRID_OFFSET.x
	var y_pos = snapped(pos.y, Runtime.GRID_SIZE.y) - Runtime.GRID_OFFSET.y
	node.position.x = x_pos
	node.position.y = y_pos
	world.add_child(node)
	
func free_staged_assembly():
	for staged_node in get_tree().get_nodes_in_group(Runtime.STAGED):
		staged_node.queue_free()
	
func stage_node_in_front(node: Node2D):
	free_staged_assembly()
	node.snap_to_grid(get_player_actor().get_front(node.size), Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
	node.get_node("Sprite").modulate.a = 0.333
	node.add_to_group(Runtime.STAGED)
	world.add_child(node) 
	
func make_assembly(id: String):
	free_staged_assembly()
	var assembly_node = assemblies[id].duplicate()
	place_node_in_front(assembly_node)
	
func stage_assemby(id: String):
	var assembly_node = assemblies[id].duplicate()
	stage_node_in_front(assembly_node)

func handle_movement_input():
	var heading = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	if heading:
		get_player_actor().set_heading(heading)
	else:
		get_player_actor().stop()

func handle_action_input():
	if Input.is_action_just_pressed("action_1"):
		stage_assemby("prototype_object")
	elif Input.is_action_just_released("action_1"):
		make_assembly("prototype_object")
	if Input.is_action_just_released("action_2"):
		make_assembly("prototype_building")
		
