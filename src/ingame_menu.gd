extends MarginContainer
var active_struct: int = 0

func _ready():
	$Structures.hide()
	$Mission.hide()
	$Controls.hide()
	$Resources.hide()
	$Tools.hide()
	$Gauges.hide()
	$Mission/Label.set_text(Cache.mission_description)
	$Main.show()
	
	
func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
		
	if Input.is_action_just_pressed("left"):
		decrement_structure()
	elif Input.is_action_just_pressed("right"):
		increment_structure()


func _on_exit_button_button_down():
	get_tree().change_scene_to_file("res://src/splash.tscn")


func _on_mission_button_button_down():
	$Main.hide()
	$Mission.show()



func _on_controls_button_button_down():
	$Main.hide()
	$Controls.show()


func _on_resources_button_button_down():
	$Main.hide()
	$Resources.show()


func _on_structures_button_down():
	$Main.hide()
	$Structures.show()
	
func _on_tools_button_button_down():
	$Main.hide()
	$Tools.show()


func _on_gauges_button_button_down():
	$Main.hide()
	$Gauges.show()
	
func increment_structure():
	active_struct = min((active_struct + 1), 4)
	for i in range(0, 5):
		if i != active_struct:
			$Structures.get_node("Struct%s" % i).hide()
		else:
			$Structures.get_node("Struct%s" % i).show()
			
func decrement_structure():
	active_struct = max((active_struct - 1), 0)
	for i in range(0, 5):
		if i != active_struct:
			$Structures.get_node("Struct%s" % i).hide()
		else:
			$Structures.get_node("Struct%s" % i).show()
			


func _on_left_button_button_down():
	decrement_structure()


func _on_right_button_button_down():
	increment_structure()
	
	
