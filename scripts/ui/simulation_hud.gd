extends Control

@onready var viewport: SubViewport = $ViewportContainer/SubViewport
@onready var mars_surface: Node2D = $ViewportContainer/SubViewport/MarsSurface

# HUD Top Telemetry
@onready var o2_bar: SegmentedBar = $HUD/Margin/VBox/TopBar/Margin/HBox/Telemetry/O2Box/Bar
@onready var o2_val: Label = $HUD/Margin/VBox/TopBar/Margin/HBox/Telemetry/O2Box/Hdr/Val
@onready var water_bar: SegmentedBar = $HUD/Margin/VBox/TopBar/Margin/HBox/Telemetry/WaterBox/Bar
@onready var water_val: Label = $HUD/Margin/VBox/TopBar/Margin/HBox/Telemetry/WaterBox/Hdr/Val
@onready var food_bar: SegmentedBar = $HUD/Margin/VBox/TopBar/Margin/HBox/Telemetry/FoodBox/Bar
@onready var food_val: Label = $HUD/Margin/VBox/TopBar/Margin/HBox/Telemetry/FoodBox/Hdr/Val
@onready var power_bar: SegmentedBar = $HUD/Margin/VBox/TopBar/Margin/HBox/Telemetry/PowerBox/Bar
@onready var power_val: Label = $HUD/Margin/VBox/TopBar/Margin/HBox/Telemetry/PowerBox/Hdr/Val

@onready var sol_label: Label = $HUD/Margin/VBox/TopBar/Margin/HBox/TimeBox/SolLabel
@onready var hab_label: Label = $HUD/Margin/VBox/TopBar/Margin/HBox/TimeBox/HabLabel

# Prompt
# Prompts & Alerts
@onready var prompt_banner: PanelContainer = $HUD/Margin/VBox/Center/PromptBanner
@onready var prompt_text: Label = $HUD/Margin/VBox/Center/PromptBanner/Margin/PromptLabel
@onready var alert_banner: PanelContainer = $HUD/Margin/VBox/Center/AlertBanner
@onready var alert_label: Label = $HUD/Margin/VBox/Center/AlertBanner/Margin/AlertLabel

# Objective HUD box
@onready var current_obj_label: Label = $HUD/Margin/VBox/Center/ObjectiveBox/Margin/VBox/ObjText

# Radar Minimap
@onready var minimap: RadarMinimap = $HUD/Margin/VBox/Center/RadarBox/Margin/VBox/Minimap

# Bottom dock buttons
@onready var btn_explore: Button = $HUD/Margin/VBox/BottomDock/HBox/BtnExplore
@onready var btn_crew: Button = $HUD/Margin/VBox/BottomDock/HBox/BtnCrew
@onready var btn_obj: Button = $HUD/Margin/VBox/BottomDock/HBox/BtnObj
@onready var btn_logs: Button = $HUD/Margin/VBox/BottomDock/HBox/BtnLogs
@onready var btn_pause: Button = $HUD/Margin/VBox/BottomDock/HBox/BtnPause

# Modal Popups
@onready var event_modal: PanelContainer = $Modals/EventModal
@onready var event_title: Label = $Modals/EventModal/Margin/VBox/Header/Title
@onready var event_desc: Label = $Modals/EventModal/Margin/VBox/Desc
@onready var event_options_box: VBoxContainer = $Modals/EventModal/Margin/VBox/Options

@onready var crew_modal: PanelContainer = $Modals/CrewModal
@onready var crew_list_box: VBoxContainer = $Modals/CrewModal/Margin/VBox/Scroll/List
@onready var btn_rest_crew: Button = $Modals/CrewModal/Margin/VBox/Actions/RestBtn
@onready var btn_close_crew: Button = $Modals/CrewModal/Margin/VBox/Actions/CloseBtn

@onready var obj_modal: PanelContainer = $Modals/ObjectivesModal
@onready var obj_list_box: VBoxContainer = $Modals/ObjectivesModal/Margin/VBox/Scroll/List

@onready var logs_modal: PanelContainer = $Modals/LogsModal
@onready var tab_discoveries: Button = $Modals/LogsModal/Margin/VBox/Tabs/TabDiscoveries
@onready var tab_logs: Button = $Modals/LogsModal/Margin/VBox/Tabs/TabLogs
@onready var logs_list_box: VBoxContainer = $Modals/LogsModal/Margin/VBox/Scroll/List

