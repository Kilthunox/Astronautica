extends CanvasLayer

@onready var player = get_node("../Player")

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
	handle_warning_transmissions()
	
func handle_warning_transmissions():
	if is_equal_approx(power_meter.value, Runtime.POWER_WARNING_VALUE):
		player.new_transmission(">power levels at %s percent" % ((Cache.power / Runtime.POWER_MAX) * 100))
	elif is_equal_approx(power_meter.value, Runtime.POWER_CRITICAL_WARNING_VALUE):
		player.new_transmission("!power levels at %s percent" % ((Cache.power / Runtime.POWER_MAX) * 100), Runtime.COLOR_RED)
	elif is_equal_approx(power_meter.value, Runtime.POWER_MIN + 1):
		player.new_transmission("!power lost, shutting down drilling and oxygen production", Runtime.COLOR_RED)
		
	if is_equal_approx(temperature_meter.value, Runtime.TEMPERATURE_WARNING_VALUE):
		player.new_transmission(">temperature levels at %s percent" % ((Cache.temperature / Runtime.TEMPERATURE_MAX) * 100))
	elif is_equal_approx(temperature_meter.value, Runtime.TEMPERATURE_CRITICAL_WARNING_VALUE):
		player.new_transmission("!temperature levels at %s percent" % ((Cache.temperature / Runtime.TEMPERATURE_MAX) * 100), Runtime.COLOR_RED)
	elif is_equal_approx(temperature_meter.value, Runtime.TEMPERATURE_MAX):
		player.new_transmission("!plasma reactor overheat", Runtime.COLOR_RED)
		
	if is_equal_approx(fuel_meter.value, Runtime.FUEL_WARNING_VALUE):
		player.new_transmission(">fuel levels at %s percent" % ((Cache.fuel / Runtime.FUEL_MAX) * 100))
	elif is_equal_approx(fuel_meter.value, Runtime.FUEL_CRITICAL_WARNING_VALUE):
		player.new_transmission("!fuel levels at %s percent" % ((Cache.fuel / Runtime.FUEL_MAX) * 100), Runtime.COLOR_RED)
	elif is_equal_approx(fuel_meter.value, Runtime.FUEL_MIN + 1):
		player.new_transmission("!fuel is empty, shutting down plasma reactors", Runtime.COLOR_RED)
		
	if is_equal_approx(oxygen_meter.value, Runtime.OXYGEN_WARNING_VALUE):
		player.new_transmission(">oxygen levels at %s percent" % ((Cache.oxygen / Runtime.OXYGEN_MAX) * 100))
	elif is_equal_approx(oxygen_meter.value, Runtime.OXYGEN_CRITICAL_WARNING_VALUE):
		player.new_transmission("!oxygen levels at %s percent" % ((Cache.oxygen / Runtime.OXYGEN_MAX) * 100), Runtime.COLOR_RED)
	elif is_equal_approx(oxygen_meter.value, Runtime.OXYGEN_MIN + 1):
		player.new_transmission("!you have run out of oxygen", Runtime.COLOR_RED)

func _on_button_0_button_down():
	Cache.selected_resource = "ore"
	player.new_transmission("> loading tilium ore")


func _on_button_1_button_down():
	Cache.selected_resource = "gas"
	player.new_transmission("> loading plasma gas")


func _on_button_2_button_down():
	Cache.selected_resource = "bio"
	player.new_transmission("> loading biomass")


func _on_button_3_button_down():
	Cache.selected_resource = "cry"
	player.new_transmission("> loading warp crystal")

func _on_button_4_button_down():
	var index = (Runtime.RESOURCES.find(Cache.selected_resource) + 1) % Runtime.RESOURCES.size()
	Cache.selected_resource = Runtime.RESOURCES[index]
	player.new_transmission("> loading %s" % Runtime.RESOURCE_TITLE_MAP.get(Cache.selected_resource))

		
