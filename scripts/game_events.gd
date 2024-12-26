extends Node

signal player_died
signal scored

func emit_player_died() -> void:
    player_died.emit()

func emit_scored() -> void:
    scored.emit()