@onready var pause_modal: PanelContainer = $Modals/PauseModal
@onready var btn_resume: Button = $Modals/PauseModal/Margin/VBox/ResumeBtn
@onready var btn_save: Button = $Modals/PauseModal/Margin/VBox/SaveBtn
@onready var btn_abort: Button = $Modals/PauseModal/Margin/VBox/AbortBtn
@onready var btn_quit_menu: Button = $Modals/PauseModal/Margin/VBox/QuitBtn
@onready var save_status_lbl: Label = $Modals/PauseModal/Margin/VBox/SaveStatus
@onready var pause_slider_master: HSlider = $Modals/PauseModal/Margin/VBox/AudioBox/Master/Slider
@onready var pause_lbl_master: Label = $Modals/PauseModal/Margin/VBox/AudioBox/Master/Val
@onready var pause_slider_sfx: HSlider = $Modals/PauseModal/Margin/VBox/AudioBox/Sfx/Slider
@onready var pause_lbl_sfx: Label = $Modals/PauseModal/Margin/VBox/AudioBox/Sfx/Val

# State
var tick_accumulator: float = 0.0
var active_event: Dictionary = {}
var eva_dist_accum: float = 0.0
var logs_active_tab: String = "discoveries"

func _ready() -> void:
	mars_surface.player_prompt_changed.connect(_on_prompt_changed)
	mars_surface.poi_selected.connect(_on_poi_interacted)
	if mars_surface.get("player") != null:
		mars_surface.player.moved.connect(_on_player_moved)
		minimap.player_node = mars_surface.player
	minimap.poi_container = mars_surface
	
	GameState.resource_updated.connect(_on_resource_updated)
	GameState.weather_changed.connect(func(_w, _wind, _temp): _update_all_hud())
	GameState.time_advanced.connect(func(_sol, _time): _update_all_hud())
	GameState.crew_updated.connect(func(): if crew_modal.visible: _render_crew_modal())
	GameState.objective_updated.connect(func(_id):
		_update_objective_display()
		if obj_modal.visible:
			_render_obj_modal()
	)
	
	btn_explore.pressed.connect(_close_all_modals)
	btn_crew.pressed.connect(func(): _toggle_modal(crew_modal))
	btn_obj.pressed.connect(func(): _toggle_modal(obj_modal))
	btn_logs.pressed.connect(func(): _toggle_modal(logs_modal))
	btn_pause.pressed.connect(func(): _toggle_modal(pause_modal))
	
	tab_discoveries.pressed.connect(func():
		logs_active_tab = "discoveries"
		_render_logs_modal()
	)
	tab_logs.pressed.connect(func():
		logs_active_tab = "logs"
		_render_logs_modal()
	)
	
	btn_resume.pressed.connect(func(): pause_modal.visible = false)
	btn_save.pressed.connect(_on_save_pressed)
	btn_abort.pressed.connect(func():
		_end_mission("PARTIAL", "Expedition commander ordered premature extraction. Telemetry safely packaged.")
	)
	btn_quit_menu.pressed.connect(_on_quit_to_menu)
	
	pause_slider_master.value_changed.connect(func(v): pause_lbl_master.text = "%d%%" % int(v))
	pause_slider_sfx.value_changed.connect(func(v): pause_lbl_sfx.text = "%d%%" % int(v))
	
	btn_rest_crew.pressed.connect(_on_rest_crew_pressed)
	btn_close_crew.pressed.connect(func(): crew_modal.visible = false)
	
	# Close buttons inside modals
	$Modals/ObjectivesModal/Margin/VBox/CloseBtn.pressed.connect(func(): obj_modal.visible = false)
	$Modals/LogsModal/Margin/VBox/CloseBtn.pressed.connect(func(): logs_modal.visible = false)
	
	_update_all_hud()
	_update_objective_display()

func _process(delta: float) -> void:
	tick_accumulator += delta
	# Simulation heartbeat: tick every 3 seconds
	if tick_accumulator >= 3.0:
		tick_accumulator = 0.0
		_simulation_step()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _has_open_modal():
			_close_all_modals()
		else:
			_toggle_modal(pause_modal)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			_close_all_modals()
		elif event.keycode == KEY_2:
			_toggle_modal(crew_modal)
		elif event.keycode == KEY_3:
			_toggle_modal(obj_modal)
		elif event.keycode == KEY_4:
			_toggle_modal(logs_modal)

func _simulation_step() -> void:
	GameState.simulation_step(15)
	_update_all_hud()
	
	# Check mission ending conditions
	if GameState.resources["oxygen"]["current"] <= 0 or GameState.resources["water"]["current"] <= 0 or GameState.habitat_integrity <= 0:
		_end_mission("FAILED", "Life support or habitat failure critical. Mission aborted.")
	elif GameState.current_sol > GameState.expedition_duration:
		_end_mission("SUCCESS", "Expedition duration fulfilled. Surface mission concluded.")

func _on_prompt_changed(text: String) -> void:
	if text == "":
		prompt_banner.visible = false
	else:
		prompt_text.text = text
		prompt_banner.visible = true

func _on_player_moved(distance: float) -> void:
	eva_dist_accum += distance
	if eva_dist_accum >= 80.0:
		GameState.modify_resource("oxygen", -0.15)
		eva_dist_accum = 0.0

