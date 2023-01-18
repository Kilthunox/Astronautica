extends Node

const ASSETS: String = "res://assets/"
const PLAYER_ACTOR_ID: String = "PlayerActor"
const PLAYER_SPEED: float = 4500.0
const LOADER_SPEED: float = 4500.0
const DESTRUCTOR_ACTOR_ID: String = "DestructorActor"
const ASSEMBLER_ACTOR_ID: String = "AssemblerActor"
const GRID_SIZE: Vector2i = Vector2i(16, 8)
const GRID_OFFSET: Vector2i = Vector2i(0, 0)
const STAGED: String = "StagedAssembly"
const OPACITY: float = 0.45
const INVALID_COLOR: Color = Color(1, 0.45, 0.45, 0.45)
const ASSEMBLY_COLOR: Color = Color(0.45, 0.45, 1, 1)
const ASSEMBLER_SPEED: float = 1000.0
const DRILL_RANGE: float = 100.0
const DRILL_GATHERING_INTERVAL: int = 1
const STARTING_TEMPERATURE: int = 0
const STARTING_OXYGEN: int = 25
const STARTING_POWER: int = 25
const STARTING_FUEL: int = 25
const COMS_LINE_LIFETIME: float = 16.6
const OXYGEN_MIN: float = 0.0
const OXYGEN_MAX: float = 200.0
const OXYGEN_LOSS_VALUE: float = 1.0
const TICK_RATE: float = 3.3
const OXYGEN_FARM_PRODUCTION_VALUE: int = 3
const OXYGEN_FARM_PRODUCTION_RATE: float = 3.3
const OXYGEN_FARM_POWER_CONSUMPTION: int = 3
const REACTOR_PRODUCTION_VALUE: int = 3
const REACTOR_PRODUCTION_RATE: float = 3.3
const REACTOR_CONSUMPTION_VALUE: int = 3
const REFINERY_PRODUCTION_VALUE: int = 3
const REFINERY_PRODUCTION_RATE: float = 3.3
const SOLAR_PANEL_PRODUCTION_VALUE: int = 3
const SOLAR_PANEL_PRODUCTION_RATE: float = 3.3
const SOLAR_PANEL_PRODUCTION_CHANCE: int = 3
const POWER_MIN: float = 0.0
const POWER_MAX: float = 100.0
const FUEL_MIN: float = 0.0
const FUEL_MAX: float = 100.0
const DRILL_FUEL_CONSUMPTION_VALUE: int = 3
const TEMPERATURE_MIN: float = 0.0
const TEMPERATURE_MAX: float = 100.0
const DESTRUCTOR_TEMPERATURE_CONSUMPTION_VALUE: int = 6
const DESTRUCTOR_TEMPERATURE_CONSUMPTION_RATE: float = 0.333
const LOADER_TEMPERATURE_CONSUMPTION_VALUE: int = 3
const LOADER_TEMPERATURE_CONSUMPTION_RATE: float = 1.0
const ASSEMBLER_POWER_CONSUMPTION_VALUE: int = 3
const ASSEMBLER_POWER_CONSUMPTION_RATE: float = 0.333
const TEMPERATURE_DROP_VALUE: int = 3
const SAVING_CHANCE: int = 3
const ORE_QUANTITY_RANGE: int = 3
const GAS_QUANTITY_RANGE: int = 2
const BIO_QUANTITY_RANGE: int = 1
const CRY_QUANTITY_RANGE: int = 1
const MAX_DRILLS: int = 12
const MIN_DRILLS: int = 0

enum STRUCTURE {
	BASE_STATION,
	SHUTTLE,
	POWER_PLANT,
	OXYGEN_FARM,
	REFINERY,
	VAPOR_COLLECTOR
}


var RESOURCES = ["ore", "bio", "gas", "cry"]
var RECIPE: Dictionary = {
	{
		Vector2i(0, 2): "ore",
		Vector2i(0, 0): "ore", 
		Vector2i(1, 1): "bio", 
		Vector2i(2, 2): "ore",
		Vector2i(2, 0): "ore",
	}: "oxygen_farm",
		{
		Vector2i(0, 2): "ore",
		Vector2i(0, 0): "ore", 
		Vector2i(1, 1): "gas", 
		Vector2i(2, 2): "ore",
		Vector2i(2, 0): "ore",
	}: "reactor",
	{
		Vector2i(0, 2): "gas",
		Vector2i(0, 0): "gas", 
		Vector2i(1, 1): "ore", 
		Vector2i(2, 2): "gas",
		Vector2i(2, 0): "gas",
	}: "refinery",
	{
		Vector2i(0, 2): "ore",
		Vector2i(0, 0): "ore", 
		Vector2i(1, 1): "ore", 
		Vector2i(2, 2): "ore",
		Vector2i(2, 0): "ore",
	}: "fabricator",
	{
		Vector2i(0, 2): "ore",
		Vector2i(0, 0): "ore", 
		Vector2i(1, 1): "cry", 
		Vector2i(2, 2): "ore",
		Vector2i(2, 0): "ore",
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
	timer.connect("timeout", compute_produce_oxygen)
	timer.wait_time = Runtime.OXYGEN_FARM_PRODUCTION_RATE
	timer.autostart = true
	oxygen_farm_node.add_child(timer)
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
		if Cache.gas > 0 and Cache.ore > 0:
			randomize()
			Cache.fuel = clamp(Cache.fuel + (randi() % Runtime.REFINERY_PRODUCTION_VALUE), Runtime.FUEL_MIN, Runtime.FUEL_MAX)
			randomize()
			if randi() % 3 == 0:
				randomize()
				Cache.gas = max(Cache.gas - (randi() % 2), 0)
				randomize()
				Cache.ore = max(Cache.ore - (randi() % 2), 0)
	timer.connect("timeout", compute_produce_fuel)
	timer.wait_time = Runtime.REFINERY_PRODUCTION_RATE
	timer.autostart = true
	refinery_node.add_child(timer)
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
	return fabricator_node


func make_drill_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": "drill",
		"name": "DrillActor0",
		"sprite": "drill.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	
	
func make_ore_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": "ore",
		"name": "TiliumOreActor0",
		"sprite": "tilium_ore.sprite",
		"speed": Runtime.LOADER_SPEED,
	})


func make_gas_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": "gas",
		"name": "PlasmaGasActor0",
		"sprite": "plasma_gas.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	
func make_bio_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": "bio",
		"name": "BioMassActor0",
		"sprite": "biomass.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	
func make_cry_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": "cry",
		"name": "WarpCrystalActor0",
		"sprite": "warp_crystal.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
