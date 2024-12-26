extends CharacterBody2D
class_name Player

var gravity: int = 1400
var flap_force: int = -400

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = lerpf(velocity.y, flap_force, 1)

	rotation = lerp_angle(rotation, deg_to_rad(15 if velocity.y > 0 else -30), 5 * delta)
	rotation = clamp(rotation, deg_to_rad(-30), deg_to_rad(30))
	
	velocity.y = clamp(velocity.y, flap_force, gravity)
	
	move_and_slide()