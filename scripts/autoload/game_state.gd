extends Node

signal screen_changed(screen_name: String)
signal mission_started()
signal resource_updated(res_name: String, current: float, max_val: float)
signal crew_updated()
signal objective_updated(obj_id: String)
signal event_triggered(event_data: Dictionary)
signal log_added(entry: Dictionary)
signal time_advanced(sol: int, time_str: String)
signal weather_changed(weather_type: String, wind_kts: float, temp_c: float)
signal alert_triggered(alert_data: Dictionary)

const SAVE_PATH := "user://martianbound_save.json"

# Color constants matching UI reference
const COLOR_BG_DARK := Color("#0b1118")
const COLOR_PANEL_BG := Color("#121a24")
const COLOR_PANEL_CARD := Color("#16212d")
const COLOR_BORDER := Color("#293b4e")
const COLOR_CORNER_TABS := Color("#547796")
const COLOR_CYAN := Color("#3ce3d9")
const COLOR_AMBER := Color("#e58338")
const COLOR_RED := Color("#e75a5a")
const COLOR_GREEN := Color("#3ce88c")
const COLOR_TEXT_MUTED := Color("#7590aa")
const COLOR_TEXT_WHITE := Color("#f0f6f6")

var current_screen: String = "main_menu"

# Mission outcome & Debrief cache
var last_outcome: String = ""
var last_narrative: String = ""

# Mission configuration data
var expedition_duration: int = 1 # 1-Sol strict intensive survival trainer for MVP
var difficulty: String = "STANDARD"
var selected_site_id: String = "site_a"

# Crew database
var crew_database: Dictionary = {
	"vance": {
		"id": "vance",
		"name": "Cmdr. Sarah Vance",
		"short_name": "Sarah Vance",
		"title": "COMMANDER // EXPLORATION",
		"spec": "EVA Coordination & Flight Ops",
		"category": "EXP",
		"code": "CMD",
		"radar": {"PHYS": 82, "SCI": 65, "LEAD": 95, "PSY": 90, "EXP": 94},
		"overall": 85.2,
		"status": "ASSIGNED",
		"condition": 100,
		"fatigue": 0,
		"morale": 95
	},
	"chen": {
		"id": "chen",
		"name": "Dr. Alexei Chen",
		"short_name": "Dr. Alexei Chen",
		"title": "CHIEF MEDIC // BIO-ANALYSIS",
		"spec": "Bio-Containment & Life Support",
		"category": "MED",
		"code": "BIO",
		"radar": {"PHYS": 70, "SCI": 92, "LEAD": 68, "PSY": 85, "EXP": 80},
		"overall": 79.0,
		"status": "ASSIGNED",
		"condition": 100,
		"fatigue": 0,
		"morale": 90
	},
	"thorne": {
		"id": "thorne",
		"name": "Lt. Marcus Thorne",
		"short_name": "Marcus Thorne",
		"title": "HABITAT SYS // LIFE SUPP",
		"spec": "Power Rig & Hab Systems",
		"category": "ENG",
		"code": "ENG",
		"radar": {"PHYS": 88, "SCI": 74, "LEAD": 72, "PSY": 80, "EXP": 78},
		"overall": 78.4,
		"status": "ASSIGNED",
		"condition": 100,
		"fatigue": 0,
		"morale": 88
	},
	"rostova": {
		"id": "rostova",
		"name": "Dr. Elena Rostova",
		"short_name": "Dr. Elena Rostova",
		"title": "AQUIFER DRILL & GEOLOGY",
		"spec": "Sub-surface Hydrogeology",
		"category": "SCI",
		"code": "GEO",
		"radar": {"PHYS": 76, "SCI": 96, "LEAD": 70, "PSY": 88, "EXP": 92},
		"overall": 84.4,
		"status": "AVAILABLE",
		"condition": 100,
		"fatigue": 0,
		"morale": 92
	},
	"miller": {
		"id": "miller",
		"name": "Jaxson Miller",
		"short_name": "Jaxson Miller",
		"title": "ROVER OPS // TERRAIN NAV",
		"spec": "Surface Transport & Logistics",
		"category": "EXP",
		"code": "EXP",
		"radar": {"PHYS": 90, "SCI": 55, "LEAD": 60, "PSY": 82, "EXP": 88},
		"overall": 75.0,
		"status": "AVAILABLE",
		"condition": 100,
		"fatigue": 0,
		"morale": 85
	},
	"einstein": {
		"id": "einstein",
		"name": "Albert Einstien",
		"short_name": "Albert Einstien",
		"title": "THEORETICAL PHYSICIST",
		"spec": "Instrumentation & Spectral Scan",
		"category": "SCI",
		"code": "SCI",
		"radar": {"PHYS": 50, "SCI": 99, "LEAD": 58, "PSY": 75, "EXP": 70},
		"overall": 70.4,
		"status": "AVAILABLE",
		"condition": 100,
		"fatigue": 0,
		"morale": 82
	}
}

