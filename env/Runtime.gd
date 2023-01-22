extends Node

const INT64_LIMIT: int = -9223372036854775807
const TRANSMISSIONS_QUEUE_SIZE: int = 12
const ASSETS: String = "res://assets/"
const PLAYER_ACTOR_ID: String = "PlayerActor"
const PLAYER_SPEED: float = 5500.0
const LOADER_SPEED: float = 3500.0
const EMITTER_ACTOR_ID: String = "EmitterActor"
const GRID_SIZE: Vector2i = Vector2i(16, 8)
const GRID_OFFSET: Vector2i = Vector2i(0, 0)
const STAGED: String = "StagedAssembly"
const OPACITY: float = 0.45
const INVALID_COLOR: Color = Color(1, 0.45, 0.45, 0.45)
const ASSEMBLY_COLOR: Color = Color(0.45, 0.45, 1, 1)
const ASSEMBLER_SPEED: float = 1000.0
const DRILL_RANGE: float = 100.0
const DRILL_GATHERING_INTERVAL: int = 4
const STARTING_TEMPERATURE: int = 0
const STARTING_OXYGEN: int = 50
const STARTING_POWER: int = 50
const STARTING_FUEL: int = 50
const COMS_LINE_LIFETIME: float = 6.6
const OXYGEN_MIN: float = 0.0
const OXYGEN_MAX: float = 100.0
const OXYGEN_LOSS_VALUE: float = 0.33
const TICK_RATE: float = 2.5
const OXYGEN_FARM_PRODUCTION_VALUE: int = 4
const OXYGEN_FARM_PRODUCTION_RATE: float = 3.3
const OXYGEN_FARM_POWER_CONSUMPTION: int = 2
const OXYGEN_FARM_BIO_CONSUMPTION_CHANCE: int = 4
const REACTOR_PRODUCTION_VALUE: int = 6
const REACTOR_PRODUCTION_RATE: float = 3.3
const REACTOR_CONSUMPTION_VALUE: int = 6
const REFINERY_PRODUCTION_VALUE: int = 8
const REFINERY_PRODUCTION_RATE: float = 3.3
const SOLAR_PANEL_PRODUCTION_VALUE: int = 3
const SOLAR_PANEL_PRODUCTION_RATE: float = 3.3
const SOLAR_PANEL_PRODUCTION_CHANCE: int = 3
const POWER_MIN: float = 0.0
const POWER_MAX: float = 100.0
const FUEL_MIN: float = 0.0
const FUEL_MAX: float = 100.0
const DRILL_CONSUMPTION_VALUE: int = 2
const DRILL_TEMP_INCREASE_VALUE: int = 1
const TEMPERATURE_MIN: float = 0.0
const TEMPERATURE_MAX: float = 100.0
const DESTRUCTOR_TEMPERATURE_CONSUMPTION_VALUE: int = 6
const DESTRUCTOR_TEMPERATURE_CONSUMPTION_RATE: float = 0.333
const DESTRUCTOR_FUEL_CONSUMPTION_VALUE: int = 1
const LOADER_TEMPERATURE_CONSUMPTION_VALUE: int = 3
const LOADER_TEMPERATURE_CONSUMPTION_RATE: float = 1.0
const ASSEMBLER_POWER_CONSUMPTION_VALUE: int = 3
const ASSEMBLER_POWER_CONSUMPTION_RATE: float = 0.333
const TEMPERATURE_DROP_VALUE: int = 3
const SAVING_CHANCE: int = 3
const MAX_DRILLS: int = 100
const MIN_DRILLS: int = 0
const RECIPE_RECURSION_LIMIT: int = 1001
const COLOR_GRAY: Color = Color(0.6, 0.6, 0.6)
const COLOR_RED: Color = Color(1, 0.3, 0.3)
const POWER_WARNING_VALUE: float = 20.0
const POWER_CRITICAL_WARNING_VALUE: float = 5.0
const FUEL_WARNING_VALUE: float = 20.0
const FUEL_CRITICAL_WARNING_VALUE: float = 5.0
const TEMPERATURE_WARNING_VALUE: float = 80.0
const TEMPERATURE_CRITICAL_WARNING_VALUE: float = 95.0
const OXYGEN_WARNING_VALUE: float = 20.0
const OXYGEN_CRITICAL_WARNING_VALUE: float = 5.0
const STRUCTURE_TITLE_MAP: Dictionary = {
	"oxygen_farm": "Oxygen Farm",
	"reactor": "Plasma Reactor",
	"solar_panel": "Solar Panel",
	"refinery": "Refinery",
	"fabricator": "Fabricator",
}
const RESOURCE_TITLE_MAP: Dictionary = {
	"ore": "Tilium Ore",
	"bio": "Biomass",
	"gas": "Plasma Gas",
	"cry": "Warp Crystal"
}
const STATIC_ACTORS: Array = [
	"ore",
	"bio",
	"cry",
	"gas",
	"dirt",
	"rock",
	"oxygen_farm",
	"refinery",
	"reactor",
	"solar_panel",
	"fabricator",
	"drill",
]
			
