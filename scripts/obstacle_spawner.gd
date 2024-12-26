extends Node2D
class_name ObstacleSpawner

# Export variables grouped by functionality
@export_group("Obstacle Scenes")
@export var top_obstacle_scene: PackedScene
@export var bottom_obstacle_scene: PackedScene

@export_group("Spawn Settings")
@export var spawn_interval: float = 1
@export var spawn_position_x: float = 800.0

@export_group("Gap Settings")
var vertical_gap: float = -40
@export var min_height: float = 150.0
@export var max_height: float = 450.0

# Add variations arrays
@export var top_obstacle_variations: Array[ObstacleVariation]
@export var bottom_obstacle_variations: Array[ObstacleVariation]

# Private variables
var _spawn_timer: float = 0.0
var _current_variation_index: int = -1
var _variation_use_count: int = 0
var _variation_max_uses: int = 0
var _next_variation_index: int = -1

# Add at the top with other class variables
signal variation_changed(variation_index: int)
signal next_variation_selected(variation_index: int)

func _ready() -> void:
	# Pre-roll the next variation
	_roll_next_variation()
	get_next_variation_index()
	spawn_obstacles()

func _process(delta: float) -> void:
	_spawn_timer += delta
	
	if _spawn_timer >= spawn_interval:
		_spawn_timer = 0
		spawn_obstacles()

func spawn_obstacles() -> void:
	var gap_center: float = randf_range(min_height, max_height)
	var viewport_height: float = get_viewport().size.y
	
	if _variation_use_count >= _variation_max_uses or _current_variation_index == -1:
		_current_variation_index = _next_variation_index
		_variation_use_count = 0
		_variation_max_uses = 3
		# Roll the next variation for future use
		_roll_next_variation()
		get_next_variation_index()
		# Emit the signal when variation changes
		variation_changed.emit(_current_variation_index)
	
	_variation_use_count += 1
	
	var top_obstacle: Obstacle = _spawn_top_obstacle(gap_center, _current_variation_index)
	var bottom_obstacle: Obstacle = _spawn_bottom_obstacle(gap_center, viewport_height, _current_variation_index)
	
	var score_position := Vector2(
		spawn_position_x + 12,
		(top_obstacle.global_position.y + bottom_obstacle.global_position.y) / 2
	)
	create_score_area(score_position)

func _spawn_top_obstacle(gap_center: float, variation_index: int) -> Obstacle:
	var obstacle: Obstacle = top_obstacle_scene.instantiate()
	obstacle.global_position = Vector2(spawn_position_x, vertical_gap + gap_center)
	add_child(obstacle, true)
	# Configure with specific variation
	if variation_index >= 0:
		obstacle.configure(top_obstacle_variations[variation_index])
	return obstacle

func _spawn_bottom_obstacle(gap_center: float, viewport_height: float, variation_index: int) -> Obstacle:
	var obstacle: Obstacle = bottom_obstacle_scene.instantiate()
	obstacle.global_position = Vector2(
		spawn_position_x,
		(viewport_height / 2) - vertical_gap + gap_center
	)
	add_child(obstacle, true)
	# Configure with specific variation
	if variation_index >= 0:
		obstacle.configure(bottom_obstacle_variations[variation_index])
	return obstacle

func create_score_area(new_position: Vector2) -> void:
	var score_area := Area2D.new()
	score_area.name = "ScoreArea"
	score_area.global_position = new_position
	score_area.set_script(preload("res://scripts/score_area.gd"))
	
	var collision_shape := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(25, 100)
	collision_shape.shape = shape
	
	get_parent().call_deferred("add_child", score_area)
	score_area.add_child(collision_shape)

# Optional: Method to start/stop spawning
func set_spawning_active(active: bool) -> void:
	set_process(active)
	
# Optional: Method to clear all obstacles
func clear_obstacles() -> void:
	for child in get_children():
		if child is StaticBody2D:
			child.queue_free()

# Add new helper function
func _roll_next_variation() -> void:
	_next_variation_index = randi() % top_obstacle_variations.size() if not top_obstacle_variations.is_empty() else -1

# Add getter for next variation
func get_next_variation_index() -> int:
	next_variation_selected.emit(_next_variation_index)
	return _next_variation_index
