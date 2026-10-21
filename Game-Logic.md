# Game Logic — Night Ferry

Mechanics reference for the co-op shift-sim. This file consolidates the logic
described in `Idea-Pitch.md` and
`docs/superpowers/plans/2026-10-21-night-ferry-milestones.md`. Market research,
art direction, and deployment steps stay in those documents.

**Last reviewed:** 2026-10-21  
**Code baseline:** `be29d42` plus the in-progress M1 working tree  
**Status legend:** ✅ implemented · 🟡 partial or configured but unused · ❌ failing · ⬜ planned

> The server loop and client UI are still stubs. Everything marked ⬜ is design
> intent, not behavior you can play today. When this document and the code
> disagree, fix the code or fix this file — do not let both drift.

**Current state:** the shared state machine, seeded RNG, weighted selection,
interaction rules, anomaly definitions, greybox ferry, world accessors, three
anomaly behaviors, and the anomaly service exist. The server bootstrap, shift
loop, client UI, and playtest path do not. The e2e suite is currently red:
24 passed, 4 failed in `shift-state.spec.luau` (last run).

## 1. Game identity

| Item | Value |
|---|---|
| Genre | Co-op shift-sim with anomaly spotting |
| Players | 2–4 per server |
| Perspective | Third-person R15 |
| Authority | Server-authoritative; client presentation only |
| Session shape | One ferry, one crew, repeating day/night shifts |
| Content rating | Moderate or below; eerie, not gory |
| M1 scope | One greybox ferry, one route, 3 anomalies, no persistence |

The crew runs a ferry across a fogbound archipelago. By day they sell tickets,
load cargo, and keep the boat running. At night, anomalies appear — a passenger
sitting wrong, a cabin that should not exist, cargo that will not stay still —
and the crew must find and fix them.

## 2. Core loop

```text
Lobby
  → Day        (configured 120s; ends early when all day tasks are done)
  → Night      (configured 90s; ends early when all anomalies are fixed)
  → Results    (configured 12s; shows success/failure and the shift seed)
  → Lobby      (shiftNumber increments, next shift starts)
```

A **shift** is one full `Lobby → Day → Night → Results` cycle. The loop then
repeats with a new seeded night.

| Outcome | Rule | Status |
|---|---|---|
| Night success | All spawned anomalies resolved before the night timer expires | ⬜ |
| Night failure | Night timer expires with at least one anomaly unresolved | ⬜ |
| Day early finish | All day tasks completed; Night starts immediately | ⬜ |
| Day timeout | Day timer expires; Night starts with whatever tasks were completed | ⬜ |
| Night early finish | Last anomaly resolved; Results starts immediately | ⬜ |

Open questions about penalties and rewards are tracked in section 17.

## 3. Shift state machine

The pure state machine lives in `ShiftState` and owns phase, time remaining,
shift number, and last result. Server services drive it; the client only reads
the replicated attributes.

### 3.1 Phases

| Phase | Duration key | Entry | Exit | Early exit |
|---|---|---|---|---|
| `Lobby` | `LOBBY_DURATION_SECONDS` | Server start; after `Results` | Timer | None |
| `Day` | `DAY_DURATION_SECONDS` | From `Lobby` | Timer or all tasks done | Yes |
| `Night` | `NIGHT_DURATION_SECONDS` | From `Day` | Timer or all anomalies fixed | Yes |
| `Results` | `RESULTS_DURATION_SECONDS` | From `Night` | Timer | None |

Live durations in `ShiftConfig`: `Lobby 8s`, `Day 120s`, `Night 90s`,
`Results 12s`. The milestone plan originally listed `Day 300s` and
`Night 240s`; the working tree uses the shorter values. Confirm whether these
are the final M1 timings (section 17).

### 3.2 State shape

```lua
type ShiftState = {
    phase: ShiftPhase,
    timeRemaining: number,
    shiftNumber: number,
    lastSuccess: boolean,
}
```

### 3.3 API

| Function | Contract | Status |
|---|---|---|
| `ShiftState.new(config)` | New state in `Lobby`, `shiftNumber = 1`, `lastSuccess = false`, lobby duration | ✅ |
| `ShiftState.update(state, dt, config)` | Subtract `dt`; if the timer expires, advance exactly one phase and discard the remainder; `dt <= 0` is a no-op | ✅ |
| `ShiftState.advance(state, config, success?)` | Advance one phase explicitly; used for early exits | ✅ |

