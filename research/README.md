# Reference investigation

## Obtaining the reference

Download from the [official Voices of the Void page](https://mrdrnose.itch.io/votv). Keep the complete extracted game directory, including its data folders, rather than only the launcher executable. Use `../reference/local/` inside this project for local copies; its contents are ignored by Git.

Record the exact build version and archive filename. A download is valuable for observing interaction feel, pacing, sound, and job flow. It is not required to begin our original prototype.

## Observe first

Play one tutorial/work cycle and record observations in [observations.md](observations.md). Time travel and work stages, note what feedback explains progress or failure, and distinguish observed behavior from guesses. Record settings and build version so comparisons are meaningful.

Useful questions:

1. What can the player do while acquisition or processing runs?
2. How does tuning communicate that the player is close to a useful signal?
3. How frequently does maintenance interrupt station work, and how long are the trips?
4. Which sounds are routine, and what makes an unusual sound stand out?
5. Which interactions make ordinary objects enjoyable to handle?

## Optional REA investigation

First inventory the downloaded build and identify the actual executable and content containers. Do not assume the launcher contains gameplay logic.

The documented REA native workflow uses an analysis provider; inspect its installation requirements before setup. Tool configuration is not part of this initial research workspace. [REA native investigation](https://github.com/morluto/rea/blob/main/docs/native-investigation.md) · [Installation documentation](https://github.com/morluto/rea/blob/main/docs/installation.md)

Pick a bounded question, such as whether a processing duration appears to depend on signal quality or equipment level. Compare controlled gameplay observations first. If ambiguity remains, use REA to look for supporting evidence and record addresses, tool versions, and limitations. Decompiled output is a hypothesis to validate against behavior.

Time-box the first investigation to one focused session. Continue only if it informs a concrete design decision; otherwise implement a tunable model of our own. Store binaries and raw analysis in `reference/local/`; put concise evidence summaries here.

## Research status

- Public documentation reviewed.
- The user supplied `~/Downloads/a09n.7z` (about 2.2 GB). A read-only archive directory listing identified `a09n/WindowsNoEditor/` and Unreal Engine runtime folders, including PhysX and XAudio2. No game code or visual assets have been extracted or analyzed.
- No REA installation or analysis performed.
- No claim that a specific mechanic has been reverse engineered.
