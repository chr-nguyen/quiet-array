extends Node3D
## Original, deliberately small, low-poly roadside scene. Distances are in metres.

const PlayerController = preload("res://scripts/player.gd")
const SlidingDoor = preload("res://scripts/sliding_door.gd")
const SurfaceLibrary = preload("res://scripts/surface_library.gd")
const Soundscape = preload("res://scripts/soundscape.gd")
var soundscape: Node
var player: CharacterBody3D
var door: Node3D
var materials: Dictionary = {}
var random := RandomNumberGenerator.new()
var pause_panel: PanelContainer
var location_label: Label
var flicker_light: OmniLight3D
var elapsed := 0.0

func _ready() -> void:
	random.seed = 1709
	_materials()
	SurfaceLibrary.apply(materials)
	_environment()
	_ground()
	_building()
	_canopy()
	_pumps()
	_interior()
	_details()
	_surface_details()
	_forest()
	_audio()
	player = PlayerController.new()
	player.position = Vector3(9, 0.15, 14.5)
	player.rotation.y = 0.52
	add_child(player)
	_hud()
	if "--capture" in OS.get_cmdline_user_args():
		_capture.call_deferred()

func _mat(key: String, color: String, texture_name: String = "", emission: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color)
	material.roughness = 0.95
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	if not texture_name.is_empty():
		material.albedo_texture = load("res://assets/textures/" + texture_name + ".png")
		material.uv1_triplanar = true
		material.uv1_scale = Vector3.ONE * 0.55
	if emission > 0:
		material.emission_enabled = true
		material.emission = Color(color)
		material.emission_energy_multiplier = emission
	materials[key] = material
	return material

func _materials() -> void:
	_mat("asphalt", "a5acb0", "asphalt")
	_mat("concrete", "b3b8a4", "concrete")
	_mat("plaster", "dad6ac", "plaster")
	_mat("tile", "c8d0b0", "tile")
	_mat("roof", "858d86", "roof")
	_mat("dirt", "6a7059", "dirt")
	_mat("bark", "9b947b", "bark")
	_mat("red", "934c36")
	_mat("cream", "d3c9a2")
	_mat("dark", "172522")
	_mat("metal", "53605a")
	_mat("white", "b5c2ac")
	_mat("yellow", "b5a36b")
	_mat("green", "374d3e")
	_mat("pine", "1d302d")
	_mat("pine2", "263c35")
	_mat("lamp", "ffe0a0", "", 2.5)
	_mat("fluorescent", "c9f7d4", "", 1.7)
	_mat("amber", "ffb15f", "", 1.1)
	_mat("screen", "416a59", "", 0.5)
	_mat("black", "111916")
	var glass := _mat("glass", "678c79")
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.albedo_color.a = 0.16
	glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	glass.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

func _box(label_text: String, size: Vector3, at: Vector3, mat: String, solid: bool = true, parent: Node3D = self) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.name = label_text
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = materials[mat]
	mesh.position = at
	parent.add_child(mesh)
	if solid:
		var body := StaticBody3D.new()
		var shape := CollisionShape3D.new()
		var bounds := BoxShape3D.new()
		bounds.size = size
		shape.shape = bounds
		body.add_child(shape)
		mesh.add_child(body)
	return mesh

func _cylinder(at: Vector3, radius: float, height: float, mat: String, top_radius: float = -1, sides: int = 8) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.bottom_radius = radius
	cylinder.top_radius = radius if top_radius < 0 else top_radius
	cylinder.height = height
	cylinder.radial_segments = sides
	cylinder.rings = 1
	mesh.mesh = cylinder
	mesh.material_override = materials[mat]
	mesh.position = at
	add_child(mesh)
	return mesh

func _text(words: String, at: Vector3, size: int, pixel_size: float, color: Color = Color("e6d8b2"), yaw: float = 0) -> Label3D:
	var label := Label3D.new()
	label.text = words
	label.font_size = size
	label.pixel_size = pixel_size
	label.position = at
	label.rotation.y = yaw
	label.modulate = color
	label.outline_size = 0
	label.no_depth_test = false
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	add_child(label)
	return label

