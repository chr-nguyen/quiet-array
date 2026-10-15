extends Node
## Quiet stereo score, spatial machinery, and smoothly muffled outdoor ambience.

var music: AudioStreamPlayer
var forest: AudioStreamPlayer
var compressor: AudioStreamPlayer3D
var creak: AudioStreamPlayer3D
var outdoor_filter: AudioEffectLowPassFilter
var interior_mix := 0.0
var next_creak := 26.0
var clock := 0.0
var random := RandomNumberGenerator.new()

func _ready() -> void:
	name = "Soundscape"
	random.seed = 903
	outdoor_filter = AudioServer.get_bus_effect(AudioServer.get_bus_index("Outdoors"), 0)
	music = _flat("after_hours", "Music", -12)
	forest = _flat("forest", "Outdoors", -17)
	compressor = _spatial("compressor", Vector3(-1.9, 1.4, -9.8), -10, 8, true)
	creak = _spatial("sign_creak", Vector3(-11.6, 4.3, 9), -13, 26, false)
	# Load user's mix without changing the generated audio files.
	var config := ConfigFile.new()
	if config.load("user://audio.cfg") == OK:
		for bus in ["Music", "Effects"]:
			set_level(bus, clampf(float(config.get_value("audio", bus, 0.7)), 0, 1), false)

func _stream(name_text: String, loop: bool) -> AudioStreamWAV:
	var sound: AudioStreamWAV = load("res://assets/audio/" + name_text + ".wav")
	if loop:
		sound.loop_mode = AudioStreamWAV.LOOP_FORWARD
		sound.loop_begin = 0
		sound.loop_end = int(sound.mix_rate * sound.get_length())
	return sound

func _flat(file: String, bus: String, volume: float) -> AudioStreamPlayer:
	var node := AudioStreamPlayer.new()
	node.name = file.to_pascal_case()
	node.stream = _stream(file, true)
	node.bus = bus
	node.volume_db = volume
	add_child(node)
	node.play()
	return node

func _spatial(file: String, at: Vector3, volume: float, distance: float, loop: bool) -> AudioStreamPlayer3D:
	var node := AudioStreamPlayer3D.new()
	node.name = file.to_pascal_case()
	node.stream = _stream(file, loop)
	node.bus = "Effects"
	node.position = at
	node.volume_db = volume
	node.max_distance = distance
	node.unit_size = 2.0
	add_child(node)
	if loop:
		node.play()
	return node

func update_listener(at: Vector3, delta: float) -> void:
	var in_footprint := absf(at.x) < 6.95 and at.z > -10.95
	var target := clampf((-at.z - 0.7) / 2.4, 0, 1) if in_footprint else 0.0
	interior_mix = move_toward(interior_mix, target, delta * 0.8)
	forest.volume_db = lerpf(-17, -30, interior_mix)
	outdoor_filter.cutoff_hz = lerpf(6500, 850, interior_mix)
	music.volume_db = lerpf(-12, -15, interior_mix)
	clock += delta
	if clock > next_creak:
		next_creak = clock + random.randf_range(32, 53)
		creak.pitch_scale = random.randf_range(0.88, 1.04)
		creak.play()

func set_level(bus: String, value: float, save: bool = true) -> void:
	var index := AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.0001)))
	AudioServer.set_bus_mute(index, value < 0.001)
	if save:
		var config := ConfigFile.new()
		for key in ["Music", "Effects"]:
			config.set_value("audio", key, get_level(key))
		config.save("user://audio.cfg")

func get_level(bus: String) -> float:
	var index := AudioServer.get_bus_index(bus)
	return 0.0 if AudioServer.is_bus_mute(index) else db_to_linear(AudioServer.get_bus_volume_db(index))