`update` and `advance` return:

```lua
{
    changed: boolean,
    previous: ShiftPhase,
    current: ShiftPhase,
}
```

### 3.4 Transition rules

1. A single `update` may advance at most one phase, even with a huge `dt`.
2. `update` with `dt <= 0` is a no-op.
3. On entering a phase, `timeRemaining` is reset to that phase's full duration.
4. `Night → Results` records `lastSuccess` from the `success` argument.
5. `lastSuccess` resets to `false` when the next `Day` starts.
6. `Results → Lobby` increments `shiftNumber`.
7. `Lobby → Day` does not increment `shiftNumber`.
8. The shift clock pauses when the server has zero players (intended; not
   implemented).

## 4. Day phase

Day is the calm half of the loop: five chores that teach movement and
interaction before the night.

| Task | Count | World object | Completion |
|---|---|---|---|
| Ticket | 3 | Ticket booth `ProximityPrompt` | `ShiftDayTasksDone += 1` |
| Cargo | 2 | Cargo area `ProximityPrompt` | `ShiftDayTasksDone += 1` |
| **Total** | **5** | | |

Rules:

- Prompts are enabled only during `Day` and disabled in every other phase.
- Completing all five tasks ends `Day` early and advances to `Night`.
- The task counter resets to `0` at the start of every shift.
- Completion is server-side and global to the crew. Per-player task credit is
  not part of M1.
- The client sees `ShiftDayTasksDone` and `ShiftDayTasksTotal`; it never writes
  them.
- Objective copy is carried by `ShiftObjective`; exact text is TBD.
- `ShiftConfig.DAY_TASK_COUNT` is `5`. `GreyboxFerry` creates five prompts and
  `WorldService:GetDayPrompts()` returns them; the shift service that enables
  and counts them does not exist yet.

## 5. Night phase

Night is the anomaly half. The server picks a seeded set of anomalies, spawns
them at tagged anchors, and waits for the crew to resolve them.

### 5.1 Spawning

- `AnomalyService:BeginNight(seed, count)` selects and spawns anomalies and
  returns the spawned count.
- M1 has three definitions and three anchor tags: `bench`, `cabin`, `cargo`.
  One anomaly is selected per tag from the seeded weighted table.
- Selection is without replacement. A count larger than the pool is capped at
  the pool size.
- Each anomaly is parented under `Ferry.Anomalies`.
- Each anchor is an invisible, anchored, non-collidable part with an
  `AnchorTag` attribute.
- Log the seed and the selected ids:
  `[NightFerry] night seed=<seed> anomalies=<ids>`.

### 5.2 Interaction and resolution

- Each anomaly gets a `ProximityPrompt`.
- The server validates distance, cooldown, and line of sight before calling the
  behavior; tool checks apply only to anomalies that require a tool.
- `onInteract` performs the fix; `resolve` marks the anomaly resolved; the
  service decrements the remaining count.
- Resolving the last anomaly ends `Night` early with success.
- When the night timer expires with anomalies remaining, the shift ends with
  failure.

### 5.3 Cleanup

`EndNight()` must:

- disconnect prompt connections,
- cancel tweens,
- destroy anomaly models and prompts,
- leave `Ferry.Anomalies` empty,
- return `GetRemainingCount() == 0`.

### 5.4 Service API

| Function | Contract | Status |
|---|---|---|
| `BeginNight(seed, count)` | Spawn selected anomalies, return spawned count | ✅ |
| `EndNight()` | Clean up all anomalies and return to idle | ✅ |
| `GetRemainingCount()` | Number of unresolved anomalies | ✅ |
| `GetActiveIds()` | Ids of active anomalies | ✅ |

Implemented in `src/server/Services/AnomalyService.luau`; not bootstrapped or
driven by a shift service yet.

## 6. Anomaly catalog (M1)