func _show_event(title: String, desc: String, options: Array[Dictionary]) -> void:
	_close_all_modals()
	event_title.text = "⚠ " + title
	event_desc.text = desc
	
	for c in event_options_box.get_children():
		event_options_box.remove_child(c)
		c.queue_free()
		
	for opt in options:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 48)
		var label_str: String = opt.get("label", "CONFIRM")
		var hint_str: String = opt.get("hint", "")
		if hint_str != "":
			btn.text = "%s\n  ↳ %s" % [label_str, hint_str]
		else:
			btn.text = label_str
			
		btn.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
		btn.add_theme_font_size_override("font_size", 12)
		
		var is_prim = opt.get("primary", false)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#142330") if is_prim else Color("#0e1722")
		sb.border_color = Color("#3ce3d9") if is_prim else Color("#293b4e")
		sb.set_border_width_all(2 if is_prim else 1)
		sb.set_content_margin_all(8)
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_color_override("font_color", Color("#3ce3d9") if is_prim else Color("#d0e2ec"))
		
		var cb: Callable = opt.get("callback", func(): pass)
		btn.pressed.connect(func():
			event_modal.visible = false
			cb.call()
			_update_all_hud()
		)
		event_options_box.add_child(btn)
		
	event_modal.visible = true

func _on_poi_interacted(poi_id: String) -> void:
	match poi_id:
		"hab_airlock":
			_handle_hab_airlock_interaction()
		"solar_array":
			_handle_solar_array_interaction()
		"comms_dish":
			_handle_comms_dish_interaction()
		"aquifer_drill":
			_handle_aquifer_drill_interaction()
		"basalt_anomaly":
			_handle_basalt_anomaly_interaction()
		"crate_supplies":
			_handle_crate_supplies_interaction()

func _handle_hab_airlock_interaction() -> void:
	GameState.modify_resource("oxygen", 30.0)
	GameState.add_log_entry("HAB", "Accessed Hab-01 Core airlock. Life support scrubbers equalized.")
	_update_all_hud()
	
	var opt_shield = func():
		GameState.modify_resource("power", -15.0)
		for cid in GameState.assigned_roster:
			if cid != "" and GameState.crew_database.has(cid):
				GameState.crew_database[cid]["fatigue"] = min(100.0, GameState.crew_database[cid]["fatigue"] + 14.0)
		GameState.radiation_mSv = max(0.12, GameState.radiation_mSv - 0.08)
		GameState.habitat_integrity = min(100.0, GameState.habitat_integrity + 15.0)
		GameState.add_log_entry("RADIATION SHIELD", "Poured 1.2 tons of compacted regolith shielding over Hab dome. Internal radiation halved to %.2f mSv/h!" % GameState.radiation_mSv)
		
	_show_event(
		"HAB-01 PRESSURIZATION & RADIATION SHIELDING",
		"Astronaut Cadet Briefing: Space radiation passes straight through thin metal! Shoveling Martian regolith dirt over the Hab dome blocks cosmic rays, but tires out your astronauts. Choose protocol:",
		[
			{
				"label": "SHOVEL REGOLITH RADIATION SHIELD OVER DOME",
				"hint": "[🛡️ Rad Shield: -40% Exposure | Hab Integrity: +15% | 😓 Crew Fatigue: +14 | 🔋 Power: -15]",
				"primary": true,
				"callback": opt_shield
			},
			{
				"label": "STANDARD AIRLOCK REPRESSURIZATION ONLY",
				"hint": "[🫁 O2: +30 Restored | 🔋 Power: +0 Safe Reserves | Zero Crew Fatigue]",
				"primary": false,
				"callback": func(): pass
			}
		]
	)

func _handle_solar_array_interaction() -> void:
	GameState.solar_efficiency = min(100.0, GameState.solar_efficiency + 8.0)
	GameState.modify_resource("power", 75.0)
	GameState.complete_objective("sec_solar")
	_update_all_hud()
	
	var opt_overclock = func():
		GameState.modify_resource("power", 120.0)
		GameState.habitat_integrity = max(0.0, GameState.habitat_integrity - 4.0)
		GameState.add_log_entry("POWER", "Inverters overclocked for maximum energy capture.")
		
	_show_event(
		"PHOTOVOLTAIC ARRAY OPTIMIZATION",
		"Abrasive ferric dust wiped from photovoltaic cells. Collector efficiency elevated to %.1f%%. Choose grid lock profile:" % GameState.solar_efficiency,
		[
			{
				"label": "STANDARD STABILIZED CHARGE PROFILE",
				"hint": "[Battery: +50 kWh | Safe capacitor margins]",
				"primary": true,
				"callback": func(): GameState.modify_resource("power", 50.0)
			},
			{
				"label": "OVERCLOCK CAPACITOR INVERTERS",
				"hint": "[Battery: +120 kWh | Habitat Wear: -4% capacitor strain]",
				"primary": false,
				"callback": opt_overclock
			}
		]
	)

