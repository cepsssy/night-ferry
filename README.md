# night-ferry

Co-op shift-sim: 2–4 players crew a ferry by day and fix anomalies at night.

## Quickstart

```powershell
# 1. Toolchain (once)
winget install --id Rojo.Rokit -e
rokit install

# 2. Packages
wally install

# 3. Studio link
rojo plugin install
rojo serve
```

In Roblox Studio, open the place and connect the Rojo plugin to `localhost:34872`.

Keep a second terminal running:

```powershell
rojo sourcemap default.project.json --watch -o sourcemap.json
```

## Checks

```powershell
.\scripts\check.ps1
```

## Tests

```powershell
rojo build test.project.json -o build/NightFerryTests.rbxl
```

Open the built place, press Play, and check Output for `[NightFerry] tests passed`.

## Studio MCP

1. In Studio: Assistant → ⋯ → Manage MCP Servers → Enable Studio as MCP server.
2. Restart OpenCode.
3. `opencode mcp list` should show `roblox_studio` connected.

Agent rules live in `AGENTS.md`.
