extends Node
func _ready():
	set_process_unhandled_input(false)
	
func handle_input():
	var player_actor = get_parent().get_node("World").get_node_or_null(Runtime.PLAYER_ACTOR_ID)
	if player_actor:
		var heading = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
		if heading:
			player_actor.set_heading(heading)
		else:
			player_actor.stop()
		
func _unhandled_input(event):
	handle_input()
