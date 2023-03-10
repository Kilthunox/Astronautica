extends Node

const STAGED_COLLISIONS = [[], []]

@export var  WorldNodePath: NodePath
@onready var world: Node = get_node_or_null(WorldNodePath)
@export var ComsNodePath: NodePath
@onready var coms: Node = get_node_or_null(ComsNodePath)
@onready var DrillTimer: PackedScene = preload("res://src/drill_timer.tscn")
@onready var Line: PackedScene = preload("res://src/line.tscn")
@onready var PlayerActorMixer = preload("res://src/player_actor_mixer.tscn")
@onready var DrillAudio = preload("res://src/drill_audio.tscn")

var emitting = false
var just_canceled: bool = false
var transmission_cooling_down: bool = true

var invalid_assembly_placement: bool = false

signal assembly_query(coords)
signal drill_placed(coords)

func player_actor_mixer_stop():
	get_player_actor().get_node("PlayerActorMixer/Quake").stop()
	get_player_actor().get_node("PlayerActorMixer/Footsteps").stop()

func new_transmission(text: String, color: Color = Color(1, 1, 1)):
	if !transmission_cooling_down:
		if color != Runtime.COLOR_GRAY:
			get_player_actor().get_node("PlayerActorMixer/Notification").play()
		transmission_cooling_down = true
		$TransmissionCooldown.start()
		var line = Line.instantiate()
		line.set("theme_override_colors/font_color", color)
		line.uppercase = true
		line.text = text
		coms.add_child(line)
		var n_lines = coms.get_child_count()
		while n_lines > Runtime.TRANSMISSIONS_QUEUE_SIZE:
			n_lines -= 1
			coms.get_child(0).queue_free()


func _ready():
	$TransmissionCooldown.start()
	make_player_actor_node()
	

func _physics_process(_delta):
	if !$"../UserInterface".has_node("InGameMenu") and !$"../UserInterface".has_node("WinScreen"):
		handle_action_input()
		handle_movement_input()
	handle_heading_while_staging()
	
func handle_heading_while_staging():
	var staged_node = get_staged_node()
	if staged_node:
		get_player_actor().set_heading(get_player_actor().position.direction_to(staged_node.position))
	elif get_player_actor().state == "tool" and !world.get_node_or_null(Runtime.EMITTER_ACTOR_ID):
		get_player_actor().set_state("idle")

func make_player_actor_node():
	var player_actor_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": Runtime.PLAYER_ACTOR_ID,
		"name": Runtime.PLAYER_ACTOR_ID,
		"sprite": "astronaut.sprite",
		"zone": Cache.zone,
		"spawn": "player",
		"speed": Runtime.PLAYER_SPEED,
	})
	player_actor_node.camera_lock()
	player_actor_node.set_collision_layer_value(1, 1)
	player_actor_node.set_collision_mask_value(2, 1)
	player_actor_node.set_collision_mask_value(4, 1)
	var mixer = PlayerActorMixer.instantiate()
	player_actor_node.add_child(mixer)
	world.add_child(player_actor_node)

func get_player_actor():
	return world.get_node_or_null(Runtime.PLAYER_ACTOR_ID)
	
func place_node_in_front(node: Node2D):
	var staged = get_staged_node()
	if staged:
		get_player_actor().get_node("PlayerActorMixer/BlockPlaced").play()
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
	just_canceled = false

