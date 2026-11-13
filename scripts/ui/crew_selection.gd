extends Control

@onready var candidate_list_container: VBoxContainer = $Margin/VBox/CenterContent/LeftCol/VBox/CandidateScroll/List
@onready var filter_tabs: HBoxContainer = $Margin/VBox/CenterContent/LeftCol/VBox/Tabs

# Middle details
@onready var selected_name_label: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/Hdr
@onready var radar_chart: RadarChart = $Margin/VBox/CenterContent/MiddleCol/VBox/RadarContainer/RadarChart
@onready var overall_index_label: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/MatrixHdr/IndexLabel

@onready var bar_phys: SegmentedBar = $Margin/VBox/CenterContent/MiddleCol/VBox/Bars/Phys/Bar
@onready var lbl_phys: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/Bars/Phys/Hdr/Val
@onready var bar_sci: SegmentedBar = $Margin/VBox/CenterContent/MiddleCol/VBox/Bars/Sci/Bar
@onready var lbl_sci: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/Bars/Sci/Hdr/Val
@onready var bar_lead: SegmentedBar = $Margin/VBox/CenterContent/MiddleCol/VBox/Bars/Lead/Bar
@onready var lbl_lead: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/Bars/Lead/Hdr/Val
@onready var bar_psy: SegmentedBar = $Margin/VBox/CenterContent/MiddleCol/VBox/Bars/Psy/Bar
@onready var lbl_psy: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/Bars/Psy/Hdr/Val
@onready var bar_exp: SegmentedBar = $Margin/VBox/CenterContent/MiddleCol/VBox/Bars/Exp/Bar
@onready var lbl_exp: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/Bars/Exp/Hdr/Val

# Right roster
@onready var roster_header_count: Label = $Margin/VBox/CenterContent/RightCol/VBox/Hdr/CountLabel
@onready var slots_container: VBoxContainer = $Margin/VBox/CenterContent/RightCol/VBox/SlotsContainer

@onready var bar_team_eng: SegmentedBar = $Margin/VBox/CenterContent/RightCol/VBox/ReadinessMatrix/Eng/Bar
@onready var lbl_team_eng: Label = $Margin/VBox/CenterContent/RightCol/VBox/ReadinessMatrix/Eng/Hdr/Val
@onready var bar_team_med: SegmentedBar = $Margin/VBox/CenterContent/RightCol/VBox/ReadinessMatrix/Med/Bar
@onready var lbl_team_med: Label = $Margin/VBox/CenterContent/RightCol/VBox/ReadinessMatrix/Med/Hdr/Val
@onready var bar_team_exp: SegmentedBar = $Margin/VBox/CenterContent/RightCol/VBox/ReadinessMatrix/Exp/Bar
@onready var lbl_team_exp: Label = $Margin/VBox/CenterContent/RightCol/VBox/ReadinessMatrix/Exp/Hdr/Val
@onready var bar_team_sci: SegmentedBar = $Margin/VBox/CenterContent/RightCol/VBox/ReadinessMatrix/Sci/Bar
@onready var lbl_team_sci: Label = $Margin/VBox/CenterContent/RightCol/VBox/ReadinessMatrix/Sci/Hdr/Val
@onready var lbl_viable: Label = $Margin/VBox/CenterContent/RightCol/VBox/ReadinessMatrix/Hdr/ViableLabel
@onready var advisory_text: Label = $Margin/VBox/CenterContent/RightCol/VBox/AdvisoryBox/Margin/VBox/Text

# Navigation
@onready var back_btn: Button = $Margin/VBox/BottomDock/BackBtn
@onready var proceed_btn: Button = $Margin/VBox/BottomDock/ProceedBtn

var current_candidate_id: String = "rostova"
var current_filter: String = "ALL"

func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	proceed_btn.pressed.connect(_on_proceed_pressed)
	GameState.crew_updated.connect(_refresh_all)
	
	_setup_filter_tabs()
	_refresh_all()
	proceed_btn.grab_focus()

func _setup_filter_tabs() -> void:
	for child in filter_tabs.get_children():
		if child is Button:
			child.pressed.connect(func(): _on_filter_changed(child.name))

func _on_filter_changed(tab_name: String) -> void:
	current_filter = tab_name
	_refresh_candidates_list()

func _refresh_all() -> void:
	_refresh_candidates_list()
	_show_candidate_details(current_candidate_id)
	_refresh_roster_slots()
	_refresh_team_readiness()

