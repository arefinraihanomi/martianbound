extends Control

@onready var duration_label: Label = $Margin/VBox/CenterContent/RightCol/VBox/DurationSection/HBox/ValLabel
@onready var prev_dur_btn: Button = $Margin/VBox/CenterContent/RightCol/VBox/DurationSection/HBox/PrevBtn
@onready var next_dur_btn: Button = $Margin/VBox/CenterContent/RightCol/VBox/DurationSection/HBox/NextBtn

@onready var normal_btn: Button = $Margin/VBox/CenterContent/RightCol/VBox/DiffSection/Buttons/NormalBtn
@onready var hard_btn: Button = $Margin/VBox/CenterContent/RightCol/VBox/DiffSection/Buttons/HardBtn
@onready var extreme_btn: Button = $Margin/VBox/CenterContent/RightCol/VBox/DiffSection/Buttons/ExtremeBtn

@onready var back_btn: Button = $Margin/VBox/BottomDock/BackBtn
@onready var next_btn: Button = $Margin/VBox/BottomDock/NextBtn

@onready var o2_val: Label = $Margin/VBox/CenterContent/RightCol/VBox/O2Section/Hdr/Val
@onready var o2_bar: SegmentedBar = $Margin/VBox/CenterContent/RightCol/VBox/O2Section/Bar

@onready var water_val: Label = $Margin/VBox/CenterContent/RightCol/VBox/WaterSection/Hdr/Val
@onready var water_bar: SegmentedBar = $Margin/VBox/CenterContent/RightCol/VBox/WaterSection/Bar

@onready var food_val: Label = $Margin/VBox/CenterContent/RightCol/VBox/FoodSection/Hdr/Val
@onready var food_bar: SegmentedBar = $Margin/VBox/CenterContent/RightCol/VBox/FoodSection/Bar

@onready var power_val: Label = $Margin/VBox/CenterContent/RightCol/VBox/PowerSection/Hdr/Val
@onready var power_bar: SegmentedBar = $Margin/VBox/CenterContent/RightCol/VBox/PowerSection/Bar

@onready var sector_label: Label = $Margin/VBox/CenterContent/MiddleCol/VBox/ReconViewport/Margin/VBox/TopTags/Sec

const DURATION_OPTIONS := [1, 30, 45, 90, 180]
var cur_dur_idx := 0
var is_lz_bravo := true

func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	prev_dur_btn.pressed.connect(_on_prev_dur)
	next_dur_btn.pressed.connect(_on_next_dur)
	
	normal_btn.pressed.connect(func(): _set_difficulty("NORMAL"))
	hard_btn.pressed.connect(func(): _set_difficulty("HARD"))
	extreme_btn.pressed.connect(func(): _set_difficulty("EXTREME"))
	
	# Determine initial duration index
	for i in range(DURATION_OPTIONS.size()):
		if DURATION_OPTIONS[i] == GameState.expedition_duration:
			cur_dur_idx = i
			break
			
	_update_ui()
	next_btn.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_next_pressed()
	elif event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
	elif event.is_action_pressed("ui_focus_next"): # Tab key
		_toggle_sector()

func _toggle_sector() -> void:
	is_lz_bravo = not is_lz_bravo
	sector_label.text = "TARGET SECTOR: LZ-BRAVO" if is_lz_bravo else "TARGET SECTOR: LZ-ALPHA"

func _update_ui() -> void:
	GameState.expedition_duration = DURATION_OPTIONS[cur_dur_idx]
	if GameState.expedition_duration == 1:
		duration_label.text = "1 SOL (INTENSIVE)"
	else:
		duration_label.text = "%d SOLS" % GameState.expedition_duration
	_set_difficulty(GameState.difficulty)
	_update_staged_assets_display()

func _update_staged_assets_display() -> void:
	var staged = GameState.calculate_staged_resources()
	
	var o2 = staged["oxygen"]
	o2_val.text = "%s %s" % [String.num(o2["current"], 0), o2["unit"]]
	o2_bar.fill_ratio = o2["current"] / o2["max"]
	
	var w = staged["water"]
	water_val.text = "%s %s" % [String.num(w["current"], 0), w["unit"]]
	water_bar.fill_ratio = w["current"] / w["max"]
	
	var f = staged["food"]
	food_val.text = "%s %s" % [String.num(f["current"], 0), f["unit"]]
	food_bar.fill_ratio = f["current"] / f["max"]
	
	var p = staged["power"]
	power_val.text = "%s %s" % [String.num(p["current"], 0), p["unit"]]
	power_bar.fill_ratio = p["current"] / p["max"]

func _on_prev_dur() -> void:
	if cur_dur_idx > 0:
		cur_dur_idx -= 1
		_update_ui()

func _on_next_dur() -> void:
	if cur_dur_idx < DURATION_OPTIONS.size() - 1:
		cur_dur_idx += 1
		_update_ui()

func _set_difficulty(diff: String) -> void:
	GameState.difficulty = diff
	_style_diff_btn(normal_btn, diff == "NORMAL")
	_style_diff_btn(hard_btn, diff == "HARD")
	_style_diff_btn(extreme_btn, diff == "EXTREME")

func _style_diff_btn(btn: Button, active: bool) -> void:
	if active:
		btn.add_theme_color_override("font_color", GameState.COLOR_AMBER)
	else:
		btn.add_theme_color_override("font_color", GameState.COLOR_TEXT_MUTED)

func _on_back_pressed() -> void:
	GameState.change_screen("main_menu")

func _on_next_pressed() -> void:
	GameState.change_screen("crew_selection")
