extends Node

var offset: Vector2
var zone: String = "main.zone"
var tilemap: String = "main.tilemap"

var assembler_lock: bool = false

var drills: int = 1
var selected_resource: String = "ore"
var ore: int = 100
var gas: int = 0
var bio: int = 0
var cry: int = 0



var temperature: int = Runtime.STARTING_TEMPERATURE
var oxygen: int = Runtime.STARTING_OXYGEN + 100
var power: int = Runtime.STARTING_POWER
var fuel: int = Runtime.STARTING_FUEL
