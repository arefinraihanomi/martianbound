@tool
extends Control
class_name SegmentedBar

@export var total_segments: int = 16 : set = _set_total_segments
@export_range(0.0, 1.0, 0.01) var fill_ratio: float = 0.85 : set = _set_fill_ratio
@export var fill_color: Color = Color("#3ce3d9") : set = _set_fill_color
@export var empty_color: Color = Color("#17222e") : set = _set_empty_color
@export var border_color: Color = Color("#223242") : set = _set_border_color
@export var segment_gap: float = 2.0 : set = _set_segment_gap

func _set_total_segments(val: int) -> void:
	total_segments = max(1, val)
	queue_redraw()

func _set_fill_ratio(val: float) -> void:
	fill_ratio = clamp(val, 0.0, 1.0)
	queue_redraw()

func _set_fill_color(val: Color) -> void:
	fill_color = val
	queue_redraw()

func _set_empty_color(val: Color) -> void:
	empty_color = val
	queue_redraw()

func _set_border_color(val: Color) -> void:
	border_color = val
	queue_redraw()

func _set_segment_gap(val: float) -> void:
	segment_gap = max(0.0, val)
	queue_redraw()

func _draw() -> void:
	if total_segments <= 0 or size.x <= 0:
		return
		
	var available_width: float = size.x - (segment_gap * (total_segments - 1))
	var seg_w: float = available_width / float(total_segments)
	var seg_h: float = size.y
	
	var active_count: int = int(round(fill_ratio * total_segments))
	
	for i in range(total_segments):
		var x: float = i * (seg_w + segment_gap)
		var seg_rect := Rect2(x, 0, seg_w, seg_h)
		
		if i < active_count:
			draw_rect(seg_rect, fill_color, true)
		else:
			draw_rect(seg_rect, empty_color, true)
			
		# Optional outline per segment
		draw_rect(seg_rect, border_color, false, 1.0)
