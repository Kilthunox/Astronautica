extends Node

func _ready():
	$Timer.wait_time = Runtime.TICK_RATE

func _on_timer_timeout():
	Cache.oxygen = clamp(Cache.oxygen - (Runtime.OXYGEN_LOSS_VALUE), Runtime.OXYGEN_MIN, Runtime.OXYGEN_MAX)
	Cache.temperature = clamp(Cache.temperature - Runtime.TEMPERATURE_DROP_VALUE, Runtime.TEMPERATURE_MIN, Runtime.TEMPERATURE_MAX)
	if Cache.oxygen <= Runtime.OXYGEN_MIN:
		if randi() % Runtime.SAVING_CHANCE == 0:
			get_tree().change_scene_to_file("res://src/menu/lose_screen.tscn")
