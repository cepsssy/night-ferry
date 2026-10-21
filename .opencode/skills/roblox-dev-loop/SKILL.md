---
name: roblox-dev-loop
description: Use when starting, running, or verifying Night Ferry work in Roblox Studio — syncing with Rojo, running quality gates, or playtesting through Studio MCP.
---

# Night Ferry Dev Loop

## Preconditions

- `rokit install` and `wally install` have run.
- Roblox Studio is open with the Night Ferry place.
- The Rojo Studio plugin is installed (`rojo plugin install`).

## Start

Terminal A:

```powershell
rojo serve
```

Terminal B:

```powershell
rojo sourcemap default.project.json --watch -o sourcemap.json
```

In Studio: Rojo plugin → Connect → `localhost:34872`.

## Edit

- Only edit files under `src/`.
- `.server.luau` = Script, `.client.luau` = LocalScript, `.luau` = ModuleScript.
- Rojo pushes the change into Studio. Do not edit the same script in Studio.
- `Packages/` is generated; never edit it.

## Gates

```powershell
selene src
stylua --check src
rojo sourcemap default.project.json -o sourcemap.json
luau-lsp analyze --sourcemap=sourcemap.json src
rojo build default.project.json -o build/NightFerry.rbxl
```

## Playtest through MCP

1. `list_roblox_studios` — pick the right `studio_id`.
2. `search_game_tree` — confirm `ReplicatedStorage.Shared` and `ServerScriptService.Server`.
3. `start_stop_play` — start.
4. `get_console_output` — expect `[NightFerry] server boot`.
5. `screen_capture` — capture what changed.
6. `start_stop_play` — stop.

## Evidence

Report the console line and what the screenshot shows. A change is not verified until play mode ran.

## Stop

- MCP tries to edit a script under `src/` → stop and edit the file instead.
- Rojo is not connected → `rojo plugin install`, then restart Studio.
- Type errors look wrong → regenerate `sourcemap.json` before trusting them.
