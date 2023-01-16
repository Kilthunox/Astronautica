extends Node

var offset: Vector2
var zone: String = "main.zone"
var tilemap: String = "main.tilemap"

var drills: int = 1
var selected_resource: String = "ore"
var ore: int = 0



var temperature: int = Runtime.STARTING_TEMPERATURE
var oxygen: int = Runtime.STARTING_OXYGEN
var power: int = Runtime.STARTING_POWER
var fuel: int = Runtime.STARTING_FUEL
