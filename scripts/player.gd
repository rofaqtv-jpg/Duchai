extends CharacterBody3D

var move_input := Vector2.ZERO

const SPEED := 5.5
const GRAVITY := 22.0

func _physics_process(delta: float) -> void:
	var keyboard := Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		keyboard.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		keyboard.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		keyboard.y += 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		keyboard.y -= 1.0

	var input_dir := (move_input + keyboard).limit_length(1.0)
	var direction := Vector3(input_dir.x, 0.0, -input_dir.y)

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	if direction.length() > 0.01:
		var target_yaw := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(
			rotation.y,
			target_yaw,
			min(1.0, delta * 10.0)
		)

	move_and_slide()
