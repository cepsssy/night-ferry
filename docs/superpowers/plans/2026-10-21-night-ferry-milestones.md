# Night Ferry Milestone Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a playable 2–4 player co-op shift loop, then grow it into a soft-launchable game with retention, content, and a clear continue/rework/stop gate.

**Architecture:** Server-authoritative Roblox place. Shared pure modules own state, seeded selection, and interaction rules. Server services own the world, shift loop, anomalies, and funnel events. Client controllers only render attributes and lighting. M1 uses native ProximityPrompts and workspace attributes: no remotes, no runtime dependencies. M2 adds ProfileStore and the first typed remote. M3 adds content, art, and Select readiness. M4 adds deterministic weekly modifiers and soft launch.

**Tech Stack:** Luau, Rojo 7.7.1, Wally, Jest Roblox, Selene, StyLua, luau-lsp, Roblox Studio, Studio MCP for playtests, Blender from M3.

**Spec:** `Idea-Pitch.md`

## Global Constraints

- Server owns phase, timers, seeds, anomaly resolution, grants, and purchases. Client never decides outcomes.
- Content as data: anomaly definitions and upgrade definitions are pure tables in `src/shared/Config`.
- Seeded RNG runs on the server only. Log every shift seed and every night's anomaly ids.
- Validate every interaction on the server: distance, cooldown, line of sight for anomalies.
- Keep content at Moderate or below. No gore, no external links.
- Never edit `src/**` or `Packages/**` through Studio MCP. MCP is for inspect, execute, playtest.
- Never commit `Packages/`, `DevPackages/`, `sourcemap.json`, `build/`, `*.rbxl`, `*.rbxlx`.
- A change is done only with test output and playtest evidence (console or screenshot).
- M1 excludes persistence, coins, shop, routes, private servers, Robux products, Blender, and React/Fusion.
- Calendar targets assume full-time work. Cut art and monetization before cutting the core loop.

## Milestone Map

| Milestone | Target | Goal | Exit gate |
|---|---|---|---|
| M0 Foundation | done | Toolchain, CI, headless tests, shared stubs | `check.ps1` + `e2e.ps1` pass; MCP or manual playtest path agreed |
| M1 Vertical slice | pitch Week 1 | One greybox ferry, day chores, 3 seeded anomalies, HUD, funnel, 2 players | Two full loops, day 5/5, night 3/3, failure path, reset, gates + playtest evidence |
| M2 Meta loop | pitch Week 2 | Persistent coins, 3 upgrades, coin shop, tutorial under 60s | Rejoin keeps progress, purchase applies, first interaction <60s |
| M3 Content + art + Select | pitch Week 3 | 10–12 anomalies, procedural variation, first art pass, closed playtest, Select checklist | 10–12 anomalies, ≥8 playtesters, ≥70% finish shift 1, Select checklist done |
| M4 Soft launch + live ops | pitch Week 4 | Deterministic weekly modifiers, route 2, soft launch, first content update | Live place, weekly event, 7 days of analytics, no P0 |
| M5 Gate review | +2 weeks | Decide continue, rework, or stop using the pitch gates | Gate report and signed decision |

**Pitch gates for M5:** ≥70% of new players finish shift one; D1 ≥30%; D7 ≥12%; D28 ≥5%; ≥1.3 sessions/day among returning players. Miss two of four after two content updates → rework the core loop before user acquisition.

## Review Focus

These are the failure modes the plan's tests must pin, most likely first:

1. Prompt triggered from outside range or through a wall → server rejects; pure range test plus service raycast.
2. Night starts with zero spawned anomalies or all anomalies resolve → no stuck phase; `nightActive` guard plus state tests.
3. Zero players or a player leaves mid-shift → timer does not run empty and no nil-character errors; `_update` guard plus playtest.
4. Shift repeats → day prompts reset, anomaly models and tweens cleaned; service cleanup test plus playtest.
5. Large frame delta at a phase boundary → one transition per tick, Results never skipped; ShiftState test.

## Current State

Already verified on 2026-10-21:

