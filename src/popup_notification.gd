extends MarginContainer

@onready var exit_button = get_node("VBoxContainer/ExitButton")
@onready var label = get_node("VBoxContainer/Label")
var message

func popup(message: String):
	self.message = message
	$WinDelay.start()


func _on_continue_button_button_down():
	hide()


func _on_exit_button_button_down():
	pass
#	get_tree().change_scene_to_file("res://src/splash.tscn")


func _on_win_delay_timeout():
	if exit_button and label:
		show()
		exit_button.focus()
		label.set_text(message)
