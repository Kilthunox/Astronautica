extends Node


func _on_tree_exiting():
	if get_parent().id not in ["dirt", "rock"]:
		$BlockRemoved.play()
