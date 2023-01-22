extends MarginContainer

@export var text: String
@export var start_with_focus: bool

signal button_down()
signal on_focus()
signal text_changed(new_text)

func focus():
	$Control/Button.grab_focus()

func set_text(new_text):
	text = new_text
	text_changed.emit(new_text)
	$Control/Button.set_text(new_text)

func _ready():
	$Control/Label.hide()
	$Control/Button.set_text(text)
	if start_with_focus:
		$Control/Button.grab_focus()

func _on_button_focus_entered():
	$Control/Label.show()
	$FocusSound.play()
	on_focus.emit()


func _on_button_focus_exited():
	$Control/Label.hide()


func _on_button_button_down():
	button_down.emit()
