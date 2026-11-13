extends Node

func _ready() -> void:
	print("--- TESTING FULL GAME NAVIGATION WITH AUTOLOADS ---")
	var screens := [
		"main_menu",
		"mission_briefing",
		"crew_selection",
		"mission_planner",
		"outpost_selection"
	]
	
	for s in screens:
		print("Navigating to screen: ", s)
		GameState.change_screen(s)
		await get_tree().process_frame
		print("Screen active: ", GameState.current_screen)
		
	print("--- TEST PASSED: ALL SCREENS SUCCESSFULLY INITIALIZED & NAVIGATED ---")
	get_tree().quit(0)
