extends Control


func _on_continue_button_button_down():
	queue_free()


func _on_exit_button_button_down():
	get_tree().change_scene_to_file("res://src/splash.tscn")