| Id | Display name | Anchor | Weight | Max distance | Prompt | Behavior |
|---|---|---|---|---|---|---|
| `wrong_passenger` | The Wrong Passenger | `bench` | 1 | 10 | Turn the passenger around | Passenger sits facing away from the bench; a face GUI is attached to the head. Interacting turns the head around and resolves. |
| `impossible_cabin` | The Impossible Cabin | `cabin` | 1 | 10 | Close the impossible door | An extra door frame appears on the cabin side with a neon gap. Interacting closes and dims it, then resolves. |
| `restless_cargo` | The Restless Cargo | `cargo` | 1 | 10 | Settle the cargo | A crate bobs on a looping tween. Interacting cancels the tween, settles the crate, and resolves. |

The definitions, three behavior modules, and `Registry` are implemented, and
`tests/anomalies.spec.luau` covers registration plus start/interact/cleanup. The
anomaly service that builds `AnomalyContext` and drives them is implemented but
not bootstrapped.

M1 constraints:

- Visuals are non-collidable primitives; no uploaded assets.
- No `math.random`; all randomness comes from the seeded RNG.
- `onInteract` does not read `player` in M1.
- Every definition in `AnomalyDefs` is registered in `Registry`.

## 7. Anomaly contract

An anomaly is **data + a server behavior + a test**. Definitions are pure
tables; behaviors are server-only modules.

```lua
type AnomalyDefinition = {
    id: string,
    displayName: string,
    weight: number,
    maxDistance: number,
    promptText: string,
    anchorTag: string,
}

type AnomalyContext = {
    definition: AnomalyDefinition,
    model: Model,
    anchor: BasePart,
    prompt: ProximityPrompt,
    state: { [string]: any },
    resolve: () -> (),
    log: (message: string) -> (),
}

type AnomalyBehavior = {
    start: (ctx: AnomalyContext) -> (),
    onInteract: (ctx: AnomalyContext, player: Player) -> (),
    resolve: (ctx: AnomalyContext) -> (),
    cleanup: (ctx: AnomalyContext) -> (),
}
```

The types above are implemented in `src/shared/Types.luau`, and the three
behavior modules, registry, and anomaly service are implemented in
`src/server`. The service is not bootstrapped yet.

Authoring steps:

1. Add the definition to `src/shared/Config/AnomalyDefs.luau` as pure data.
2. Add `src/server/Anomalies/<Name>.luau` implementing all four functions.
3. Register it in `src/server/Anomalies/Registry.luau`.
4. Add a test for selection or resolution logic.
5. Run the quality gates and playtest the fix and cleanup.

## 8. Seeded RNG and weighted selection

- The server owns the seed. Clients never generate gameplay randomness.
- `SeededRandom.new(seed)` wraps `Random.new(seed)`.
- `NextInteger(min, max)` returns an integer in `[min, max]`.
- `NextNumber(min, max)` returns a number in `[min, max)`.
- `AnomalySelection.pick(nextNumber, definitions, count)` filters out
  definitions with `weight <= 0`, draws from the cumulative weight, removes the
  selected definition, and repeats. It returns ids, caps at the pool size, and
  never repeats.
- The same seed and the same definition order produce the same id order.
- No `math.random` anywhere in gameplay code.

Both modules are implemented. The tests cover determinism, range, zero-weight
exclusion, count capping, the upper boundary, and an empty pool.

Reference selection loop:

```text
pool = definitions with weight > 0
repeat up to count times, or until pool is empty:
    total = sum(pool.weight)
    roll = nextNumber(0, total)        -- [0, total)
    accumulated = 0
    for each definition in pool:
        accumulated += definition.weight
        if roll < accumulated:
            select definition
            remove it from pool
            break
```

## 9. Server authority, attributes, and networking

### 9.1 M1: attributes, no remotes

The server publishes shift state as attributes on `workspace`. The client reads
attributes and updates presentation. M1 uses native `ProximityPrompt`s, so
there is no remote surface to validate yet.

| Attribute | Type | Writer | Purpose |
|---|---|---|---|
| `ShiftPhase` | string | `ShiftService` | `Lobby`, `Day`, `Night`, or `Results` |
| `ShiftTimeRemaining` | number | `ShiftService` | Seconds left in the current phase |
| `ShiftNumber` | number | `ShiftService` | Current shift, starting at 1 |
| `ShiftObjective` | string | `ShiftService` | HUD objective copy |
| `ShiftResult` | string | `ShiftService` | Success/failure text; format TBD |
| `ShiftSeed` | number | `ShiftService` | Seed for the current night |
| `ShiftDayTasksDone` | number | `ShiftService` | Completed day tasks |
| `ShiftDayTasksTotal` | number | `ShiftService` | Total day tasks (5) |
| `ShiftAnomaliesRemaining` | number | `AnomalyService` | Unresolved anomalies |

