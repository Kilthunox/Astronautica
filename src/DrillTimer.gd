extends Timer

signal pulse(drill)

func _ready():
	autostart = true
	wait_time = Runtime.DRILL_GATHERING_INTERVAL

func drill_gathers_resource(drill):
	for resource_node in get_tree().get_nodes_in_group("resource"):
		var isofactor = IsoKit.isometric_factor(drill.position.angle_to(resource_node.position))
		var distance = drill.position.distance_to(resource_node.position)
		if distance * isofactor <= Runtime.DRILL_RANGE:
			match resource_node.id:
				"ore_resource":
					Cache.ore += 1
					resource_node.queue_free()
					break


func _on_timeout():
	drill_gathers_resource(self.get_parent())


func _on_tree_exiting():
	Cache.drills += 1
