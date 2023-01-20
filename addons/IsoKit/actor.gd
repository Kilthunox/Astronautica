extends CharacterBody2D

const POSITION_PRESICION: float = 9.9
var polygon: PackedVector2Array
@onready var origin: Vector2 = position
@onready var destination: Vector2 = position
@onready var Self = preload("res://addons/IsoKit/IsoKit.gd").new()
@onready var area = get_node("Area")
var speed: float = 3000
var heading: Vector2
var state: String = "idle"
var threat: int
var coords: Vector2i
var id: String

var margin: Vector2
var size: Vector2
var rect: Rect2

var on_area_entered_hooks: Array[Callable] = []
var on_area_exited_hooks: Array[Callable] = []

signal state_change(state)

class ComputeProcess extends Node:
		var function: Callable
		var args: Dictionary
		
		func _physics_process(delta) -> void:
			args["delta"] = delta
			if self.function.call(self.args):
				self.queue_free()


func add_compute(id: String, function: Callable, args: Dictionary = {}):
	var cprocess: ComputeProcess = ComputeProcess.new()
	cprocess.args = args
	cprocess.args['self'] = self
	cprocess.name = id
	cprocess.function = function
	add_child(cprocess)

func set_compute(value: bool):
	propagate_call("set_physics_process", [value])
	
func build_collision_shapes():
	if polygon:
		var shape: CollisionPolygon2D = CollisionPolygon2D.new()
		shape.name = "CollisionShape"
		shape.set_polygon(polygon)
		add_child(shape.duplicate())
		$Area.add_child(shape.duplicate())

func _ready():
	y_sort_enabled = true

func build_rect() -> void:
	rect.size = size - margin 
	rect.position.x -= rect.size.x / 2
	rect.position.y -= rect.size.y
	
func sync_rect() -> void:
	rect.position = Vector2(position.x - rect.size.x / 2, position.y - rect.size.y)

func set_destination(value: Vector2):
	destination = value
	
func stop():
	set_destination(position)
	
func camera_lock():
	$Camera.set_current(true)
	
func set_heading(value: Vector2):
	heading = value
	destination = position + heading * speed
	
func set_state(value: String) -> void:
	state = value
	state_change.emit(value)


func handle_animation():
	$Sprite.set_animation("%s:%s" % [state, Self.map_radial(heading.angle())])


func handle_movement(delta):
	if (destination.distance_to(position) > 0) and state in ["idle", "run"]:
		velocity = heading * speed * delta * max(Self.isometric_factor(heading.angle()), 0.70)
	else:
		velocity = Vector2(0, 0)
		destination = position
	move_and_slide()
	
func handle_state() -> void:
	match state:
		'idle':
			if position.distance_to(destination) > POSITION_PRESICION:
				set_state('run')
				
		# TODO -- add walking
		'run': 
			if position.distance_to(destination) <= POSITION_PRESICION:
				set_state('idle')

func _physics_process(delta):
	sync_rect()
	handle_movement(delta)
	handle_state()
	handle_animation()
	
func set_sprite_frames(sprite_frames: SpriteFrames) -> void:
	$Sprite.set_sprite_frames(sprite_frames)

func get_direction():
	return Vector2(cos(heading.angle()), sin(heading.angle()))

func get_front(offset: Vector2 = Vector2(0, 0)):
	return position + get_direction() + (get_direction() * (offset) * IsoKit.isometric_factor(heading.angle()))
	
func snap_to_grid(at: Vector2i, grid_size: Vector2i, offset: Vector2i = Vector2i(0, 0)):
	position = IsoKit.snap_to_grid(position, at, grid_size, offset)


func _on_area_body_entered(body):
	for hook in on_area_entered_hooks:
		hook.call(body)


func _on_area_body_exited(body):
	for hook in on_area_exited_hooks:
		hook.call(body)