func _light(at: Vector3, color: Color, energy: float, distance: float, shadows: bool = false) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.position = at
	light.light_color = color
	light.light_energy = energy
	light.omni_range = distance
	light.omni_attenuation = 1.2
	light.shadow_enabled = shadows
	add_child(light)
	return light

func _downlight(at: Vector3, color: Color, energy: float, distance: float) -> void:
	var light := SpotLight3D.new()
	light.position = at
	light.rotation_degrees.x = -90
	light.light_color = color
	light.light_energy = energy
	light.spot_range = distance
	light.spot_angle = 66
	light.spot_angle_attenuation = 0.7
	light.spot_attenuation = 1.2
	light.shadow_enabled = true
	add_child(light)

func _decal(title: String, at: Vector3, size: Vector2, mat: String, yaw: float = 0) -> void:
	var node := MeshInstance3D.new()
	node.name = title
	var quad := QuadMesh.new()
	quad.size = size
	node.mesh = quad
	node.material_override = materials[mat]
	node.position = at
	node.rotation.y = yaw
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)

func _environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("11191e")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("8096a0")
	env.ambient_light_energy = 0.17
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.fog_enabled = true
	env.fog_light_color = Color("182329")
	env.fog_light_energy = 0.5
	env.fog_density = 0.016
	env.fog_height = -1.5
	env.fog_height_density = 0.08
	world.environment = env
	add_child(world)
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-38, -25, 0)
	moon.light_color = Color("8aabb9")
	moon.light_energy = 0.17
	moon.shadow_enabled = true
	moon.directional_shadow_max_distance = 55
	add_child(moon)
	var moon_mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 2.3
	sphere.height = 4.6
	sphere.radial_segments = 12
	sphere.rings = 6
	moon_mesh.mesh = sphere
	var moon_material := StandardMaterial3D.new()
	moon_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	moon_material.albedo_color = Color("8faaa7")
	moon_material.disable_fog = true
	moon_mesh.material_override = moon_material
	moon_mesh.position = Vector3(-35, 48, -85)
	add_child(moon_mesh)

func _ground() -> void:
	_box("Ground", Vector3(180, 0.4, 180), Vector3(0, -0.25, 0), "dirt")
	_box("Forecourt", Vector3(33, 0.10, 32), Vector3(0, -0.01, 5), "asphalt")
	_box("Road", Vector3(170, 0.08, 8), Vector3(0, 0, 25), "asphalt")
	for x in range(-80, 81, 7):
		_box("Road dash", Vector3(3, 0.008, 0.09), Vector3(x, 0.046, 25), "yellow", false)
	for z in [21.3, 28.7]:
		_box("Road edge", Vector3(170, 0.008, 0.08), Vector3(0, 0.046, z), "white", false)
	for x in [-13.5, -10.5, -7.5, 7.5, 10.5, 13.5]:
		_box("Parking stripe", Vector3(0.10, 0.012, 4), Vector3(x, 0.048, -0.2), "cream", false)
	for x in [-16.5, 16.5]:
		_box("Curb", Vector3(0.22, 0.16, 24), Vector3(x, 0.04, 1), "concrete")
	# Invisible boundaries keep the small environment walkable without falling off it.
	for x in [-60, 60]:
		_boundary(Vector3(x, 4, 0), Vector3(1, 8, 140))
	for z in [-60, 60]:
		_boundary(Vector3(0, 4, z), Vector3(140, 8, 1))

