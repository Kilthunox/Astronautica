extends Node

const STAGED_COLLISIONS = [[], []]

@export var  WorldNodePath: NodePath
@onready var world: Node = get_node_or_null(WorldNodePath)
@onready var DrillTimer: PackedScene = preload("res://src/drill_timer.tscn")

var invalid_assembly_placement: bool = false

signal assembly_placed(coords)
signal drill_placed(coords)

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
		"zone": "main.zone",
		"spawn": "spawn",
		"speed": Runtime.PLAYER_SPEED,
	})
	player_actor_node.camera_lock()
	player_actor_node.set_collision_layer_value(1, 1)
	player_actor_node.set_collision_mask_value(2, 1)
	player_actor_node.set_collision_mask_value(4, 1)
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
	if !invalid_assembly_placement and Cache.get(Cache.selected_resource) > 0:
		Cache.set(Cache.selected_resource, Cache.get(Cache.selected_resource) - 1)
		var assembly_node = Runtime.call("make_%s_node" % id)
		assembly_node.set_collision_layer_value(2, 1)
		assembly_node.set_collision_layer_value(3, 1)
#		assembly_node.set_collision_mask_value(1, 1)
		place_node_in_front(assembly_node)
		assembly_node.snap_to_grid(assembly_node.position, Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
		var x_coord = int(assembly_node.position.x) / int(Runtime.GRID_SIZE.x)
		var y_coord = int(assembly_node.position.y) / int(Runtime.GRID_SIZE.y)
		assembly_node.coords = Vector2i(x_coord, y_coord)
		assembly_node.add_to_group(str(assembly_node.coords))
		assembly_placed.emit(assembly_node.coords)
	else:
		print("TODO - tell player they are out of %s" % Cache.selected_resource)
	free_staged_assembly()
	
func stage_assembly(id: String):
	free_staged_assembly()
	if Cache.get(Cache.selected_resource) > 0:
		var assembly_node = Runtime.call("make_%s_node" % id)
		assembly_node.get_node("Area").set_collision_layer_value(2, 1)
		assembly_node.get_node("Area").set_collision_mask_value(1, 1)
		assembly_node.get_node("Area").set_collision_mask_value(2, 1)
		assembly_node.on_area_entered_hooks.append(handle_body_entered_staged_assembly)
		assembly_node.on_area_exited_hooks.append(handle_body_exited_staged_assembly)
		stage_node_in_front(assembly_node)
	else:
		print("TODO - tell player they are out of %s" % Cache.selected_resource)

func handle_body_entered_staged_assembly(_body):
	invalid_assembly_placement = true
	get_staged_node().get_node("Sprite").set_modulate(Runtime.INVALID_COLOR)
	# TODO - tell player bad assign
		
func handle_body_exited_staged_assembly(_body):
	invalid_assembly_placement = false
	get_staged_node().get_node("Sprite").set_modulate(Color(1, 1, 1, Runtime.OPACITY))
	


func handle_movement_input(_delta):
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
		
func compute_destructor_node_placement(args: Dictionary):
	args["self"].position = get_player_actor().get_front()
	
func compute_destructor_node_self_destruct(args: Dictionary):
	if Time.get_unix_time_from_system() > args.destruct_time:
		args["self"].queue_free()
		
func handle_destructor_contact(body):
	body.queue_free()
		
func destructor_emission():
	if !world.get_node_or_null(Runtime.DESTRUCTOR_ACTOR_ID):
		var destructor_node = IsoKit.make_actor(Runtime.ASSETS, {
			"id": Runtime.DESTRUCTOR_ACTOR_ID,
			"name": Runtime.DESTRUCTOR_ACTOR_ID,
			"sprite": "destructor_sprite.sprite",
		})
		destructor_node.add_compute("ComputeDestructorNodePlacement", compute_destructor_node_placement)
		destructor_node.add_compute("ComputeDestructorNodeSelfDestruct", compute_destructor_node_self_destruct, {
			"destruct_time":  Time.get_unix_time_from_system() + Runtime.DESTRUCTOR_ACTOR_LIFESPAN
		})
#		destructor_node.get_node("Area").set_collision_layer_value(1, 1)
		destructor_node.get_node("Area").set_collision_mask_value(3, 1)
		destructor_node.on_area_entered_hooks.append(handle_destructor_contact)
		world.add_child(destructor_node)	
	
func revoke_destructor_emission():
	var destructor_node = world.get_node_or_null(Runtime.DESTRUCTOR_ACTOR_ID)
	if destructor_node:
		destructor_node.queue_free()
		
func stage_drill():
	free_staged_assembly()
	var drill_node = Runtime.call("make_drill_node")
	drill_node.get_node("Area").set_collision_layer_value(2, 1)
	drill_node.get_node("Area").set_collision_mask_value(1, 1)
	drill_node.get_node("Area").set_collision_mask_value(2, 1)
	drill_node.on_area_entered_hooks.append(handle_body_entered_staged_assembly)
	drill_node.on_area_exited_hooks.append(handle_body_exited_staged_assembly)
	stage_node_in_front(drill_node)
	
func make_drill():
	if !invalid_assembly_placement:
		var drill_node = Runtime.call("make_drill_node")
		drill_node.set_collision_layer_value(2, 1)
		drill_node.set_collision_layer_value(3, 1)
		place_node_in_front(drill_node)
		drill_node.snap_to_grid(drill_node.position, Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
		var x_coord = int(drill_node.position.x) / int(Runtime.GRID_SIZE.x)
		var y_coord = int(drill_node.position.y) / int(Runtime.GRID_SIZE.y)
		drill_node.coords = Vector2i(x_coord, y_coord)
		drill_node.add_to_group(str(drill_node.coords))
		drill_placed.emit(drill_node.coords)
		var timer = DrillTimer.instantiate()
		drill_node.add_child(timer)
	free_staged_assembly()

func handle_action_input():
	if Input.is_action_just_pressed("action_1"):
		stage_assembly("prototype_object")
	elif Input.is_action_just_released("action_1"):
		make_assembly("prototype_object")
	if Input.is_action_just_pressed("action_2"):
		stage_drill()
	elif Input.is_action_just_released("action_2"):
		make_drill()
	
	if Input.is_action_pressed("action_3"):
		destructor_emission()
#	elif Input.is_action_just_released("action_3"):
#		revoke_destructor_emission()
	
	
	if Input.is_action_just_released("cancel"):
		free_staged_assembly()
		
