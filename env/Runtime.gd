extends Node

const ASSETS: String = "res://assets/"
const PLAYER_ACTOR_ID: String = "PlayerActor"
const PLAYER_SPEED: float = 10000.0
const LOADER_SPEED: float = 5000.0
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
const OXYGEN_FARM_PRODUCTION_VALUE: float = 1.0
const OXYGEN_FARM_PRODUCTION_RATE: float = 3.3
const OXYGEN_FARM_POWER_CONSUMPTION: float = 1.0
const POWER_MIN: float = 0.0
const POWER_MAX: float = 100.0
const FUEL_MIN: float = 0.0
const FUEL_MAX: float = 100.0
const DRILL_FUEL_CONSUMPTION_VALUE: float = 1.0
const TEMPERATURE_MIN: float = 0.0
const TEMPERATURE_MAX: float = 100.0
const DESTRUCTOR_TEMPERATURE_CONSUMPTION_VALUE: float = 6.666
const DESTRUCTOR_TEMPERATURE_CONSUMPTION_RATE: float = 0.333
const TEMPERATURE_DROP_VALUE: float = 3.0
const SAVING_CHANCE: int = 3



enum STRUCTURE {
	BASE_STATION,
	SHUTTLE,
	POWER_PLANT,
	OXYGEN_FARM,
	REFINERY,
	VAPOR_COLLECTOR
}

enum RESOURCE {
	ORE,
	GAS,
	MAS,
	CRY,
	SPI
}
const ORE = "ore"
const GAS = "gas"
const MAS = "mass"
const CRY = "crystal"
const SPI = "spice"
#
var RECIPE: Dictionary = {
	{
		Vector2i(0, 0): ORE,
		Vector2i(1, 1): ORE,
		Vector2i(2, 2): ORE,
	}: "oxygen_farm",
#	{
#		Vector2i(0, 0): ORE,
#		Vector2i(1, 1): ORE,
#		Vector2i(2, 2): ORE,
#	}: "prototype_building",
}

func make_prototype_player_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": Runtime.PLAYER_ACTOR_ID,
		"name": "PlayerActor",
		"sprite": "prototype_sprite.sprite",
		"zone": "prototype_zone.zone",
		"spawn": "spawn",
		"speed": Runtime.LOADER_SPEED,
	})
	
func make_prototype_building_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": "prototype_building",
		"sprite": "prototype_building_sprite.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	
func make_oxygen_farm_node():
	var oxygen_farm_node = IsoKit.make_actor(Runtime.ASSETS, {
		"id": "oxygen_farm",
		"name": "OxygenFarmActor0",
		"sprite": "oxygen_farm.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	var timer = Timer.new()
	var compute_produce_oxygen = func produce_oxygen():
		Cache.oxygen = clamp(Cache.oxygen + Runtime.OXYGEN_FARM_PRODUCTION_VALUE, Runtime.OXYGEN_MIN, Runtime.OXYGEN_MAX)
		Cache.power = clamp(Cache.power - Runtime.OXYGEN_FARM_POWER_CONSUMPTION, Runtime.POWER_MIN, Runtime.POWER_MAX)
		if Cache.power <= Runtime.POWER_MIN:
			oxygen_farm_node.queue_free()
		
	timer.connect("timeout", compute_produce_oxygen)
	timer.wait_time = Runtime.OXYGEN_FARM_PRODUCTION_RATE
	timer.autostart = true
	oxygen_farm_node.add_child(timer)
	return oxygen_farm_node
	
func make_drill_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": "drill",
		"name": "DrillActor0",
		"sprite": "drill.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
	
func make_prototype_object_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
	"id": "ore",
	"name": "TiliumOreActor0",
	"sprite": "prototype_object_sprite.sprite",
	"speed": Runtime.LOADER_SPEED,
	})
	
func make_ore_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": "ore",
		"name": "TiliumOreActor0",
		"sprite": "tilium_ore.sprite",
		"speed": Runtime.LOADER_SPEED,
	})
