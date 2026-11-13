extends Control

@onready var screen_container: Control = $ScreenContainer

var screens: Dictionary = {
	"main_menu": "res://scenes/screens/main_menu.tscn",
	"mission_briefing": "res://scenes/screens/mission_briefing.tscn",
	"crew_selection": "res://scenes/screens/crew_selection.tscn",
	"mission_planner": "res://scenes/screens/mission_planner.tscn",
	"outpost_selection": "res://scenes/screens/outpost_selection.tscn",
	"simulation_hud": "res://scenes/screens/simulation_hud.tscn",
	"mission_report": "res://scenes/screens/mission_report.tscn"
}

var current_screen_node: Node = null

func _ready() -> void:
	GameState.screen_changed.connect(_on_screen_changed)
	load_screen(GameState.current_screen)
	
	for arg in OS.get_cmdline_args():
		if arg == "--run-nav-test":
			_run_automated_nav_test()
			break
		elif arg == "--run-sim-test":
			_run_automated_sim_test()
			break
		elif arg == "--run-setup-test":
			_run_automated_setup_test()
			break
		elif arg == "--run-world-test":
			_run_automated_world_test()
			break
		elif arg == "--run-simsys-test":
			_run_automated_simsys_test()
			break
		elif arg == "--run-events-test":
			_run_automated_events_test()
			break
		elif arg == "--run-ending-test":
			_run_automated_ending_test()
			break
		elif arg == "--run-qa-test":
			_run_automated_qa_test()
			break

func _run_automated_qa_test() -> void:
	var tester = load("res://tests/test_milestone_7_qa_polish.gd").new()
	add_child(tester)

func _run_automated_ending_test() -> void:
	var tester = load("res://tests/test_milestone_6_ending_persistence.gd").new()
	add_child(tester)

func _run_automated_events_test() -> void:
	var tester = load("res://tests/test_milestone_5_events_research.gd").new()
	add_child(tester)

func _run_automated_simsys_test() -> void:
	var tester = load("res://tests/test_milestone_4_simulation.gd").new()
	add_child(tester)

func _run_automated_world_test() -> void:
	var tester = load("res://tests/test_milestone_3_world.gd").new()
	add_child(tester)

func _run_automated_setup_test() -> void:
	var tester = load("res://tests/test_milestone_2_setup.gd").new()
	add_child(tester)

func _run_automated_sim_test() -> void:
	var tester = load("res://tests/test_simulation_gameplay.gd").new()
	add_child(tester)

func _run_automated_nav_test() -> void:
	print("--- COMMENCING FULL GAMEPLAY & SCREEN NAVIGATION TEST ---")
	var flow := [
		"main_menu",
		"mission_briefing",
		"crew_selection",
		"mission_planner",
		"outpost_selection",
		"simulation_hud",
		"mission_report",
		"main_menu"
	]
	for scr in flow:
		print("Testing transition to: ", scr)
		GameState.change_screen(scr)
		await get_tree().create_timer(0.3).timeout
		if current_screen_node == null:
			printerr("Screen failed to instantiate: ", scr)
			get_tree().quit(1)
			return
		print("Successfully mounted and rendered: ", scr)
	print("--- AUTOMATED FULL NAVIGATION TEST PASSED CLEANLY ---")
	get_tree().quit(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Global escape handler
		pass

func _on_screen_changed(screen_name: String) -> void:
	load_screen(screen_name)

func load_screen(screen_name: String) -> void:
	if not screens.has(screen_name):
		push_error("Unknown screen: " + screen_name)
		return
		
	var path: String = screens[screen_name]
	if not ResourceLoader.exists(path):
		push_error("Screen scene not found: " + path)
		return
		
	if current_screen_node != null:
		current_screen_node.queue_free()
		current_screen_node = null
		
	var scene: PackedScene = load(path)
	if scene:
		var instance = scene.instantiate()
		screen_container.add_child(instance)
		current_screen_node = instance
