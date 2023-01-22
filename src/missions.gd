extends MarginContainer

var mission_labels: Array = [
	"HBoxContainer/VBoxContainer1/HBoxContainer/Label0",
	"HBoxContainer/VBoxContainer1/HBoxContainer/Label1",
	"HBoxContainer/VBoxContainer1/HBoxContainer/Label2",
	"HBoxContainer/VBoxContainer1/HBoxContainer/Label3",
]
# Called when the node enters the scene tree for the first time.
func _ready():
	hide_all()
	$HBoxContainer/VBoxContainer1/HBoxContainer/Label0.show()
	
func hide_all():
	for label in mission_labels:
		get_node(label).hide()
		
func set_label(i: int):
	hide_all()
	get_node(mission_labels[i]).show()
	

func _on_mission_button_0_on_focus():
	set_label(0)


func _on_mission_button_1_on_focus():
	set_label(1)


func _on_mission_button_2_on_focus():
	set_label(2)


func _on_mission_button_3_on_focus():
	set_label(3)


func _on_mission_button_0_button_down():
	Cache.zone = "mission0.zone"
	Cache.tilemap = "mission0.tilemap"
	Cache.win_conditions = {
		"fabricator": 1,
		"oxygen_farm": 1,
	}
	get_tree().change_scene_to_file("res://src/instance.tscn")


func _on_mission_button_1_button_down():
	Cache.zone = "mission1.zone"
	Cache.tilemap = "mission1.tilemap"
	get_tree().change_scene_to_file("res://src/instance.tscn")


func _on_mission_button_2_button_down():
	Cache.zone = "mission2.zone"
	Cache.tilemap = "mission2.tilemap"
	get_tree().change_scene_to_file("res://src/instance.tscn")


func _on_mission_button_3_button_down():
	Cache.zone = "mission3.zone"
	Cache.tilemap = "mission3.tilemap"
	get_tree().change_scene_to_file("res://src/instance.tscn")
	
func _unhandled_input(_event):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().change_scene_to_file("res://src/menu.tscn")
