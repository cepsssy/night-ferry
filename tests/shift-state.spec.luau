--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local JestGlobals = require(ReplicatedStorage:WaitForChild("Packages").JestGlobals)
local it = JestGlobals.it
local expect = JestGlobals.expect

local ShiftState = require(Shared:WaitForChild("ShiftState"))

local CONFIG = {
	LOBBY_DURATION_SECONDS = 2,
	DAY_DURATION_SECONDS = 4,
	NIGHT_DURATION_SECONDS = 3,
	RESULTS_DURATION_SECONDS = 1,
	MAX_PARTY_SIZE = 4,
	DAY_TASK_COUNT = 5,
	ANOMALIES_PER_NIGHT = 3,
	INTERACTION_MAX_DISTANCE = 10,
	INTERACTION_COOLDOWN_SECONDS = 0.5,
}

it("starts in the lobby with the lobby duration", function()
	local state = ShiftState.new(CONFIG)

	expect(state.phase).toBe("Lobby")
	expect(state.timeRemaining).toBe(CONFIG.LOBBY_DURATION_SECONDS)
	expect(state.shiftNumber).toBe(1)
	expect(state.lastSuccess).toBe(false)
end)

it("moves from lobby to day when the timer expires", function()
	local state = ShiftState.new(CONFIG)
	local transition = ShiftState.update(state, CONFIG.LOBBY_DURATION_SECONDS, CONFIG)

	expect(transition.changed).toBe(true)
	expect(transition.previous).toBe("Lobby")
	expect(transition.current).toBe("Day")
	expect(state.phase).toBe("Day")
	expect(state.timeRemaining).toBe(CONFIG.DAY_DURATION_SECONDS)
end)

it("does not change phase while time remains", function()
	local state = ShiftState.new(CONFIG)
	local transition = ShiftState.update(state, 1.5, CONFIG)

	expect(transition.changed).toBe(false)
	expect(transition.current).toBe("Lobby")
	expect(state.phase).toBe("Lobby")
	expect(state.timeRemaining).toBe(0.5)
end)

it("advances at most one phase for a huge delta", function()
	local state = ShiftState.new(CONFIG)
	local transition = ShiftState.update(state, 100, CONFIG)

	expect(transition.changed).toBe(true)
	expect(transition.current).toBe("Day")
	expect(state.phase).toBe("Day")
	expect(state.timeRemaining).toBe(CONFIG.DAY_DURATION_SECONDS)
end)

it("records night success in results", function()
	local state = ShiftState.new(CONFIG)

	ShiftState.advance(state, CONFIG)
	ShiftState.advance(state, CONFIG)
	expect(state.phase).toBe("Night")

	local transition = ShiftState.advance(state, CONFIG, true)
	expect(transition.current).toBe("Results")
	expect(state.phase).toBe("Results")
	expect(state.lastSuccess).toBe(true)
end)

it("records night failure in results", function()
	local state = ShiftState.new(CONFIG)

	ShiftState.advance(state, CONFIG)
	ShiftState.advance(state, CONFIG)
	ShiftState.advance(state, CONFIG, false)

	expect(state.phase).toBe("Results")
	expect(state.lastSuccess).toBe(false)
end)

it("increments the shift number when results return to lobby", function()
	local state = ShiftState.new(CONFIG)

	ShiftState.advance(state, CONFIG)
	ShiftState.advance(state, CONFIG)
	ShiftState.advance(state, CONFIG, true)
	ShiftState.advance(state, CONFIG)

	expect(state.phase).toBe("Lobby")
	expect(state.shiftNumber).toBe(2)
	expect(state.timeRemaining).toBe(CONFIG.LOBBY_DURATION_SECONDS)
end)

it("resets last success when the next day starts", function()
	local state = ShiftState.new(CONFIG)

	ShiftState.advance(state, CONFIG)
	ShiftState.advance(state, CONFIG)
	ShiftState.advance(state, CONFIG, true)
	expect(state.lastSuccess).toBe(true)

	ShiftState.advance(state, CONFIG)
	expect(state.lastSuccess).toBe(true)

	ShiftState.advance(state, CONFIG)
	expect(state.phase).toBe("Day")
	expect(state.lastSuccess).toBe(false)
end)