None of these attributes are written yet; the table is the contract.

### 9.2 Server rules

- The server is the only writer of phase, timers, seeds, anomaly resolution,
  coins, and purchases.
- Validate every interaction: distance, cooldown, and line of sight; add tool
  checks when an anomaly requires one.
- The client never decides whether an anomaly is resolved or a phase changed.
- M2 adds one typed remote for shop purchases in `src/shared/Net`; every
  argument is validated and rate-limited.

### 9.3 Client responsibilities

- HUD: phase, timer, objective, result, seed.
- Lighting: tween `ClockTime`, `Brightness`, `Ambient`, `OutdoorAmbient`,
  `FogEnd`, and `FogColor` on phase changes.
- Anomaly FX, audio, and prompts presented locally; no outcome decisions.
- HUD works at 375px wide; the top frame uses 90% width with a
  `UISizeConstraint` max of 480.

## 10. Player and party flow

- M1 allows 1–4 players to join the same public server. There is no party
  system, private server, or matchmaking.
- Players spawn on the ferry near the ticket booth.
- The first interaction must be reachable in under 60 seconds.
- A player leaving mid-shift is removed from per-player tracking; the shift
  continues if other players remain.
- With zero players, the shift clock pauses (intended; not implemented).
- Mid-shift joiners spawn into the current phase and participate immediately.
  There is no catch-up or spectator mode in M1.
- Downed, revive, and role assignment are out of scope for M1.

## 11. Economy and progression (M2)

M2 turns a completed shift into persistent progress. Nothing in this section
exists yet.

### 11.1 Coins

- Coins are granted server-side on shift success.
- Intended formula: base reward + reward per completed day task + reward per
  resolved anomaly. Exact values are TBD.
- Balance can never go negative.
- Spending is validated server-side.

### 11.2 Upgrades

| Id | Effect | Levels | Cost per level |
|---|---|---|---|
| `lamp` | Improves night visibility | 3 | `[100, 250, 600]` |
| `ledger` | +10% coins per day task per level | 3 | `[100, 250, 600]` |
| `hull` | +10s night duration per level | 3 | `[100, 250, 600]` |

- The shared ferry uses the highest level among the crew for each upgrade.
- The exact `lamp` effect (radius, brightness, or both) is TBD.

### 11.3 Profile schema v1

```lua
{
    version = 1,
    coins = 0,
    upgrades = { lamp = 0, ledger = 0, hull = 0 },
    stats = { shifts = 0, successes = 0, anomaliesFixed = 0 },
    tutorialDone = false,
}
```

### 11.4 Data and shop

- `DataService` owns all DataStore access: session-locked profiles, schema
  versioning, migrations, 60-second autosave, and `BindToClose`.
- `EconomyService` owns grants, spends, and `GetBalance`.
- The shop uses one `RemoteFunction` in `src/shared/Net`.
- Validate player, upgrade id, cost, balance, and rate limit on every request.
- The first-time tutorial has three steps: move, interact, fix. Completion is
  saved in the profile.
- The Results screen shows coins earned and the new balance.

## 12. Live ops and routes (M4)

- `WeeklyEvent.luau` derives a deterministic seed from the ISO week and
  exposes a name and modifiers. No backend and no hand-authored weekly
  treadmill.
- Example modifiers:
  - Fog Week: +1 anomaly, 1.25× coins.
  - Quiet Crossing: −1 anomaly, 0.9× coins, shorter day.
  - Ledger Week: 2× day-task coins.
- The event banner appears in the HUD; the seed appears in Results.
- Route 2, “North Passage”, unlocks through the lobby selection board
  (`ProximityPrompt`), uses different anomaly weights, a different fog color,
  and a coin multiplier.

The newer `event-update.md` roadmap proposes epoch-week indexing and a fixed
8-event rotation instead of the ISO-week seed above. Resolve that conflict
before M4.

## 13. Analytics and gates

### 13.1 Funnel

