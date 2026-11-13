@tool
extends Control
class_name RadarMinimap

@export var radar_range: float = 600.0
@export var player_node: Node2D
@export var poi_container: Node2D

var sweep_angle: float = 0.0

func _process(delta: float) -> void:
	sweep_angle += delta * 2.0
	queue_redraw()

func _draw() -> void:
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.44
	
	# Radar background circle
	draw_circle(center, radius, Color("#091017"))
	draw_arc(center, radius, 0.0, TAU, 32, Color("#213244"), 1.5)
	draw_arc(center, radius * 0.66, 0.0, TAU, 24, Color("#162330"), 1.0)
	draw_arc(center, radius * 0.33, 0.0, TAU, 16, Color("#162330"), 1.0)
	
	# Crosshairs
	draw_line(Vector2(center.x, center.y - radius), Vector2(center.x, center.y + radius), Color("#1a2b3c"), 1.0)
	draw_line(Vector2(center.x - radius, center.y), Vector2(center.x + radius, center.y), Color("#1a2b3c"), 1.0)
	
	# Radar sweep line
	var sweep_end: Vector2 = center + Vector2(cos(sweep_angle), sin(sweep_angle)) * radius
	draw_line(center, sweep_end, Color(0.24, 0.89, 0.85, 0.4), 1.5)
	
	var player_pos: Vector2 = Vector2.ZERO
	if player_node != null and is_instance_valid(player_node):
		player_pos = player_node.global_position
		
	# Draw POIs relative to player
	if poi_container != null and is_instance_valid(poi_container):
		for node in poi_container.get_tree().get_nodes_in_group("interactable"):
			if node is Node2D and is_instance_valid(node):
				var diff: Vector2 = node.global_position - player_pos
				var dist: float = diff.length()
				if dist <= radar_range:
					var norm_dist: float = (dist / radar_range) * radius
					var blip_pos: Vector2 = center + diff.normalized() * norm_dist
					
					var col := Color("#3ce3d9") # Cyan
					var poi_id = node.get("poi_id")
					if poi_id == "basalt_anomaly":
						col = Color("#e58338") # Amber
					elif poi_id == "hab_airlock":
						col = Color("#3ce88c") # Green
					elif poi_id == "solar_array":
						col = Color("#ffe066") # Yellow
					elif poi_id == "crate_supplies":
						col = Color("#e75a5a") # Coral Red
					elif poi_id == "comms_dish":
						col = Color("#7590aa") # Slate Blue
						
					draw_circle(blip_pos, 3.0, col)
					
	# Draw player blip at center
	draw_circle(center, 3.5, Color("#ffffff"))
	draw_arc(center, 6.0, 0.0, TAU, 12, Color("#3ce3d9"), 1.0)
