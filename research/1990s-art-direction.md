# Late-1990s 3D: research and the Last Light art pass

Research and implementation: 2026-10-15. Focus: a readable first-person gas station on Ubuntu, informed by the texture economy of early 3D and the atmosphere of survival horror. Historical observations below are attributed; specific visual and musical choices for Last Light are our design judgments.

## Small textures did substantial work

In his retrospective, original Silent Hill artist Takayoshi Sato recalls early production constraints including 128×128 textures with 16 colors. He also argues that shadow placement and composition shape the final impression. His recollection is a useful production example, not a universal specification for all games on those consoles. [Sato, The Dust of Everyday Life](https://www.gamedeveloper.com/design/the-dust-of-everyday-life-the-art-of-building-characters)

Our application: replace generic noise and flat colors with readable surface information. A brick joint, paint chip, stain, or printed packet should explain what an object is before its geometry becomes detailed. The new atlas supplies masonry, aggregate asphalt, checkerboard tiles, oxidized steel, chipped paint, wood, concrete, rubber, ventilation slots, posters, and packaging. Each surface is reduced to 128×128 at runtime and sampled with nearest-neighbor filtering.

Broad variations matter more than high-frequency speckle. Wear is visible at edges and joints, and the main material remains legible from walking distance. The source atlas is deliberately higher resolution so future revisions can change the import treatment. This pass does not claim to reproduce a particular game's exact palette or memory budget.

## There was more than one period rendering style

The reverse-engineered PS1 GPU documentation describes 4-bit, 8-bit, and 15-bit texture modes; flat and Gouraud shading; and a specific 4×4 dither offset pattern used in reducing color to five bits per channel. These are concrete constraints, rather than a general rule that old games were blurry or noisy. [PSX-SPX GPU documentation](https://psx-spx.consoledev.net/graphicsprocessingunitgpu/)

For comparison, id Software's released Quake renderer explicitly builds surface lightmaps and combines them with dynamic light contributions. That is evidence for a different contemporary approach to surface lighting. We use this as a comparison, not as a claim about how Silent Hill was rendered. [Quake renderer source, R_BuildLightMap](https://github.com/id-Software/Quake/blob/master/WinQuake/gl_rsurf.c)

Our compromise is a modern Godot renderer with deliberately small diffuse textures, simple geometry, and partial RGB555-style postprocessing. The updated shader uses the documented dither offsets, but applies them to the final image rather than emulating GPU primitive processing. The 640×360 widescreen viewport, accurate depth testing, stable perspective, and dynamic shadow maps are modern conveniences. No forced vertex wobble, VHS noise, or severe texture distortion was added in this pass.

## Lighting should describe a place

Design judgment: the useful contrast here is between a small island of artificial light and the surrounding darkness. The earlier scene lit the canopy underside broadly and made the shop evenly green. That reduced the distinction between spaces.

| Zone | Revised treatment | Intended reading |
| --- | --- | --- |
| Forecourt | Warm downward spotlights with small local fill lights | A working station surrounded by night |
| Shop | Cooler fluorescent light with shorter reach | Familiar, slightly uncomfortable interior |
| Refrigerators | A localized cool light | A clear destination at the back wall |
| Counter | A small warm lamp | Human scale and evidence of daily use |
| Forest and road | Low ambient fill and denser blue-gray fog | Silhouettes and distance rather than total blackness |

Keep the doorway visible without the flashlight. Avoid making every surface glossy or using bloom to hide material detail. The floor pattern, shelving silhouette, and counter should remain distinguishable in a still image. Slight fluorescent variation stays infrequent and mild.

## Audio was richer than an 8-bit stereotype

The PS1 SPU documentation describes 24 voices, 44.1 kHz output, stereo reverberation, and external CD audio inputs. Small sampled sounds and high-quality streamed music could coexist; reducing every sound to a harsh low-bit-rate effect is not required for this era. [PSX-SPX SPU documentation](https://psx-spx.consoledev.net/soundprocessingunitspu/)

In a later interview reflecting on Silent Hill, Akira Yamaoka describes an emotional aim that includes loneliness and anxiety. He distinguishes the first game's more industrial character from later melodic approaches and discusses choosing sounds for the particular story. This is retrospective testimony, not a technical specification for the 1999 score. [Yamaoka interview, MusicRadar](https://www.musicradar.com/artists/rather-than-simply-writing-scary-music-i-wanted-to-express-loneliness-sadness-anxiety-and-the-psychological-aspects-of-fear-we-speak-to-video-game-horror-soundtrack-godfather-akira-yamaoka-about-the-legacy-of-silent-hill)

Our application is an original 64-second ambient cue, **After Hours**, built from slow overlapping minor/add9 voicings, a sparse bell-like motif, and stereo delay tails. It is synthesized from oscillators and an original note sequence, with no borrowed music or recordings. The quiet gaps let environmental sounds remain relevant.

The score is accompanied by filtered wind and insects, a localized refrigerator compressor, occasional distant sign creaks, and distinct asphalt/tile footsteps. Crossing into the shop smoothly reduces and low-pass filters the outdoor layer. Indoor footsteps use a short room reverb. Music and effects have separate volume sliders, including true mute, with preferences saved locally.

## How to review this pass

1. Stand at the initial view and locate the entrance without a flashlight.
2. Walk past a pump and inspect paint chips, the display, and its contact with the island.
3. Enter the shop, listen for the outdoor sound transition, then walk back outside.
4. Approach the fridge and compare its localized hum with the score.
5. Inspect the counter, wall posters, and products; details should come from texture as well as geometry.
6. Mute music in the menu and check whether the location still has an audible identity.

The generated source, prompt, and import notes are recorded in [texture-atlas-prompt.md](texture-atlas-prompt.md). Audio synthesis is reproducible with `tools/compose-audio.py`; `assets/audio/audio-report.json` records file levels and loop boundary measurements. Runtime previews and physics/audio integration checks provide validation; headphones and a longer subjective playtest are still useful for tuning the mix.
