I'll start with live research on what's trending on Roblox right now, then build the analysis on top of it.

**Short version:** Roblox's ranking system now rewards 28-day retention and co-play. The biggest new hit of 2026 is a co-op shift game, and clones of viral loops mostly fizzle. My pick is **Night Ferry**, a 2–4 player co-op shift-sim, and Phase 4 has its Rojo/Luau/MCP/Blender blueprint.

## Phase 1: Market research (as of Oct 21, 2026)

Concurrent-player figures come from third-party trackers, so treat them as approximate.

- **Traffic is cooler but more spread out.** Daily active users have fallen for three straight quarters, from a 152M peak in Q3 2025 to 123M in Q2 2026, though they're still up year over year. The top 10 games now hold about 20% of hours versus about 30% three years ago, and hours outside the top 10 grew 25% year over year. That favors sticky mid-sized games over one-week virals.
- **Discovery now pays for retention.** Recommended For You moved from a 7-day to a 28-day view. It scores day 1, days 2–7 and days 8–28 separately, and splits play-through, session quality and spend into their own signals. Roblox says retention, co-play and spend earn reach. The shareholder letter adds first-play bounce (leaving within roughly 30–90 seconds), spend days and Robux per user as inputs.
- **Money is moving toward older players.** US 18–34 players are growing over 50% year over year and monetize about 50% better than under-18s. From June 8, Roblox pays a 42% higher DevEx rate on spend from age-checked US 18+ players in eligible "novel" R15 games, and promotes those games in a Standout Games row. That lifts the rate from $0.0038 to about $0.0054 per Robux.
- **Under-16 reach is gated.** Kids (5–8) and Select (9–15) accounts only see games with approved maturity labels, and both catalogs exclude social hangouts and free-form drawing games. Developers need ID verification, two-factor authentication, and either a subscription or a refundable fee. That catalog is already around 30,000 games.
- **Current leaders.** On Oct 19 the top by live players were Steal An Egg (~895K), Murder Mystery 2 (~450K), Brookhaven (~372K), Adopt Me (~200K), Rivals (~194K) and 99 Nights in the Forest (~161K).
- **Steal An Egg and its clones.** It launched July 25 and hit about 14.3M concurrent on Sept 19 during a crossover, after weekly Saturday updates. It's now at about 6% of that peak. The clones mostly missed the wave: two peaked at 841 and 378 players, and the best one I found reached 45K.
- **Animal Hospital.** It launched May 10: you treat animal patients by day and survive anomalies at night. It went from about 884 average players on June 9 to about 430K on June 30, with a new event nearly every Saturday. It peaked around 1.3M in July. Parties are up to four players. Roblox itself named it as a game the new discovery system helped reach the top.
- **99 Nights in the Forest.** It launched in March 2025 and is rated Minimal. It's still #6 on live players about 19 months later.
- **Sports.** Volleyball Legends and Blue Lock: Rivals each peaked near 150K concurrent over the past 30 days.
- **Platform risk.** Roblox guided Q3 bookings down 14–18% year over year and expects monetization softness to persist. Don't build a plan on viral-level revenue.

**My design filter:** a 28-day meta-loop, co-play by default, fun inside 60 seconds, a maturity profile that can enter the Select catalog, and moments worth clipping.

## Phase 2: Pitch and Rebuttal

### 1. Night Ferry: co-op shift-sim with a persistent ferry
Players crew a ferry across a fogbound archipelago. By day they sell tickets, load cargo and keep passengers happy. At night anomalies appear, such as a passenger standing wrong or a cabin that wasn't there, and the crew must spot and fix them. Between shifts you upgrade the ferry, unlock routes, and play a weekly seeded "Fog Event."

**The Pitch.** The design lines up with what the ranking system measures:
- **Retention and co-play:** Ferry upgrades and routes give days 8–28 a purpose, and parties give co-play.
- **First-play bounce:** Shift one can start in seconds.
- **Demand:** Animal Hospital proved it in 2026.
- **Cost and netcode:** The footprint is small (one ferry, a few islands, modular props), and it's PvE, so there's no competitive netcode.
- **Monetization:** Ferry skins, uniforms and a weekly rotating shop create repeat spend days. Private servers and a route subscription are spend types the higher DevEx rate covers if you ever qualify as novel.
- **Clips:** Anomaly reactions are naturally clippable.