- Toolchain: Rojo 7.7.1, Wally 0.3.2, Selene 0.32.0, StyLua 2.6.0, luau-lsp 1.70.1, Lune 0.11.0.
- `scripts/check.ps1` exit 0; `scripts/e2e.ps1` prints `[NightFerry] e2e tests passed` with 3 tests.
- CI workflow green; artifact builds. Studio MCP not connected yet.
- `src/shared` has `Types`, `ShiftConfig`, `SeededRandom`; server/client only print boot lines.

M0 remaining manual work: enable Studio MCP (or use manual Play + screenshots), create the group-owned place, enable 2FA, and start Select paperwork (ID verification, maturity questionnaire). Start these in M1, not M3.

---

## M1 — Vertical Slice

### Scope

In:

- One code-built greybox ferry: deck, open cabin, bench, ticket booth, cargo area, lamps, water, spawn.
- One route, implied by the single map. No route system.
- Day: 5 ProximityPrompt tasks (3 passengers, 2 crates). Completing all ends day early.
- Night: 3 anomalies, one per anchor tag (`bench`, `cabin`, `cargo`), selected from a seeded weighted table. All fixed ends night early.
- Server state machine: Lobby → Day → Night → Results → Lobby. Timers can be tuned after playtest.
- Client HUD: phase, timer, objective, result, seed. Client lighting: day/night/fog.
- Funnel events: joined, first interaction, first successful shift. Console prints for local verification.
- Tests: shift state, seeded number stream, weighted selection, interaction rules, greybox contract, all anomaly behaviors, anomaly service spawn/cleanup.
- 1–4 players join the same public server; no party system.

Out:

- DataStore, coins, shop, upgrades, routes, private servers, Robux, ProcessReceipt, Blender, React/Fusion, Zap/Blink, remotes.
- Art beyond primitives. The greybox is a test harness and will be replaced in M3.

### File Map

```
src/shared/
  Config/ShiftConfig.luau        modify: M1 durations and counts
  Config/AnomalyDefs.luau        create: 3 definitions
  Types.luau                     modify: shift, anomaly, context types
  ShiftState.luau                create: pure phase machine
  AnomalySelection.luau          create: pure weighted selection
  Util/SeededRandom.luau         modify: NextNumber
  Util/InteractionRules.luau     create: range and cooldown
src/server/
  init.server.luau               modify: two-phase service loader
  World/GreyboxFerry.luau        create: map builder
  Services/WorldService.luau     create: map accessors
  Services/AnalyticsService.luau create: funnel wrapper
  Services/AnomalyService.luau   create: spawn/validate/resolve
  Services/ShiftService.luau     create: loop driver
  Anomalies/WrongPassenger.luau  create
  Anomalies/ImpossibleCabin.luau create
  Anomalies/RestlessCargo.luau   create
  Anomalies/Registry.luau        create
src/client/
  init.client.luau               modify: start controllers
  Controllers/HudController.luau create
  Controllers/LightingController.luau create
tests/
  seeded-random.spec.luau
  shift-state.spec.luau
  anomaly-selection.spec.luau
  interaction-rules.spec.luau
  greybox-ferry.spec.luau
  anomalies.spec.luau
  anomaly-service.spec.luau
```

### Task 1: Shift state machine and RNG extension

**Files:**
- Modify: `src/shared/Util/SeededRandom.luau`
- Modify: `src/shared/Types.luau`
- Create: `src/shared/ShiftState.luau`
- Test: `tests/seeded-random.spec.luau`, `tests/shift-state.spec.luau`

**Interfaces:**
- Produces `SeededRandom:NextNumber(min: number, max: number): number`, range `[min, max)`.
- Produces `Types.ShiftPhase = "Lobby" | "Day" | "Night" | "Results"`.
- Produces `Types.ShiftConfig` with `LOBBY_DURATION_SECONDS`, `DAY_DURATION_SECONDS`, `NIGHT_DURATION_SECONDS`, `RESULTS_DURATION_SECONDS`, `MAX_PARTY_SIZE`, `DAY_TASK_COUNT`, `ANOMALIES_PER_NIGHT`, `INTERACTION_MAX_DISTANCE`, `INTERACTION_COOLDOWN_SECONDS`.
- Produces `ShiftState.new(config)`, `ShiftState.update(state, dt, config)`, `ShiftState.advance(state, config, success?)`.
- Transition type: `{ changed: boolean, previous: ShiftPhase, current: ShiftPhase }`.

