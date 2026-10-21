---
name: roblox-anomaly-authoring
description: Use when adding or changing a Night Ferry anomaly — defining its data, server behavior, weighted spawn, test, and playtest.
---

# Anomaly Authoring

An anomaly is data + a server behavior module + a test.

## Contract

- Definition: `src/shared/Config/AnomalyDefs.luau`, entry `{ id, weight, ... }`.
- Behavior: `src/server/Anomalies/<Name>.luau` with:
  - `start(ctx)`
  - `onInteract(ctx, player)`
  - `resolve(ctx)`
  - `cleanup(ctx)`
- The server spawns from a seeded weighted table. Log the seed.
- The client never decides whether an anomaly is resolved.

## Steps

1. Add the definition as pure data (no functions).
2. Add the behavior module. Validate range, line of sight, cooldown, and tool on the server.
3. Register it in the anomaly registry.
4. Add `tests/<name>.spec.luau` for the pure selection or resolution logic.
5. Run the gates from `roblox-dev-loop`.
6. Playtest: trigger the anomaly, resolve it, confirm cleanup; capture console and screenshot.

## Rules

- No anomaly logic in client scripts.
- No `math.random`; use the seeded RNG.
- Every interaction is validated on the server.
- If the anomaly needs a new replicated effect, add a typed contract in `src/shared/Net`.
