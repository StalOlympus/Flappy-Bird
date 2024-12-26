extends CanvasLayer
class_name UI

@export var score_label: Label

func _ready() -> void:
    GameEvents.scored.connect(_on_scored)
    _on_scored()

func _on_scored() -> void:
    score_label.text = str(Global.score)