**The Rebuttal.** You'd be entering the shadow of an incumbent with a 1.3M peak, 2B+ visits, weekly events and a fandom. "Cozy day, horror night, co-op" will read as a reskin, and the clone data above shows how that ends. Anomaly-spotting is also a memorization puzzle. Once players learn the tells, tension dies unless you fund procedural variation. The weekly-event cadence is a staffing treadmill, and missing it will drag D28. Heavy horror can push your maturity label out of Select eligibility. A slow atmospheric opening is bounce poison.

### 2. Ricochet League: ranked 3v3 ability dodgeball
**The Pitch.** Competitive ability and sports games already hold big, loyal crowds, as the roughly 150K peaks above show. Rivals has about 194K live players at 94% approval. Ranked seasons and cosmetics are a natural D28 and spend-days engine, and skill expression produces highlight clips. R15 characters are native to sports, so the DevEx boost stays in play. Dodgeball is legible in five seconds, and I didn't see it among the top sports titles I pulled, though you should verify that before committing.

**The Rebuttal.** PvP lives on population density. At a few hundred concurrent players, queues stall and players leave, so you'd need bot-fill from day one. Fast projectiles are the hardest thing to make fair on Roblox's replication model. You'd end up writing server-authoritative projectile simulation with lag compensation, then fighting exploiters indefinitely. Incumbents with 150K-peak audiences set an animation and polish bar that is likely a 6–12 month build for a small team. Ranked players are also the least forgiving about balance patches.

### 3. Conveyor Island: co-op automation tycoon
**The Pitch.** Tycoon is Roblox-native: a tycoon variant, "Tycoon, but one dropper," ranked third on an early-October trending chart, and Theme Park Tycoon 2 is still on current best-of lists. Conveyor Island adds real logistics (belts, splitters, throughput ratios) in a factory shared by 2–4 players, with offline production. It targets the older audience Roblox is paying extra to reach. It might qualify for the novel-game rate and Standout row, but Roblox decides that. Systems depth supports long-term retention, and there's no PvP netcode.

**The Rebuttal.** Demand is unproven, since I found no Factorio-style game at scale in the charts. A financial model built on the 42% rate is a bet on Roblox's definition of "novel." Precise belt placement on a phone is miserable, and first-session complexity is exactly the bounce the algorithm punishes. Thousands of moving items punish low-end mobile, so you'd need a data-oriented simulation with client-side visualization, and months of work before it's fun. The older players who'd want this may not browse Roblox Home for it.

## Phase 3: The Judge's Verdict

Scores are my judgment, 1–5, higher is better.

| Criterion | Night Ferry | Ricochet League | Conveyor Island |
|---|---|---|---|
| Fit with 28-day retention and co-play signals | 5 | 4 | 3 |
| Demand proven in 2026 | 4 | 4 | 2 |
| Build cost and risk (5 = cheap) | 4 | 1 | 2 |
| Clone and incumbent safety | 2 | 2 | 4 |
| Under-16 reach (Select-friendly) | 4 | 4 | 3 |
| 18+ and DevEx upside | 3 | 4 | 5 |
| **Total** | **22** | **19** | **19** |

**Eliminated: Ricochet League.** Cold-start matchmaking, projectile netcode and an animation bar make it the most expensive way into a market where each incumbent already peaks near 150K. It's a good second-year game, not a first one.

**Eliminated: Conveyor Island.** It has the highest upside and the weakest evidence. Time-to-fun and bounce risk are too high for a first launch. Park it as the "novel" bet for when you have revenue.

