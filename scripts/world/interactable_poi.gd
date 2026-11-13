@tool
extends Area2D
class_name InteractablePOI

@export var poi_id: String = ""
@export var poi_name: String = "Interactive Point"
@export var prompt_action: String = "[E] INTERACT"
@export var description: String = ""
@export var ring_radius: float = 32.0

var is_player_nearby: bool = false
var pulse_time: float = 0.0

signal poi_action_triggered(poi_id: String)

func _ready() -> void:
	add_to_group("interactable")
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	pulse_time += delta * 2.5
	if is_player_nearby or Engine.is_editor_hint():
		queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body is AstronautPlayer:
		is_player_nearby = true
		queue_redraw()

func _on_body_exited(body: Node2D) -> void:
	if body is AstronautPlayer:
		is_player_nearby = false
		queue_redraw()

func interact() -> void:
	emit_signal("poi_action_triggered", poi_id)

func _draw() -> void:
	var col := Color("#3ce3d9") if is_player_nearby else Color("#547796")
	col.a = 0.6 + sin(pulse_time) * 0.25 if is_player_nearby else 0.25
	
	# Draw outer circular target bracket
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 24, col, 1.5)
	
	# Draw 4 corner reticle tick marks
	var tick := 6.0
	for angle in [0, PI * 0.5, PI, PI * 1.5]:
		var dir := Vector2(cos(angle), sin(angle))
		draw_line(dir * (ring_radius - tick), dir * (ring_radius + tick), col, 1.5)