func _handle_comms_dish_interaction() -> void:
	GameState.complete_objective("comms_dish")
	_update_all_hud()
	
	var opt_radar = func():
		GameState.modify_resource("power", -20.0)
		GameState.add_discovery({
			"id": "orbital_radar_void",
			"title": "Orbital Sub-surface Void Map",
			"category": "ORBITAL RADAR",
			"evidence": "Synthetic aperture radar reveals a 120-meter cylindrical hollow cavity 80m beneath Sector 4 crater fault.",
			"science_xp": 450
		})
		for obj in GameState.objectives:
			if obj["id"] == "primary_anomaly" and obj["status"] == "NOT_STARTED":
				obj["status"] = "IN_PROGRESS"
				GameState.emit_signal("objective_updated", "primary_anomaly")
				
	var opt_morale = func():
		GameState.add_log_entry("HQ", "Mission Control confirms crew vitals. Family transmission packets received.")
		for cid in GameState.assigned_roster:
			if cid != "" and GameState.crew_database.has(cid):
				GameState.crew_database[cid]["morale"] = min(100.0, GameState.crew_database[cid]["morale"] + 12.0)
		GameState.emit_signal("crew_updated")
		
	_show_event(
		"DEEP SPACE NETWORK RELAY // 14-MIN SPEED-OF-LIGHT DELAY",
		"Astronaut Cadet Science: Earth is 140 million miles away! Radio waves travel at the speed of light, causing a 14-minute one-way delay. Houston cannot help you in real time! Choose communication bandwidth:",
		[
			{
				"label": "DOWNLOAD NASA ORBITAL RADAR VOID MAP",
				"hint": "[📡 14-Min Light Lag | 🔋 Power: -20 kWh | 🧠 Unlocks: Orbital Sub-surface Void Discovery]",
				"primary": true,
				"callback": opt_radar
			},
			{
				"label": "PING TELEMETRY BEACON & SAVE POWER",
				"hint": "[🔋 Power Saved: +0 | 😊 Crew Morale: +12% from hearing families back on Earth]",
				"primary": false,
				"callback": opt_morale
			}
		]
	)

func _handle_aquifer_drill_interaction() -> void:
	var w_yield = 180.0 if GameState.assigned_roster.has("rostova") else 150.0
	GameState.modify_resource("water", w_yield)
	GameState.complete_objective("primary_water")
	GameState.add_discovery({
		"id": "nasa_swim_ice_core",
		"title": "NASA SWIM Sub-surface Glacier Core",
		"category": "ISRU ICE MAPPING",
		"evidence": "Borehole sample at -38m depth validates NASA SWIM / MRO SHARAD radar dielectric dielectric models. Sub-surface sheet ice confirmed with 84% purity and trace perchlorate salts.",
		"science_xp": 480
	})
	_update_all_hud()
	
	var opt_triangulate = func():
		GameState.modify_resource("power", -25.0)
		for cid in GameState.assigned_roster:
			if cid != "" and GameState.crew_database.has(cid):
				GameState.crew_database[cid]["fatigue"] = min(100.0, GameState.crew_database[cid]["fatigue"] + 15.0)
		GameState.add_discovery({
			"id": "seismic_acoustic_pulse",
			"title": "Harmonic Bedrock Acoustic Pulse",
			"category": "ACOUSTIC",
			"evidence": "Repeating 14.2 Hz harmonic pulse captured in bedrock. Mathematical transform indicates non-volcanic structured resonance.",
			"science_xp": 550
		})
		for obj in GameState.objectives:
			if obj["id"] == "primary_anomaly":
				obj["status"] = "IN_PROGRESS"
				GameState.emit_signal("objective_updated", "primary_anomaly")
				
	var opt_buffer = func():
		GameState.modify_resource("water", 100.0)
		GameState.add_log_entry("MISSION", "Water extraction continued safely without sensor diversion.")
		
	_show_event(
		"SUB-SURFACE SEISMIC PULSE // AQUIFER DISCOVERY",
		"Astronaut Cadet Trade-Off: Water ice drills at -38m detected a rhythmic 14.2 Hz acoustic pulse deep under the ground! Diverting battery power will help discover the mystery, but leaves less energy for tonight's heaters. What should we do?",
		[
			{
				"label": "DIVERT POWER TO TRIANGULATE ACOUSTIC ECHO",
				"hint": "[🧠 New Science Discovery | 🔋 Power: -25 kWh | 😓 Crew Fatigue: +15 | 💧 Water: +" + str(int(w_yield)) + "L]",
				"primary": true,
				"callback": opt_triangulate
			},
			{
				"label": "PUMP MAXIMUM WATER BUFFER INTO HAB TANKS",
				"hint": "[💧 Extra Water: +100 L (Total +" + str(int(w_yield + 100)) + "L) | 🔋 Power Saved: 100% | Zero Fatigue]",
				"primary": false,
				"callback": opt_buffer
			}
		]
	)