func _boundary(at: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.position = at
	body.add_child(shape)
	add_child(body)

func _building() -> void:
	_box("Shop floor", Vector3(14, 0.14, 10), Vector3(0, 0, -6), "tile")
	_box("Back wall", Vector3(14.4, 3.7, 0.3), Vector3(0, 1.8, -11), "plaster")
	for x in [-7, 7]:
		_box("Side wall", Vector3(0.3, 3.7, 10), Vector3(x, 1.8, -6), "plaster")
		_box("Side trim", Vector3(0.34, 0.35, 10.2), Vector3(x, 0.7, -6), "red")
	_box("Roof", Vector3(14.7, 0.25, 10.7), Vector3(0, 3.68, -6), "roof")
	_box("Interior ceiling", Vector3(13.7, 0.1, 9.7), Vector3(0, 3.5, -6), "cream", false)
	for x in [-4.35, 4.35]:
		_box("Window sill wall", Vector3(5.3, 0.62, 0.24), Vector3(x, 0.31, -1), "plaster")
		_box("Window", Vector3(5.3, 2.1, 0.045), Vector3(x, 1.69, -1), "glass")
		_box("Window bottom frame", Vector3(5.4, 0.075, 0.14), Vector3(x, 0.68, -0.96), "metal")
		for dx in [-2.66, 0, 2.66]:
			_box("Window mullion", Vector3(0.08, 2.25, 0.16), Vector3(x + dx, 1.67, -0.96), "metal")
		_box("Red facade stripe", Vector3(5.35, 0.19, 0.28), Vector3(x, 0.4, -0.97), "red", false)
	_box("Lintel", Vector3(14.4, 0.78, 0.32), Vector3(0, 3.12, -1), "cream")
	_box("Fascia", Vector3(14.9, 0.59, 0.26), Vector3(0, 3.85, -0.75), "red")
	_text("L A S T   L I G H T", Vector3(0, 3.88, -0.60), 56, 0.010)
	_text("FUEL  /  COFFEE  /  PROVISIONS", Vector3(0, 3.23, -0.80), 30, 0.008, Color("3e4d40"))
	for x in [-1.52, 1.52]:
		_box("Door jamb", Vector3(0.14, 2.74, 0.22), Vector3(x, 1.37, -1), "metal")
	_box("Door motor housing", Vector3(3.15, 0.19, 0.30), Vector3(0, 2.77, -1), "metal")
	_box("Door sensor", Vector3(0.18, 0.08, 0.09), Vector3(0, 2.79, -0.80), "black", false)
	_box("Sensor LED", Vector3(0.025, 0.025, 0.012), Vector3(0, 2.79, -0.749), "fluorescent", false)
	_box("Entry mat", Vector3(2.9, 0.025, 1.7), Vector3(0, 0.087, -1.5), "rubber", false)
	door = SlidingDoor.new()
	door.name = "AutomaticDoors"
	door.position = Vector3(0, 0.08, -1)
	add_child(door)
	_box("Open sign panel", Vector3(1.3, 0.55, 0.07), Vector3(4.4, 2.13, -0.9), "dark", false)
	_text("OPEN", Vector3(4.4, 2.13, -0.85), 52, 0.009, Color("edb976"))
	_light(Vector3(4.4, 2.1, -0.4), Color("f2b06f"), 0.7, 2.8)
	# Exterior notice, deliberately tiny and diegetic.
	_box("Notice", Vector3(0.8, 0.48, 0.03), Vector3(-2.7, 1.55, -0.89), "cream", false)
	_text("NO SIGNAL\nCASH ONLY", Vector3(-2.7, 1.55, -0.865), 24, 0.006, Color("394b40"))

func _canopy() -> void:
	_box("Canopy top", Vector3(15.2, 0.28, 7.8), Vector3(0, 4.35, 4.9), "roof")
	_box("Canopy underside", Vector3(15, 0.12, 7.6), Vector3(0, 4.16, 4.9), "cream", false)
	for z in [1.0, 8.8]:
		_box("Canopy red fascia", Vector3(15.4, 0.57, 0.17), Vector3(0, 4.34, z), "red")
		_box("Canopy pinstripe", Vector3(15.5, 0.07, 0.18), Vector3(0, 4.16, z + 0.012), "yellow", false)
	for x in [-7.65, 7.65]:
		_box("Canopy side fascia", Vector3(0.17, 0.57, 7.85), Vector3(x, 4.34, 4.9), "red")
	for x in [-6.6, 6.6]:
		_box("Canopy post", Vector3(0.27, 4.2, 0.27), Vector3(x, 2.1, 5), "cream")
		_box("Post foot", Vector3(0.38, 0.7, 0.38), Vector3(x, 0.35, 5), "red")
	for x in [-4, 4]:
		for z in [3.0, 7.0]:
			_box("Canopy light", Vector3(1.45, 0.05, 0.45), Vector3(x, 4.07, z), "lamp", false)
			_downlight(Vector3(x, 3.86, z), Color("ffd098"), 2.8, 8.5)
			_light(Vector3(x, 3.90, z), Color("ffe0b5"), 0.45, 4.0)
	_text("24 HOUR", Vector3(0, 4.36, 8.91), 42, 0.010)

func _pumps() -> void:
	for x in [-4.5, 4.5]:
		_box("Pump island", Vector3(2.5, 0.16, 3.5), Vector3(x, 0.08, 4.6), "concrete")
		_box("Pump base", Vector3(0.98, 1.0, 0.64), Vector3(x, 0.66, 4.6), "red")
		_box("Pump head", Vector3(1.12, 1.0, 0.73), Vector3(x, 1.66, 4.6), "cream")
		_box("Pump cap", Vector3(1.17, 0.09, 0.78), Vector3(x, 2.20, 4.6), "red")
		for z in [4.22, 4.98]:
			_box("Pump display", Vector3(0.79, 0.40, 0.025), Vector3(x, 1.76, z), "black", false)
			_box("Pump keys", Vector3(0.48, 0.18, 0.025), Vector3(x, 1.34, z), "metal", false)
			var yaw := PI if z < 4.6 else 0.0
			var face := -0.02 if z < 4.6 else 0.02
			_text("038.90", Vector3(x, 1.81, z + face), 32, 0.0048, Color("bdd6a2"), yaw)
			_text("UNLEADED", Vector3(x, 2.08, z + face), 20, 0.0044, Color("3a4e40"), yaw)
		_box("Pump number", Vector3(0.38, 0.31, 0.08), Vector3(x, 2.39, 4.6), "dark", false)
		_text("01" if x < 0 else "02", Vector3(x, 2.39, 4.65), 30, 0.007)
		# A coarse segmented hose hangs down the outside of each pump.
		var side := -1 if x < 0 else 1
		var points: Array[Vector3] = [Vector3(x + side * 0.57, 1.92, 4.6), Vector3(x + side * 0.88, 1.72, 4.6), Vector3(x + side * 1.0, 0.54, 4.6), Vector3(x + side * 0.76, 0.39, 4.6), Vector3(x + side * 0.62, 1.35, 4.6)]
		for i in range(points.size() - 1):
			_rod(points[i], points[i+1], 0.035, "black")
		_box("Nozzle", Vector3(0.11, 0.32, 0.14), Vector3(x + side * 0.63, 1.43, 4.6), "metal", false).rotation.z = side * -0.3
		for z in [3.3, 5.9]:
			_cylinder(Vector3(x, 0.48, z), 0.08, 0.80, "yellow")

func _rod(a: Vector3, b: Vector3, radius: float, mat: String) -> void:
	var rod := _cylinder((a + b) * 0.5, radius, a.distance_to(b), mat, -1, 6)
	var direction := (b-a).normalized()
	if absf(direction.dot(Vector3.UP)) < 0.999:
		rod.quaternion = Quaternion(Vector3.UP, direction)

func _interior() -> void:
	for x in [-4.5, 0.0, 4.5]:
		_box("Ceiling tube housing", Vector3(0.42, 0.09, 2.0), Vector3(x, 3.38, -6.2), "metal", false)
		_box("Ceiling tube", Vector3(0.23, 0.04, 1.8), Vector3(x, 3.32, -6.2), "fluorescent", false)
		var lamp := _light(Vector3(x, 3.08, -6.2), Color("b8d8ca"), 1.12, 5.4, true)
		if x == -4.5:
			flicker_light = lamp
	# Counter to the left of the entrance leaves the middle aisle clear.
	_box("Counter", Vector3(3.4, 1.03, 1.1), Vector3(-4.75, 0.60, -3.5), "red")
	_box("Countertop", Vector3(3.6, 0.13, 1.25), Vector3(-4.75, 1.18, -3.5), "cream")
	_box("Register base", Vector3(0.60, 0.18, 0.48), Vector3(-4.5, 1.33, -3.5), "metal", false)
	_box("Register", Vector3(0.52, 0.38, 0.36), Vector3(-4.5, 1.55, -3.7), "cream", false)
	_box("Register screen", Vector3(0.36, 0.18, 0.025), Vector3(-4.5, 1.58, -3.50), "screen", false)
	_text("0.00", Vector3(-4.5, 1.58, -3.48), 25, 0.003, Color("bfddae"))
	_box("Counter service mat", Vector3(0.9, 0.02, 0.5), Vector3(-3.8, 1.26, -3.25), "dark", false)
	# Coffee station along the left wall.
	_box("Coffee cabinet", Vector3(1.0, 0.94, 2.2), Vector3(-6.15, 0.56, -8.1), "metal")
	_box("Coffee worktop", Vector3(1.14, 0.10, 2.35), Vector3(-6.15, 1.08, -8.1), "cream")
	_box("Coffee machine", Vector3(0.60, 0.85, 0.65), Vector3(-6.15, 1.55, -8.65), "dark", false)
	_cylinder(Vector3(-6.1, 1.38, -7.65), 0.17, 0.5, "cream")
	_text("FRESH COFFEE\nALL NIGHT", Vector3(-6.8, 2.15, -8.0), 35, 0.008, Color("ddd0a0"), PI/2)
	# Rear refrigerator bank, each with visible bottles and a glass door.
	for x in [-3.5, -1.85, -0.2]:
		_box("Refrigerator", Vector3(1.50, 2.55, 0.85), Vector3(x, 1.35, -10.35), "metal")
		_box("Fridge interior", Vector3(1.29, 2.13, 0.04), Vector3(x, 1.35, -9.90), "dark", false)
		for y in [0.48, 1.04, 1.60]:
			_box("Fridge shelf", Vector3(1.27, 0.045, 0.32), Vector3(x, y, -9.72), "white", false)
			for dx in [-0.43, -0.14, 0.14, 0.43]:
				_cylinder(Vector3(x+dx, y+0.19, -9.72), 0.09, 0.32, "green" if y < 1.5 else "amber", 0.065)
		_box("Fridge glass", Vector3(1.28, 2.12, 0.025), Vector3(x, 1.35, -9.50), "glass", false)
		_box("Fridge handle", Vector3(0.055, 0.6, 0.08), Vector3(x+0.51, 1.34, -9.46), "white", false)
		_box("Fridge header", Vector3(1.3, 0.19, 0.04), Vector3(x, 2.43, -9.89), "fluorescent", false)
	_text("C O L D   D R I N K S", Vector3(-1.9, 2.96, -10.76), 38, 0.011, Color("bccdae"))
	_light(Vector3(-1.9, 1.7, -9.2), Color("a1c9cc"), 1.0, 4)
	# Two low aisles: compact enough to see the door from anywhere.
	for z in [-5.2, -7.6]:
		_box("Aisle plinth", Vector3(3.2, 0.18, 0.9), Vector3(3.4, 0.17, z), "red")
		_box("Aisle back", Vector3(3.1, 1.45, 0.09), Vector3(3.4, 0.97, z), "cream")
		for x in [1.85, 4.95]:
			_box("Aisle upright", Vector3(0.07, 1.5, 0.85), Vector3(x, 0.99, z), "metal")
		for y in [0.35, 0.90, 1.45]:
			_box("Shelf", Vector3(3.2, 0.07, 0.92), Vector3(3.4, y, z), "cream")
			for x in range(8):
				for side in [-1, 1]:
					var px := 2.04 + x * 0.38
					var mat: String = ["red", "yellow", "green", "cream"][(x + int(y*3)) % 4]
					var height := random.randf_range(0.24, 0.38)
					_box("Packaged goods", Vector3(0.25, height, 0.23), Vector3(px, y+height/2+0.04, z+side*0.28), mat, false)
					_decal("Packet label", Vector3(px, y+height/2+0.05, z+side*0.402), Vector2(0.22, height*0.88), "crisps" if x % 2 == 0 else "soup", 0 if side == 1 else PI)
		_text("PANTRY  /  SUPPLIES", Vector3(3.4, 0.22, z+0.46), 20, 0.005, Color("d8caa0"))
	# Clock and a battered employee-only door on the back wall.
	_box("Staff door", Vector3(1.3, 2.45, 0.08), Vector3(5.7, 1.30, -10.80), "green", false)
	_box("Staff door frame", Vector3(1.43, 0.09, 0.14), Vector3(5.7, 2.56, -10.76), "metal", false)
	_text("STAFF ONLY", Vector3(5.7, 1.98, -10.73), 27, 0.005)
	_box("Staff handle", Vector3(0.12, 0.04, 0.08), Vector3(5.22, 1.18, -10.72), "cream", false)
	_box("Clock", Vector3(0.75, 0.48, 0.10), Vector3(3.4, 2.85, -10.75), "dark", false)
	_text("02:17", Vector3(3.4, 2.85, -10.68), 40, 0.007, Color("b5c69a"))

func _details() -> void:
	# Roadside pylon and prices.
	for x in [-12.8, -10.4]:
		_box("Sign post", Vector3(0.18, 6.5, 0.18), Vector3(x, 3.25, 9), "metal")
	_box("Pylon top", Vector3(3.7, 1.7, 0.32), Vector3(-11.6, 5.6, 9), "red")
	_text("LAST\nLIGHT", Vector3(-11.6, 5.65, 9.18), 56, 0.017)
	_box("Price board", Vector3(3.4, 1.5, 0.22), Vector3(-11.6, 3.8, 9), "dark")
	_text("REG   3.89\nDSL   4.09", Vector3(-11.6, 3.88, 9.13), 36, 0.011, Color("c4c9a0"))
	_text("OPEN ALL NIGHT", Vector3(-11.6, 3.25, 9.13), 24, 0.008, Color("d8a76b"))
	_light(Vector3(-11.6, 5.4, 9.7), Color("ffd99f"), 1.4, 7)
	# Bin and outdoor payphone.
	_box("Bin", Vector3(0.75, 1.15, 0.75), Vector3(6, 0.63, 0), "green")
	_box("Bin lid", Vector3(0.84, 0.14, 0.84), Vector3(6, 1.24, 0), "dark")
	_box("Bin slot", Vector3(0.43, 0.14, 0.025), Vector3(6, 1.03, 0.39), "black", false)
	_box("Payphone stand", Vector3(0.18, 1.4, 0.18), Vector3(-8.4, 0.7, -1.0), "metal")
	_box("Payphone cabinet", Vector3(0.75, 1.1, 0.4), Vector3(-8.4, 1.7, -1), "red")
	_box("Payphone face", Vector3(0.6, 0.72, 0.04), Vector3(-8.4, 1.66, -0.78), "metal", false)
	_box("Payphone handset", Vector3(0.13, 0.42, 0.10), Vector3(-8.57, 1.75, -0.73), "black", false)
	_text("PHONE", Vector3(-8.4, 2.17, -0.77), 26, 0.006)
	for y in range(3):
		for x in range(3):
			_box("Phone keypad", Vector3(0.04, 0.04, 0.02), Vector3(-8.31+x*0.06, 1.78-y*0.07, -0.75), "cream", false)
	# Utility pole and an angular overhead wire.
	_cylinder(Vector3(20, 4.4, 18), 0.18, 8.8, "bark")
	_box("Pole crossarm", Vector3(2.3, 0.16, 0.18), Vector3(20, 8.2, 18), "bark", false)
	_rod(Vector3(19,8.2,18), Vector3(3,7,18), 0.026, "black")
	_rod(Vector3(3,7,18), Vector3(-20,8.2,18), 0.026, "black")
	# A few curb weeds and loose paper scraps.
	for i in range(28):
		var x := random.randf_range(-16, 16)
		var z := random.randf_range(10, 18)
		if i < 5:
			_box("Discarded paper", Vector3(0.22, 0.005, 0.28), Vector3(x, 0.046, z), "cream", false).rotation.y = random.randf_range(0, TAU)
	# Wooden fence behind the property.
	for x in range(-22, 23, 3):
		_box("Fence post", Vector3(0.14, 1.4, 0.14), Vector3(x, 0.7, -17), "bark")
	for y in [0.42, 1.07]:
		_box("Fence rail", Vector3(45, 0.15, 0.10), Vector3(0, y, -17), "bark")

func _forest() -> void:
	for i in range(110):
		var x := random.randf_range(-65, 65)
		var z := random.randf_range(-58, 56)
		if (absf(x) < 22 and z > -19 and z < 32) or (z > 19 and z < 32):
			continue
		var height := random.randf_range(5.5, 11)
		_cylinder(Vector3(x, height*0.28, z), 0.16, height*0.56, "bark", 0.10, 5)
		for layer in range(3):
			var y := height * (0.39 + layer * 0.20)
			var radius := height * (0.27 - layer * 0.055)
			_cylinder(Vector3(x, y, z), radius, height*0.49, "pine" if i % 2 == 0 else "pine2", 0, 5)
	for i in range(16):
		var x := random.randf_range(-45, 45)
		var z := random.randf_range(-35, -20)
		var rock := _cylinder(Vector3(x, 0.25, z), random.randf_range(0.5, 1.2), 0.9, "metal", 0.3, 5)
		rock.rotation_degrees = Vector3(12, random.randf_range(0, 360), 15)

func _surface_details() -> void:
	_decal("Weathered coffee advertisement", Vector3(-5.7, 1.70, -0.90), Vector2(1.06, 1.32), "coffee_poster")
	_decal("Trail notice", Vector3(6.81, 1.90, -8.3), Vector2(1.0, 1.25), "forest_poster", -PI/2)
	_decal("Coffee menu", Vector3(-6.81, 2.2, -6.0), Vector2(1.05, 1.35), "coffee_poster", PI/2)
	_decal("Wall air vent", Vector3(1.8, 2.8, -10.82), Vector2(0.9, 0.55), "vent")
	# Warm counter lamp: a small competing pool of color in the cool shop.
	_box("Counter lamp foot", Vector3(0.24, 0.045, 0.24), Vector3(-5.7, 1.27, -3.6), "metal", false)
	_cylinder(Vector3(-5.7, 1.54, -3.6), 0.025, 0.5, "metal")
	_cylinder(Vector3(-5.7, 1.86, -3.6), 0.25, 0.28, "red", 0.13)
	_light(Vector3(-5.7, 1.71, -3.6), Color("ffb773"), 1.2, 3.5, true)
	# Small footings give the fixtures contact with the floor.
	for x in [-1.85, -3.5, -0.2]:
		_decal("Fridge lower vent", Vector3(x, 0.28, -9.885), Vector2(1.24, 0.23), "vent")

func _audio() -> void:
	soundscape = Soundscape.new()
	add_child(soundscape)
	var hum := AudioStreamPlayer3D.new()
	var hum_sound: AudioStreamWAV = load("res://assets/audio/hum.wav")
	hum_sound.loop_mode = AudioStreamWAV.LOOP_FORWARD
	hum_sound.loop_end = hum_sound.data.size() / 2
	hum.stream = hum_sound
	hum.position = Vector3(0, 3, -5)
	hum.volume_db = -18
	hum.bus = "Interior"
	hum.max_distance = 18
	add_child(hum)
	hum.play()

func _hud() -> void:
	var post_layer := CanvasLayer.new()
	post_layer.layer = 2
	add_child(post_layer)
	var effect := ColorRect.new()
	effect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := ShaderMaterial.new()
	shader.shader = load("res://shaders/retro.gdshader")
	effect.material = shader
	post_layer.add_child(effect)
	var layer := CanvasLayer.new()
	layer.layer = 3
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	var title := Label.new()
	title.text = "LAST LIGHT"
	title.position = Vector2(22, 16)
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color("e0d5b6"))
	root.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "ROUTE 09  /  02:17 AM"
	subtitle.position = Vector2(23, 36)
	subtitle.add_theme_font_size_override("font_size", 9)
	subtitle.add_theme_color_override("font_color", Color("91a89a"))
	root.add_child(subtitle)
	var controls := Label.new()
	controls.text = "WASD  WALK    SHIFT  HURRY    F  FLASHLIGHT    ESC  MENU"
	controls.position = Vector2(22, 330)
	controls.add_theme_font_size_override("font_size", 9)
	controls.add_theme_color_override("font_color", Color("a9b3a1"))
	root.add_child(controls)
	location_label = Label.new()
	location_label.position = Vector2(460, 20)
	location_label.size.x = 158
	location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	location_label.add_theme_font_size_override("font_size", 9)
	location_label.add_theme_color_override("font_color", Color("a9b3a1"))
	root.add_child(location_label)
	var crosshair := ColorRect.new()
	crosshair.color = Color(0.85, 0.9, 0.76, 0.65)
	crosshair.position = Vector2(319, 179)
	crosshair.size = Vector2(2, 2)
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(crosshair)
	pause_panel = PanelContainer.new()
	pause_panel.position = Vector2(165, 55)
	pause_panel.size = Vector2(310, 250)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.065, 0.06, 0.96)
	style.border_color = Color("68796b")
	style.set_border_width_all(1)
	style.content_margin_left = 24
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	style.content_margin_right = 24
	pause_panel.add_theme_stylebox_override("panel", style)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 10)
	pause_panel.add_child(menu)
	var heading := Label.new()
	heading.text = "TAKE YOUR TIME."
	heading.add_theme_font_size_override("font_size", 17)
	menu.add_child(heading)
	var info := Label.new()
	info.text = "Mouse to look · F11 fullscreen\nThe station is open. Come inside."
	info.add_theme_font_size_override("font_size", 11)
	menu.add_child(info)
	for bus in ["Music", "Effects"]:
		var row := HBoxContainer.new()
		var label := Label.new()
		label.text = bus.to_upper()
		label.custom_minimum_size.x = 65
		label.add_theme_font_size_override("font_size", 11)
		row.add_child(label)
		var slider := HSlider.new()
		slider.name = bus + "Volume"
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.01
		slider.value = soundscape.get_level(bus)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.value_changed.connect(func(value: float): soundscape.set_level(bus, value))
		row.add_child(slider)
		menu.add_child(row)
	var resume := Button.new()
	resume.text = "RESUME"
	resume.add_theme_font_size_override("font_size", 12)
	resume.pressed.connect(func(): player.capture_mouse(true))
	menu.add_child(resume)
	var quit_button := Button.new()
	quit_button.text = "QUIT TO DESKTOP"
	quit_button.add_theme_font_size_override("font_size", 12)
	quit_button.pressed.connect(func(): get_tree().quit())
	menu.add_child(quit_button)
	root.add_child(pause_panel)
	pause_panel.visible = false

