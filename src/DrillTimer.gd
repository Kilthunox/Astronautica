extends Timer

func _ready():
	get_parent().set_state("drilling")
	Cache.drills -= 1
	autostart = true
	wait_time = Runtime.DRILL_GATHERING_INTERVAL
	
func drill_gathers_resource(drill):
	if Cache.power <= Runtime.POWER_MIN:
		get_parent().set_state("idle")
		# TODO - notify player that drill x has stopped
	else:
		get_parent().set_state("drilling")
		randomize()
		Cache.power = clamp(Cache.power - (randi() % Runtime.DRILL_CONSUMPTION_VALUE), Runtime.POWER_MIN, Runtime.POWER_MAX)
		var nodes_in_range: Array
		for resource_node in get_tree().get_nodes_in_group("resource"):
			var isofactor = IsoKit.isometric_factor(drill.position.angle_to(resource_node.position))
			var distance = drill.position.distance_to(resource_node.position)
			if distance * isofactor <= Runtime.DRILL_RANGE:
				nodes_in_range.append(resource_node)
		randomize()
		if nodes_in_range:
			var resource_node = nodes_in_range[randi() % nodes_in_range.size()]
			match resource_node.id:
				"ore":
					Cache.ore += 1
					resource_node.queue_free()
				"gas":
					Cache.gas += 1
					resource_node.queue_free()
				"bio":
					Cache.bio += 1
					resource_node.queue_free()
				"cry":
					resource_node.queue_free()
				_:
					resource_node.queue_free()
						


func _on_timeout():
	drill_gathers_resource(self.get_parent())


func _on_tree_exiting():
	Cache.drills += 1