func _handle_basalt_anomaly_interaction() -> void:
	GameState.complete_objective("sec_basalt")
	GameState.complete_objective("primary_anomaly")
	GameState.add_discovery({
		"id": "anomalous_basalt_core",
		"title": "Anomalous Silicate Basalt Core",
		"category": "GEOLOGY",
		"evidence": "Micro-lattice alignment in crystalline basalt core exhibits resonance matching the 14.2 Hz pulse. Proves ancient subterranean hydrothermal or engineered architecture.",
		"science_xp": 650
	})
	_update_all_hud()
	
	var opt_end = func():
		_end_mission("SUCCESS", "Primary research anomaly documented and verified. Expedition concludes in victory.")
		
	var opt_explore = func():
		for cid in GameState.assigned_roster:
			if cid != "" and GameState.crew_database.has(cid):
				GameState.crew_database[cid]["morale"] = min(100.0, GameState.crew_database[cid]["morale"] + 15.0)
		GameState.emit_signal("crew_updated")
		
	_show_event(
		"SEDIMENTARY ANOMALY DISCOVERY BREAKTHROUGH",
		"Spectrometric analysis proves mineral lattice alignment not explainable by impact or volcanic cooling. Sub-surface hydrothermal/engineered structure confirmed! Choose mission directive:",
		[
			{
				"label": "TRANSMIT RESEARCH DOSSIER & CONCLUDE EXPEDITION",
				"hint": "[Success: Primary mission directives fulfilled | Transmit to Houston]",
				"primary": true,
				"callback": opt_end
			},
			{
				"label": "LOG EVIDENCE & MAINTAIN SURFACE EXPLORATION",
				"hint": "[Discoveries: Recorded | Crew Morale: +15% | Expedition Continues]",
				"primary": false,
				"callback": opt_explore
			}
		]
	)

func _handle_crate_supplies_interaction() -> void:
	GameState.modify_resource("food", 25.0)
	GameState.modify_resource("oxygen", 40.0)
	GameState.complete_objective("sec_crate")
	GameState.add_discovery({
		"id": "ares_precursor_cache",
		"title": "Ares Survey Expedition Stash",
		"category": "ARES PRECURSOR",
		"evidence": "Emergency canisters sealed with military polymers preserved without atmospheric contamination or regolith leakage.",
		"science_xp": 350
	})
	_update_all_hud()
	
	var opt_morale = func():
		GameState.modify_resource("food", -5.0)
		for cid in GameState.assigned_roster:
			if cid != "" and GameState.crew_database.has(cid):
				GameState.crew_database[cid]["morale"] = min(100.0, GameState.crew_database[cid]["morale"] + 15.0)
		GameState.emit_signal("crew_updated")
		
	_show_event(
		"ARES PRECURSOR EMERGENCY CACHE RECOVERED",
		"Astronaut Cadet Dilemma: You found emergency supplies left by an earlier Ares mission! Do we store everything safely in the Hab dome, or share treat packs to lift the team's spirits?",
		[
			{
				"label": "STORE IN LIFE-SUPPORT BUFFER (SAFETY FIRST)",
				"hint": "[🫁 O2: +40 L | 🍱 Food: +25 Packs | Safe reserves for nighttime survival]",
				"primary": true,
				"callback": func(): pass
			},
			{
				"label": "FEAST RATION PACKS (BOOST CREW MORALE)",
				"hint": "[🍱 Food: -5 Packs | 😊 Crew Morale: +15% across team | Prevents astronaut despair]",
				"primary": false,
				"callback": opt_morale
			}
		]
	)

func _update_objective_display() -> void:
	for obj in GameState.objectives:
		if obj["status"] == "IN_PROGRESS":
			current_obj_label.text = "★ " + obj["title"]
			return
	current_obj_label.text = "★ ALL DIRECTIVES OPERATIONAL"

