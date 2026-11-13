extends Node2D

@onready var player: AstronautPlayer = $AstronautPlayer
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

signal poi_selected(poi_id: String)
signal player_prompt_changed(prompt_text: String)

func _ready() -> void:
	player.poi_entered.connect(_on_player_poi_entered)
	player.poi_exited.connect(_on_player_poi_exited)
	
	# Connect POIs
	for poi in get_tree().get_nodes_in_group("interactable"):
		if poi is InteractablePOI:
			poi.poi_action_triggered.connect(_on_poi_triggered)

func update_ambient_lighting(color: Color) -> void:
	if canvas_modulate:
		canvas_modulate.color = color

func _on_player_poi_entered(poi: Node) -> void:
	if poi is InteractablePOI:
		emit_signal("player_prompt_changed", "[E] %s — %s" % [poi.prompt_action, poi.poi_name])

func _on_player_poi_exited(_poi: Node) -> void:
	emit_signal("player_prompt_changed", "")

func _on_poi_triggered(poi_id: String) -> void:
	emit_signal("poi_selected", poi_id)