| Step | Number | Event | Dedupe |
|---|---|---|---|
| Joined | 1 | `joined` | Once per player |
| First interaction | 2 | `first_interaction` | Once per player |
| First successful shift | 3 | `shift_1_complete` | Once per player |

`AnalyticsService` calls
`AnalyticsService:LogOnboardingFunnelStepEvent(player, stepNumber, step)`
inside `pcall` and prints a local line for verification.

### 13.2 Soft-launch gates

- ≥70% of new players finish shift one.
- D1 ≥30%.
- D7 ≥12%.
- D28 ≥5%.
- ≥1.3 sessions per day among returning players.
- Miss two of four after two content updates: rework the core loop before
  spending on user acquisition.

## 14. Tuning and config

Live values and intended values are different things. The test fixtures
(`2 / 4 / 3 / 1` seconds) are not live tuning.

| Key | Live `ShiftConfig` | Intended M1 | Status |
|---|---|---|---|
| `LOBBY_DURATION_SECONDS` | 8 | 8s | 🟡 configured, no consumer yet |
| `DAY_DURATION_SECONDS` | 120 | 120s | 🟡 configured, no consumer yet |
| `NIGHT_DURATION_SECONDS` | 90 | 90s | 🟡 configured, no consumer yet |
| `RESULTS_DURATION_SECONDS` | 12 | 12s | 🟡 configured, no consumer yet |
| `MAX_PARTY_SIZE` | 4 | 4 | 🟡 configured, not enforced |
| `DAY_TASK_COUNT` | 5 | 5 | 🟡 configured, no consumer yet |
| `ANOMALIES_PER_NIGHT` | 3 | 3 | 🟡 configured, no consumer yet |
| `INTERACTION_MAX_DISTANCE` | 10 | 10 | 🟡 configured, no consumer yet |
| `INTERACTION_COOLDOWN_SECONDS` | 0.5 | 0.5 | 🟡 configured, no consumer yet |

The working tree uses `120s` day / `90s` night; the milestone plan originally
listed `300s` / `240s`. Confirm the final tuning. Values in
`tests/shift-state.spec.luau` are fixtures, not live tuning.

## 15. Invariants

1. The server is the only writer of phase, timers, seeds, resolution, coins, and
   purchases.
2. One `update` advances at most one phase; leftover delta is discarded.
3. Every phase exit cleans up its prompts, models, tweens, and connections.
4. Night never starts with zero spawned anomalies.
5. Anomaly ids never repeat within a night, and the count never exceeds the
   pool size.
6. Every id in `AnomalyDefs` has a behavior in `Registry`.
7. Every interaction is validated for range, cooldown, and line of sight; tool
   checks apply when the anomaly requires one.
8. Every night logs its seed and selected anomaly ids.
9. No `math.random` in gameplay code.
10. Coins never go negative; spends are validated server-side.
11. `ProcessReceipt` is idempotent and backed by a receipt ledger (M5).
12. Content stays at Moderate or below.
13. The client never decides outcomes.
14. Config tables contain data, not functions.

## 16. Implementation map

| Path | Responsibility | Status |
|---|---|---|
| `src/shared/Types.luau` | Shift, anomaly, and transition types | ✅ |
| `src/shared/Config/ShiftConfig.luau` | Nine tuning values | ✅ |
| `src/shared/Util/SeededRandom.luau` | `new`, `NextInteger`, `NextNumber` | ✅ |
| `src/shared/ShiftState.luau` | Pure phase machine | ✅ |
| `src/shared/AnomalySelection.luau` | Seeded weighted selection | ✅ |
| `src/shared/Util/InteractionRules.luau` | Range and cooldown helpers | ✅ |
| `src/shared/Config/AnomalyDefs.luau` | Three M1 definitions | ✅ |
| `src/server/init.server.luau` | Boot print only | 🟡 |
| `src/server/World/GreyboxFerry.luau` | Greybox map builder | ✅ |
| `src/server/Services/WorldService.luau` | Map accessors | 🟡 implemented, not bootstrapped |
| `src/server/Anomalies/*.luau` | Three behaviors plus `Registry` | ✅ |
| `src/server/Services/ShiftService.luau` | Loop driver and attributes | ⬜ |
| `src/server/Services/AnomalyService.luau` | Spawn, validate, resolve, clean up | 🟡 implemented, not bootstrapped |
| `src/server/Services/AnalyticsService.luau` | Funnel events | ⬜ |
| `src/client/init.client.luau` | Boot print only | 🟡 |
| `src/client/Controllers/HudController.luau` | Phase, timer, objective, result UI | ⬜ |
| `src/client/Controllers/LightingController.luau` | Day/night/fog lighting | ⬜ |
| `tests/smoke.spec.luau` | Smoke and seeded sequence | ✅ |
| `tests/shift-state.spec.luau` | Eight state-machine tests | ❌ 4 of 8 failing |
| `tests/seeded-random.spec.luau` | `NextNumber` determinism | ✅ |
| `tests/anomaly-selection.spec.luau` | Selection boundaries, cap, zero weight, empty pool | ✅ |
| `tests/interaction-rules.spec.luau` | Range and cooldown boundaries | ✅ |
| `tests/greybox-ferry.spec.luau` | World contract and prompt count | ✅ |
| `tests/anomalies.spec.luau` | Behavior contract | ✅ |
| `tests/anomaly-service.spec.luau` | Spawn/cap/cleanup contract | ⬜ not written |
| `docs/superpowers/plans/2026-10-21-night-ferry-milestones.md` | Delivery plan | ✅ |

