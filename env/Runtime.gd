extends Node

const ASSETS: String = "res://assets/"
const PLAYER_ACTOR_ID: String = "PlayerActor"
const PLAYER_SPEED: float = 10000.0
const GRID_SIZE: Vector2i = Vector2i(32, 16)
const GRID_OFFSET: Vector2i = Vector2i(16, 16)
const STAGED: String = "StagedAssembly"

enum ASSEMBLY {
	BASE_STATION,
	SHUTTLE,
	POWER_PLANT,
	OXYGEN_FARM,
	REFINERY,
	VAPOR_COLLECTOR
}
