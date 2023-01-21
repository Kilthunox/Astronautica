extends MarginContainer


var fullscreen_toggle_label_map = {
	Window.MODE_WINDOWED: "FULLSCREEN",
	Window.MODE_EXCLUSIVE_FULLSCREEN: "WINDOWED"
}

func _ready():
	refresh_toggle_label()

func refresh_toggle_label():
	$HBoxContainer/VBoxContainer0/FullscreenToggle.set_text(fullscreen_toggle_label_map.get(DisplayServer.window_get_mode()))
	
func _on_fullscreen_toggle_button_down():
	match DisplayServer.window_get_mode():
		Window.MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(Window.MODE_WINDOWED)
			refresh_toggle_label()
		Window.MODE_WINDOWED:
			DisplayServer.window_set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
			$HBoxContainer/VBoxContainer0/FullscreenToggle.set_text("FULLSCREEN")
			refresh_toggle_label()
		_:
			DisplayServer.window_set_mode(Window.MODE_WINDOWED)
			$HBoxContainer/VBoxContainer0/FullscreenToggle.set_text("FULLSCREEN")
			refresh_toggle_label()
			
func _unhandled_input(_event):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().change_scene_to_file("res://src/menu.tscn")

			
