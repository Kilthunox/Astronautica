extends CharacterBody2D

const POSITION_PRESICION: float = 9.9

@onready var origin: Vector2 = position
@onready var destination: Vector2 = position
var speed: float = 3000
var heading: Vector2
var state: String = "idle"
var threat: int
var base: Vector2

var margin: Vector2
var size: Vector2
var rect: Rect2

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
	
func set_heading(value: Vector2):
	heading = value
	destination = position + heading * speed
	
func set_state(value: String) -> void:
	state = value


func handle_animation():
	$AnimatedSprite.set_animation("%s:%s" % [state, IsoKit.map_radial(heading.angle())])


func handle_movement(delta):
	if (destination.distance_to(position) > 0):
		velocity = heading * speed * delta * IsoKit.isometric_factor(heading.angle())
#		$AnimatedSprite.set_animation("%s:%s" % [state, IsoKit.map_radial(velocity.angle())])
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
	$AnimatedSprite.set_sprite_frames(sprite_frames)
#	$Outline.set_sprite_frames(sprite_frames)