func _update_all_hud() -> void:
	var o2 = GameState.resources["oxygen"]
	o2_bar.fill_ratio = o2["current"] / o2["max"]
	o2_val.text = "%d %s" % [int(o2["current"]), o2["unit"]]
	if o2_bar.fill_ratio < 0.20:
		o2_bar.fill_color = GameState.COLOR_RED
	elif o2_bar.fill_ratio < 0.35:
		o2_bar.fill_color = GameState.COLOR_AMBER
	else:
		o2_bar.fill_color = GameState.COLOR_CYAN
	
	var w = GameState.resources["water"]
	water_bar.fill_ratio = w["current"] / w["max"]
	water_val.text = "%d %s" % [int(w["current"]), w["unit"]]
	if water_bar.fill_ratio < 0.20:
		water_bar.fill_color = GameState.COLOR_RED
	elif water_bar.fill_ratio < 0.35:
		water_bar.fill_color = GameState.COLOR_AMBER
	else:
		water_bar.fill_color = GameState.COLOR_CYAN
	
	var f = GameState.resources["food"]
	food_bar.fill_ratio = f["current"] / f["max"]
	food_val.text = "%d %s" % [int(f["current"]), f["unit"]]
	if food_bar.fill_ratio < 0.20:
		food_bar.fill_color = GameState.COLOR_RED
	else:
		food_bar.fill_color = GameState.COLOR_GREEN
	
	var p = GameState.resources["power"]
	power_bar.fill_ratio = p["current"] / p["max"]
	power_val.text = "%d %s" % [int(p["current"]), p["unit"]]
	if power_bar.fill_ratio < 0.20:
		power_bar.fill_color = GameState.COLOR_RED
	elif power_bar.fill_ratio < 0.35:
		power_bar.fill_color = GameState.COLOR_AMBER
	else:
		power_bar.fill_color = GameState.COLOR_AMBER
	
	sol_label.text = "SOL %03d // %s" % [GameState.current_sol, GameState.current_time_str]
	hab_label.text = "HAB: %d%% | RAD: %.2f mSv | %s [%.0f kts] | %d°C" % [
		int(GameState.habitat_integrity), 
		GameState.radiation_mSv, 
		GameState.weather_name, 
		GameState.wind_speed_kts, 
		int(GameState.ambient_temp_c)
	]
	
	# Active Alert Banner
	var alerts = GameState.get_active_alerts()
	if alerts.size() > 0:
		var top_alert = alerts[0]
		alert_label.text = top_alert["message"]
		if top_alert["level"] == "CRITICAL":
			alert_label.add_theme_color_override("font_color", GameState.COLOR_RED)
		else:
			alert_label.add_theme_color_override("font_color", GameState.COLOR_AMBER)
		alert_banner.visible = true
	else:
		alert_banner.visible = false
		
	# World ambient lighting based on Sol diurnal phase & weather
	if mars_surface and mars_surface.has_method("update_ambient_lighting"):
		mars_surface.update_ambient_lighting(GameState.get_ambient_tint())

func _on_resource_updated(_res_name: String, _curr: float, _max: float) -> void:
	_update_all_hud()

func _show_quick_event(title: String, desc: String, opt1_text: String, opt1_cb: Callable, opt2_text: String, opt2_cb: Callable) -> void:
	_show_event(title, desc, [
		{"label": opt1_text, "hint": "", "primary": true, "callback": opt1_cb},
		{"label": opt2_text, "hint": "", "primary": false, "callback": opt2_cb}
	])

func _toggle_modal(modal: PanelContainer) -> void:
	var was_vis = modal.visible
	_close_all_modals()
	modal.visible = not was_vis
	if modal.visible:
		if modal == crew_modal:
			_render_crew_modal()
		elif modal == obj_modal:
			_render_obj_modal()
		elif modal == logs_modal:
			_render_logs_modal()

func _close_all_modals() -> void:
	event_modal.visible = false
	crew_modal.visible = false
	obj_modal.visible = false
	logs_modal.visible = false
	pause_modal.visible = false

func _has_open_modal() -> bool:
	return event_modal.visible or crew_modal.visible or obj_modal.visible or logs_modal.visible or pause_modal.visible

func _on_rest_crew_pressed() -> void:
	var res = GameState.rest_crew(4)
	_update_all_hud()
	_render_crew_modal()
	if not res["success"]:
		_show_quick_event("REST CYCLE FAILED", res["message"], "UNDERSTOOD", func(): pass, "DISMISS", func(): pass)

