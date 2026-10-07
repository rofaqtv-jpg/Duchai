extends CharacterBody3D

var drive_input := Vector2.ZERO
var current_speed := 0.0

const MAX_SPEED := 17.0
const ACCELERATION := 11.0
const GRAVITY := 22.0
const TURN_RATE := 1.5

func _physics_process(delta: float) -> void:
	var target_speed := drive_input.y * MAX_SPEED
	current_speed = move_toward(
		current_speed,
		target_speed,
		ACCELERATION * delta
	)

	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = 0.0
	else:
		velocity.y -= GRAVITY * delta

	if abs(current_speed) > 0.4:
		var steering_factor := clamp(
			abs(current_speed) / MAX_SPEED,
			0.2,
			1.0
		)
		rotation.y -= (
			drive_input.x
			* TURN_RATE
			* steering_factor
			* sign(current_speed)
			* delta
		)

	var forward := -global_basis.z
	velocity.x = forward.x * current_speed
	velocity.z = forward.z * current_speed

	move_and_slide()
