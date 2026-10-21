# Night Ferry — Agent Guide

Co-op shift-sim for 2–4 players: crew a ferry by day, fix anomalies at night.

## Architecture

- Server is authoritative. Client is presentation only.
- `src/shared` holds config, types, and network contracts used by both sides.
- Content as data: anomalies, items, and upgrades are pure tables in `src/shared/Config`.
- Anomaly behavior modules implement `start`, `onInteract`, `resolve`, `cleanup`.
- Seeded RNG runs on the server only. Log the seed so bugs reproduce.

## Layout

| Path | DataModel target |
|---|---|
| `src/shared` | `ReplicatedStorage.Shared` |
| `src/server` | `ServerScriptService.Server` |
| `src/client` | `StarterPlayerScripts.Client` |
| `Packages` | `ReplicatedStorage.Packages` (Wally runtime deps, generated) |
| `DevPackages` | `ReplicatedStorage.Packages` in the test project (Wally dev deps, generated) |
| `tests` | `ServerScriptService.Tests` (test project only) |

File suffixes: `.server.luau` = Script, `.client.luau` = LocalScript, `.luau` = ModuleScript.

`Packages/` is not mapped in `default.project.json` yet because there are no runtime dependencies. Add `{ "$path": "Packages" }` under `ReplicatedStorage` when the first one lands.

## Commands

```powershell
rokit install
wally install
rojo serve
rojo sourcemap default.project.json --watch -o sourcemap.json
selene src
stylua --check src
luau-lsp analyze --sourcemap=sourcemap.json src
rojo build default.project.json -o build/NightFerry.rbxl
```

If a tool is not found, prepend `$env:USERPROFILE\.rokit\bin` to `PATH`.

## Rules

- Never edit `src/**` or `Packages/**` through Studio MCP. MCP is for inspecting, executing, and playtesting.
- Never commit `Packages/`, `sourcemap.json`, `build/`, `*.rbxl`, or `*.rbxlx`.
- Validate every remote argument on the server and rate-limit it.
- Keep DataStore access inside the data service. `ProcessReceipt` must be idempotent.
- Keep content at Moderate or below; the target catalog is Select-friendly.
- A change is done only with test output and a playtest evidence (console or screenshot).

## Testing

```powershell
rojo build test.project.json -o build/NightFerryTests.rbxl
```

Open the built place, press Play, and read the Output window. `tests/spec.server.luau` runs Jest Roblox and prints `[NightFerry] tests passed`.