func _render_crew_modal() -> void:
	for c in crew_list_box.get_children():
		c.queue_free()
	for cid in GameState.assigned_roster:
		if cid != "" and GameState.crew_database.has(cid):
			var d = GameState.crew_database[cid]
			var card := PanelContainer.new()
			var style := StyleBoxFlat.new()
			style.bg_color = Color("#111a24")
			style.border_color = Color("#233547")
			style.set_border_width_all(1)
			style.set_content_margin_all(8)
			card.add_theme_stylebox_override("panel", style)
			
			var v := VBoxContainer.new()
			v.add_theme_constant_override("separation", 6)
			
			var top_row := HBoxContainer.new()
			var name_lbl := Label.new()
			name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name_lbl.text = "%s [%s] — %s" % [d["name"], d["code"], d["title"]]
			name_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			name_lbl.add_theme_font_size_override("font_size", 12)
			name_lbl.add_theme_color_override("font_color", Color("#ffffff"))
			top_row.add_child(name_lbl)
			
			var badge := Label.new()
			var tag_str = d.get("status_tag", "OPTIMAL")
			badge.text = "[%s]" % tag_str
			badge.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			badge.add_theme_font_size_override("font_size", 11)
			if tag_str == "CRITICAL":
				badge.add_theme_color_override("font_color", GameState.COLOR_RED)
			elif tag_str == "EXHAUSTED":
				badge.add_theme_color_override("font_color", Color("#e77b4a"))
			elif tag_str == "FATIGUED":
				badge.add_theme_color_override("font_color", GameState.COLOR_AMBER)
			else:
				badge.add_theme_color_override("font_color", GameState.COLOR_GREEN)
			top_row.add_child(badge)
			v.add_child(top_row)
			
			var stats_row := HBoxContainer.new()
			stats_row.add_theme_constant_override("separation", 24)
			
			var vit_lbl := Label.new()
			vit_lbl.text = "VITALS: %d%%" % int(d["condition"])
			vit_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			vit_lbl.add_theme_font_size_override("font_size", 11)
			vit_lbl.add_theme_color_override("font_color", GameState.COLOR_GREEN if d["condition"] > 50 else GameState.COLOR_RED)
			stats_row.add_child(vit_lbl)
			
			var fat_lbl := Label.new()
			fat_lbl.text = "FATIGUE: %d%%" % int(d["fatigue"])
			fat_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			fat_lbl.add_theme_font_size_override("font_size", 11)
			fat_lbl.add_theme_color_override("font_color", GameState.COLOR_AMBER if d["fatigue"] > 50 else GameState.COLOR_CYAN)
			stats_row.add_child(fat_lbl)
			
			var mor_lbl := Label.new()
			mor_lbl.text = "MORALE: %d%%" % int(d["morale"])
			mor_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			mor_lbl.add_theme_font_size_override("font_size", 11)
			mor_lbl.add_theme_color_override("font_color", GameState.COLOR_CYAN)
			stats_row.add_child(mor_lbl)
			
			var spec_lbl := Label.new()
			spec_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spec_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			spec_lbl.text = d["spec"]
			spec_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			spec_lbl.add_theme_font_size_override("font_size", 10)
			spec_lbl.add_theme_color_override("font_color", Color("#7590aa"))
			stats_row.add_child(spec_lbl)
			
			v.add_child(stats_row)
			card.add_child(v)
			crew_list_box.add_child(card)

func _render_obj_modal() -> void:
	for c in obj_list_box.get_children():
		c.queue_free()
		
	var p_hdr := Label.new()
	p_hdr.text = "PRIMARY EXPEDITION DIRECTIVES"
	p_hdr.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
	p_hdr.add_theme_font_size_override("font_size", 13)
	p_hdr.add_theme_color_override("font_color", GameState.COLOR_CYAN)
	obj_list_box.add_child(p_hdr)
	
	for obj in GameState.objectives:
		if obj["type"] in ["PRIMARY", "CRITICAL"]:
			_add_obj_card(obj)
			
	var s_hdr := Label.new()
	s_hdr.text = "SECONDARY EXPLORATION OBJECTIVES"
	s_hdr.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
	s_hdr.add_theme_font_size_override("font_size", 13)
	s_hdr.add_theme_color_override("font_color", GameState.COLOR_AMBER)
	obj_list_box.add_child(s_hdr)
	
	for obj in GameState.objectives:
		if obj["type"] == "SECONDARY":
			_add_obj_card(obj)

func _add_obj_card(obj: Dictionary) -> void:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#111a24")
	style.border_color = Color("#233547")
	style.set_border_width_all(1)
	style.set_content_margin_all(8)
	card.add_theme_stylebox_override("panel", style)
	
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	
	var top := HBoxContainer.new()
	var title := Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.text = obj["title"]
	title.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color("#ffffff"))
	top.add_child(title)
	
	var xp_lbl := Label.new()
	xp_lbl.text = "+%d XP" % obj.get("xp", 300)
	xp_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
	xp_lbl.add_theme_font_size_override("font_size", 11)
	xp_lbl.add_theme_color_override("font_color", GameState.COLOR_CYAN)
	top.add_child(xp_lbl)
	
	var badge := Label.new()
	badge.text = " [%s] " % obj["status"]
	badge.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
	badge.add_theme_font_size_override("font_size", 11)
	if obj["status"] == "COMPLETED":
		badge.add_theme_color_override("font_color", GameState.COLOR_GREEN)
	elif obj["status"] == "IN_PROGRESS":
		badge.add_theme_color_override("font_color", GameState.COLOR_AMBER)
	else:
		badge.add_theme_color_override("font_color", GameState.COLOR_TEXT_MUTED)
	top.add_child(badge)
	v.add_child(top)
	
	var desc := Label.new()
	desc.text = obj["desc"]
	desc.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color("#7590aa"))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(desc)
	
	card.add_child(v)
	obj_list_box.add_child(card)