func _refresh_candidates_list() -> void:
	for c in candidate_list_container.get_children():
		c.queue_free()
		
	for cid in GameState.crew_database.keys():
		var data = GameState.crew_database[cid]
		if current_filter != "ALL" and data["category"] != current_filter:
			continue
			
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 56)
		card.set_script(preload("res://scenes/components/terminal_panel.gd"))
		card.is_card = true
		card.corner_accent = false
		
		var is_selected : bool = (cid == current_candidate_id)
		card.is_highlighted = is_selected
		
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_right", 12)
		card.add_child(margin)
		
		var hbox := HBoxContainer.new()
		margin.add_child(hbox)
		
		var name_box := VBoxContainer.new()
		name_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_box.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_child(name_box)
		
		var lbl_name := Label.new()
		lbl_name.text = data["name"]
		lbl_name.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
		lbl_name.add_theme_font_size_override("font_size", 14)
		name_box.add_child(lbl_name)
		
		var is_in_roster = GameState.assigned_roster.has(cid)
		var roster_slot_num = GameState.assigned_roster.find(cid) + 1 if is_in_roster else -1
		
		var lbl_sub := Label.new()
		if is_in_roster:
			lbl_sub.text = "[ IN ROSTER - 0%d ]" % roster_slot_num
			lbl_sub.add_theme_color_override("font_color", GameState.COLOR_CYAN)
		else:
			lbl_sub.text = "STATUS: AVAILABLE"
			lbl_sub.add_theme_color_override("font_color", GameState.COLOR_TEXT_MUTED)
		lbl_sub.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
		lbl_sub.add_theme_font_size_override("font_size", 11)
		name_box.add_child(lbl_sub)
		
		var btn_assign := Button.new()
		btn_assign.custom_minimum_size = Vector2(90, 32)
		btn_assign.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
		btn_assign.add_theme_font_size_override("font_size", 11)
		
		if is_in_roster:
			btn_assign.text = "ASSIGNED"
			btn_assign.disabled = true
			btn_assign.add_theme_color_override("font_color", GameState.COLOR_TEXT_MUTED)
		else:
			btn_assign.text = "ASSIGN"
			btn_assign.add_theme_color_override("font_color", GameState.COLOR_CYAN)
			btn_assign.pressed.connect(func(): _assign_candidate(cid))
		hbox.add_child(btn_assign)
		
		# Make whole card clickable to view details
		card.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				current_candidate_id = cid
				_refresh_all()
		)
		
		candidate_list_container.add_child(card)

func _show_candidate_details(cid: String) -> void:
	if not GameState.crew_database.has(cid):
		return
	var d = GameState.crew_database[cid]
	selected_name_label.text = "▶ " + d["name"].to_upper()
	radar_chart.stats = d["radar"]
	overall_index_label.text = "INDEX: OPTIMAL (%.1f OVR)" % d["overall"]
	
	bar_phys.fill_ratio = d["radar"]["PHYS"] / 100.0
	lbl_phys.text = "%d%% FIT-A" % d["radar"]["PHYS"]
	
	bar_sci.fill_ratio = d["radar"]["SCI"] / 100.0
	lbl_sci.text = "%d%% EXPERT" % d["radar"]["SCI"]
	
	bar_lead.fill_ratio = d["radar"]["LEAD"] / 100.0
	lbl_lead.text = "%d%% CLASS-II" % d["radar"]["LEAD"]
	
	bar_psy.fill_ratio = d["radar"]["PSY"] / 100.0
	lbl_psy.text = "%d%% STABLE" % d["radar"]["PSY"]
	
	bar_exp.fill_ratio = d["radar"]["EXP"] / 100.0
	lbl_exp.text = "%d%% VETERAN" % d["radar"]["EXP"]

func _assign_candidate(cid: String) -> void:
	# Find first empty slot
	var empty_idx := GameState.assigned_roster.find("")
	if empty_idx == -1:
		empty_idx = 3 # overwrite slot 4 by default if full
	GameState.assign_candidate_to_slot(cid, empty_idx)

