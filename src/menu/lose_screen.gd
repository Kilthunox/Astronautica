extends Control

	
func _unhandled_input(_event):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().change_scene_to_file("res://src/menu.tscn")
