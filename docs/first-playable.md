# First playable: one shift

Historical exploratory plan. The user's selected first implementation is now the **Last Light gas station walkthrough**; see the project README for the runnable milestone. This signal-work plan is possible future scope.

Proposed scope, pending the user's preferred focus. Target duration: 10–15 minutes.

## Player journey

1. Arrive at a small listening station near dusk. A short job note explains the controls and objective.
2. Tune a receiver using two controls and clear visual/audio feedback.
3. Lock onto a signal and start acquisition. The job advances while the player can move around.
4. An outdoor relay fails. Acquisition pauses with a clear explanation; the player carries a replacement part down a short path and repairs it.
5. Return, finish processing, and listen to the result. One subtle, original anomaly changes something the player previously saw or heard.
6. Archive the signal, receive credits, buy one useful upgrade, and finish the shift.

All events and tuning values here are original design proposals. We do not need the reference's exact formulas to test them.

## Implementation order

| Milestone | Deliverable | Acceptance check |
| --- | --- | --- |
| Movement and interaction | Blockout station, path, doors, receiver, carryable part | Complete the route and use objects without getting stuck |
| Signal loop | Explicit idle/tuning/acquiring/processing/ready/archived states | Complete a job and receive its reward exactly once |
| Maintenance | Relay health and a repair interaction | Failure pauses the job; repair resumes it without losing progress |
| Atmosphere | Original ambient sound, dusk lighting, one event | Event fires once and does not prevent completing the shift |
| Persistence | Versioned save data and continue/new-shift flow | Reload during acquisition, failure, and after payout with consistent state |

## Suggested architecture

- A player controller handles movement, looking, and interaction targeting.
- Interactable objects share a small interface for prompt, use, and availability.
- A signal-job state machine owns progress and payout eligibility; the receiver UI displays it.
- Equipment state influences job progress through explicit events.
- An event director checks prerequisites, cooldowns, and one-time event flags.
- Save data stores stable object/job IDs and gameplay state rather than arbitrary scene nodes.

Use a fixed random seed and a debug trigger for reproducible tuning and event checks. Keep economy values, timings, and signal definitions in data resources so we can adjust feel without rewriting systems.

## Scope limits for this milestone

One small map, three original signals, one failure type, one upgrade, one anomaly, and a small number of carryable props. Defer vehicles, multiplayer, a large wilderness, extensive crafting, and a long story campaign.

## Playtest questions

- Can a new player explain the job and finish it without developer help?
- Is there a meaningful action available while a signal processes?
- Does the maintenance trip create anticipation rather than annoyance?
- Is the anomaly noticeable without an explicit explanation?
- Would the player willingly start another shift?

Choose target hardware and a measurable frame-rate budget before performance sign-off. No playtest or runtime verification has occurred yet.
