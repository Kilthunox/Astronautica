@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("IsoKit", "Node", preload("IsoKit.gd"), preload("icon.svg"))
	add_autoload_singleton("IsoKit", "res://addons/IsoKit/IsoKit.gd")
	
func _exit_tree():
	remove_custom_type("IsoKit")
	remove_autoload_singleton("IsoKit")
