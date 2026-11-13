extends Control

@onready var back_btn: Button = $Margin/VBox/BottomDock/BackBtn
@onready var next_btn: Button = $Margin/VBox/BottomDock/NextBtn

@onready var crew_container: VBoxContainer = $Margin/VBox/CenterContent/LeftCol/VBox/CrewAssignment/List
@onready var subheader_label: Label = $Margin/VBox/Subheader/Margin/Label

# Timeline
@onready var p1_desc: Label = $Margin/VBox/CenterContent/LeftCol/VBox/TimelineList/P1/Desc
@onready var p2_desc: Label = $Margin/VBox/CenterContent/LeftCol/VBox/TimelineList/P2/Desc
@onready var p3_desc: Label = $Margin/VBox/CenterContent/LeftCol/VBox/TimelineList/P3/Desc
@onready var p4_desc: Label = $Margin/VBox/CenterContent/LeftCol/VBox/TimelineList/P4/Desc

# Allocations
@onready var o2_val: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/O2/Hdr/V
@onready var o2_bar: SegmentedBar = $Margin/VBox/CenterContent/MiddleCol/VBox/O2/Bar
@onready var water_val: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/Water/Hdr/V
@onready var water_bar: SegmentedBar = $Margin/VBox/CenterContent/MiddleCol/VBox/Water/Bar
@onready var food_val: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/Food/Hdr/V
@onready var food_bar: SegmentedBar = $Margin/VBox/CenterContent/MiddleCol/VBox/Food/Bar
@onready var energy_val: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/Energy/Hdr/V
@onready var energy_bar: SegmentedBar = $Margin/VBox/CenterContent/MiddleCol/VBox/Energy/Bar

func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	_update_crew_list()
	_update_header()
	_update_timeline()
	_update_allocations()
	next_btn.grab_focus()

func _update_header() -> void:
	var site = GameState.get_selected_site_data()
	var dur_str = "1 SOL (INTENSIVE)" if GameState.expedition_duration == 1 else ("%d SOLS" % GameState.expedition_duration)
	subheader_label.text = "TARGET INSERTION: %s | ORBITAL WINDOW: SYNCED | %s | STAGE: FINAL REVIEW | READINESS: 91%% [STAGE OK]" % [site["title"].trim_prefix("SITE-A: ").trim_prefix("SITE-B: ").trim_prefix("SITE-C: ").trim_prefix("SITE-D: "), dur_str]

func _update_timeline() -> void:
	var phases = GameState.get_mission_timeline()
	p1_desc.text = "%s: %s  (%s)" % [phases[0]["phase"], phases[0]["name"], phases[0]["range"]]
	p2_desc.text = "%s: %s  (%s)" % [phases[1]["phase"], phases[1]["name"], phases[1]["range"]]
	p3_desc.text = "%s: %s  (%s)" % [phases[2]["phase"], phases[2]["name"], phases[2]["range"]]
	p4_desc.text = "%s: %s  (%s)" % [phases[3]["phase"], phases[3]["name"], phases[3]["range"]]

func _update_allocations() -> void:
	var staged = GameState.calculate_staged_resources()
	
	var o2 = staged["oxygen"]
	var o2_pct = int((o2["current"] / o2["max"]) * 100.0)
	o2_val.text = "%s / %s %s [%d%%]" % [String.num(o2["current"], 0), String.num(o2["max"], 0), o2["unit"], o2_pct]
	o2_bar.fill_ratio = o2["current"] / o2["max"]
	
	var w = staged["water"]
	var w_pct = int((w["current"] / w["max"]) * 100.0)
	water_val.text = "%s / %s %s [%d%%]" % [String.num(w["current"], 0), String.num(w["max"], 0), w["unit"], w_pct]
	water_bar.fill_ratio = w["current"] / w["max"]
	
	var f = staged["food"]
	var f_pct = int((f["current"] / f["max"]) * 100.0)
	food_val.text = "%s / %s %s [%d%%]" % [String.num(f["current"], 0), String.num(f["max"], 0), f["unit"], f_pct]
	food_bar.fill_ratio = f["current"] / f["max"]
	
	var e = staged["power"]
	var e_pct = int((e["current"] / e["max"]) * 100.0)
	energy_val.text = "%s / %s %s [%d%%]" % [String.num(e["current"], 0), String.num(e["max"], 0), e["unit"], e_pct]
	energy_bar.fill_ratio = e["current"] / e["max"]

func _update_crew_list() -> void:
	for c in crew_container.get_children():
		c.queue_free()
		
	for cid in GameState.assigned_roster:
		if cid != "" and GameState.crew_database.has(cid):
			var d = GameState.crew_database[cid]
			var row := HBoxContainer.new()
			
			var info_box := VBoxContainer.new()
			info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var name_lbl := Label.new()
			name_lbl.text = d["name"].to_upper()
			name_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			name_lbl.add_theme_font_size_override("font_size", 12)
			info_box.add_child(name_lbl)
			
			var spec_lbl := Label.new()
			spec_lbl.text = d["spec"]
			spec_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			spec_lbl.add_theme_font_size_override("font_size", 11)
			spec_lbl.add_theme_color_override("font_color", GameState.COLOR_TEXT_MUTED)
			info_box.add_child(spec_lbl)
			
			row.add_child(info_box)
			
			var badge := Label.new()
			badge.text = "[%s]" % d["code"]
			badge.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			badge.add_theme_font_size_override("font_size", 12)
			badge.add_theme_color_override("font_color", GameState.COLOR_CYAN)
			row.add_child(badge)
			
			crew_container.add_child(row)

func _on_back_pressed() -> void:
	GameState.change_screen("crew_selection")

func _on_next_pressed() -> void:
	GameState.change_screen("outpost_selection")
