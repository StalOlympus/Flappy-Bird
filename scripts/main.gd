extends Node
class_name Main

@export var obstacle_spawner: ObstacleSpawner

# Difficulty settings
var _base_difficulty: float = -40.0 # Easiest gap
var _max_difficulty: float = 10.0 # Hardest gap
var normal_difficulty: float = -10
var _current_difficulty: float = _base_difficulty
var _difficulty_increase_rate: float = 2.0
var _breathing_timer: float = 0.0
var _breathing_interval: float = 15.0 # Seconds between difficulty resets
var _difficulty_state: String = "increasing"

func _ready() -> void:
    _update_spawner_difficulty()
    GameEvents.player_died.connect(_player_died)

func _process(delta: float) -> void:
    match _difficulty_state:
        "increasing":
            _current_difficulty = min(_current_difficulty + _difficulty_increase_rate * delta, _max_difficulty)
            if _current_difficulty >= _max_difficulty:
                _difficulty_state = "breathing"
                _breathing_timer = 0.0
        "breathing":
            _breathing_timer += delta
            if _breathing_timer >= _breathing_interval:
                _current_difficulty = normal_difficulty
                _difficulty_state = "increasing"
    
    _update_spawner_difficulty()

func _update_spawner_difficulty() -> void:
    obstacle_spawner.vertical_gap = _current_difficulty

func _player_died() -> void:
    _current_difficulty = _base_difficulty
    _difficulty_state = "increasing"
    _breathing_timer = 0.0
    _update_spawner_difficulty()

    obstacle_spawner.clear_obstacles()

    get_tree().call_deferred("reload_current_scene")