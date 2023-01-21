extends MarginContainer


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