func _process(delta: float) -> void:
	elapsed += delta
	if is_instance_valid(player):
		pause_panel.visible = not player.mouse_captured
		var inside := player.position.z < -1 and absf(player.position.x) < 7 and player.position.z > -11
		location_label.text = "CONVENIENCE STORE" if inside else "FORECOURT"
		soundscape.update_listener(player.position, delta)
	if is_instance_valid(flicker_light):
		# Infrequent gentle fluorescent flutter, not a strobe.
		flicker_light.light_energy = 0.91 if fmod(elapsed, 17.0) > 16.86 else 1.12

func _capture() -> void:
	player.test_mode = true
	player.capture_mouse(false)
	pause_panel.get_parent().visible = false
	await get_tree().create_timer(2).timeout
	var out := "res://artifacts"
	DirAccess.make_dir_recursive_absolute(out)
	get_viewport().get_texture().get_image().save_png(out + "/exterior.png")
	player.position = Vector3(0.4, 0.12, -2.8)
	player.rotation.y = -0.18
	player.pitch = -0.08
	await get_tree().create_timer(1).timeout
	get_viewport().get_texture().get_image().save_png(out + "/interior.png")
	player.position = Vector3(-2.0, 0.12, -2.1)
	player.rotation.y = 0.92
	player.pitch = -0.08
	await get_tree().create_timer(1).timeout
	get_viewport().get_texture().get_image().save_png(out + "/counter.png")
	print("RENDER_FPS: ", Engine.get_frames_per_second())
	print("CAPTURE_OK")
	get_tree().quit()