# 4 Crew Slots: array of IDs or ""
var assigned_roster: Array[String] = ["vance", "chen", "thorne", "rostova"]

# Sites database
var sites_database: Dictionary = {
	"site_a": {
		"id": "site_a",
		"title": "SITE-A: ACIDALIA PLANITIA",
		"tag": "SELECTED",
		"coords": "28.4° N, 332.1° E",
		"terrain": "Basalt Sand Plains",
		"safety_index": 94,
		"grade": "GRADE A+",
		"badge": "PRECURSOR OK",
		"temp": -62,
		"rad": 0.24,
		"atmos": 88,
		"dust_risk": 42,
		"unlocked": true
	},
	"site_b": {
		"id": "site_b",
		"title": "SITE-B: VALLES MARINERIS",
		"tag": "AVAILABLE",
		"coords": "13.9° S, 298.5° E",
		"terrain": "Canyon Rift Valley",
		"safety_index": 68,
		"grade": "GRADE B-",
		"badge": "GEOLOGIC TARGET",
		"temp": -54,
		"rad": 0.35,
		"atmos": 65,
		"dust_risk": 60,
		"unlocked": true
	},
	"site_c": {
		"id": "site_c",
		"title": "SITE-C: UTOPIA PLANITIA",
		"tag": "AVAILABLE",
		"coords": "46.7° N, 117.5° E",
		"terrain": "Mantled Ice Sheet",
		"safety_index": 82,
		"grade": "GRADE B+",
		"badge": "CRYO RESERVE",
		"temp": -78,
		"rad": 0.20,
		"atmos": 75,
		"dust_risk": 30,
		"unlocked": true
	},
	"site_d": {
		"id": "site_d",
		"title": "SITE-D: NOCTIS LABYRINTHUS",
		"tag": "RESTRICTED",
		"coords": "07.2° S, 258.8° E",
		"terrain": "Dust Maze",
		"safety_index": 22,
		"grade": "CRITICAL",
		"badge": "VORTEX HAZARD",
		"temp": -45,
		"rad": 0.58,
		"atmos": 40,
		"dust_risk": 88,
		"unlocked": false
	}
}

# Runtime simulation state
var current_sol: int = 1
var sol_hour: int = 8
var sol_minute: int = 30
var current_time_str: String = "08:30"
var habitat_integrity: float = 100.0
var solar_efficiency: float = 94.0
var radiation_mSv: float = 0.22

# Weather and Environmental hazards
var weather_type: String = "CLEAR" # CLEAR, DUST_DEVIL, DUST_STORM, SOLAR_EVENT
var weather_name: String = "OPTIMAL / CLEAR"
var wind_speed_kts: float = 14.0
var ambient_temp_c: float = -62.0
var weather_duration_mins: int = 0

# Staged Resources
var resources: Dictionary = {
	"oxygen": {"current": 850.0, "max": 1000.0, "unit": "O2"},
	"water": {"current": 620.0, "max": 800.0, "unit": "L"},
	"food": {"current": 90.0, "max": 100.0, "unit": "PACKS"},
	"power": {"current": 1200.0, "max": 1500.0, "unit": "kWh"}
}