func stage_node_in_front(node: Node2D):
	free_staged_assembly()
	node.snap_to_grid(get_player_actor().get_front(node.size), Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
	node.get_node("Sprite").modulate.a = Runtime.OPACITY
	node.add_to_group(Runtime.STAGED)
	world.add_child(node) 
	
func make_assembly(id: String):
	if !invalid_assembly_placement and Cache.get(Cache.selected_resource) > 0 and !just_canceled:
		var assembly_node = Runtime.call("make_%s_node" % id)
		assembly_node.set_collision_layer_value(2, 1)
		assembly_node.set_collision_layer_value(3, 1)
		assembly_node.set_collision_layer_value(4, 1)
		assembly_node.connect("tree_entered", func(): Cache.set(Cache.selected_resource, Cache.get(Cache.selected_resource) - 1))
		place_node_in_front(assembly_node)
		assembly_node.snap_to_grid(assembly_node.position, Runtime.GRID_SIZE, Runtime.GRID_OFFSET)
		var x_coord = int(assembly_node.position.x) / int(Runtime.GRID_SIZE.x)
		var y_coord = int(assembly_node.position.y) / int(Runtime.GRID_SIZE.y)
		assembly_node.coords = Vector2i(x_coord, y_coord)
		assembly_node.add_to_group(str(assembly_node.coords))

		assembly_node.connect("tree_exiting", get_player_actor().get_node("PlayerActorMixer/BlockRemoved").play)
	free_staged_assembly()
	
func stage_assembly(id: String):
	free_staged_assembly()
	if Cache.get(Cache.selected_resource) > 0:
		get_player_actor().set_state("tool")
		var assembly_node = Runtime.call("make_%s_node" % id)
		assembly_node.get_node("Area").set_collision_layer_value(2, 1)
		assembly_node.get_node("Area").set_collision_mask_value(1, 1)
		assembly_node.get_node("Area").set_collision_mask_value(2, 1)
		assembly_node.on_area_entered_hooks.append(handle_body_entered_staged_assembly)
		assembly_node.on_area_exited_hooks.append(handle_body_exited_staged_assembly)
		assembly_node.remove_from_group("resource")
		var timer = Timer.new()
		timer.autostart = true
		timer.wait_time = Runtime.LOADER_TEMPERATURE_CONSUMPTION_RATE
		var compute_increase_temperature = func increase_temperature():
			Cache.temperature = clamp(Cache.temperature + Runtime.LOADER_TEMPERATURE_CONSUMPTION_VALUE, Runtime.TEMPERATURE_MIN, Runtime.TEMPERATURE_MAX)
			if Cache.temperature >= Runtime.TEMPERATURE_MAX:
				assembly_node.queue_free()
		timer.connect("timeout", compute_increase_temperature)		
		assembly_node.add_child(timer)
		stage_node_in_front(assembly_node)
	else:
		new_transmission("> insuffucient %s" % {
			"ore": "Tilium Ore",
			"gas": "Plasma Gas",
			"bio": "Biomass",
			"cry": "Warp Crystal"
		}.get(Cache.selected_resource), Color(1, 0.5, 0))

func handle_body_entered_staged_assembly(_body):
	invalid_assembly_placement = true
	get_staged_node().get_node("Sprite").set_modulate(Runtime.INVALID_COLOR)
		
func handle_body_exited_staged_assembly(_body):
	invalid_assembly_placement = false
	get_staged_node().get_node("Sprite").set_modulate(Color(1, 1, 1, Runtime.OPACITY))
	

func handle_movement_input():
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
		
func compute_node_placement(args: Dictionary):

	args["self"].position = get_player_actor().get_front(Vector2(16, 16))
	
func compute_node_self_destruct(args: Dictionary):
	if !emitting:
		args["self"].queue_free()

func handle_destructor_contact(node):
	match node.id:
		"drill":
			new_transmission("- Drill", Runtime.COLOR_GRAY)
		_:
			if node.id in Runtime.RECIPE.values():
				new_transmission("- %s" % Runtime.STRUCTURE_TITLE_MAP.get(node.id), Runtime.COLOR_GRAY)
	node.queue_free()
		
func destructor_emission():
	if !world.get_node_or_null(Runtime.EMITTER_ACTOR_ID):
		get_player_actor().get_node("PlayerActorMixer/Quake").play()
		get_player_actor().set_state("tool")
		var destructor_node = IsoKit.make_actor(Runtime.ASSETS, {
			"id": Runtime.EMITTER_ACTOR_ID,
			"name": Runtime.EMITTER_ACTOR_ID,
			"sprite": "destructor_sprite.sprite",
		})
		destructor_node.add_compute("ComputeDestructorNodePlacement", compute_node_placement)
		destructor_node.add_compute("ComputeDestructorNodeSelfDestruct", compute_node_self_destruct)
		destructor_node.get_node("Area").set_collision_mask_value(3, 1)
		destructor_node.on_area_entered_hooks.append(handle_destructor_contact)
		var timer = Timer.new()
		timer.autostart = true
		timer.wait_time = Runtime.DESTRUCTOR_TEMPERATURE_CONSUMPTION_RATE
		var compute = func():
			Cache.temperature = clamp(Cache.temperature + Runtime.DESTRUCTOR_TEMPERATURE_CONSUMPTION_VALUE, Runtime.TEMPERATURE_MIN, Runtime.TEMPERATURE_MAX)
			Cache.fuel = clamp(Cache.fuel - Runtime.DESTRUCTOR_FUEL_CONSUMPTION_VALUE, Runtime.FUEL_MIN, Runtime.FUEL_MAX)
			if Cache.temperature >= Runtime.TEMPERATURE_MAX or Cache.fuel <= Runtime.FUEL_MIN:
				destructor_node.queue_free()
		timer.connect("timeout", compute)		
		destructor_node.add_child(timer)
		world.add_child(destructor_node)
	
func handle_assembler_contact(node):
	if world.get_node_or_null(Runtime.EMITTER_ACTOR_ID):
		assembly_query.emit(node.coords)
		get_player_actor().get_node("PlayerActorMixer/StructurePlaced").play()
		world.get_node_or_null(Runtime.EMITTER_ACTOR_ID).queue_free()
		
func assembler_emission():
	if !world.get_node_or_null(Runtime.EMITTER_ACTOR_ID):
		get_player_actor().get_node("PlayerActorMixer/Quake").play()
		get_player_actor().set_state("tool")
		var assembler_node = IsoKit.make_actor(Runtime.ASSETS, {
			"id": Runtime.EMITTER_ACTOR_ID,
			"name": Runtime.EMITTER_ACTOR_ID,
			"sprite": "assembler_sprite.sprite",
		})
		assembler_node.add_compute("ComputeAssemblerNodePlacement", compute_node_placement)
		assembler_node.add_compute("ComputeAssemblerNodeSelfDestruct", compute_node_self_destruct)
		assembler_node.set_collision_layer_value(1, 0)
		assembler_node.get_node("Area").set_collision_mask_value(4, 1)
		assembler_node.on_area_entered_hooks.append(handle_assembler_contact)
		var timer = Timer.new()
		timer.autostart = true
		timer.wait_time = Runtime.ASSEMBLER_POWER_CONSUMPTION_RATE
		var compute_consume_power = func consume_power():
			Cache.power= clamp(Cache.power - Runtime.ASSEMBLER_POWER_CONSUMPTION_VALUE, Runtime.POWER_MIN, Runtime.POWER_MAX)
			if Cache.power <= Runtime.POWER_MIN:
				assembler_node.queue_free()
		timer.connect("timeout", compute_consume_power)		
		assembler_node.add_child(timer)
		world.add_child(assembler_node)
	
func revoke_destructor_emission():
	var destructor_node = world.get_node_or_null(Runtime.EMITTER_ACTOR_ID)
	if destructor_node:
		destructor_node.queue_free()
		
func stage_drill():
	free_staged_assembly()
	if Cache.drills > 0:
		get_player_actor().set_state("tool")
		var drill_node = Runtime.call("make_drill_node")	
		drill_node.get_node("Area").set_collision_layer_value(2, 1)
		drill_node.get_node("Area").set_collision_mask_value(1, 1)
		drill_node.get_node("Area").set_collision_mask_value(2, 1)
		drill_node.on_area_entered_hooks.append(handle_body_entered_staged_assembly)
		drill_node.on_area_exited_hooks.append(handle_body_exited_staged_assembly)
		stage_node_in_front(drill_node)
	
func make_drill():
	player_actor_mixer_stop()
	if !invalid_assembly_placement and Cache.drills > 0:
		new_transmission("+ Drill", Runtime.COLOR_GRAY)
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
		drill_node.add_child(DrillAudio.instantiate())
	free_staged_assembly()

func handle_action_input():
	if Input.is_action_just_pressed("action_1"):
		stage_drill()
	elif Input.is_action_just_released("action_1"):
		make_drill()
		player_actor_mixer_stop()

	if Input.is_action_just_pressed("action_2"):
		stage_assembly(Cache.selected_resource)
	elif Input.is_action_just_released("action_2"):
		make_assembly(Cache.selected_resource)
		player_actor_mixer_stop()

		
	emitting = Input.is_action_pressed("action_3") or Input.is_action_pressed("action_4")
	if !Input.is_action_pressed("action_3") or !Input.is_action_pressed("action_4"):
		if Input.is_action_pressed("action_3"):
			destructor_emission()
		elif Input.is_action_just_released("action_3"):
			player_actor_mixer_stop()
		if Input.is_action_just_pressed("action_4"):
			assembler_emission()
		elif Input.is_action_just_released("action_4"):
			player_actor_mixer_stop()
			
	
	
	if Input.is_action_just_released("cancel"):
		just_canceled = true
		free_staged_assembly()
		
	if Input.is_action_just_pressed("switch_right"):
		var index = (Runtime.RESOURCES.find(Cache.selected_resource) + 1) % Runtime.RESOURCES.size()
		Cache.selected_resource = Runtime.RESOURCES[index]
		new_transmission("> loading %s" % Runtime.RESOURCE_TITLE_MAP.get(Cache.selected_resource), Runtime.COLOR_GRAY)
		
	if Input.is_action_just_pressed("switch_left"):
		var index = (Runtime.RESOURCES.find(Cache.selected_resource) - 1) % Runtime.RESOURCES.size()
		Cache.selected_resource = Runtime.RESOURCES[index]
		new_transmission("> loading %s" % Runtime.RESOURCE_TITLE_MAP.get(Cache.selected_resource), Runtime.COLOR_GRAY)
		
		
		
		


func _on_transmission_cooldown_timeout():
	transmission_cooling_down = false
