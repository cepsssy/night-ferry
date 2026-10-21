--!strict

local Types = require(script.Parent.Parent.Types)

local ShiftConfig: Types.ShiftConfig = {
	LOBBY_DURATION_SECONDS = 8,
	DAY_DURATION_SECONDS = 120,
	NIGHT_DURATION_SECONDS = 90,
	RESULTS_DURATION_SECONDS = 12,
	MAX_PARTY_SIZE = 4,
	DAY_TASK_COUNT = 5,
	ANOMALIES_PER_NIGHT = 3,
	INTERACTION_MAX_DISTANCE = 10,
	INTERACTION_COOLDOWN_SECONDS = 0.5,
}

return table.freeze(ShiftConfig)
