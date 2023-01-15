extends Node

const ASSETS: String = "res://assets/"
const PLAYER_ACTOR_ID: String = "PlayerActor"
const PLAYER_SPEED: float = 10000.0
const DESTRUCTOR_ACTOR_ID: String = "DestructorActor"
const DESTRUCTOR_ACTOR_LIFESPAN: float = 1.1
const GRID_SIZE: Vector2i = Vector2i(16, 8)
const GRID_OFFSET: Vector2i = Vector2i(0, 0)
const STAGED: String = "StagedAssembly"
const OPACITY: float = 0.45
const INVALID_COLOR: Color = Color(1, 0.45, 0.45, 0.45)
const ASSEMBLY_COLOR: Color = Color(0.45, 0.45, 1, 1)
const ASSEMBLER_SPEED: float = 1000.0


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
	}: "prototype_building",
}

func make_prototype_player_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": Runtime.PLAYER_ACTOR_ID,
		"sprite": "prototype_sprite.sprite",
		"zone": "prototype_zone.zone",
		"spawn": "spawn",
		"speed": Runtime.PLAYER_SPEED,
	})
	
func make_prototype_building_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
		"id": "prototype_building",
		"sprite": "prototype_building_sprite.sprite",
		"speed": Runtime.PLAYER_SPEED,
	})
	
func make_prototype_object_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
	"id": "ore",
	"sprite": "prototype_object_sprite.sprite",
		"speed": Runtime.PLAYER_SPEED,
	})
