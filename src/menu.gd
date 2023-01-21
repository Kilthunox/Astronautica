extends Control

func _ready():
	name = "InGameMenu"

func _on_missions_button_button_down():
	get_tree().change_scene_to_file("res://src/missions.tscn")


func _on_settings_button_button_down():
	get_tree().change_scene_to_file("res://src/settings.tscn")
		
		
func _unhandled_input(_event):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().change_scene_to_file("res://src/splash.tscn")


func _on_credits_button_button_down():
	get_tree().change_scene_to_file("res://src/credits.tscn")