func get_default_objectives() -> Array[Dictionary]:
	return [
		{
			"id": "life_support",
			"title": "[01] LIFE SUPPORT INIT",
			"type": "CRITICAL",
			"status": "COMPLETED",
			"desc": "Pressurize habitat airlocks & stabilize Core A-1 internal scrubbers.",
			"xp": 250
		},
		{
			"id": "comms_dish",
			"title": "[02] HIGH-GAIN COMMS DISH",
			"type": "PRIMARY",
			"status": "IN_PROGRESS",
			"desc": "Calibrate directional array to orbital relay probe 04.",
			"xp": 350
		},
		{
			"id": "primary_water",
			"title": "[03] AQUIFER EXTRACTION BOREHOLE (NASA SWIM / SHARAD)",
			"type": "PRIMARY",
			"status": "NOT_STARTED",
			"desc": "Access Acidalia sub-surface ice table at -38m depth identified by NASA SWIM radar consistency mapping and initiate thermal extraction.",
			"xp": 500
		},
		{
			"id": "primary_anomaly",
			"title": "[04] INVESTIGATE SUB-SURFACE ACOUSTIC ANOMALY",
			"type": "PRIMARY",
			"status": "NOT_STARTED",
			"desc": "Cross-reference seismic pulse echo with Sector 4 basalt fault spectrometry.",
			"xp": 600
		},
		{
			"id": "sec_solar",
			"title": "[S-1] Maintain solar collector output > 85%",
			"type": "SECONDARY",
			"status": "IN_PROGRESS",
			"desc": "Clear dust buildup periodically from photovoltaic panels (+400 XP).",
			"xp": 400
		},
		{
			"id": "sec_basalt",
			"title": "[S-2] Collect 15kg sedimentary basalt from Sector 4 crater fault",
			"type": "SECONDARY",
			"status": "NOT_STARTED",
			"desc": "Sample regolith with rover drill apparatus (+400 XP).",
			"xp": 400
		},
		{
			"id": "sec_crate",
			"title": "[S-3] Recover Ares emergency supply cache",
			"type": "SECONDARY",
			"status": "NOT_STARTED",
			"desc": "Retrieve precursor emergency canisters from Ares survey stash (+300 XP).",
			"xp": 300
		}
	]

# Mission objectives
var objectives: Array[Dictionary] = get_default_objectives()

# Discoveries and scientific evidence
var discoveries: Array[Dictionary] = []
var mission_logs: Array[Dictionary] = []

func complete_objective(obj_id: String) -> bool:
	for obj in objectives:
		if obj["id"] == obj_id and obj["status"] != "COMPLETED":
			obj["status"] = "COMPLETED"
			add_log_entry("OBJECTIVE", "Directive fulfilled: " + obj["title"])
			emit_signal("objective_updated", obj_id)
			
			if obj_id == "primary_water":
				for o2 in objectives:
					if o2["id"] == "primary_anomaly" and o2["status"] == "NOT_STARTED":
						o2["status"] = "IN_PROGRESS"
						emit_signal("objective_updated", "primary_anomaly")
			return true
	return false

func fail_objective(obj_id: String) -> bool:
	for obj in objectives:
		if obj["id"] == obj_id and obj["status"] != "FAILED":
			obj["status"] = "FAILED"
			add_log_entry("OBJECTIVE", "Directive failed: " + obj["title"])
			emit_signal("objective_updated", obj_id)
			return true
	return false

func add_discovery(disc: Dictionary) -> void:
	for existing in discoveries:
		if existing.get("id") == disc.get("id"):
			return
			
	disc["sol"] = current_sol
	disc["time"] = current_time_str
	discoveries.append(disc)
	
	add_log_entry("SCIENCE", "Research Discovery: " + disc.get("title", disc.get("name", "Unknown Finding")))
	
	for cid in assigned_roster:
		if cid != "" and crew_database.has(cid):
			crew_database[cid]["morale"] = min(100.0, crew_database[cid]["morale"] + 8.0)
			
	emit_signal("crew_updated")

func get_completed_objectives_count() -> int:
	var count = 0
	for obj in objectives:
		if obj["status"] == "COMPLETED":
			count += 1
	return count

func get_total_science_xp() -> int:
	var total = 0
	for disc in discoveries:
		total += disc.get("science_xp", disc.get("xp", 300))
	for obj in objectives:
		if obj["status"] == "COMPLETED":
			total += obj.get("xp", 200)
	return total

