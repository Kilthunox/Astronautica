extends Node
var params: Dictionary = {}
var offset: Vector2
var zone: String = ""
var tilemap: String = ""

var assembler_lock: bool = false
var drills: int = 1
var selected_resource: String = "ore"
var ore: int = 0 + 10
var gas: int = 0 + 10
var bio: int = 0 + 10
var cry: int = 0 + 10



var temperature: int = Runtime.STARTING_TEMPERATURE
var oxygen: int = Runtime.STARTING_OXYGEN
var power: int = Runtime.STARTING_POWER
var fuel: int = Runtime.STARTING_FUEL

var mission_description = "Test mission desc"
