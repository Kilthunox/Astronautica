extends Node

const STAGED_COLLISIONS = [[], []]

@export var  WorldNodePath: NodePath
@onready var world: Node = get_node_or_null(WorldNodePath)

var invalid_assembly_placement: bool = false

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
	player_actor_node.set_collision_layer_value(1, 1)
	player_actor_node.set_collision_mask_value(1, 1)
	world.add_child(player_actor_node)
	
func get_player_actor():
	return get_parent().get_node("World").get_node_or_null(Runtime.PLAYER_ACTOR_ID)
	
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
	
func snap_node_to_grid_cprocess(args: Dictionary):
	args["self"].snap_to_grid(get_player_actor().get_front(args["self"].size), Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
	
func stage_node_in_front(node: Node2D):
	free_staged_assembly()
	node.snap_to_grid(get_player_actor().get_front(node.size), Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
	node.get_node("Sprite").modulate.a = Runtime.OPACITY
	node.add_to_group(Runtime.STAGED)
	node.add_compute("SnapToGrid", snap_node_to_grid_cprocess)
	world.add_child(node) 
	
func make_assembly(id: String):
	if !invalid_assembly_placement:
		var assembly_node = Runtime.call("make_%s_node" % id)
		assembly_node.set_collision_layer_value(1, 1)
		assembly_node.set_collision_mask_value(1, 1)
		place_node_in_front(assembly_node)
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
	# TODO - tell player bad assign
		
func handle_body_exited_staged_assembly():
	invalid_assembly_placement = false


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
		stage_assembly("prototype_object")
	elif Input.is_action_just_released("action_1"):
		make_assembly("prototype_object")
	if Input.is_action_just_pressed("action_2"):
		stage_assembly("prototype_building")
	elif Input.is_action_just_released("action_2"):
		make_assembly("prototype_building")
	
	if Input.is_action_just_released("cancel"):
		free_staged_assembly()
		