func _ready() -> void:
	add_log_entry("SYSTEM", "Orbital telemetry link established with Ares Expedition Unit.")
	add_log_entry("MISSION", "Pre-deployment checklist staged for Acidalia Planitia.")

func change_screen(new_screen: String) -> void:
	current_screen = new_screen
	emit_signal("screen_changed", new_screen)

func add_log_entry(category: String, text: String) -> void:
	var entry := {
		"sol": current_sol,
		"time": current_time_str,
		"category": category,
		"text": text
	}
	mission_logs.append(entry)
	emit_signal("log_added", entry)

func assign_candidate_to_slot(candidate_id: String, slot_idx: int) -> bool:
	if slot_idx < 0 or slot_idx >= 4:
		return false
	# If candidate is already assigned elsewhere, unassign them first
	var existing_idx = assigned_roster.find(candidate_id)
	if existing_idx != -1:
		assigned_roster[existing_idx] = ""
	assigned_roster[slot_idx] = candidate_id
	emit_signal("crew_updated")
	return true

func unassign_slot(slot_idx: int) -> void:
	if slot_idx >= 0 and slot_idx < 4:
		assigned_roster[slot_idx] = ""
		emit_signal("crew_updated")

func is_roster_complete() -> bool:
	for member in assigned_roster:
		if member == "":
			return false
	return true

func calculate_team_readiness() -> Dictionary:
	var eng := 0.0
	var med := 0.0
	var exp := 0.0
	var sci := 0.0
	var count := 0
	
	for cid in assigned_roster:
		if cid != "" and crew_database.has(cid):
			count += 1
			var data = crew_database[cid]
			eng += data["radar"]["PHYS"] * 0.4 + data["radar"]["EXP"] * 0.6
			med += data["radar"]["PHYS"] * 0.3 + data["radar"]["PSY"] * 0.7
			exp += data["radar"]["EXP"] * 0.7 + data["radar"]["LEAD"] * 0.3
			sci += data["radar"]["SCI"]
			
	if count > 0:
		eng = eng / count
		med = med / count
		exp = exp / count
		sci = sci / count
		
	var viable = int((eng + med + exp + sci) / 4.0)
	return {
		"ENG": int(eng),
		"MED": int(med),
		"EXP": int(exp),
		"SCI": int(sci),
		"viable": viable
	}

func modify_resource(res_key: String, delta: float) -> void:
	if resources.has(res_key):
		resources[res_key]["current"] = clamp(resources[res_key]["current"] + delta, 0.0, resources[res_key]["max"])
		emit_signal("resource_updated", res_key, resources[res_key]["current"], resources[res_key]["max"])

func advance_time(mins: int) -> void:
	sol_minute += mins
	while sol_minute >= 60:
		sol_minute -= 60
		sol_hour += 1
		
		# Sol 1 Midday dynamic space weather hazard (13:00 - NASA DONKI Solar Flare Alert)
		if current_sol == 1 and sol_hour == 13 and weather_type == "CLEAR":
			set_weather("SOLAR_EVENT", "NASA DONKI SEP FLARE EVENT", 18.0, 1.15, 120)
			add_log_entry("SPACE WEATHER", "NASA DONKI Alert: Coronal Mass Ejection shock front impacting Mars. Surface radiation spiking to 1.15 mSv/h!")
		# Sol 1 Afternoon dust squall (17:00 - InSight TWINS Dust Gale)
		elif current_sol == 1 and sol_hour == 17 and weather_type == "CLEAR":
			set_weather("DUST_STORM", "PERSEID DUST GALE (INSIGHT TWINS)", 58.0, 0.35, 180)
			add_log_entry("WEATHER", "NASA InSight TWINS Telemetry: 58-knot convective dust gale engulfing Acidalia Planitia.")
			
		if sol_hour >= 24:
			sol_hour = 0
			current_sol += 1
			_on_new_sol()
	current_time_str = "%02d:%02d" % [sol_hour, sol_minute]
	_update_ambient_environment()
	emit_signal("time_advanced", current_sol, current_time_str)

func is_daytime() -> bool:
	return sol_hour >= 6 and sol_hour < 18

