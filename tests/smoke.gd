extends SceneTree
## Integration checks use actual physics, door detection, and the player's movement.

var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: " + description)
	else:
		failures.append(description)
		push_error("FAIL: " + description)

func stop_audio(node: Node) -> void:
	if node is AudioStreamPlayer or node is AudioStreamPlayer3D:
		node.stop()
	for child in node.get_children():
		stop_audio(child)

func _run() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	var game = scene.instantiate()
	root.add_child(game)
	var player = game.player
	var door = game.door
	player.test_mode = true
	player.position = Vector3(0, 0.15, 6)
	player.rotation = Vector3.ZERO
	await frames(60)
	check(player.is_on_floor(), "player stands on forecourt")
	check(game.soundscape.music.playing and game.soundscape.music.stream.stereo, "original stereo score starts playing")
	var previous_music: float = game.soundscape.get_level("Music")
	var previous_effects: float = game.soundscape.get_level("Effects")
	game.soundscape.set_level("Music", 0, false)
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")) and is_equal_approx(game.soundscape.get_level("Effects"), previous_effects), "music can be muted without changing effects")
	game.soundscape.set_level("Music", previous_music, false)
	check(door.openness < 0.01, "doors are closed without a nearby player")
	player.test_direction = Vector2(0, -1)
	await frames(185)
	player.test_direction = Vector2.ZERO
	await frames(15)
	check(player.position.z < -3.8, "walk from forecourt into shop through automatic doors")
	check(player.is_on_floor(), "shop floor supports player")
	await frames(160)
	check(door.openness < 0.01, "doors close after player leaves detection area")
	check(game.soundscape.interior_mix > 0.95 and game.soundscape.outdoor_filter.cutoff_hz < 1000, "entering shop muffles outdoor sound")
	check(player.footstep.stream == player.tile_step, "walking inside uses tile footsteps")
	player.test_direction = Vector2(0, 1)
	await frames(205)
	player.test_direction = Vector2.ZERO
	await frames(15)
	check(player.position.z > 3.0, "doors also detect player approaching from inside")
	player.position = Vector3(0, 0.15, -1)
	player.velocity = Vector3.ZERO
	await frames(220)
	check(door.openness > 0.99, "doors stay open while player stands in doorway")
	player.position = Vector3(4, 0.15, 2)
	player.velocity = Vector3.ZERO
	await frames(180)
	check(door.openness < 0.01, "doors close after the doorway is clear")
	check(game.soundscape.interior_mix < 0.05 and game.soundscape.outdoor_filter.cutoff_hz > 6000, "returning outside restores outdoor sound")
	player.test_direction = Vector2(0, -1)
	await frames(110)
	player.test_direction = Vector2.ZERO
	check(player.position.z > -0.65, "front windows and walls block walking through them")
	player.position = Vector3(6, 0.15, -6)
	player.velocity = Vector3.ZERO
	player.test_direction = Vector2(1, 0)
	await frames(65)
	player.test_direction = Vector2.ZERO
	check(player.position.x < 6.65, "side wall collision contains player")
	print("SMOKE_RESULT: %d failures" % failures.size())
	stop_audio(game)
	# Fixed-FPS tests outrun the real audio thread; allow its stop commands to drain.
	OS.delay_msec(100)
	game.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures.is_empty() else 1)
