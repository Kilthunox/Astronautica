extends Control


func _input(event: InputEvent) -> void:
	if event.is_pressed() and !Input.is_action_just_pressed('ui_cancel'):
		get_tree().change_scene_to_file("res://src/menu.tscn")
	elif Input.is_action_just_pressed('ui_cancel'):
		get_tree().quit()
