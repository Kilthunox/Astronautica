extends Timer

signal pulse(drill)

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
		for resource_node in get_tree().get_nodes_in_group("resource"):
			var isofactor = IsoKit.isometric_factor(drill.position.angle_to(resource_node.position))
			var distance = drill.position.distance_to(resource_node.position)
			if distance * isofactor <= Runtime.DRILL_RANGE:
				match resource_node.id:
					"ore":
						randomize()
						Cache.ore += (randi() % Runtime.ORE_QUANTITY_RANGE) + 1
						resource_node.queue_free()
						break
					"gas":
						randomize()
						Cache.gas += (randi() % Runtime.GAS_QUANTITY_RANGE) + 1
						resource_node.queue_free()
						break
					"bio":
						randomize()
						Cache.bio += (randi() % Runtime.BIO_QUANTITY_RANGE) + 1
						resource_node.queue_free()
						break
					"cry":
						randomize()
						Cache.cry += (randi() % Runtime.CRY_QUANTITY_RANGE) + 1
						resource_node.queue_free()
						break
						


func _on_timeout():
	drill_gathers_resource(self.get_parent())


func _on_tree_exiting():
	Cache.drills += 1
