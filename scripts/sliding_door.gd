extends Node3D
## Two solid sliding leaves. Detection covers the approach on BOTH sides.

const LEAF_WIDTH := 1.45
const TRAVEL := 1.42
const SPEED := 2.8
var openness := 0.0
var hold_time := 0.0
var sensor: Area3D
var leaves: Array[AnimatableBody3D] = []
var motor: AudioStreamPlayer3D
var is_opening := false

func _ready() -> void:
	sensor = Area3D.new()
	sensor.collision_layer = 0
	sensor.collision_mask = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4.6, 3.0, 5.4)
	shape.shape = box
	shape.position.y = 1.4
	sensor.add_child(shape)
	add_child(sensor)
	var frame := StandardMaterial3D.new()
	frame.albedo_color = Color("424f4b")
	frame.roughness = 0.85
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.16, 0.29, 0.27, 0.27)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	glass.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var stripe := StandardMaterial3D.new()
	stripe.albedo_color = Color("c8b88a")
	for side in [-1, 1]:
		var leaf := AnimatableBody3D.new()
		leaf.sync_to_physics = false
		leaf.position = Vector3(side * LEAF_WIDTH / 2.0, 0, 0)
		var collision := CollisionShape3D.new()
		var collision_box := BoxShape3D.new()
		collision_box.size = Vector3(LEAF_WIDTH, 2.65, 0.12)
		collision.shape = collision_box
		collision.position.y = 1.325
		leaf.add_child(collision)
		add_child(leaf)
		leaves.append(leaf)
		_piece(leaf, Vector3(LEAF_WIDTH - 0.08, 2.5, 0.035), Vector3(0, 1.325, 0), glass)
		for x in [-LEAF_WIDTH / 2.0 + 0.035, LEAF_WIDTH / 2.0 - 0.035]:
			_piece(leaf, Vector3(0.07, 2.65, 0.10), Vector3(x, 1.325, 0), frame)
		for y in [0.07, 2.60]:
			_piece(leaf, Vector3(LEAF_WIDTH, 0.1, 0.10), Vector3(0, y, 0), frame)
		_piece(leaf, Vector3(LEAF_WIDTH, 0.08, 0.055), Vector3(0, 1.2, 0.015), stripe)
	motor = AudioStreamPlayer3D.new()
	motor.bus = "Effects"
	motor.stream = load("res://assets/audio/door.wav")
	motor.volume_db = -11
	motor.max_distance = 16
	motor.position.y = 2.4
	add_child(motor)

func _piece(parent: Node3D, size: Vector3, at: Vector3, material: Material) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = material
	mesh.position = at
	parent.add_child(mesh)

func _physics_process(delta: float) -> void:
	var occupied := false
	for body in sensor.get_overlapping_bodies():
		if body.is_in_group("player"):
			occupied = true
	if occupied:
		hold_time = 1.2
	else:
		hold_time = maxf(0, hold_time - delta)
	var opening := hold_time > 0
	if opening != is_opening:
		is_opening = opening
		motor.pitch_scale = 1.0 if opening else 0.85
		motor.play()
	openness = move_toward(openness, 1.0 if opening else 0.0, delta * SPEED / TRAVEL)
	for i in range(2):
		var side := -1.0 if i == 0 else 1.0
		leaves[i].position.x = side * (LEAF_WIDTH / 2.0 + openness * TRAVEL)
