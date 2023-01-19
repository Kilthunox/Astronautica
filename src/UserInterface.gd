extends CanvasLayer

@onready var ore_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button0")
@onready var gas_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button1")
@onready var bio_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button2")
@onready var cry_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button3")
@onready var toggle_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button4")
@onready var drill_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button6")
# Called every frame. 'delta' is the elapsed time since the previous frame.
@export var OxygenMeterNodePath: NodePath
@onready var oxygen_meter = get_node(OxygenMeterNodePath)
@export var PowerMeterNodePath: NodePath
@onready var power_meter = get_node(PowerMeterNodePath)
@export var FuelMeterNodePath: NodePath
@onready var fuel_meter = get_node(FuelMeterNodePath)
@export var TemperatureMeterNodePath: NodePath
@onready var temperature_meter = get_node(TemperatureMeterNodePath)

func _ready():
	oxygen_meter.set_max(Runtime.OXYGEN_MAX)
	oxygen_meter.set_min(Runtime.OXYGEN_MIN)
	power_meter.set_max(Runtime.POWER_MAX)
	power_meter.set_min(Runtime.POWER_MIN)
	fuel_meter.set_max(Runtime.FUEL_MAX)
	fuel_meter.set_min(Runtime.FUEL_MIN)
	temperature_meter.set_max(Runtime.TEMPERATURE_MAX)
	temperature_meter.set_min(Runtime.TEMPERATURE_MIN)
	handle_toggle_texture()


func handle_toggle_texture():
	match Cache.selected_resource:
		"ore":
			toggle_button.icon = ore_button.icon
		"gas":
			toggle_button.icon = gas_button.icon
		"bio":
			toggle_button.icon = bio_button.icon
		"cry":
			toggle_button.icon = cry_button.icon

func _process(_delta):
	handle_toggle_texture()
	oxygen_meter.value = Cache.oxygen
	power_meter.value = Cache.power
	fuel_meter.value = Cache.fuel
	temperature_meter.value = Cache.temperature
	ore_button.set_text(str(Cache.ore))
	gas_button.set_text(str(Cache.gas))
	bio_button.set_text(str(Cache.bio))
	cry_button.set_text(str(Cache.cry))
	drill_button.set_text(str(Cache.drills))


func _on_button_0_button_down():
	Cache.selected_resource = "ore"


func _on_button_1_button_down():
	Cache.selected_resource = "gas"


func _on_button_2_button_down():
	Cache.selected_resource = "bio"


func _on_button_3_button_down():
	Cache.selected_resource = "cry"


func _on_button_4_button_down():
	var index = (Runtime.RESOURCES.find(Cache.selected_resource) + 1) % Runtime.RESOURCES.size()
	Cache.selected_resource = Runtime.RESOURCES[index]
