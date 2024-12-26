extends Area2D
class_name ScoreArea

var speed: float = 200.0

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    position.x -= speed * delta
    
    if position.x < -100: # Destroy when off screen
        queue_free()

func _on_body_entered(body: Node) -> void:
    print("Scored!" + str(body.name))
    GameEvents.emit_scored()