**Winner: Night Ferry.**
1. It matches the signals Roblox says it rewards.
2. It has the best proof of a fast climb: Animal Hospital went from hundreds of players to roughly 430K in three weeks.
3. It has the cheapest path to a fun first build.
4. It can reach under-16s if you keep content at Moderate or below and clear the developer requirements.
5. Its main weakness, clone risk, is fixable by design: a persistent ferry base, procedural anomalies, an original setting, and weekly seeded events.

**Kill/continue gates.** These are my planning heuristics, not Roblox benchmarks, so recalibrate them against Creator Analytics. In a soft launch of a few hundred to a thousand players, I'd want:
- at least 70% of new players finishing shift one
- D1 ≥ 30%, D7 ≥ 12%, D28 ≥ 5%
- at least 1.3 sessions per day among returning players

If you miss two of the four after two content updates, rework the core loop before spending on user acquisition.

## Phase 4: Execution and technical blueprint (Night Ferry)

### 4.1 Environment setup
**Toolchain.** The usual stack is Rokit as the toolchain manager, with pinned tools such as Rojo, Wally, Selene, StyLua and luau-lsp. Use Rojo 7.7.0 or later, which adds `rojo syncback` for converting an existing place file into a project.

```bash
rokit init
rokit add rojo-rbx/rojo
rokit add UpliftGames/wally
rokit add JohnnyMorganz/StyLua
rokit add Kampfkarren/selene
rokit add JohnnyMorganz/luau-lsp
rojo plugin install                                              # Studio plugin
rojo serve                                                       # then Studio → Rojo plugin → Connect
rojo sourcemap default.project.json --watch -o sourcemap.json    # feeds luau-lsp
```

**Extensions and plugins.** In VS Code, install Luau Language Server, Rojo, StyLua and Selene. A common Studio plugin set is Rojo, Hoarcekat or UI Labs for UI stories, the luau-lsp companion, and Roblox's Blender add-on.

**Folder structure.**

```
night-ferry/
├─ default.project.json        # dev: rojo serve
├─ build.project.json          # CI/prod: rojo build -o build/NightFerry.rbxl
├─ rokit.toml  wally.toml  stylua.toml  selene.toml  .luaurc
├─ CLAUDE.md                   # architecture + rules for AI agents
├─ Packages/  ServerPackages/  # wally installs (gitignored)
├─ src/
│  ├─ shared/                  # → ReplicatedStorage.Shared
│  │  ├─ Config/               # ShiftConfig, AnomalyDefs, FerryUpgrades, Economy (pure data)
│  │  ├─ Types.luau
│  │  ├─ Net/                  # typed remote contracts
│  │  └─ Util/                 # Signal, Maid, SeededRandom
│  ├─ server/                  # → ServerScriptService.Server
│  │  ├─ init.server.luau      # two-phase bootstrap
│  │  ├─ Services/             # Data, Economy, Ferry, Shift, Anomaly, LiveOps, Analytics
│  │  └─ Anomalies/            # one module per anomaly behavior
│  ├─ client/                  # → StarterPlayerScripts.Client
│  │  ├─ init.client.luau
│  │  ├─ Controllers/          # Input, Camera, UI, Audio, AnomalyFX
│  │  └─ UI/                   # React-Lua / Vide / Fusion components
│  ├─ serverContent/           # → ServerStorage.Content (server-only prefabs)
│  └─ assets/                  # exported .rbxm models (reference uploaded asset IDs)
├─ assets-src/                 # .blend files, textures, export-manifest.json
├─ tests/                      # *.spec.luau for pure modules
└─ .github/workflows/          # selene, stylua --check, type-check, rojo build, Open Cloud publish
```

```json
{
  "name": "NightFerry",
  "globIgnorePaths": ["**/*.spec.luau"],
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "Shared": { "$path": "src/shared" },
      "Assets": { "$path": "src/assets" },
      "Packages": { "$path": "Packages" }
    },
    "ServerScriptService": {
      "Server": { "$path": "src/server" },
      "ServerPackages": { "$path": "ServerPackages" }
    },
    "ServerStorage": { "Content": { "$path": "src/serverContent" } },
    "StarterPlayer": {
      "StarterPlayerScripts": { "Client": { "$path": "src/client" } }
    }
  }
}
```

