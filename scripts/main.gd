extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const CAR_SCRIPT = preload("res://scripts/car.gd")

var player: CharacterBody3D
var car: CharacterBody3D
var camera: Camera3D

var driving := false
var e_key_was_down := false

var touch := {
	"up": false,
	"down": false,
	"left": false,
	"right": false
}


func _ready() -> void:
	_make_world()
	_make_player()
	_make_car()
	_make_camera()
	_make_controls()


func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var e_key_down := Input.is_key_pressed(KEY_E)
	if e_key_down and not e_key_was_down:
		_toggle_vehicle()
	e_key_was_down = e_key_down

	var x := 0.0
	var y := 0.0

	if touch["right"]:
		x += 1.0
	if touch["left"]:
		x -= 1.0
	if touch["up"]:
		y += 1.0
	if touch["down"]:
		y -= 1.0

	if driving:
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			x -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			x += 1.0
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			y += 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			y -= 1.0

		car.set("drive_input", Vector2(x, y).limit_length(1.0))
	else:
		player.set("move_input", Vector2(x, y))

	var follow_target: Node3D = car if driving else player
	var target_position := follow_target.global_position + Vector3(0.0, 5.0, 9.0)

	camera.global_position = camera.global_position.lerp(
		target_position,
		min(1.0, delta * 5.0)
	)
	camera.look_at(
		follow_target.global_position + Vector3(0.0, 1.0, 0.0),
		Vector3.UP
	)


func _make_world() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	sun.light_energy = 1.2
	add_child(sun)

	_add_box(
		self,
		"Ground",
		Vector3(0.0, -0.5, 0.0),
		Vector3(100.0, 1.0, 100.0),
		Color(0.24, 0.47, 0.25)
	)

	_add_box(
		self,
		"Road",
		Vector3(0.0, 0.04, 0.0),
		Vector3(12.0, 0.06, 100.0),
		Color(0.16, 0.17, 0.19),
		false
	)

	var building_colors := [
		Color(0.68, 0.48, 0.34),
		Color(0.52, 0.59, 0.65),
		Color(0.72, 0.67, 0.50),
		Color(0.48, 0.55, 0.43)
	]
	var heights := [6.0, 9.0, 7.0, 11.0]
	var z_positions := [-30.0, -10.0, 10.0, 30.0]

	for side in [-1, 1]:
		for i in range(4):
			var height: float = heights[i]
			_add_box(
				self,
				"Building_%s_%s" % [side, i],
				Vector3(float(side) * 15.0, height / 2.0, z_positions[i]),
				Vector3(8.0, height, 8.0),
				building_colors[i]
			)


func _add_box(
	parent: Node,
	box_name: String,
	box_position: Vector3,
	box_size: Vector3,
	color: Color,
	solid: bool = true
) -> void:
	var holder: Node3D

	if solid:
		holder = StaticBody3D.new()
	else:
		holder = Node3D.new()

	holder.name = box_name
	holder.position = box_position
	parent.add_child(holder)

	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size
	mesh_instance.mesh = box_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	mesh_instance.material_override = material
	holder.add_child(mesh_instance)

	if solid:
		var collision := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = box_size
		collision.shape = box_shape
		holder.add_child(collision)


func _make_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0.0, 0.12, 0.0)
	player.set_script(PLAYER_SCRIPT)
	add_child(player)

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.position.y = 0.9

	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.42
	capsule_shape.height = 1.8
	collision.shape = capsule_shape
	player.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.position.y = 0.9

	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.42
	capsule_mesh.height = 1.8
	mesh_instance.mesh = capsule_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.12, 0.34, 0.9)
	mesh_instance.material_override = material
	player.add_child(mesh_instance)


