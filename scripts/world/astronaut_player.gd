extends CharacterBody2D
class_name AstronautPlayer

@export var move_speed: float = 180.0
@export var sprint_multiplier: float = 1.45

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var dust_particles: CPUParticles2D = $DustParticles

var nearby_poi: Node = null
var total_distance_walked: float = 0.0
var walk_anim_timer: float = 0.0

signal poi_entered(poi: Node)
signal poi_exited(poi: Node)
signal moved(distance_pixels: float)

func _ready() -> void:
	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)

func _physics_process(delta: float) -> void:
	var input_vec := Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vec.x += 1.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vec.x -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vec.y += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vec.y -= 1.0

	var current_speed = move_speed
	var is_sprinting = Input.is_key_pressed(KEY_SHIFT)
	if is_sprinting:
		current_speed *= sprint_multiplier

	input_vec = input_vec.normalized()
	velocity = input_vec * current_speed
	
	if velocity.length() > 0.0:
		move_and_slide()
		var step_dist = velocity.length() * delta
		total_distance_walked += step_dist
		emit_signal("moved", step_dist)
		
		# Dust particles & walk bobbing
		dust_particles.emitting = true
		walk_anim_timer += delta * (14.0 if is_sprinting else 10.0)
		sprite.position.y = sin(walk_anim_timer) * 1.5
		
		# Face direction of movement
		if abs(velocity.x) > 5.0:
			sprite.flip_h = velocity.x < 0.0
	else:
		dust_particles.emitting = false
		sprite.position.y = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
		if nearby_poi != null and nearby_poi.has_method("interact"):
			nearby_poi.interact()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		nearby_poi = area
		emit_signal("poi_entered", area)

func _on_area_exited(area: Area2D) -> void:
	if nearby_poi == area:
		nearby_poi = null
		emit_signal("poi_exited", area)
