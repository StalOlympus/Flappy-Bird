extends Node

var score: int = 0

func _ready() -> void:
    score = 0
    GameEvents.scored.connect(_on_scored)
    GameEvents.player_died.connect(_on_player_died)

func _on_scored() -> void:
    score += 1

func _on_player_died() -> void:
    score = 0