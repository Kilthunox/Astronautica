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
	Cache.mission_description = $HBoxContainer/VBoxContainer1/HBoxContainer/Label0.text
	Cache.zone = "mission0.zone"
	Cache.tilemap = "mission0.tilemap"
	Cache.win_conditions = {
		"fabricator": 1,
		"oxygen_farm": 1,
		"solar_panel": 1,
		"refinery": 1,
		"plasma_reactor": 1,
	}
	Cache.oxygen = 100
	Cache.power = 100
	Cache.fuel = 100
	Cache.temperature = 0
	Cache.ore = 0
	Cache.bio = 0
	Cache.cry = 0
	Cache.gas = 0
	get_tree().change_scene_to_file("res://src/instance.tscn")


func _on_mission_button_1_button_down():
	Cache.mission_description = $HBoxContainer/VBoxContainer1/HBoxContainer/Label1.text
	Cache.zone = "mission1.zone"
	Cache.tilemap = "mission1.tilemap"
	Cache.win_conditions = {
		"oxygen_farm": 3,
		"refinery": 1,
		"plasma_reactor": 1,
	}
	Cache.oxygen = 75
	Cache.power = 50
	Cache.fuel = 50
	Cache.temperature = 0
	Cache.ore = 0
	Cache.bio = 0
	Cache.cry = 0
	Cache.gas = 0
	get_tree().change_scene_to_file("res://src/instance.tscn")


func _on_mission_button_2_button_down():
	Cache.mission_description = $HBoxContainer/VBoxContainer1/HBoxContainer/Label2.text
	Cache.zone = "mission2.zone"
	Cache.tilemap = "mission2.tilemap"
	Cache.win_conditions = {
		"fabricator": 6,
		"oxygen_farm": 1,
		"solar_panel": 2,
		"refinery": 1,
		"plasma_reactor": 1,
	}
	Cache.oxygen = 50
	Cache.power = 25
	Cache.fuel = 25
	Cache.temperature = 0
	Cache.ore = 0
	Cache.bio = 0
	Cache.cry = 0
	Cache.gas = 0
	get_tree().change_scene_to_file("res://src/instance.tscn")


func _on_mission_button_3_button_down():
	Cache.mission_description = $HBoxContainer/VBoxContainer1/HBoxContainer/Label3.text
	Cache.zone = "mission3.zone"
	Cache.tilemap = "mission3.tilemap"
	Cache.win_conditions = {
		"fabricator": 0,
		"oxygen_farm": 0,
		"solar_panel": 12,
		"refinery": 0,
		"plasma_reactor": 0,
	}
	Cache.oxygen = 25
	Cache.power = 20
	Cache.fuel = 10
	Cache.temperature = 0
	Cache.ore = 0
	Cache.bio = 0
	Cache.cry = 0
	Cache.gas = 0
	get_tree().change_scene_to_file("res://src/instance.tscn")
	
func _unhandled_input(_event):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().change_scene_to_file("res://src/menu.tscn")
