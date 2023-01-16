extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = Runtime.COMS_LINE_LIFETIME
	$Timer.start()


func _on_timer_timeout():
	queue_free()