func get_daylight_factor() -> float:
	if sol_hour < 6 or sol_hour >= 18:
		return 0.0
	var current_float = float(sol_hour) + float(sol_minute) / 60.0
	var dist_from_noon = abs(current_float - 12.0)
	return clamp(1.0 - (dist_from_noon / 6.0), 0.0, 1.0)

func get_ambient_temperature() -> float:
	var base_temp = -105.0 + (get_daylight_factor() * 58.0)
	if weather_type == "DUST_STORM":
		base_temp -= 12.0
	return base_temp

func get_ambient_tint() -> Color:
	if weather_type == "DUST_STORM":
		return Color(0.72, 0.45, 0.32, 1.0)
	elif weather_type == "SOLAR_EVENT":
		return Color(1.0, 0.85, 0.70, 1.0)
	
	if sol_hour >= 9 and sol_hour < 16:
		return Color(1.0, 0.96, 0.90, 1.0)
	elif (sol_hour >= 6 and sol_hour < 9) or (sol_hour >= 16 and sol_hour < 19):
		return Color(0.92, 0.65, 0.45, 1.0)
	else:
		return Color(0.30, 0.35, 0.48, 1.0)

func _update_ambient_environment() -> void:
	ambient_temp_c = get_ambient_temperature()

func set_weather(w_type: String, w_name: String, wind_kts: float, rad_mSv: float, duration_mins: int = 0) -> void:
	weather_type = w_type
	weather_name = w_name
	wind_speed_kts = wind_kts
	radiation_mSv = rad_mSv
	weather_duration_mins = duration_mins
	_update_ambient_environment()
	emit_signal("weather_changed", weather_type, wind_speed_kts, ambient_temp_c)
	add_log_entry("WEATHER", "Atmospheric alert: " + weather_name)

func _on_new_sol() -> void:
	modify_resource("food", -2.0)
	add_log_entry("SOL", "Commenced Sol %03d operational cycle." % current_sol)
	
	# Sol 2 Perseid storm front
	if current_sol == 2 and weather_type == "CLEAR":
		set_weather("DUST_STORM", "PERSEID DUST GALE", 64.0, 0.38, 360)
	elif current_sol >= 3 and weather_type == "DUST_STORM" and weather_duration_mins <= 0:
		set_weather("CLEAR", "OPTIMAL / CLEAR", 14.0, 0.22, 0)

func simulation_step(delta_mins: int = 15) -> void:
	advance_time(delta_mins)
	
	# Weather timer decrement
	if weather_duration_mins > 0:
		weather_duration_mins -= delta_mins
		if weather_duration_mins <= 0 and weather_type == "DUST_STORM":
			set_weather("CLEAR", "OPTIMAL / CLEAR", 14.0, 0.22, 0)
			add_log_entry("WEATHER", "Perseid atmospheric disturbance resolved. Surface clear.")
	
	# 1. Power balance (Solar generation vs Hab heating & Life Support)
	var daylight = get_daylight_factor()
	var solar_gen = daylight * (solar_efficiency / 100.0) * 16.0
	if weather_type == "DUST_STORM":
		solar_gen *= 0.30 # 70% attenuation from dust haze
		
	var has_thorne = assigned_roster.has("thorne")
	var base_load = 3.5 if is_daytime() else 5.5
	if has_thorne:
		base_load *= 0.80 # Thorne's electrical optimization reduces drain by 20%
		
	var net_power = solar_gen - base_load
	modify_resource("power", net_power)
	
	# 2. Oxygen & Water life support
	var has_chen = assigned_roster.has("chen")
	var o2_burn = 0.85 if has_chen else 1.1 # Dr. Chen life-support efficiency
	modify_resource("oxygen", -o2_burn)
	modify_resource("water", -0.5)
	
	# 3. Habitat condition & Power failure
	if resources["power"]["current"] <= 0.0:
		habitat_integrity = max(0.0, habitat_integrity - 1.2)
		for cid in assigned_roster:
			if cid != "" and crew_database.has(cid):
				crew_database[cid]["condition"] = max(0.0, crew_database[cid]["condition"] - 0.8)
		add_log_entry("CRITICAL", "Habitat blackout! Thermal scrubbers failing from power loss.")
	elif weather_type == "DUST_STORM":
		habitat_integrity = max(0.0, habitat_integrity - 0.15)
		solar_efficiency = max(45.0, solar_efficiency - 0.2)
		
	# 4. Crew Fatigue and Morale
	var has_vance = assigned_roster.has("vance")
	for cid in assigned_roster:
		if cid != "" and crew_database.has(cid):
			var c = crew_database[cid]
			var fatigue_gain = 0.4
			if weather_type == "DUST_STORM":
				fatigue_gain += 0.8
			c["fatigue"] = min(100.0, c["fatigue"] + fatigue_gain)
			
			# High fatigue causes health degradation
			if c["fatigue"] >= 75.0:
				c["condition"] = max(0.0, c["condition"] - 0.5)
				c["morale"] = max(0.0, c["morale"] - (0.5 if has_vance else 1.0))
			_update_crew_status_tag(c)
			
	# 5. Check alerts
	var alerts = get_active_alerts()
	if alerts.size() > 0:
		emit_signal("alert_triggered", alerts[0])

