@tool
extends PanelContainer
class_name TerminalPanel

@export var title: String = "" : set = _set_title
@export var badge_text: String = "" : set = _set_badge_text
@export var badge_color: Color = Color("#3ce3d9") : set = _set_badge_color
@export var show_header: bool = false : set = _set_show_header
@export var corner_accent: bool = true : set = _set_corner_accent
@export var is_card: bool = false : set = _set_is_card
@export var is_highlighted: bool = false : set = _set_is_highlighted

var header_box: HBoxContainer
var title_label: Label
var badge_label: Label
var content_margin: MarginContainer

func _init() -> void:
	pass

func _ready() -> void:
	queue_redraw()

func _set_title(val: String) -> void:
	title = val
	queue_redraw()

func _set_badge_text(val: String) -> void:
	badge_text = val
	queue_redraw()

func _set_badge_color(val: Color) -> void:
	badge_color = val
	queue_redraw()

func _set_show_header(val: bool) -> void:
	show_header = val
	queue_redraw()

func _set_corner_accent(val: bool) -> void:
	corner_accent = val
	queue_redraw()

func _set_is_card(val: bool) -> void:
	is_card = val
	queue_redraw()

func _set_is_highlighted(val: bool) -> void:
	is_highlighted = val
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var bg_col := Color("#16212d") if is_card else Color("#121a24")
	if is_highlighted:
		bg_col = Color("#172a38")
	
	# Draw background
	draw_rect(rect, bg_col, true)
	
	# Draw border
	var border_col := Color("#3ce3d9") if is_highlighted else Color("#293b4e")
	draw_rect(rect, border_col, false, 1.5)
	
	# Draw corner tabs / industrial brackets if enabled
	if corner_accent:
		var tab_col := Color("#3ce3d9") if is_highlighted else Color("#547796")
		var tab_size := 6.0
		# Top-Left tab
		draw_rect(Rect2(0, 0, tab_size, tab_size), tab_col, true)
		# Top-Right tab
		draw_rect(Rect2(rect.size.x - tab_size, 0, tab_size, tab_size), tab_col, true)
		# Bottom-Left tab
		draw_rect(Rect2(0, rect.size.y - tab_size, tab_size, tab_size), tab_col, true)
		# Bottom-Right tab
		draw_rect(Rect2(rect.size.x - tab_size, rect.size.y - tab_size, tab_size, tab_size), tab_col, true)