func _refresh_roster_slots() -> void:
	for c in slots_container.get_children():
		c.queue_free()
		
	var active_count := 0
	for i in range(4):
		var cid = GameState.assigned_roster[i]
		var slot_card := PanelContainer.new()
		slot_card.custom_minimum_size = Vector2(0, 54)
		slot_card.set_script(preload("res://scenes/components/terminal_panel.gd"))
		slot_card.is_card = true
		slot_card.corner_accent = false
		
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_right", 10)
		slot_card.add_child(margin)
		
		var hbox := HBoxContainer.new()
		margin.add_child(hbox)
		
		var num_lbl := Label.new()
		num_lbl.text = "0%d" % (i + 1)
		num_lbl.custom_minimum_size = Vector2(28, 0)
		num_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
		num_lbl.add_theme_font_size_override("font_size", 12)
		num_lbl.add_theme_color_override("font_color", GameState.COLOR_CYAN)
		hbox.add_child(num_lbl)
		
		var info_box := VBoxContainer.new()
		info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_box.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_child(info_box)
		
		if cid != "" and GameState.crew_database.has(cid):
			active_count += 1
			var d = GameState.crew_database[cid]
			var name_lbl := Label.new()
			name_lbl.text = d["short_name"]
			name_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			name_lbl.add_theme_font_size_override("font_size", 13)
			info_box.add_child(name_lbl)
			
			var role_lbl := Label.new()
			role_lbl.text = d["title"]
			role_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			role_lbl.add_theme_font_size_override("font_size", 11)
			role_lbl.add_theme_color_override("font_color", GameState.COLOR_TEXT_MUTED)
			info_box.add_child(role_lbl)
			
			var unassign_btn := Button.new()
			unassign_btn.text = "[X]"
			unassign_btn.custom_minimum_size = Vector2(32, 28)
			unassign_btn.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			unassign_btn.add_theme_font_size_override("font_size", 11)
			unassign_btn.pressed.connect(func(): GameState.unassign_slot(i))
			hbox.add_child(unassign_btn)
		else:
			slot_card.is_highlighted = true
			var empty_lbl := Label.new()
			empty_lbl.text = "[ EMPTY SLOT 0%d ]" % (i + 1)
			empty_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			empty_lbl.add_theme_font_size_override("font_size", 12)
			empty_lbl.add_theme_color_override("font_color", GameState.COLOR_AMBER)
			info_box.add_child(empty_lbl)
			
			var sub_lbl := Label.new()
			sub_lbl.text = "WAITING ASSIGNMENT..."
			sub_lbl.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
			sub_lbl.add_theme_font_size_override("font_size", 10)
			sub_lbl.add_theme_color_override("font_color", GameState.COLOR_TEXT_MUTED)
			info_box.add_child(sub_lbl)
			
			var select_btn := Button.new()
			select_btn.text = "[SELECT]"
			select_btn.custom_minimum_size = Vector2(70, 28)
			select_btn.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Bold.ttf"))
			select_btn.add_theme_font_size_override("font_size", 11)
			select_btn.pressed.connect(func(): GameState.assign_candidate_to_slot(current_candidate_id, i))
			hbox.add_child(select_btn)
			
		slots_container.add_child(slot_card)
		
	roster_header_count.text = "%d/4 READY" % active_count
	proceed_btn.disabled = not GameState.is_roster_complete()

func _refresh_team_readiness() -> void:
	var r = GameState.calculate_team_readiness()
	bar_team_eng.fill_ratio = r["ENG"] / 100.0
	lbl_team_eng.text = "%d%% (OPT)" % r["ENG"]
	
	bar_team_med.fill_ratio = r["MED"] / 100.0
	lbl_team_med.text = "%d%% (OPT)" % r["MED"]
	
	bar_team_exp.fill_ratio = r["EXP"] / 100.0
	lbl_team_exp.text = "%d%% (ADEQ)" % r["EXP"]
	
	bar_team_sci.fill_ratio = r["SCI"] / 100.0
	if r["SCI"] < 50:
		lbl_team_sci.text = "%d%% [WARN]" % r["SCI"]
		bar_team_sci.fill_color = GameState.COLOR_RED
	else:
		lbl_team_sci.text = "%d%% (OPT)" % r["SCI"]
		bar_team_sci.fill_color = GameState.COLOR_CYAN
		
	lbl_viable.text = "%d%% VIABLE" % r["viable"]
	advisory_text.text = GameState.get_directive_advisory()

func _on_back_pressed() -> void:
	GameState.change_screen("mission_briefing")

func _on_proceed_pressed() -> void:
	if GameState.is_roster_complete():
		GameState.change_screen("mission_planner")