- [ ] **Step 1: Write the failing tests.**
  - `NextNumber` is deterministic for the same seed and stays in `[min, max)`.
  - New state is Lobby with the lobby duration.
  - `update` with the lobby duration moves to Day and resets to the day duration.
  - `update` with a smaller dt leaves the phase and reduces `timeRemaining`.
  - One `update` with a huge dt advances exactly one phase and discards the remainder.
  - `advance` moves Day → Night, Night → Results with `lastSuccess`, Results → Lobby increments `shiftNumber`.
  - `lastSuccess` resets when the next Day starts.
- [ ] **Step 2: Run `.\scripts\e2e.ps1`.** Expected: FAIL on missing `ShiftState` / nil `NextNumber`.
- [ ] **Step 3: Implement the tests' minimal code.** Keep one transition per `update`.
- [ ] **Step 4: Run `.\scripts\e2e.ps1`.** Expected: all specs pass.
- [ ] **Step 5: Run `.\scripts\check.ps1`.** Expected: exit 0.
- [ ] **Step 6: Commit.** `feat: add shift state machine and seeded number stream`.

### Task 2: Anomaly definitions and weighted selection

**Files:**
- Modify: `src/shared/Types.luau`
- Create: `src/shared/Config/AnomalyDefs.luau`
- Create: `src/shared/AnomalySelection.luau`
- Test: `tests/anomaly-selection.spec.luau`

**Interfaces:**
- `Types.AnomalyDefinition = { id: string, displayName: string, weight: number, maxDistance: number, promptText: string, anchorTag: string }`.
- `AnomalyDefs` contains exactly `wrong_passenger` (bench), `impossible_cabin` (cabin), `restless_cargo` (cargo); weight 1 each; max distance 10.
- `AnomalySelection.pick(nextNumber: (min: number, max: number) -> number, definitions: { { id: string, weight: number } }, count: number): { string }`.
- Selection filters weight ≤ 0, never repeats, caps at pool size, and is deterministic for the same stream.

- [ ] **Step 1: Write the failing tests.** Boundaries (`0` picks first, `total - epsilon` picks last), no repeats, zero-weight excluded, count cap, same seed same ids.
- [ ] **Step 2: Run e2e.** Expected: FAIL on missing module.
- [ ] **Step 3: Implement.** Use cumulative weights and remove each pick from the pool.
- [ ] **Step 4: Run e2e.** Expected: pass.
- [ ] **Step 5: Run `check.ps1`.** Expected: exit 0.
- [ ] **Step 6: Commit.** `feat: add anomaly definitions and seeded weighted selection`.

### Task 3: Interaction validation helpers

**Files:**
- Create: `src/shared/Util/InteractionRules.luau`
- Test: `tests/interaction-rules.spec.luau`

**Interfaces:**
- `InteractionRules.isInRange(from: Vector3, to: Vector3, maxDistance: number): boolean`.
- `InteractionRules.cooldownReady(lastUsedAt: number?, now: number, cooldown: number): boolean`.

- [ ] **Step 1: Write the failing tests.** Exact max distance passes; epsilon beyond fails. Nil last use passes; exact cooldown passes; too soon fails; zero cooldown passes.
- [ ] **Step 2: Run e2e.** Expected: FAIL on missing module.
- [ ] **Step 3: Implement.** Magnitude `<= maxDistance`; `nil or now - lastUsedAt >= cooldown`.
- [ ] **Step 4: Run e2e.** Expected: pass.
- [ ] **Step 5: Commit.** `feat: add server interaction validation helpers`.

### Task 4: Greybox ferry and world service

**Files:**
- Create: `src/server/World/GreyboxFerry.luau`
- Create: `src/server/Services/WorldService.luau`
- Test: `tests/greybox-ferry.spec.luau`

