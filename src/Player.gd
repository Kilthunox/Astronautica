extends Node

const STAGED_COLLISIONS = [[], []]

@export var  WorldNodePath: NodePath
@onready var world: Node = get_node_or_null(WorldNodePath)

var invalid_assembly_placement: bool = false

signal assembly_placed(coords)

func _ready():
	make_player_actor_node()
	
func _physics_process(delta):
	handle_movement_input(delta)
	
	
func _unhandled_input(_event):
	handle_action_input()

func make_player_actor_node():
	var player_actor_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": Runtime.PLAYER_ACTOR_ID,
		"name": Runtime.PLAYER_ACTOR_ID,
		"sprite": "prototype_sprite.sprite",
		"zone": "prototype_zone.zone",
		"spawn": "spawn",
		"speed": Runtime.PLAYER_SPEED,
	})
	player_actor_node.camera_lock()
	player_actor_node.set_collision_layer_value(1, 1)
	player_actor_node.set_collision_mask_value(1, 1)
	world.add_child(player_actor_node)
	
func get_player_actor():
	return world.get_node_or_null(Runtime.PLAYER_ACTOR_ID)
	
func place_node_in_front(node: Node2D):
	var staged = get_staged_node()
	if staged:
		node.position = staged.position
		world.add_child(node)
	
func get_staged_node():
	var staged = get_tree().get_nodes_in_group(Runtime.STAGED)
	if staged:
		return staged[0]
	
	
func free_staged_assembly():
	invalid_assembly_placement = false
	for staged_node in get_tree().get_nodes_in_group(Runtime.STAGED):
		staged_node.queue_free()

func stage_node_in_front(node: Node2D):
	free_staged_assembly()
	node.snap_to_grid(get_player_actor().get_front(node.size), Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
	node.get_node("Sprite").modulate.a = Runtime.OPACITY
	node.add_to_group(Runtime.STAGED)
	world.add_child(node) 
	
func make_assembly(id: String):
	if !invalid_assembly_placement:
		var assembly_node = Runtime.call("make_%s_node" % id)
		assembly_node.set_collision_layer_value(1, 1)
		assembly_node.set_collision_mask_value(1, 1)
		place_node_in_front(assembly_node)
		assembly_node.snap_to_grid(assembly_node.position, Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
		var x_coord = int(assembly_node.position.x) / int(Runtime.GRID_SIZE.x)
		var y_coord = int(assembly_node.position.y) / int(Runtime.GRID_SIZE.y)
		assembly_node.coords = Vector2i(x_coord, y_coord)
		assembly_node.add_to_group(str(assembly_node.coords))
		assembly_placed.emit(assembly_node.coords)
	free_staged_assembly()
	
func stage_assembly(id: String):
	free_staged_assembly()
	var assembly_node = Runtime.call("make_%s_node" % id)
	assembly_node.get_node("Area").set_collision_layer_value(1, 1)
	assembly_node.get_node("Area").set_collision_mask_value(1, 1)
	assembly_node.on_area_entered_hooks.append(handle_body_entered_staged_assembly)
	assembly_node.on_area_exited_hooks.append(handle_body_exited_staged_assembly)
	stage_node_in_front(assembly_node)

func handle_body_entered_staged_assembly():
	invalid_assembly_placement = true
	get_staged_node().get_node("Sprite").set_modulate(Runtime.INVALID_COLOR)
	# TODO - tell player bad assign
		
func handle_body_exited_staged_assembly():
	invalid_assembly_placement = false
	get_staged_node().get_node("Sprite").set_modulate(Color(1, 1, 1, Runtime.OPACITY))
	


func handle_movement_input(delta):
	var heading = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	if !get_staged_node():
		Cache.offset = Vector2()
		if heading:
			get_player_actor().set_heading(heading)
		else:
			get_player_actor().stop()
	else:
		get_player_actor().stop()
		get_staged_node().set_heading(heading)

func handle_action_input():
	if Input.is_action_just_pressed("action_1"):
		stage_assembly("prototype_object")
	elif Input.is_action_just_released("action_1"):
		make_assembly("prototype_object")
	if Input.is_action_just_pressed("action_2"):
		stage_assembly("prototype_building")
	elif Input.is_action_just_released("action_2"):
		make_assembly("prototype_building")
	
	if Input.is_action_just_released("cancel"):
		free_staged_assembly()
		