func get_active_alerts() -> Array[Dictionary]:
	var alerts: Array[Dictionary] = []
	if resources["oxygen"]["current"] <= 200.0:
		alerts.append({"level": "CRITICAL", "message": "CRITICAL: O2 RESERVES DEPLETED BELOW 20%"})
	if resources["power"]["current"] <= 250.0:
		alerts.append({"level": "CRITICAL", "message": "CRITICAL: MAIN BATTERY UNDER 20% CAPACITY"})
	if resources["water"]["current"] <= 150.0:
		alerts.append({"level": "WARNING", "message": "WARNING: POTABLE WATER LOW (< 150 L)"})
	if resources["food"]["current"] <= 15.0:
		alerts.append({"level": "WARNING", "message": "ADVISORY: FOOD RATIONS BELOW 15 PACKS"})
	if habitat_integrity <= 50.0:
		alerts.append({"level": "CRITICAL", "message": "HABITAT BREACH RISK: INTEGRITY UNDER 50%"})
	if radiation_mSv >= 0.8:
		alerts.append({"level": "CRITICAL", "message": "HAZARD: HIGH RADIATION (%.2f mSv) - SHELTER REQUIRED" % radiation_mSv})
	if weather_type == "DUST_STORM":
		alerts.append({"level": "WARNING", "message": "ENVIRONMENT: DUST STORM IN PROGRESS (%.0f KTS)" % wind_speed_kts})
	return alerts

func _update_crew_status_tag(c: Dictionary) -> void:
	if c["condition"] <= 35:
		c["status_tag"] = "CRITICAL"
	elif c["fatigue"] >= 80:
		c["status_tag"] = "EXHAUSTED"
	elif c["fatigue"] >= 50:
		c["status_tag"] = "FATIGUED"
	else:
		c["status_tag"] = "OPTIMAL"

func rest_crew(hours: int = 4) -> Dictionary:
	if resources["food"]["current"] < 2.0 or resources["water"]["current"] < 4.0:
		return {"success": false, "message": "Insufficient rations for rest cycle."}
		
	modify_resource("food", -2.0)
	modify_resource("water", -4.0)
	
	var has_chen = assigned_roster.has("chen")
	var has_vance = assigned_roster.has("vance")
	
	for cid in assigned_roster:
		if cid != "" and crew_database.has(cid):
			var c = crew_database[cid]
			c["fatigue"] = max(0.0, c["fatigue"] - (45.0 if has_chen else 35.0))
			c["condition"] = min(100.0, c["condition"] + (18.0 if has_chen else 10.0))
			c["morale"] = min(100.0, c["morale"] + (15.0 if has_vance else 10.0))
			_update_crew_status_tag(c)
			
	advance_time(hours * 60)
	add_log_entry("HEALTH & SLEEP", "NASA OSDR Sleep Protocol: Crew finished %d-hr restorative cycle in habitat. Cellular fatigue and cognitive focus restored." % hours)
	emit_signal("crew_updated")
	return {"success": true, "message": "Rest cycle completed. Fatigue relieved and vitals stabilized."}

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save_file() -> bool:
	if has_save_file():
		var err = DirAccess.remove_absolute(SAVE_PATH)
		return err == OK
	return true