**Interfaces:**
- `GreyboxFerry.build(parent: Instance): Model` returns a `Ferry` model.
- `WorldService:Start()`, `GetAnomalyAnchors(): { BasePart }`, `GetDayPrompts(): { ProximityPrompt }`, `GetAnomalyContainer(): Folder`.

**Map contract:**
- Direct children `SpawnLocation`, `Anchors`, `DayTasks`, `Anomalies`.
- `Anchors`: 3 invisible, anchored, non-collidable, queryable parts with `AnchorTag` = `bench`, `cabin`, `cargo`.
- `DayTasks`: 5 ProximityPrompts, enabled only during Day; 3 ticket, 2 cargo.
- 3 lamp PointLights; water plane; hull, deck, open cabin, bench, ticket booth, cargo area, railings.
- `WorldService:Start` builds once, prints `[NightFerry] world ready anchors=3 dayTasks=5`.

- [ ] **Step 1: Write the failing test.** Count spawn, anchors, tags, 5 prompts, anomaly folder, anchor properties; prompt count matches `ShiftConfig.DAY_TASK_COUNT`.
- [ ] **Step 2: Run e2e.** Expected: FAIL on missing module.
- [ ] **Step 3: Implement the map and accessors.**
- [ ] **Step 4: Run e2e.** Expected: pass.
- [ ] **Step 5: Run `check.ps1`.** Expected: exit 0.
- [ ] **Step 6: Commit.** `feat: add greybox ferry map and world service`.

### Task 5: Anomaly behaviors and registry

**Files:**
- Modify: `src/shared/Types.luau`
- Create: `src/server/Anomalies/WrongPassenger.luau`
- Create: `src/server/Anomalies/ImpossibleCabin.luau`
- Create: `src/server/Anomalies/RestlessCargo.luau`
- Create: `src/server/Anomalies/Registry.luau`
- Test: `tests/anomalies.spec.luau`

**Interfaces:**
- `Types.AnomalyContext = { definition, model, anchor, prompt, state, resolve, log }`.
- `Types.AnomalyBehavior = { start(ctx), onInteract(ctx, player), resolve(ctx), cleanup(ctx) }`.
- `Registry: { [string]: AnomalyBehavior }` covers every id in `AnomalyDefs`.

**Behavior specs:**
- `WrongPassenger`: passenger at a bench facing away; face GUI on the head; interact turns the head around and resolves.
- `ImpossibleCabin`: extra door frame on the cabin side with neon gap; interact closes and dims it, resolves.
- `RestlessCargo`: crate bobs with a looping tween; interact cancels the tween, settles it, resolves.
- All visuals are non-collidable primitives; no assets; no `math.random`; `onInteract` does not read `player` in M1.

- [ ] **Step 1: Write the failing test.** For every def: behavior exists, all four functions are functions, `start` adds parts, `onInteract` calls the fake `resolve`, `resolve`/`cleanup` do not error.
- [ ] **Step 2: Run e2e.** Expected: FAIL on missing modules.
- [ ] **Step 3: Implement behaviors and registry.**
- [ ] **Step 4: Run e2e.** Expected: pass.
- [ ] **Step 5: Run `check.ps1`.** Expected: exit 0.
- [ ] **Step 6: Commit.** `feat: add three M1 anomaly behaviors`.

### Task 6: Anomaly service

**Files:**
- Create: `src/server/Services/AnomalyService.luau`
- Test: `tests/anomaly-service.spec.luau`

**Interfaces:**
- `BeginNight(seed: number, count: number): number` returns spawned count.
- `EndNight()`, `GetRemainingCount(): number`, `GetActiveIds(): { string }`.
- Uses `SeededRandom`, `AnomalySelection`, `Registry`, `WorldService`, `InteractionRules`, `ShiftConfig`.
- Validates range, cooldown, and line of sight before calling `onInteract`.
- Cleans up prompt connections, tweens, and models on resolve/end.

