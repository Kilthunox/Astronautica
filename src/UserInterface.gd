extends CanvasLayer

@onready var ore_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button0")
@onready var gas_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button1")
@onready var bio_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button2")
@onready var cry_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button3")
@onready var drill_button = get_node("MarginContainer/HBox/VBox2/VBox1/VBox0/HBox0/VBox/Grid/Button7")
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


func _process(_delta):
	oxygen_meter.value = Cache.oxygen
	power_meter.value = Cache.power
	fuel_meter.value = Cache.fuel
	temperature_meter.value = Cache.temperature
	ore_button.set_text(str(Cache.ore) + " ")
	gas_button.set_text(str(Cache.gas) + " ")
	bio_button.set_text(str(Cache.bio) + " ")
	cry_button.set_text(str(Cache.cry) + " ")
	drill_button.set_text(str(Cache.drills) + " ")


func _on_button_0_button_down():
	Cache.selected_resource = "ore"


func _on_button_1_button_down():
	Cache.selected_resource = "gas"


func _on_button_2_button_down():
	Cache.selected_resource = "bio"


func _on_button_3_button_down():
	Cache.selected_resource = "cry"