func save_game() -> bool:
	var data := {
		"current_sol": current_sol,
		"sol_hour": sol_hour,
		"sol_minute": sol_minute,
		"current_time_str": current_time_str,
		"expedition_duration": expedition_duration,
		"difficulty": difficulty,
		"selected_site_id": selected_site_id,
		"assigned_roster": assigned_roster,
		"resources": resources,
		"habitat_integrity": habitat_integrity,
		"solar_efficiency": solar_efficiency,
		"radiation_mSv": radiation_mSv,
		"weather_type": weather_type,
		"weather_name": weather_name,
		"wind_speed_kts": wind_speed_kts,
		"ambient_temp_c": ambient_temp_c,
		"weather_duration_mins": weather_duration_mins,
		"crew_database": crew_database,
		"objectives": objectives,
		"discoveries": discoveries,
		"mission_logs": mission_logs,
		"last_outcome": last_outcome,
		"last_narrative": last_narrative
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "  "))
		file.close()
		return true
	return false

func load_game() -> bool:
	if not has_save_file():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var content = file.get_as_text()
	file.close()
	var test_json_conv = JSON.new()
	var err = test_json_conv.parse(content)
	if err != OK:
		return false
	var data = test_json_conv.data
	if typeof(data) != TYPE_DICTIONARY:
		return false
	
	current_sol = data.get("current_sol", 1)
	sol_hour = data.get("sol_hour", 8)
	sol_minute = data.get("sol_minute", 30)
	current_time_str = data.get("current_time_str", "08:30")
	expedition_duration = data.get("expedition_duration", 45)
	difficulty = data.get("difficulty", "HARD")
	selected_site_id = data.get("selected_site_id", "site_a")
	assigned_roster = Array(data.get("assigned_roster", ["vance", "chen", "thorne", "rostova"]), TYPE_STRING, &"", null)
	resources = data.get("resources", resources)
	habitat_integrity = data.get("habitat_integrity", 100.0)
	solar_efficiency = data.get("solar_efficiency", 94.0)
	radiation_mSv = data.get("radiation_mSv", 0.22)
	weather_type = data.get("weather_type", "CLEAR")
	weather_name = data.get("weather_name", "OPTIMAL / CLEAR")
	wind_speed_kts = data.get("wind_speed_kts", 14.0)
	ambient_temp_c = data.get("ambient_temp_c", -62.0)
	weather_duration_mins = data.get("weather_duration_mins", 0)
	crew_database = data.get("crew_database", crew_database)
	objectives = Array(data.get("objectives", objectives), TYPE_DICTIONARY, &"", null)
	discoveries = Array(data.get("discoveries", discoveries), TYPE_DICTIONARY, &"", null)
	mission_logs = Array(data.get("mission_logs", mission_logs), TYPE_DICTIONARY, &"", null)
	last_outcome = data.get("last_outcome", "")
	last_narrative = data.get("last_narrative", "")
	return true

func calculate_staged_resources() -> Dictionary:
	var base_o2 := 850.0
	var base_water := 620.0
	var base_food := 90.0
	var base_power := 1200.0
	
	match expedition_duration:
		1:
			# 1-Sol Intensive Survival Trainer for MVP (balanced for a full 24-hr day/night cycle)
			base_o2 = 350.0
			base_water = 240.0
			base_food = 30.0
			base_power = 650.0
		30:
			base_o2 = 600.0
			base_water = 450.0
			base_food = 60.0
			base_power = 900.0
		45:
			base_o2 = 850.0
			base_water = 620.0
			base_food = 90.0
			base_power = 1200.0
		90:
			base_o2 = 1500.0
			base_water = 1100.0
			base_food = 180.0
			base_power = 2000.0
		180:
			base_o2 = 24000.0
			base_water = 18500.0
			base_food = 720.0
			base_power = 2400.0
			
	var mult := 1.0
	match difficulty:
		"NORMAL": mult = 1.2
		"HARD": mult = 1.0
		"EXTREME": mult = 0.8
		
	var max_o2 = base_o2 * 1.15
	var max_water = base_water * 1.1
	var max_food = base_food
	var max_power = base_power * 1.25
	
	return {
		"oxygen": {"current": base_o2 * mult, "max": max_o2, "unit": "O2" if expedition_duration <= 90 else "L"},
		"water": {"current": base_water * mult, "max": max_water, "unit": "L"},
		"food": {"current": base_food * mult, "max": max_food, "unit": "PACKS" if expedition_duration <= 90 else "UNITS"},
		"power": {"current": base_power * mult, "max": max_power, "unit": "kWh"}
	}

