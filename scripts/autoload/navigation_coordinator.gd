extends Node

var current_screen: Node = null

func change_screen(scene_path: String) -> void:
	if current_screen:
		current_screen.queue_free()
	
	var packed_scene = load(scene_path)
	if packed_scene:
		var new_scene = packed_scene.instantiate()
		get_tree().root.add_child(new_scene)
		current_screen = new_scene