func _make_car() -> void:
	car = CharacterBody3D.new()
	car.name = "Car"
	car.position = Vector3(2.5, 0.0, 2.5)
	car.set_script(CAR_SCRIPT)
	add_child(car)

	var collision := CollisionShape3D.new()
	collision.position.y = 0.6

	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(1.8, 0.8, 3.4)
	collision.shape = box_shape
	car.add_child(collision)

	var body_mesh := MeshInstance3D.new()
	body_mesh.position.y = 0.6

	var body_box := BoxMesh.new()
	body_box.size = Vector3(1.8, 0.8, 3.4)
	body_mesh.mesh = body_box

	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color(0.78, 0.12, 0.08)
	body_mesh.material_override = body_material
	car.add_child(body_mesh)

	var wheel_material := StandardMaterial3D.new()
	wheel_material.albedo_color = Color(0.08, 0.08, 0.08)

	for x in [-0.95, 0.95]:
		for z in [-1.1, 1.1]:
			var wheel := MeshInstance3D.new()
			wheel.position = Vector3(float(x), 0.34, float(z))
			wheel.rotation_degrees.z = 90.0

			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.34
			wheel_mesh.bottom_radius = 0.34
			wheel_mesh.height = 0.22
			wheel.mesh = wheel_mesh
			wheel.material_override = wheel_material
			car.add_child(wheel)


func _make_camera() -> void:
	camera = Camera3D.new()
	camera.name = "FollowCamera"
	add_child(camera)

	camera.global_position = player.global_position + Vector3(0.0, 5.0, 9.0)
	camera.current = true
	camera.look_at(
		player.global_position + Vector3(0.0, 1.0, 0.0),
		Vector3.UP
	)


func _make_controls() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(ui)

	var hint := Label.new()
	hint.text = "WASD / Arrows — E: Enter or exit car"
	hint.position = Vector2(20.0, 18.0)
	hint.add_theme_font_size_override("font_size", 22)
	ui.add_child(hint)

	_add_touch_button(ui, "↑", "up", 82.0, -205.0)
	_add_touch_button(ui, "←", "left", 10.0, -132.0)
	_add_touch_button(ui, "↓", "down", 82.0, -132.0)
	_add_touch_button(ui, "→", "right", 154.0, -132.0)

	var vehicle_button := Button.new()
	vehicle_button.text = "Enter / Exit"
	vehicle_button.focus_mode = Control.FOCUS_NONE
	vehicle_button.anchor_left = 1.0
	vehicle_button.anchor_right = 1.0
	vehicle_button.anchor_top = 1.0
	vehicle_button.anchor_bottom = 1.0
	vehicle_button.offset_left = -190.0
	vehicle_button.offset_top = -100.0
	vehicle_button.offset_right = -20.0
	vehicle_button.offset_bottom = -35.0
	vehicle_button.pressed.connect(_toggle_vehicle)
	ui.add_child(vehicle_button)


func _add_touch_button(
	ui: Control,
	label_text: String,
	action: String,
	x: float,
	bottom_offset: float
) -> void:
	var button := Button.new()
	button.text = label_text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 28)

	button.anchor_left = 0.0
	button.anchor_right = 0.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = x
	button.offset_top = bottom_offset
	button.offset_right = x + 64.0
	button.offset_bottom = bottom_offset + 64.0

	button.button_down.connect(_set_touch.bind(action, true))
	button.button_up.connect(_set_touch.bind(action, false))
	ui.add_child(button)


func _set_touch(action: String, is_down: bool) -> void:
	touch[action] = is_down


func _toggle_vehicle() -> void:
	if not driving:
		if player.global_position.distance_to(car.global_position) > 4.5:
			return

		driving = true
		player.hide()
		player.set_physics_process(false)

		var player_collision := player.get_node(
			"CollisionShape3D"
		) as CollisionShape3D
		player_collision.set_deferred("disabled", true)

		car.set("drive_input", Vector2.ZERO)
	else:
		driving = false
		car.set("drive_input", Vector2.ZERO)

		player.global_position = (
			car.global_position
			+ car.global_basis.x * 2.0
			+ Vector3(0.0, 0.12, 0.0)
		)

		var player_collision := player.get_node(
			"CollisionShape3D"
		) as CollisionShape3D
		player_collision.set_deferred("disabled", false)

		player.show()
		player.set_physics_process(true)
