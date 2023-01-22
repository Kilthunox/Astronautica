extends Node
@onready var InGameMenu: PackedScene = preload("res://src/ingame_menu.tscn")
@onready var WinScreen: PackedScene = preload("res://src/win_screen.tscn")
var has_won = false

signal win

func _ready():
	$TickRateTimer.wait_time = Runtime.TICK_RATE

func reset_win_conditions():
	Cache.win_conditions = {}

func _process(_delta):	
	var results = 0
	for condition in Cache.win_conditions.keys():
		if Cache.win_conditions[condition] <= get_tree().get_nodes_in_group(condition).size():
			results += 1
	if results >= Cache.win_conditions.size() and Cache.win_conditions.size() > 0:
		win.emit()		

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
		


func _on_win():
	if $WinTimer.is_stopped():
		$WinTimer.start()


func _on_win_timer_timeout():
	$Player.new_transmission("MISSISON COMPLETE!", Color(0.3, 1, 0.3))
	Cache.win_conditions = {}
	$UserInterface.add_child(WinScreen.instantiate())
