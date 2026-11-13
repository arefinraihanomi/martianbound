extends Node

func _ready() -> void:
	print("--- COMMENCING MILESTONE 4: SIMULATION SYSTEMS & HAZARDS TEST ---")
	
	# 1. Initialize fresh mission
	GameState.start_new_mission()
	print("Initialized Mission: Sol = %d, Time = %s, Weather = %s" % [GameState.current_sol, GameState.current_time_str, GameState.weather_type])
	assert(GameState.current_sol == 1, "Mission should start on Sol 1")
	assert(GameState.sol_hour == 8 and GameState.sol_minute == 30, "Mission starts at 08:30")
	assert(GameState.weather_type == "CLEAR", "Weather starts CLEAR")
	assert(GameState.is_daytime() == true, "08:30 is Martian daytime")
	
	# 2. Test Diurnal Day/Night calculations & daylight factor
	var noon_daylight = GameState.get_daylight_factor()
	print("Daylight factor at 08:30: ", noon_daylight)
	assert(noon_daylight > 0.0, "Daylight factor should be positive during morning")
	
	GameState.sol_hour = 12
	GameState.sol_minute = 0
	var midday_factor = GameState.get_daylight_factor()
	print("Midday daylight factor at 12:00: ", midday_factor)
	assert(is_equal_approx(midday_factor, 1.0), "Daylight factor at noon must be 1.0")
	var midday_temp = GameState.get_ambient_temperature()
	
	GameState.sol_hour = 2
	GameState.sol_minute = 0
	var midnight_factor = GameState.get_daylight_factor()
	print("Midnight daylight factor at 02:00: ", midnight_factor)
	assert(midnight_factor == 0.0, "Daylight factor at night must be 0.0")
	var midnight_temp = GameState.get_ambient_temperature()
	assert(midnight_temp < midday_temp, "Martian night must be colder than midday")
	print("Verified: Midday temp = %.1f°C, Midnight temp = %.1f°C" % [midday_temp, midnight_temp])
	
	# 3. Test Time Progression & Sol Rollover
	GameState.sol_hour = 23
	GameState.sol_minute = 45
	GameState.current_sol = 1
	GameState.advance_time(30) # Advances to 00:15 of Sol 2
	print("After 30 mins from 23:45: Sol = %d, Time = %s" % [GameState.current_sol, GameState.current_time_str])
	assert(GameState.current_sol == 2, "Sol should increment to Sol 2 at midnight rollover")
	assert(GameState.sol_hour == 0 and GameState.sol_minute == 15, "Time should be 00:15")
	print("Verified: Sol diurnal cycle and rollover successfully advanced.")
	
	# 4. Test Weather Hazards: Dust Storm & Solar Event
	GameState.set_weather("DUST_STORM", "PERSEID DUST GALE", 68.0, 0.42, 180)
	assert(GameState.weather_type == "DUST_STORM")
	assert(GameState.wind_speed_kts == 68.0)
	var storm_tint = GameState.get_ambient_tint()
	print("Storm ambient tint: ", storm_tint)
	assert(storm_tint.r > storm_tint.b, "Dust storm ambient tint should be warm reddish-orange")
	
	# 5. Test Power balance & attenuated solar generation in storm
	GameState.sol_hour = 12
	GameState.sol_minute = 0
	var initial_power = GameState.resources["power"]["current"]
	GameState.simulation_step(15)
	print("Power before/after 15-min storm step at noon: Initial = %.1f, Now = %.1f" % [initial_power, GameState.resources["power"]["current"]])
	assert(GameState.resources["power"]["current"] != initial_power, "Power should update dynamically")
	
	# 6. Test Crew Fatigue, Condition, and Rest Cycle
	var initial_vance_fatigue = GameState.crew_database["vance"]["fatigue"]
	# Simulate severe fatigue
	GameState.crew_database["vance"]["fatigue"] = 85.0
	GameState.crew_database["vance"]["condition"] = 70.0
	GameState.crew_database["vance"]["morale"] = 65.0
	GameState._update_crew_status_tag(GameState.crew_database["vance"])
	assert(GameState.crew_database["vance"]["status_tag"] == "EXHAUSTED", "85% fatigue should tag crew as EXHAUSTED")
	
	# Execute Rest cycle (4 hours)
	var rest_result = GameState.rest_crew(4)
	assert(rest_result["success"] == true, "Crew rest cycle should succeed")
	print("Vance fatigue after rest: ", GameState.crew_database["vance"]["fatigue"])
	assert(GameState.crew_database["vance"]["fatigue"] < 85.0, "Fatigue should be reduced after rest cycle")
	assert(GameState.crew_database["vance"]["condition"] > 70.0, "Condition should recover after rest cycle")
	print("Verified: Crew fatigue and restorative sleep cycle functioning.")
	
	# 7. Test Threshold Warnings & Alerts
	GameState.resources["oxygen"]["current"] = 150.0 # Below 200 threshold
	var alerts = GameState.get_active_alerts()
	print("Active alerts with 150 O2: ", alerts)
	assert(alerts.size() > 0, "Low O2 must trigger an active alert")
	var has_o2_crit = false
	for a in alerts:
		if "O2" in a["message"]:
			has_o2_crit = true
			assert(a["level"] == "CRITICAL", "Depleted O2 must have CRITICAL severity")
	assert(has_o2_crit, "Active alerts must include O2 warning")
	print("Verified: Critical threshold alerts generated reliably.")
	
	# 8. Test Save & Load of Simulation Systems
	var save_ok = GameState.save_game()
	assert(save_ok == true, "Save game must succeed")
	
	# Mutate values in memory
	GameState.current_sol = 99
	GameState.sol_hour = 4
	GameState.weather_type = "SOLAR_EVENT"
	GameState.crew_database["vance"]["fatigue"] = 0.0
	
	# Reload
	var load_ok = GameState.load_game()
	assert(load_ok == true, "Load game must succeed")
	assert(GameState.current_sol == 2, "Restored current_sol must match saved value")
	assert(GameState.weather_type == "DUST_STORM", "Restored weather_type must match saved DUST_STORM")
	assert(GameState.crew_database["vance"]["fatigue"] > 0.0, "Restored crew fatigue must match saved value")
	print("Verified: Complete simulation and crew condition state restored from save file.")
	
	# 9. Verify HUD integration
	GameState.change_screen("simulation_hud")
	await get_tree().create_timer(0.3).timeout
	var main_node = get_parent()
	var hud_screen = main_node.get("current_screen_node")
	assert(hud_screen != null, "HUD screen must mount")
	
	var alert_banner = hud_screen.get("alert_banner")
	assert(alert_banner != null, "Alert banner must exist in HUD")
	assert(alert_banner.visible == true, "Alert banner must be visible while alert is active")
	print("Verified: Alert banner active in Simulation HUD.")
	
	print("--- MILESTONE 4: ALL SIMULATION SYSTEM TESTS PASSED SUCCESSFULLY ---")
	get_tree().quit(0)