- [ ] **Step 1: Write the failing test.** Fake world with 3 tagged anchors and a separate container. Same seed twice gives the same id order. Count 3 spawns 3, count 10 caps at 3, `EndNight` leaves the container empty and remaining 0.
- [ ] **Step 2: Run e2e.** Expected: FAIL on missing module.
- [ ] **Step 3: Implement the service.** Log `[NightFerry] night seed=<seed> anomalies=<ids>`.
- [ ] **Step 4: Run e2e.** Expected: pass.
- [ ] **Step 5: Run `check.ps1`.** Expected: exit 0.
- [ ] **Step 6: Commit.** `feat: spawn and resolve seeded anomalies on the server`.

### Task 7: Analytics, shift service, bootstrap

**Files:**
- Create: `src/server/Services/AnalyticsService.luau`
- Create: `src/server/Services/ShiftService.luau`
- Modify: `src/server/init.server.luau`

**Interfaces:**
- `AnalyticsService:LogStep(player, step, stepNumber)`, `LogFirstInteraction(player)`, `LogShiftComplete(player)`.
  - Roblox call: `AnalyticsService:LogOnboardingFunnelStepEvent(player, stepNumber, step)`; wrap in `pcall` and print.
  - Steps: `joined` (1), `first_interaction` (2), `shift_1_complete` (3), deduped per player.
- `ShiftService:Start()` drives `ShiftState`, publishes attributes, connects day prompts, calls `AnomalyService`.
- Bootstrap order: `AnalyticsService`, `WorldService`, `AnomalyService`, `ShiftService`; require all, Init all, Start all synchronously.

**Published attributes on `workspace`:** `ShiftPhase`, `ShiftTimeRemaining`, `ShiftNumber`, `ShiftObjective`, `ShiftResult`, `ShiftSeed`, `ShiftDayTasksDone`, `ShiftDayTasksTotal`, `ShiftAnomaliesRemaining`.

- [ ] **Step 1: Implement the services.** No new pure logic; the state machine is already tested.
- [ ] **Step 2: Run `check.ps1`.** Expected: exit 0 (type/lint/build).
- [ ] **Step 3: Run `e2e.ps1`.** Expected: existing specs pass; no server boot in the RunScript path.
- [ ] **Step 4: Manual Play or MCP verification.** Expected console: `[NightFerry] server boot`, `world ready anchors=3 dayTasks=5`, `funnel step=joined`, `phase=Lobby`, `phase=Day shift=1 seed=<n>`, `phase=Night`, `phase=Results`.
- [ ] **Step 5: Commit.** `feat: run the day/night shift loop on the server`.

### Task 8: Client HUD and lighting

**Files:**
- Modify: `src/client/init.client.luau`
- Create: `src/client/Controllers/HudController.luau`
- Create: `src/client/Controllers/LightingController.luau`

**Interfaces:**
- `HudController:Start()` builds a `ScreenGui` with phase, timer, objective, results, seed; reads workspace attributes; no polling.
- `LightingController:Start()` tweens `ClockTime`, `Brightness`, `Ambient`, `OutdoorAmbient`, `FogEnd`, `FogColor` on phase changes.
- HUD works on a 375px-wide phone; top frame uses 90% width and `UISizeConstraint` max 480.
- Client only displays; no phase decisions.

- [ ] **Step 1: Implement controllers and wire `init.client.luau`.**
- [ ] **Step 2: Run `check.ps1`.** Expected: exit 0.
- [ ] **Step 3: Run `e2e.ps1`.** Expected: pass.
- [ ] **Step 4: Playtest.** Expected: HUD shows Lobby 0:08, Day objective, Night objective, Results with seed; lighting switches day/night; phone emulator screenshot.
- [ ] **Step 5: Commit.** `feat: add shift HUD and day/night lighting`.

### Task 9: Integration playtest, tuning, docs

**Files:**
- Modify: `src/shared/Config/ShiftConfig.luau` only if playtest shows timings are wrong.
- Modify: `README.md`, `Manual.md`
- Create: `docs/evidence/m1-playtest.md`

