# Last Light / Quiet Array

A playable PSX-style Godot prototype: a small gas station at night, inspired by the low-poly atmosphere of Voices of the Void and PS1-era games. Walk around the forecourt, approach the automatic sliding doors, and explore the shop.

Original geometry, signs, synthesized audio, and a generated surface atlas. No extracted reference-game assets are required. The [1990s art-direction research](research/1990s-art-direction.md) explains the sources and how they informed the current scene.

## Run on Ubuntu

From this folder:

```bash
./run.sh
```

The official Godot **4.7.2 stable Linux x86_64** binary is already installed locally in `.tools/` on this machine. No system-wide engine installation is needed. The game uses OpenGL Compatibility rendering and was rendered on this Ubuntu machine's Intel UHD Graphics 620.

On a fresh checkout, install the project-local engine once (requires `curl`, `unzip`, and internet access), then play:

```bash
./tools/setup-godot.sh
./run.sh --editor --import --quit
./run.sh
```

Alternatively, import `project.godot` in Godot 4.7.2 and press F5. Open the editor with `./run.sh --editor`. Linux needs a graphical desktop and working OpenGL drivers; `--headless` is for checks, not playing.

## Controls

| Input | Action |
| --- | --- |
| WASD | Walk |
| Mouse | Look |
| Shift | Move faster |
| F | Toggle flashlight |
| Escape | Release mouse / show menu; press again to resume |
| Left click | Capture mouse / resume |
| F11 | Toggle fullscreen |
| Q while menu is open | Quit |

Doors open automatically from either side, remain open while you are nearby, and close shortly after you leave. The menu releases the mouse and stops player movement; ambient simulation continues.

The Escape menu includes independent **Music** and **Effects** sliders. Dragging a slider to zero mutes that bus. Levels are remembered between runs in Godot's local user-data folder.

## What is here

- A 640×360 render enlarged with nearest-neighbor scaling, RGB555-inspired 4×4 dithering, and angular trees/props.
- Sixteen 128×128 atlas surfaces: cracked asphalt, stained blocks, chipped enamel, worn checkerboard tile, timber, steel, vents, posters, and printed products.
- Warm downward canopy lights, cool fluorescents, a warm counter lamp, two fuel pumps, a price sign, payphone, forest, road, and blue-gray fog.
- A walkable shop with checkout, coffee station, stocked shelves, and refrigerators.
- Solid walls, windows, fixtures, and sliding door panels.
- **After Hours**, an original 64-second stereo ambient score with slow pads, a sparse bell-like motif, and repeating delay tails.
- Wind and insects that become quieter and muffled indoors, a spatial refrigerator compressor, distant sign creaks, fluorescent hum, and a door motor.
- Separate asphalt/tile footsteps and a little interior room reverb.
- Flashlight, fullscreen toggle, and a small menu.

This milestone is an explorable scene. Pumps, products, register, and staff door are scenery; signal jobs, inventory, saving, and story events belong to later milestones. The earlier signal-station design in `docs/` is retained as exploratory background.

## Checks and previews

```bash
./tools/check.sh
./run.sh --audio-driver Dummy -- --capture
```

The integration check covers floor support, entering and leaving the shop, door hold-open/close behavior, wall/window collisions, music startup/mute, surface footsteps, and indoor/outdoor audio transitions. Capture mode briefly opens a window, saves `artifacts/exterior.png`, `artifacts/interior.png`, and `artifacts/counter.png`, then exits. Preview files are local and ignored by Git.

The style pass passed all 15 integration checks and rendered on the Ubuntu Intel UHD 620 system. These are short validation runs, not a sustained performance benchmark.

## Project layout

- `scenes/main.tscn`: scene entry point.
- `scripts/station.gd`: deterministic procedural environment, lighting, sound, and HUD.
- `scripts/player.gd`: first-person capsule controller.
- `scripts/sliding_door.gd`: two moving collision bodies and proximity detection.
- `scripts/surface_library.gd`: source-atlas slicing and 128px material import.
- `scripts/soundscape.gd`: music, spatial effects, room transition, and saved mix controls.
- `shaders/retro.gdshader`: color banding, dithering, and vignette.
- `assets/`: generated texture atlas, base textures, and original sounds, included in the project.
- `assets/audio/after_hours.wav`: the standalone original soundtrack.
- `tools/generate-assets.py`: legacy base textures and basic effects (Python + Pillow).
- `tools/compose-audio.py`: reproducible original score and environment sounds (Python + NumPy 2.2.6; development only).
- `tests/smoke.gd`: physics integration checks.
- `reference/local/`: ignored space for private reference material.

Reference archive supplied by the user: `~/Downloads/a09n.7z`. Initial directory inspection identified a Windows Unreal packaged build. The archive remains in Downloads and is not needed to run this game.

The atlas was made with the built-in imagegen tool. Its source path, full generation prompt, and import treatment are recorded in [texture provenance](research/texture-atlas-prompt.md). The score uses original synthesized oscillators and note sequences; no third-party samples or recordings were used.
