extends Node

@onready var player = get_parent()


func _process(_delta):
	match player.state:
		"run":
			if !$Footsteps.playing:
				$Footsteps.playing = true
		_: 
			$Footsteps.playing = false