- [ ] **Step 1: Run `check.ps1` and `e2e.ps1`.** Expected: pass, marker printed.
- [ ] **Step 2: Two-player playtest.** Verify two full loops; day 5/5; night 3/3; failure path; next shift resets prompts and anomalies; no duplicate models in `Ferry.Anomalies`.
- [ ] **Step 3: Measure first interaction.** From spawn to first prompt under 60 seconds. If not, shorten Lobby or move spawn.
- [ ] **Step 4: Capture evidence.** Console excerpt with seed and phase transitions, day HUD screenshot, night anomaly screenshot, phone emulator screenshot. Save images under `build/evidence-m1/` (gitignored); record the excerpt and screenshot names in `docs/evidence/m1-playtest.md`.
- [ ] **Step 5: Update docs.** README: loop and controls. Manual: M1 playtest checklist and seed reproduction. Keep it short.
- [ ] **Step 6: Commit.** `feat: complete M1 vertical slice and record playtest evidence`.

### M1 Exit Criteria

- `scripts/check.ps1` exits 0.
- `scripts/e2e.ps1` prints `[NightFerry] e2e tests passed` with all new specs.
- Two-player playtest completes two loops, day 5/5, night 3/3, failure path, reset.
- Console shows seed, anomaly ids, phase transitions, and funnel steps.
- First interaction under 60 seconds.
- Day HUD, night anomaly, and phone screenshots captured.
- No P0 bug open.

---

## M2 — Meta Loop (roadmap)

**Target:** pitch Week 2. **Goal:** a returning player has persistent progress and a reason for one more shift.

**Scope:**
- Add ProfileStore as the first runtime dependency; map `Packages` in `default.project.json`; document the Wally version.
- `DataService`: session-locked profiles, schema v1, 60s autosave, `BindToClose`, migrations. Shape:
  `{ version = 1, coins = 0, upgrades = { lamp = 0, ledger = 0, hull = 0 }, stats = { shifts = 0, successes = 0, anomaliesFixed = 0 }, tutorialDone = false }`.
- `EconomyService`: server-only grants on shift success (base + day tasks + anomalies), spend, `GetBalance`; never negative. Tests for grant/spend/insufficient funds.
- `UpgradeDefs` + `UpgradeService`: 3 upgrades, 3 levels, cost curve `[100, 250, 600]`. Lamp improves night visibility; Ledger adds +10% coins per day task per level; Hull adds +10s night per level. Shared ferry uses the max level in the server.
- Coin shop: plain Instance UI, one `RemoteFunction` purchase request in `src/shared/Net`; validate player, upgrade id, cost, balance, rate limit. Tests for request validation and upgrade math.
- First-time experience: 3-step tutorial overlay (move, interact, fix), saved in profile; target first interaction <60s and ≥70% shift-1 completion in a fresh profile.
- Results screen shows coins earned and balance.

**Tests:** `economy.spec`, `upgrades.spec`, `profile-schema.spec`, `net-validation.spec`. DataService itself is playtested with Studio API access on.

**Exit:** rejoin keeps coins/upgrades; purchase applies and cannot go negative; tutorial completes; first interaction <60s; gates + playtest evidence.

**Out:** routes, Robux, ProcessReceipt, private servers, art.

---

## M3 — Content, Art, Select (roadmap)

**Target:** pitch Week 3. **Goal:** enough content and polish for a closed playtest and a Select-compatible listing.

**Scope:**
- Grow to 10–12 anomalies. Each is a pure def + server behavior + test, authored through `roblox-anomaly-authoring`. Content stays Moderate: eerie, not gory.
- Procedural variation: 2–3 anchors per tag, per-shift anchor/variant selection, anomaly count 2–4 by route or night. Tests for anchor and variant determinism.
- Differentiation experiment: a Ship's Log board listing expected passengers/cargo so anomalies are deviations from a manifest, not pure memorization. A/B it in the closed playtest; keep only if it improves fairness and completion.
- Art pass: modular kit, hero ferry hull/cabin, 10–15 props, anomaly props, lighting/fog, prompt/anomaly/night SFX. Blender for hero assets; MCP/asset search for filler. Save `.rbxm` to `src/assets`, `.blend` to `assets-src`, manifest to `assets-src/export-manifest.json`.
- Select readiness: group-owned place, 2FA, ID verification, maturity questionnaire Moderate, no external links. Start paperwork in M1.
- Closed playtest: 8–15 players, two sessions, funnel + feedback. Fix P0/P1 and log seeds.