var RESOURCES = ["ore", "gas", "bio",  "cry"]
var RECIPE: Dictionary = {
	{
		Vector2i(-3, -3): "ore",
		Vector2i(-4, -4): "bio",
		Vector2i(-2, -2): "bio",
		Vector2i(-1, -3): "ore",
		Vector2i(0, -4): "bio",
		Vector2i(-3, -1): "ore",
		Vector2i(-4, 0): "bio",
		Vector2i(-1, -1): "ore",
		Vector2i(0, 0): "bio",
	}: "oxygen_farm",
	{
		Vector2i(-1, -4): "ore",
		Vector2i(-2, -3): "gas",
		Vector2i(-3, -4): "ore",
		Vector2i(-4, -3): "ore",
		Vector2i(-3, -2): "cry",
		Vector2i(-4, -1): "ore",
		Vector2i(-3, 0): "ore",
		Vector2i(-2, -1): "gas",
		Vector2i(-1, -2): "cry",
		Vector2i(0, -3): "ore",
		Vector2i(0, -1): "ore",
		Vector2i(-1, 0): "ore",
	}: "reactor",
	{
		Vector2i(-1, -4): "ore",
		Vector2i(-2, -3): "cry",
		Vector2i(-3, -4): "ore",
		Vector2i(-4, -3): "ore",
		Vector2i(-3, -2): "gas",
		Vector2i(-4, -1): "ore",
		Vector2i(-3, 0): "ore",
		Vector2i(-2, -1): "cry",
		Vector2i(-1, -2): "gas",
		Vector2i(0, -3): "ore",
		Vector2i(0, -1): "ore",
		Vector2i(-1, 0): "ore",
	}: "reactor",
	{
		Vector2i(-5, -3): "ore",
		Vector2i(-4, -4): "ore",
		Vector2i(-3, -3): "ore",
		Vector2i(-4, -2): "gas",
		Vector2i(-5, -1): "ore",
		Vector2i(-6, -2): "ore",
		Vector2i(-4, 0): "ore",
		Vector2i(-3, -1): "ore",
		Vector2i(-2, -2): "ore",
		Vector2i(-1, -3): "ore",
		Vector2i(0, -2): "gas",
		Vector2i(-1, -1): "ore",
	}: "refinery",
	{
		Vector2i(0, -1): "ore",
		Vector2i(-1, -2): "ore", 
		Vector2i(-2, -1): "ore", 
		Vector2i(-1, 0): "ore",
	}: "fabricator",
	{
		Vector2i(-2, -1): "cry",
		Vector2i(-1, -2): "ore",
		Vector2i(0, -1): "cry",
		Vector2i(-1, 0): "ore",
	}: "solar_panel",
	{
		Vector2i(-1, 0): "cry",
		Vector2i(-2, -1): "ore",
		Vector2i(-1, -2): "cry",
		Vector2i(0, -1): "ore",
	}: "solar_panel",
}


func make_oxygen_farm_node():
	var oxygen_farm_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "oxygen_farm",
		"name": "OxygenFarmActor0",
		"sprite": "oxygen_farm.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	oxygen_farm_node.add_to_group("oxygen_farm")
	oxygen_farm_node.add_to_group("structure")
	var timer = Timer.new()
	var compute_produce_oxygen = func produce_oxygen():
		if Cache.power > Runtime.POWER_MIN:
			randomize()
			Cache.oxygen = clamp(Cache.oxygen + (randi() % Runtime.OXYGEN_FARM_PRODUCTION_VALUE), Runtime.OXYGEN_MIN, Runtime.OXYGEN_MAX)
			randomize()
			Cache.power = clamp(Cache.power - (randi() % Runtime.OXYGEN_FARM_POWER_CONSUMPTION), Runtime.POWER_MIN, Runtime.POWER_MAX)
			randomize()
			if randi() % Runtime.OXYGEN_FARM_BIO_CONSUMPTION_CHANCE == 0:
				Cache.bio -= 1
	timer.connect("timeout", compute_produce_oxygen)
	timer.wait_time = Runtime.OXYGEN_FARM_PRODUCTION_RATE
	timer.autostart = true
	oxygen_farm_node.add_child(timer)
	oxygen_farm_node.add_to_group("resource")
	return oxygen_farm_node
	
