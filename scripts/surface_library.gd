extends RefCounted
## Slice the source atlas at load time; each surface becomes a 128px game texture.
## Keeping the source intact makes the low-resolution import reproducible.

static func apply(materials: Dictionary) -> void:
	var source: Texture2D = load("res://assets/source/station-atlas.png")
	var atlas := source.get_image()
	# The generated sheet's last row begins slightly above the mathematical grid.
	var rows := [0.0, 0.25, 0.5, 0.734, 1.0]
	var names := ["asphalt", "plaster", "tile", "red", "cream", "metal", "bark", "dirt", "roof", "concrete", "vent", "rubber", "coffee_poster", "forest_poster", "crisps", "soup"]
	var scales := [0.32, 0.5, 0.72, 0.6, 0.65, 0.7, 0.7, 0.3, 0.5, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
	for index in range(16):
		var row := index / 4
		var col := index % 4
		var rect := Rect2i(int(col * atlas.get_width() / 4.0) + 2, int(rows[row] * atlas.get_height()) + 2, int(atlas.get_width() / 4.0) - 4, int((rows[row+1] - rows[row]) * atlas.get_height()) - 4)
		var surface := atlas.get_region(rect)
		surface.resize(128, 128, Image.INTERPOLATE_LANCZOS)
		var material := StandardMaterial3D.new()
		material.albedo_texture = ImageTexture.create_from_image(surface)
		material.albedo_color = Color(0.88, 0.90, 0.88)
		material.roughness = 1.0
		material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		material.uv1_triplanar = index < 10
		material.uv1_world_triplanar = index < 10
		material.uv1_scale = Vector3.ONE * scales[index] if index < 10 else Vector3.ONE
		if index == 0:
			material.albedo_color = Color(0.64, 0.69, 0.72)
		if index == 7:
			material.albedo_color = Color(0.36, 0.43, 0.38)
		materials[names[index]] = material
