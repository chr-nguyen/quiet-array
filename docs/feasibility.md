# Feasibility assessment

Historical initial assessment. A Godot gas-station walkthrough has since been implemented and validated on Ubuntu; see the project README for current status. Read the readiness notes below as the original pre-implementation snapshot.

Research date: 2026-10-15. This assessment uses public documentation and a local tool check; the reference game has not been downloaded, played, or analyzed in this workspace.

## What we can make

The reference's official page describes collecting, analyzing, processing, and selling signals at an isolated research station. It lists Windows and Unreal Engine. [Official game page](https://mrdrnose.itch.io/votv)

Our proposed experience is an original remote listening station where familiar work gradually becomes unreliable. The first objective is a 10–15 minute session that makes the player want to finish a job while worrying about what is outside.

| System | Initial approach | Main uncertainty |
| --- | --- | --- |
| First-person movement | Small walkable station and outdoor path | Movement feel and readability in low light |
| Interaction | One shared focus/use action; carry one object | Collision behavior when carrying objects |
| Signal work | Tune, acquire, process, archive | Interesting decisions versus waiting |
| Maintenance | A relay failure pauses acquisition | Travel adds tension without becoming tedious |
| Economy | A completed signal pays for one upgrade | Reward pacing |
| Horror | One authored event following a routine task | Audio, timing, and player attention |
| Persistence | Save job state, equipment state, credits, and event flags | Restoring consistent state without duplicate rewards |

These are our proposed systems, not claims about the reference's internal implementation. The basic technical pieces are conventional. Their integration, feel, and content are the substantial work.

## Engine direction

Use Godot 4/GDScript provisionally: its documented 3D and desktop support fit this scope, and a text-based project should suit our iteration workflow. This is an engineering recommendation, not a measured performance result. [Godot overview](https://docs.godotengine.org/en/stable/about/introduction.html)

Revisit Unreal if the desired project needs a substantially richer rendering pipeline or an Unreal-specific production workflow. Using the same engine as the reference would not itself recover its systems or content.

Do a small movement, lighting, and carry-physics spike before committing. The editor, exact engine version, target hardware, and frame-rate budget are still unselected.

## Where REA fits

REA documents native-binary inspection through tools such as Ghidra, Hopper, or IDA. It can return pseudocode, assembly, strings, and references. That could help answer a narrow question about a mechanic. [REA](https://github.com/morluto/rea)

Unreal packaging compiles code and converts assets to runtime formats, with editor-only or unused data removed. A distributed build is therefore a different artifact from an editable source project. [Epic's packaging documentation](https://dev.epicgames.com/documentation/en-us/unreal-engine/packaging-your-project)

Assessment: REA is an optional research aid. Nothing reviewed establishes that it can reconstruct this particular game's project, recover its Blueprint graphs, or interpret all its packaged content. Engine code may dominate native analysis, and relevant gameplay may live elsewhere. Inspect the actual files before selecting a workflow.

Start with gameplay observation. Use binary analysis only when a specific unanswered question could change our implementation. Build our own code, map, characters, audio, and event content.

## Effort and decision gates

Planning estimates, not delivery promises, assuming one experienced developer with assistant support and placeholder assets:

- Basic movement/interaction and signal loop: several focused days to two weeks.
- Cohesive first playable with audio, repair excursion, persistence, and one event: roughly two to six weeks.
- A polished, content-rich sandbox: many months or longer, depending heavily on scope and asset production.

Continue after the first playable if testers can complete a job without intervention, enjoy the normal work, notice the strange event, and want another shift. If the work is dull, change the loop before expanding the world. If physics or performance is unreliable, simplify and measure before adding content.

## Local readiness

The initial shell checks found Node.js v24.15.0, Git, and `ps`. Godot, Ghidra, and Java were not found on PATH; this does not prove they are absent elsewhere. No reference build or REA backend has been tested. Running the Windows reference game on this Linux host remains unverified.