func make_refinery_node():
	var refinery_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "refinery",
		"name": "RefineryActor0",
		"sprite": "refinery.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	refinery_node.add_to_group("refinery")
	refinery_node.add_to_group("structure")
	var timer = Timer.new()
	var compute_produce_fuel = func produce_fuel():
		if Cache.gas > 0:
			randomize()
			Cache.fuel = clamp(Cache.fuel + (randi() % Runtime.REFINERY_PRODUCTION_VALUE), Runtime.FUEL_MIN, Runtime.FUEL_MAX)
			randomize()
			if randi() % 3 == 0:
				randomize()
				Cache.gas = max(Cache.gas - (randi() % 2), 0)
				
	timer.connect("timeout", compute_produce_fuel)
	timer.wait_time = Runtime.REFINERY_PRODUCTION_RATE
	timer.autostart = true
	refinery_node.add_child(timer)
	refinery_node.add_to_group("resource")
	return refinery_node

func make_reactor_node():
	var reactor_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "reactor",
		"name": "ReactorActor0",
		"sprite": "reactor.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	reactor_node.add_to_group("reactor")
	reactor_node.add_to_group("structure")
	var timer = Timer.new()
	var compute_produce_power = func():
		if Cache.fuel > Runtime.FUEL_MIN:
			randomize()
			Cache.power = clamp(Cache.power + (randi() % Runtime.REACTOR_PRODUCTION_VALUE), Runtime.POWER_MIN, Runtime.POWER_MAX)
			randomize()
			Cache.fuel = clamp(Cache.fuel - (randi() % Runtime.REACTOR_CONSUMPTION_VALUE), Runtime.FUEL_MIN, Runtime.FUEL_MAX)
	timer.connect("timeout", compute_produce_power)
	timer.wait_time = Runtime.REACTOR_PRODUCTION_RATE
	timer.autostart = true
	reactor_node.add_child(timer)
	reactor_node.add_to_group("resource")
	return reactor_node
	
	
	
func make_solar_panel_node():
	var solar_panel_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "solar_panel",
		"name": "SolarPanel0",
		"sprite": "solar_panel.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	solar_panel_node.add_to_group("reactor")
	solar_panel_node.add_to_group("structure")
	var timer = Timer.new()
	var compute_produce_power = func():
		randomize()
		if randi() % Runtime.SOLAR_PANEL_PRODUCTION_CHANCE:
			randomize()
			Cache.power = clamp(Cache.power + (randi() % Runtime.SOLAR_PANEL_PRODUCTION_VALUE), Runtime.POWER_MIN, Runtime.POWER_MAX)
	timer.connect("timeout", compute_produce_power)
	timer.wait_time = Runtime.SOLAR_PANEL_PRODUCTION_RATE
	timer.autostart = true
	solar_panel_node.add_child(timer)
	solar_panel_node.add_to_group("solar_panel")
	solar_panel_node.add_to_group("resource")
	return solar_panel_node
	
func make_fabricator_node():
	var fabricator_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "fabricator",
		"name": "FabricatorActor0",
		"sprite": "fabricator.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	fabricator_node.add_to_group("fabricator")
	fabricator_node.add_to_group("structure")
	fabricator_node.connect("tree_entered", func(): Cache.drills = min(Cache.drills + 1, Runtime.MAX_DRILLS))
	fabricator_node.connect("tree_exiting", func(): Cache.drills = max(Cache.drills - 1, Runtime.MIN_DRILLS))
	fabricator_node.add_to_group("resource")
	return fabricator_node


func make_drill_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": "drill",
		"name": "DrillActor0",
		"sprite": "drill.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	
	
func make_ore_node():
	var ore_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "ore",
		"name": "TiliumOreActor0",
		"sprite": "tilium_ore.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	ore_node.add_to_group("ore")
	ore_node.add_to_group("resource")
	return ore_node


func make_gas_node():
	var gas_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "gas",
		"name": "PlasmaGasActor0",
		"sprite": "plasma_gas.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	gas_node.add_to_group("gas")
	gas_node.add_to_group("resource")
	return gas_node
	
func make_bio_node():
	var bio_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "bio",
		"name": "BioMassActor0",
		"sprite": "biomass.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	bio_node.add_to_group("bio")
	bio_node.add_to_group("resource")
	return bio_node
	
func make_cry_node():
	var cry_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "cry",
		"name": "WarpCrystalActor0",
		"sprite": "warp_crystal.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	cry_node.add_to_group("cry")
	cry_node.add_to_group("resource")
	return cry_node
	
func make_dirt_node():
	var dirt_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "dirt",
		"name": "DirtActor",
		"sprite": "dirt.sprite"
	})
	dirt_node.add_to_group("dirt")
	dirt_node.add_to_group("resource")
	return dirt_node
	
func make_rock_node():
	var rock_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "rock",
		"name": "RockActor",
		"sprite": "rock.sprite"
	})
	rock_node.add_to_group("rock")
	rock_node.add_to_group("resource")
	return rock_node
	
	
