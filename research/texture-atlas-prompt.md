# Station surface atlas provenance

Created for this project with the built-in imagegen tool on 2026-10-15.

Saved source: `assets/source/station-atlas.png`. Runtime use: `scripts/surface_library.gd` slices the atlas and reduces each tile to 128×128. The original generated source remains intact. The final row starts at 73.4% of image height; the slicer accounts for this generated layout variation.

No reference-game assets were supplied to the generator. The palette follows the existing station. The shader adds RGB555-inspired color reduction after lighting. This is a modern stylistic rendering pipeline, not a console emulator.

## Final generation prompt

Use case: stylized-concept
Asset type: one production diffuse texture atlas for a late-1990s low-poly 3D roadside gas station game.
Create a perfectly square 1024x1024 image, divided into exactly 4 columns and 4 rows of equal 256x256 square cells, no gutters, no borders between cells. Each cell is a flat straight-on seamless or tileable material surface, covering the full cell. No perspective, no objects rendered in 3D, no scene, no margins.
Art direction: 1997-1999 survival-horror environmental texture painting, scanned-material look reduced to coarse texels, muted earthy colors, stained lived-in surfaces, broad readable wear and directional dirt, painted-in subtle crevice shadows. This is diffuse color only, no glossy PBR or normal maps, no dramatic cast shadows. Readable variation at 128x128 per material, not random white-noise grain. Depict a maintained but aging 24-hour station, not a ruined building.
Exact cell layout, row by row, left to right:
Row 1: charcoal weathered asphalt with embedded aggregate and hairline cracks; aged beige painted cinderblock masonry with mortar joints and lower-edge damp stains; dirty ivory and muted olive checkerboard ceramic floor tiles with dark grout and worn edges; deep faded oxblood red painted metal with chips exposing rusty steel.
Row 2: yellowed ivory enamel metal with scratches and dirty corners; dark gray-green oxidized sheet steel with subtle seams and grease; brown weathered timber grain with broad knots; mossy soil and sparse dead pine needles, very dark olive brown.
Row 3: dull green corrugated roofing sheet viewed flat from directly above; tan concrete paving slabs with seams and small chips; vent grille with horizontal dark slots in corroded dull metal; near-black ribbed rubber doormat with dust.
Row 4: a full square vintage coffee advertising poster, ochre paper, red typography 'HOT COFFEE', black simple steaming cup illustration, small '25c'; square faded green nature-trail safety poster with a silhouette of pine forest and small cream text 'KEEP TO THE ROAD'; full square printed front label of an original red-and-cream bag of chips with potato illustration, bold text 'CRISPS'; full square printed front label of an original muted green tin of soup with a tomato illustration and text 'TOMATO'.
No copyrighted brands, no real-world game assets, no external frame, no tile numbering. Accurate cell boundaries are crucial for use as an atlas.