func _render_logs_modal() -> void:
	tab_discoveries.text = "RESEARCH DISCOVERIES (%d)" % GameState.discoveries.size()
	
	for c in logs_list_box.get_children():
		c.queue_free()
		
	if logs_active_tab == "discoveries":
		tab_discoveries.add_theme_color_override("font_color", GameState.COLOR_CYAN)
		tab_logs.add_theme_color_override("font_color", Color("#8598aa"))
		
		if GameState.discoveries.size() == 0:
			var empty_lbl := Label.new()
			empty_lbl.text = "No scientific discoveries cataloged yet.\nInvestigate Points of Interest (Comms, Borehole, Crater) on the surface."
			empty_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			empty_lbl.add_theme_font_size_override("font_size", 12)
			empty_lbl.add_theme_color_override("font_color", Color("#7590aa"))
			logs_list_box.add_child(empty_lbl)
			return
			
		for disc in GameState.discoveries:
			var card := PanelContainer.new()
			var style := StyleBoxFlat.new()
			style.bg_color = Color("#111a24")
			style.border_color = Color("#293b4e")
			style.set_border_width_all(1)
			style.set_content_margin_all(8)
			card.add_theme_stylebox_override("panel", style)
			
			var v := VBoxContainer.new()
			v.add_theme_constant_override("separation", 4)
			
			var top := HBoxContainer.new()
			var cat_lbl := Label.new()
			cat_lbl.text = "[%s]" % disc.get("category", "SCIENCE")
			cat_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			cat_lbl.add_theme_font_size_override("font_size", 11)
			cat_lbl.add_theme_color_override("font_color", GameState.COLOR_AMBER)
			top.add_child(cat_lbl)
			
			var title_lbl := Label.new()
			title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			title_lbl.text = "  " + disc.get("title", disc.get("name", "Unknown Finding"))
			title_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			title_lbl.add_theme_font_size_override("font_size", 12)
			title_lbl.add_theme_color_override("font_color", Color("#ffffff"))
			top.add_child(title_lbl)
			
			var xp_lbl := Label.new()
			xp_lbl.text = "+%d XP" % disc.get("science_xp", 400)
			xp_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			xp_lbl.add_theme_font_size_override("font_size", 11)
			xp_lbl.add_theme_color_override("font_color", GameState.COLOR_GREEN)
			top.add_child(xp_lbl)
			
			v.add_child(top)
			
			var evid_lbl := Label.new()
			evid_lbl.text = disc.get("evidence", disc.get("desc", ""))
			evid_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			evid_lbl.add_theme_font_size_override("font_size", 11)
			evid_lbl.add_theme_color_override("font_color", Color("#8aa2b8"))
			evid_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			v.add_child(evid_lbl)
			
			card.add_child(v)
			logs_list_box.add_child(card)
	else:
		tab_discoveries.add_theme_color_override("font_color", Color("#8598aa"))
		tab_logs.add_theme_color_override("font_color", GameState.COLOR_CYAN)
		
		for entry in GameState.mission_logs:
			var lbl := Label.new()
			lbl.text = "[SOL %03d // %s] [%s] %s" % [entry["sol"], entry["time"], entry["category"], entry["text"]]
			lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			lbl.add_theme_font_size_override("font_size", 11)
			if entry["category"] == "SCIENCE":
				lbl.add_theme_color_override("font_color", GameState.COLOR_GREEN)
			elif entry["category"] == "OBJECTIVE":
				lbl.add_theme_color_override("font_color", GameState.COLOR_CYAN)
			elif entry["category"] in ["CRITICAL", "HAZARD"]:
				lbl.add_theme_color_override("font_color", GameState.COLOR_RED)
			elif entry["category"] == "WEATHER":
				lbl.add_theme_color_override("font_color", GameState.COLOR_AMBER)
			else:
				lbl.add_theme_color_override("font_color", Color("#c0d0dc"))
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			logs_list_box.add_child(lbl)

func _on_save_pressed() -> void:
	if GameState.save_game():
		save_status_lbl.text = "EXPEDITION SAVED SUCCESSFULLY"
		save_status_lbl.add_theme_color_override("font_color", GameState.COLOR_GREEN)
	else:
		save_status_lbl.text = "ERROR WRITING SAVE FILE"
		save_status_lbl.add_theme_color_override("font_color", GameState.COLOR_RED)

func _on_quit_to_menu() -> void:
	GameState.change_screen("main_menu")

func _end_mission(outcome: String, narrative_summary: String) -> void:
	GameState.last_outcome = outcome
	GameState.last_narrative = narrative_summary
	GameState.add_log_entry("CONCLUSION", narrative_summary)
	GameState.change_screen("mission_report")