Use `.server.luau` for Scripts, `.client.luau` for LocalScripts, and plain `.luau` for ModuleScripts. Keep anything sensitive out of ReplicatedStorage.

### 4.2 Logic and architecture
The server owns state and the client owns presentation. A shared layer holds the contracts: config, types and network definitions.

| System | Server (authoritative) | Client (presentation) |
|---|---|---|
| Shift state machine | Owns phase, timers and seed; replicates phase via attributes | Phase UI, lighting and audio transitions |
| Anomalies | Spawns from seeded weighted tables; validates every interaction (range, line of sight, cooldown, tool) | Telegraphing FX, highlights, local ambience |
| Ferry and meta-progression | Upgrades, route unlocks, per-party state | Customization UI and previews |
| Economy and purchases | All grants; idempotent `ProcessReceipt` | Shop UI and price display only |
| Data | Session-locked profiles (ProfileStore or equivalent), schema versions, migrations | Never writes |
| Input | Receives intents, not results | Mobile-first input and prompts |
| Live-ops and analytics | Weekly config, Messaging broadcasts, funnel events | Event banners |

Rules I'd enforce:
- **Content as data:** Anomalies, items and upgrades are pure tables in `shared/Config`. Behaviors are server modules that share one interface (`start`, `onInteract`, `resolve`, `cleanup`).
- **Typed networking:** Use Zap or Blink, or a typed wrapper around remotes. Validate and rate-limit every argument.
- **Seeded RNG, server-side only:** Log the seed so you can reproduce bugs.
- **Session topology:** A lobby place reserves a private server per party and passes the seed through `TeleportData`. This avoids building matchmaking first.
- **Funnel instrumentation from day one:** Use `AnalyticsService` to log steps like "joined," "first interaction" and "shift 1 complete," so you see first-play bounce before the algorithm punishes it.
- **Tests:** Cover the state machine, RNG determinism and economy math with TestEZ or Jest-Roblox.

```lua
--!strict
-- src/server/init.server.luau
local Services = script.Services
local ORDER = { "DataService", "EconomyService", "FerryService", "AnomalyService", "ShiftService", "LiveOpsService", "AnalyticsService" }

local loaded: { [string]: any } = {}
for _, name in ORDER do
	loaded[name] = require(Services:FindFirstChild(name) :: ModuleScript) -- no side effects at require time
end
for _, name in ORDER do
	local svc = loaded[name]
	if svc.Init then svc:Init(loaded) end -- wire dependencies only
end
for _, name in ORDER do
	local svc = loaded[name]
	if svc.Start then task.spawn(svc.Start, svc) end -- connect events, start loops
end
```

### 4.3 MCP and AI integration
**Use the built-in server, not the old standalone one.** Studio ships its own MCP server (Assistant → ⋯ → Manage MCP Servers → Enable Studio as MCP server). It uses stdio, and Quick Connect supports Claude Code, Claude Desktop, Cursor, VS Code, Codex CLI, Gemini CLI and Antigravity. Roblox archived its standalone Rust MCP server on April 3, 2026 and recommends the built-in one. For manual config, the Windows command is `cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat` and the macOS path is `/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`.

The tools cover script read, search and edit; Luau execution in the Edit, Client or Server data model; play-mode control; console output; viewport screenshots; simulated keyboard, mouse and character movement; a playtest subagent; asset search and insert; and AI mesh, material and procedural-model generation. Every call takes a `studio_id`, so one client can drive several Studio windows. Connected clients can read and modify your open place, so connect only clients you trust.

**The catch with Rojo (my recommendation).** Rojo's default flow is filesystem to Studio. One GitHub issue on version 7.4.1 reports Studio-side script edits being silently overwritten when reconnecting. Current Rojo has an optional two-way sync setting for supported edits, plus `rojo syncback`, but I wouldn't build a workflow on either. Run two lanes instead:

| Job | Use | Source of truth |
|---|---|---|
| Write and refactor Luau | Claude Code or another agent editing files in the repo | Git, with Rojo syncing to Studio |
| Verify behavior | MCP: `start_stop_play`, `execute_luau` (Server/Client), `get_console_output`, `screen_capture`, playtest subagent | The live Studio session |
| Inspect the scene | MCP: `search_game_tree`, `inspect_instance`, `script_grep` | Read-only |
| Greybox, props, materials | MCP: `generate_mesh`, `generate_material`, `generate_procedural_model`, `search_asset`, `insert_asset` | Studio, then saved as `.rbxm` into `src/assets` |

Keep MCP's script-editing tools away from Rojo-managed paths.

**Agent loop.** The agent edits a module and its spec, and Rojo syncs it. The agent then starts play mode, uses `execute_luau` on the Server data model to trigger a shift, reads the console, takes a screenshot, and iterates.

**Optional project-specific MCP server** (TypeScript or Python). Useful tools would be:
- `validate_content`, which schema-checks AnomalyDefs and ShiftConfig
- `simulate_economy`, an offline Monte-Carlo of coins per shift and upgrade curves
- `publish_staging`, which publishes to a staging place through Open Cloud
- `post_live_config`, which writes the weekly event config to a DataStore and broadcasts it through Messaging

Put a `CLAUDE.md` at the repo root covering architecture, naming, "server owns the economy," "never edit `Packages/`," and "never edit Rojo-managed scripts through Studio MCP."

Roblox may also cover some of this itself. It plans Playtesting, Analytics and Experiment agents for Studio and Build over the coming months, and reports rising creator adoption of the agentic Studio Assistant.

### 4.4 Art and modelling pipeline
1. **Style and budget.** Use low-poly, stylized art and a modular kit (hull sections, deck tiles, cabin walls, island props) with vertex colors or a shared atlas to save draw calls and texture memory. Developers report a per-mesh cap of about 20K triangles, with the importer simplifying anything above it. Keep props in the low thousands and check the importer's warnings.
2. **Blender export.** Apply transforms and modifiers first. Roblox's FBX settings are Path Mode: Copy with Embed Textures on, Apply Scalings: FBX Unit Scale (or Transform Scale 0.01), and Add Leaf Bones off. glTF also works.
3. **Transfer.** You can use Studio's 3D Importer, or the Roblox Blender plugin, which links your account and sends objects straight into your open Studio session. It's open source and built on Open Cloud. Enable Upload to Roblox when you need a reusable asset ID. Upload under the group that owns the experience.
4. **Make assets Rojo-friendly.** After assembling a model in Studio, save it as `.rbxm` into `src/assets/`. MeshParts reference uploaded asset IDs, so the repo stays small. Keep `.blend` files and an `export-manifest.json` (object → asset ID → path) in `assets-src/`. A short Blender Python script can batch-export each collection with identical settings.
5. **AI assist.** Use MCP generation for greyboxing and filler props. Roblox says creators generate over 60K 3D assets per day with its Cube tools. Hand-clean hero assets like the ferry and anomaly creatures in Blender for style consistency.
6. **Animation.** Use R15 for crew, which also keeps the DevEx boost in play. For anomaly creatures, go from a Blender armature to FBX to the Importer. Author in the Animation Editor or Moon Animator.
7. **QA.** Test on a low-end phone profile, watch memory and the MicroProfiler, and enable StreamingEnabled for island content.

### 4.5 First 30 days (scale to your team size)
- **Week 1:** Build a vertical slice with one ferry, one route, three anomalies and two-player play, with the funnel events wired in.
- **Week 2:** Add DataService, upgrades and a shop stub, and get the first-time experience under 60 seconds.
- **Week 3:** Grow to 10–12 anomalies with procedural variation, complete Select readiness (ID verification, 2FA, maturity questionnaire), and run a closed playtest.
- **Week 4:** Soft launch, read the gates above, and ship the first weekly event.

Want me to turn Phase 4 into a ready-to-run starter repo with the project files, folder skeleton, service stubs and `CLAUDE.md`?