Last e2e run: 28 tests, 24 passed, 4 failed. M1 Tasks 1–6 are implemented in
`src/shared` and `src/server`; the anomaly-service spec is missing, and Tasks
7–9 (shift service and bootstrap, analytics, HUD/lighting, playtest) remain.

### 16.1 Known failure

`tests/shift-state.spec.luau` has four failing cases: “records night success in
results”, “records night failure in results”, “increments the shift number when
results return to lobby”, and “resets last success when the next day starts”.
The tests call `ShiftState.advance` from `Lobby` and expect the next phase to be
`Night`, but the contract and implementation advance `Lobby → Day`. Add the
`Lobby → Day` step (`update` with the lobby duration) before the `advance`
assertions. Do this before calling M1 done.

### 16.2 Known map issue

`GreyboxFerry` places `CargoAnchor` at `(20, 2.5, 12)`, while `CargoArea` and
the day cargo prompts sit around `x = -19`. The night cargo anomaly will spawn
on the opposite side of the deck. Move the anchor into the cargo area.

Planned M2/M3/M4 modules not listed above: `DataService`, `EconomyService`,
`UpgradeService`, `ProfileStore` integration, the shop remote, `WeeklyEvent`,
and route selection.

## 17. Open questions

These are not decided anywhere in the current docs. The listed assumption is
the default the implementation will use until a decision is recorded here.

| # | Question | Current assumption | Decide by |
|---|---|---|---|
| 1 | What happens when the Day timer expires with tasks unfinished? | Shift advances to Night; no failure, coin penalty TBD | M2 |
| 2 | What is the exact `ShiftResult` string? | TBD | M1 |
| 3 | Are day tasks global or per player? | Global crew counter | M1 |
| 4 | Does the clock pause with zero players? | Yes | M1 |
| 5 | Can players join mid-shift? | Yes, they spawn into the current phase | M1 |
| 6 | Exact coin formula? | Base + day tasks + anomalies, values TBD | M2 |
| 7 | What does the `lamp` upgrade change? | Improve night visibility; exact effect TBD | M2 |
| 8 | Are the 120s day / 90s night timings final? | Current code uses 120/90; the plan originally listed 300/240 | M1 |
| 9 | Does a resolved anomaly disappear immediately or play an effect first? | Immediate despawn after its resolve animation | M1 |
| 10 | How long is the Results phase? | 12s in config; confirm | M1 |
| 11 | Does finishing Day early grant a bonus? | TBD | M2 |
| 12 | Is there a coin penalty for a failed night? | TBD | M2 |
| 13 | Which weekly-event selection design wins? | Milestone plan: ISO-week seed. `event-update.md`: epoch week plus a fixed 8-event rotation | M4 |

## 18. Change protocol

- Update this file whenever a mechanic, timing, or invariant changes.
- Add or update tests for the state machine, RNG, selection, interaction rules,
  and every anomaly behavior.
- A logic change is not done until the quality gates pass and a playtest
  console or screenshot is recorded.
- Keep market, art, and deployment material out of this file.