**Tests:** every anomaly spec; variation determinism; all defs have behaviors. Mobile memory and MicroProfiler check.

**Exit:** 10–12 anomalies; ≥8 playtesters; ≥70% finish shift 1; no P0; Select checklist complete; phone screenshot; gates + evidence.

**Out:** soft launch, Robux, route selection.

---

## M4 — Soft Launch, Live Ops (roadmap)

**Target:** pitch Week 4. **Goal:** public soft launch with a weekly reason to return and enough data for the gate review.

**Scope:**
- `WeeklyEvent.luau`: deterministic ISO-week seed, name, and modifiers. Examples: Fog Week (+1 anomaly, 1.25x coins), Quiet Crossing (−1 anomaly, 0.9x coins, shorter day), Ledger Week (2x day-task coins). No backend, no hand-authored weekly event treadmill. Event banner in HUD; seed in results.
- Route 2 “North Passage”: unlock, lobby selection board (ProximityPrompt), different anomaly weights, fog color, coin multiplier. Tests for unlock, weights, and selection.
- Publish the place under the group; icon and thumbnails from the art track; Creator Analytics dashboard; no or small UA budget until gates.
- First content update: 2 new anomalies + event, using the authoring skill.
- Monetization stays deferred. If M5 says continue, add 2 cosmetic Robux products, idempotent `ProcessReceipt`, and a receipt ledger.

**Tests:** weekly determinism, route weights, unlock logic.

**Exit:** live place, weekly event, 7 days of data, no P0, first content update, gate review scheduled.

**Out:** Robux, private servers, UA spend, console.

---

## M5 — Gate Review (decision)

**Target:** 2–3 weeks after soft launch, after two content updates.

**Review:** shift-1 completion, D1/D7/D28, sessions/day, spend days, bug/seed log. Compare against the pitch gates.

**Decide:**
- **Continue:** add Robux cosmetics + idempotent `ProcessReceipt`, private servers, route 3, UA test, art polish.
- **Rework:** change the loop (manifest deduction, shorter shifts, co-op roles), run another closed playtest, then soft launch again.
- **Stop:** archive; keep the tech base for the next pitch.

**Deliverable:** `docs/metrics/gate-report.md` with the data, decision, and next plan. No code until the decision.

---

## Parallel Tracks

- **Select/account readiness (start M1):** 2FA, group, place under group, ID verification, maturity questionnaire, no external links. Human-owned; blocks M3/M4.
- **Art (start M2):** M2 modular greybox polish → M3 hero assets/SFX → M4 icon/thumbnails/clips. Blender + Roblox plugin; `.rbxm` in repo, `.blend` in `assets-src`.
- **Studio MCP/playtest (start M1):** enable MCP; if unavailable, manual Play + Output + screenshots. Every milestone needs evidence.
- **Analytics (start M1):** funnel events in M1; dashboard and gate report in M4/M5.

## Risks and Cuts

| Risk | Mitigation |
|---|---|
| 4-week target too aggressive | Only M1 is task-level. Later milestones are exit criteria and can slip. Cut art/monetization before the loop. |
| Clone risk / Animal Hospital comparison | Persistent ferry, seeded variation, manifest experiment, weekly modifiers; ask playtesters directly. |
| Anomaly memorization | M3 anchors/variants + manifest; M4 weekly modifiers. |
| First-play bounce | 8s lobby, spawn near the booth, HUD objective, native prompts; measure <60s. |
| Select rejection | Moderate content, no gore/links, paperwork started in M1. |
| Data loss or receipt bugs | ProfileStore session lock; ProcessReceipt deferred to M5 and idempotent with a ledger. |
| Scope creep | M1 excludes data/shop/routes/art/private servers/Robux. |
| MCP unavailable | Manual Play + Output + screenshots; MCP is an accelerator, not a blocker. |
| Mobile performance | Greybox is cheap; M3 tests low-end; avoid thousands of parts; StreamingEnabled only if needed. |