func get_mission_timeline() -> Array[Dictionary]:
	if expedition_duration == 1:
		return [
			{"phase": "01", "name": "TOUCHDOWN & PRESSURIZATION", "range": "SOL 01 // 08:00-11:00", "status": "READY"},
			{"phase": "02", "name": "PEAK SOLAR & DRILLING", "range": "SOL 01 // 11:00-15:00", "status": "READY"},
			{"phase": "03", "name": "AFTERNOON EXPLORATION", "range": "SOL 01 // 15:00-19:00", "status": "IN-PLAN"},
			{"phase": "04", "name": "NIGHT SURVIVAL & DEBRIEF", "range": "SOL 01 // 19:00-08:00", "status": "PLANNING"}
		]
		
	var p1_end = max(2, int(expedition_duration * 0.1))
	var p2_end = max(p1_end + 3, int(expedition_duration * 0.25))
	var p3_end = max(p2_end + 10, int(expedition_duration * 0.85))
	
	return [
		{"phase": "01", "name": "LANDING", "range": "SOL 01-%02d" % p1_end, "status": "READY"},
		{"phase": "02", "name": "SITE ASSESSMENT", "range": "SOL %02d-%02d" % [p1_end + 1, p2_end], "status": "READY"},
		{"phase": "03", "name": "SURFACE EXPLORATION", "range": "SOL %02d-%02d" % [p2_end + 1, p3_end], "status": "IN-PLAN"},
		{"phase": "04", "name": "RETURN STAGING", "range": "SOL %02d-%02d" % [p3_end + 1, expedition_duration], "status": "PLANNING"}
	]

func get_directive_advisory() -> String:
	var has_sci = assigned_roster.has("rostova") or assigned_roster.has("einstein")
	var has_eng = assigned_roster.has("thorne")
	
	if not has_sci:
		return "⚠ CRITICAL SCIENCE DEFICIT: Acidalia Planitia requires sub-surface aquifer extraction. Assigning a Science specialist (Dr. Rostova or Einstien) is urgently recommended!"
	elif not has_eng:
		return "⚠ ADVISORY: Missing dedicated Systems Engineer. Electrical grid and habitat life-support stabilization will have narrower margins during Perseid dust storms."
	elif assigned_roster.has("rostova"):
		return "Acidalia Planitia requires sub-surface water extraction. Assigning Dr. Elena Rostova covers critical Science prerequisites (+54% surge)."
	else:
		return "Balanced team roster confirmed. Expedition crew meets primary mission operational criteria."

func get_selected_site_data() -> Dictionary:
	return sites_database.get(selected_site_id, sites_database["site_a"])

func start_new_mission() -> void:
	current_sol = 1
	sol_hour = 8
	sol_minute = 30
	current_time_str = "08:30"
	habitat_integrity = 100.0
	
	var site = get_selected_site_data()
	solar_efficiency = 94.0 if site["id"] == "site_a" else (82.0 if site["id"] == "site_c" else 75.0)
	radiation_mSv = site["rad"]
	weather_type = "CLEAR"
	weather_name = "OPTIMAL / CLEAR"
	wind_speed_kts = 14.0
	weather_duration_mins = 0
	_update_ambient_environment()
	
	for cid in crew_database:
		crew_database[cid]["condition"] = 100.0
		crew_database[cid]["fatigue"] = 0.0
		crew_database[cid]["morale"] = 92.0
		_update_crew_status_tag(crew_database[cid])
		
	resources = calculate_staged_resources()
	objectives = get_default_objectives()
	
	discoveries.clear()
	mission_logs.clear()
	add_log_entry("MISSION", "Expedition touchdown at %s confirmed." % site["title"])
	add_log_entry("SURFACE", "Core Hab pressurized. Surface telemetry initialized on %s difficulty." % difficulty)
	emit_signal("mission_started")
