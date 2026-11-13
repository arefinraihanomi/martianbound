extends SceneTree

func _init() -> void:
	print("--- BEGIN MILESTONE 1 VERIFICATION TEST ---")
	
	# Verify screens load without error
	var screens := [
		"res://scenes/screens/main_menu.tscn",
		"res://scenes/screens/mission_briefing.tscn",
		"res://scenes/screens/crew_selection.tscn",
		"res://scenes/screens/mission_planner.tscn",
		"res://scenes/screens/outpost_selection.tscn"
	]
	
	for path in screens:
		print("Testing scene loading: ", path)
		var res: PackedScene = load(path)
		if res == null:
			printerr("FAILED to load: ", path)
			quit(1)
			return
		var node = res.instantiate()
		if node == null:
			printerr("FAILED to instantiate: ", path)
			quit(1)
			return
		root.add_child(node)
		# Process one frame
		node.queue_free()
		print("SUCCESS: ", path)
		
	print("--- ALL 5 REFERENCE SCREENS LOADED & INSTANTIATED CLEANLY ---")
	quit(0)
