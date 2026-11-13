@tool
extends Control
class_name RadarChart

@export var stats: Dictionary = {
	"PHYS": 76,
	"SCI": 96,
	"LEAD": 70,
	"PSY": 88,
	"EXP": 92
} : set = _set_stats

@export var chart_color: Color = Color("#3ce3d9") : set = _set_chart_color
@export var web_color: Color = Color("#203040") : set = _set_web_color
@export var label_color: Color = Color("#8fa6c0") : set = _set_label_color
@export var font: Font

const AXES := ["PHYS", "SCI", "LEAD", "PSY", "EXP"]
const ANGLES := [
	-PI / 2.0,                  # PHYS (Top)
	-PI / 2.0 + (2.0 * PI / 5.0), # SCI (Top-Right)
	-PI / 2.0 + (4.0 * PI / 5.0), # LEAD (Bottom-Right)
	-PI / 2.0 + (6.0 * PI / 5.0), # PSY (Bottom-Left)
	-PI / 2.0 + (8.0 * PI / 5.0)  # EXP (Top-Left)
]

func _set_stats(val: Dictionary) -> void:
	stats = val
	queue_redraw()

func _set_chart_color(val: Color) -> void:
	chart_color = val
	queue_redraw()

func _set_web_color(val: Color) -> void:
	web_color = val
	queue_redraw()

func _set_label_color(val: Color) -> void:
	label_color = val
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius : float= min(size.x, size.y) * 0.38
	
	# Draw 5 concentric web pentagons (20%, 40%, 60%, 80%, 100%)
	for ring in range(1, 6):
		var r: float = radius * (ring / 5.0)
		var ring_pts: PackedVector2Array = []
		for angle in ANGLES:
			ring_pts.append(center + Vector2(cos(angle), sin(angle)) * r)
		ring_pts.append(ring_pts[0]) # close loop
		draw_polyline(ring_pts, web_color, 1.0)
		
	# Draw 5 axis lines from center to outer vertex
	for angle in ANGLES:
		var end_pt: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius
		draw_line(center, end_pt, web_color, 1.0)
		
	# Compute data polygon points
	var data_pts: PackedVector2Array = []
	for i in range(5):
		var axis_name: String = AXES[i]
		var val: float = float(stats.get(axis_name, 50.0)) / 100.0
		val = clamp(val, 0.05, 1.0)
		var pt: Vector2 = center + Vector2(cos(ANGLES[i]), sin(ANGLES[i])) * (radius * val)
		data_pts.append(pt)
		
	# Fill polygon
	if data_pts.size() >= 3:
		var fill_col := chart_color
		fill_col.a = 0.22
		var draw_pts := data_pts.duplicate()
		draw_colored_polygon(draw_pts, fill_col)
		
		# Outline polygon
		var outline_pts := data_pts.duplicate()
		outline_pts.append(outline_pts[0])
		draw_polyline(outline_pts, chart_color, 2.0)
		
		# Draw vertex dots
		for pt in data_pts:
			draw_circle(pt, 4.0, chart_color)
			draw_circle(pt, 2.0, Color.WHITE)
			
	# Draw labels
	var f: Font = font if font != null else ThemeDB.fallback_font
	var f_size: int = 12
	
	for i in range(5):
		var axis_name: String = AXES[i]
		var val_num: int = int(stats.get(axis_name, 50))
		var text: String = "%s %d%%" % [axis_name, val_num]
		var label_pt: Vector2 = center + Vector2(cos(ANGLES[i]), sin(ANGLES[i])) * (radius + 22.0)
		
		# Offset text based on quadrant
		var txt_size := f.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, f_size)
		var draw_pos := label_pt - txt_size * 0.5
		if i == 0: # Top
			draw_pos.y -= 4
		elif i == 1: # Right
			draw_pos.x += 10
		elif i == 4: # Left
			draw_pos.x -= 10
			
		var col := chart_color if axis_name == "PHYS" or axis_name == "SCI" else label_color
		draw_string(f, draw_pos + Vector2(0, txt_size.y * 0.8), text, HORIZONTAL_ALIGNMENT_LEFT, -1, f_size, col)
