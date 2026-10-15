extends CharacterBody3D
## First-person capsule, with the same movement path used by the smoke test.

const WALK_SPEED := 3.5
const RUN_SPEED := 5.5
const SENSITIVITY := 0.0025
var camera: Camera3D
var flashlight: SpotLight3D
var footstep: AudioStreamPlayer
var asphalt_step: AudioStreamWAV
var tile_step: AudioStreamWAV
var mouse_captured := true
var test_mode := false
var test_direction := Vector2.ZERO
var step_distance := 0.0
var bob_time := 0.0
var pitch := -0.02

func _ready() -> void:
	name = "Player"
	add_to_group("player")
	floor_snap_length = 0.3
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.28
	capsule.height = 1.75
	collider.shape = capsule
	collider.position.y = 0.9
	add_child(collider)
	camera = Camera3D.new()
	camera.position.y = 1.62
	camera.fov = 76
	camera.near = 0.06
	camera.far = 160
	add_child(camera)
	camera.current = true
	flashlight = SpotLight3D.new()
	flashlight.light_color = Color("d4dec3")
	flashlight.light_energy = 1.4
	flashlight.spot_range = 18.0
	flashlight.spot_angle = 30.0
	flashlight.spot_angle_attenuation = 1.3
	flashlight.shadow_enabled = true
	flashlight.position = Vector3(0.18, -0.12, 0)
	flashlight.visible = false
	camera.add_child(flashlight)
	footstep = AudioStreamPlayer.new()
	asphalt_step = load("res://assets/audio/step_asphalt.wav")
	tile_step = load("res://assets/audio/step_tile.wav")
	footstep.stream = asphalt_step
	footstep.bus = "Effects"
	footstep.volume_db = -12
	add_child(footstep)
	if not DisplayServer.get_name() == "headless":
		capture_mouse(true)

func capture_mouse(captured: bool) -> void:
	mouse_captured = captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if test_mode:
		return
	if event is InputEventMouseMotion and mouse_captured:
		rotate_y(-event.relative.x * SENSITIVITY)
		pitch = clampf(pitch - event.relative.y * SENSITIVITY, -1.4, 1.4)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		capture_mouse(true)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE:
			capture_mouse(not mouse_captured)
		if event.physical_keycode == KEY_F:
			flashlight.visible = not flashlight.visible
		if event.physical_keycode == KEY_F11:
			var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
		if event.physical_keycode == KEY_Q and not mouse_captured:
			get_tree().quit()

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if test_mode:
		direction = test_direction
	elif mouse_captured:
		direction = Vector2(float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)), float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
	direction = direction.limit_length()
	var speed := RUN_SPEED if Input.is_physical_key_pressed(KEY_SHIFT) and not test_mode else WALK_SPEED
	var world_direction := transform.basis * Vector3(direction.x, 0, direction.y)
	velocity.x = move_toward(velocity.x, world_direction.x * speed, 18 * delta)
	velocity.z = move_toward(velocity.z, world_direction.z * speed, 18 * delta)
	if not is_on_floor():
		velocity.y -= 18 * delta
	else:
		velocity.y = -0.2
	move_and_slide()
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if horizontal_speed > 0.2 and is_on_floor():
		bob_time += horizontal_speed * delta * 2.2
		step_distance += horizontal_speed * delta
		if step_distance > 1.7:
			step_distance = 0
			var inside := position.z < -1 and position.z > -11 and absf(position.x) < 7
			footstep.stream = tile_step if inside else asphalt_step
			footstep.bus = "Interior" if inside else "Effects"
			footstep.pitch_scale = randf_range(0.9, 1.12)
			footstep.play()
	camera.rotation.x = pitch
	camera.position.y = 1.62 + sin(bob_time) * 0.018 * minf(horizontal_speed / WALK_SPEED, 1)
	if position.y < -8:
		position = Vector3(10, 0.2, 17)
