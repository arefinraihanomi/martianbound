extends Control

@onready var outcome_label: Label = $Margin/VBox/CenterContent/LeftCol/VBox/OutcomeBox/OutcomeLabel
@onready var outcome_sub: Label = $Margin/VBox/CenterContent/LeftCol/VBox/OutcomeBox/SubLabel

@onready var o2_val: Label = $Margin/VBox/CenterContent/LeftCol/VBox/ResourceSummary/O2/Val
@onready var water_val: Label = $Margin/VBox/CenterContent/LeftCol/VBox/ResourceSummary/Water/Val
@onready var food_val: Label = $Margin/VBox/CenterContent/LeftCol/VBox/ResourceSummary/Food/Val
@onready var power_val: Label = $Margin/VBox/CenterContent/LeftCol/VBox/ResourceSummary/Power/Val

@onready var obj_summary_box: VBoxContainer = $Margin/VBox/CenterContent/MiddleCol/VBox/Scroll/ObjList
@onready var discoveries_box: VBoxContainer = $Margin/VBox/CenterContent/RightCol/VBox/Scroll/DiscList

@onready var narrative_text: Label = $Margin/VBox/NarrativeBox/Margin/VBox/Text
@onready var finish_btn: Button = $Margin/VBox/BottomDock/FinishBtn

func _ready() -> void:
	finish_btn.pressed.connect(_on_finish_pressed)
	_populate_report()
	finish_btn.grab_focus()

func _populate_report() -> void:
	# Compute status
	var completed_count := 0
	for obj in GameState.objectives:
		if obj["status"] == "COMPLETED":
			completed_count += 1
			
	var o2_pct = (GameState.resources["oxygen"]["current"] / GameState.resources["oxygen"]["max"]) * 100.0
	var water_pct = (GameState.resources["water"]["current"] / GameState.resources["water"]["max"]) * 100.0
	
	# Outcome Determination
	if GameState.last_outcome == "FAILED" or o2_pct <= 0 or water_pct <= 0 or GameState.habitat_integrity <= 0:
		outcome_label.text = "EXPEDITION ABORTED // CRITICAL FAILURE"
		outcome_label.add_theme_color_override("font_color", GameState.COLOR_RED)
		outcome_sub.text = "Catastrophic environmental depletion forced immediate emergency abort." if GameState.last_narrative == "" else GameState.last_narrative
	elif completed_count >= 3 or GameState.last_outcome == "SUCCESS":
		outcome_label.text = "EXPEDITION SUCCESSFUL // OBJECTIVES VERIFIED"
		outcome_label.add_theme_color_override("font_color", GameState.COLOR_GREEN)
		outcome_sub.text = "All critical and secondary mission goals achieved with intact telemetry." if GameState.last_narrative == "" else GameState.last_narrative
	else:
		outcome_label.text = "PARTIAL MISSION SUCCESS"
		outcome_label.add_theme_color_override("font_color", GameState.COLOR_AMBER)
		outcome_sub.text = "Mission parameters concluded with selective scientific returns." if GameState.last_narrative == "" else GameState.last_narrative
		
	# Resources
	o2_val.text = "%d %s" % [int(GameState.resources["oxygen"]["current"]), GameState.resources["oxygen"]["unit"]]
	water_val.text = "%d %s" % [int(GameState.resources["water"]["current"]), GameState.resources["water"]["unit"]]
	food_val.text = "%d %s" % [int(GameState.resources["food"]["current"]), GameState.resources["food"]["unit"]]
	power_val.text = "%d %s" % [int(GameState.resources["power"]["current"]), GameState.resources["power"]["unit"]]
	
	# Objectives
	for c in obj_summary_box.get_children():
		c.queue_free()
	for obj in GameState.objectives:
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.text = obj["title"]
		lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
		lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(lbl)
		
		var status := Label.new()
		status.text = "[%s]" % obj["status"]
		status.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
		status.add_theme_font_size_override("font_size", 12)
		if obj["status"] == "COMPLETED":
			status.add_theme_color_override("font_color", GameState.COLOR_GREEN)
		else:
			status.add_theme_color_override("font_color", GameState.COLOR_AMBER)
		row.add_child(status)
		obj_summary_box.add_child(row)
		
	# Discoveries
	for c in discoveries_box.get_children():
		c.queue_free()
	if GameState.discoveries.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No anomalous samples logged during surface EVA."
		empty_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", GameState.COLOR_TEXT_MUTED)
		discoveries_box.add_child(empty_lbl)
	else:
		for d in GameState.discoveries:
			var d_box := VBoxContainer.new()
			var name_l := Label.new()
			var disc_title = d.get("title", d.get("name", "Unknown Finding"))
			var cat_tag = d.get("category", "SCIENCE")
			var xp_val = d.get("science_xp", 400)
			name_l.text = "★ [%s] %s (+%d XP)" % [cat_tag, disc_title, xp_val]
			name_l.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			name_l.add_theme_font_size_override("font_size", 12)
			name_l.add_theme_color_override("font_color", GameState.COLOR_CYAN)
			d_box.add_child(name_l)
			
			var desc_l := Label.new()
			desc_l.text = d.get("evidence", d.get("desc", ""))
			desc_l.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			desc_l.add_theme_font_size_override("font_size", 11)
			desc_l.add_theme_color_override("font_color", GameState.COLOR_TEXT_WHITE)
			desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			d_box.add_child(desc_l)
			discoveries_box.add_child(d_box)
			
	# Narrative text
	if GameState.last_narrative != "":
		narrative_text.text = "EXPEDITION RESOLUTION DEBRIEF:\n%s\n\nAcidalia Planitia operational status recorded across Sol %d. Habitat integrity held at %d%%. In-situ resource extraction data successfully calibrated against NASA SWIM (Subsurface Water Ice Mapping) and PDS archives. Science transmission package dispatched to Houston Mission Control." % [GameState.last_narrative, GameState.current_sol, int(GameState.habitat_integrity)]
	else:
		narrative_text.text = "ARES Expedition Unit has concluded operations at Acidalia Planitia across Sol %d. The habitat remains stable at %d%% integrity. Sub-surface borehole extraction confirmed massive sheet ice layers correlated with NASA SWIM radar projections. Mission telemetry archived with Houston Mission Control." % [GameState.current_sol, int(GameState.habitat_integrity)]

func _on_finish_pressed() -> void:
	GameState.change_screen("main_menu")
