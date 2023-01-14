extends Node

const ASSETS: String = "res://assets/"
const PLAYER_ACTOR_ID: String = "PlayerActor"
const PLAYER_SPEED: float = 10000.0
const GRID_SIZE: Vector2i = Vector2i(16, 8)
const GRID_OFFSET: Vector2i = Vector2i(0, 0)
const STAGED: String = "StagedAssembly"
const OPACITY: float = 0.3333

enum LAYER {
	player,
	environment
}

enum ASSEMBLY {
	BASE_STATION,
	SHUTTLE,
	POWER_PLANT,
	OXYGEN_FARM,
	REFINERY,
	VAPOR_COLLECTOR
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
		"speed": 0.0,
	})
	
func make_prototype_object_node():
	return IsoKit.make_actor(Runtime.ASSETS, {
	"id": "prototype_object",
	"sprite": "prototype_object_sprite.sprite",
	"speed": 0.0,
	})
