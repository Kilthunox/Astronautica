extends Node
@onready var InGameMenu: PackedScene = preload("res://src/ingame_menu.tscn")

func _ready():
	$TickRateTimer.wait_time = Runtime.TICK_RATE

func handle_temperature():
	if Cache.temperature >= Runtime.TEMPERATURE_MAX - 1:
		Cache.fuel = 0.0	
		Cache.power = 0.0
		Cache.oxygen = Cache.oxygen / 2
		var structures = get_tree().get_nodes_in_group("structure")

		if structures:
			randomize()
			var random_structure = structures[randi() % structures.size()]
			random_structure.queue_free()
			$Player.new_transmission("! %s has been destroyed" % Runtime.STRUCTURE_TITLE_MAP.get(random_structure.id), Runtime.COLOR_RED)
	Cache.temperature = clamp(Cache.temperature - Runtime.TEMPERATURE_DROP_VALUE, Runtime.TEMPERATURE_MIN, Runtime.TEMPERATURE_MAX)

		
func handle_oxygen():
	Cache.oxygen = clamp(Cache.oxygen - (Runtime.OXYGEN_LOSS_VALUE), Runtime.OXYGEN_MIN, Runtime.OXYGEN_MAX)
	if Cache.oxygen <= Runtime.OXYGEN_MIN:
		randomize()
		if randi() % Runtime.SAVING_CHANCE == 0:
			get_tree().change_scene_to_file("res://src/menu/lose_screen.tscn")

func _on_timer_timeout():
	handle_oxygen()
	handle_temperature()


func _on_audio_track_timer_timeout():
	$BackgroundAudio.play()
	
func toggle_menu():
	if !$UserInterface.has_node("InGameMenu"):
		$UserInterface.add_child(InGameMenu.instantiate())
	else:
		$UserInterface.get_node("InGameMenu").queue_free()
	
	
func _input(_event):
	if Input.is_action_just_pressed("start"):
		toggle_menu()
		
