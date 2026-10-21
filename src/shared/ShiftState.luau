--!strict

local Types = require(script.Parent.Types)

local ShiftState = {}

local function durationFor(phase: Types.ShiftPhase, config: Types.ShiftConfig): number
	if phase == "Lobby" then
		return config.LOBBY_DURATION_SECONDS
	elseif phase == "Day" then
		return config.DAY_DURATION_SECONDS
	elseif phase == "Night" then
		return config.NIGHT_DURATION_SECONDS
	end
	return config.RESULTS_DURATION_SECONDS
end

local function transition(previous: Types.ShiftPhase, current: Types.ShiftPhase): Types.ShiftTransition
	return {
		changed = previous ~= current,
		previous = previous,
		current = current,
	}
end

function ShiftState.new(config: Types.ShiftConfig): Types.ShiftState
	return {
		phase = "Lobby",
		timeRemaining = config.LOBBY_DURATION_SECONDS,
		shiftNumber = 1,
		lastSuccess = false,
	}
end

function ShiftState.advance(
	state: Types.ShiftState,
	config: Types.ShiftConfig,
	success: boolean?
): Types.ShiftTransition
	local previous: Types.ShiftPhase = state.phase

	if previous == "Lobby" then
		state.phase = "Day"
		state.lastSuccess = false
	elseif previous == "Day" then
		state.phase = "Night"
	elseif previous == "Night" then
		state.phase = "Results"
		state.lastSuccess = success == true
	else
		state.phase = "Lobby"
		state.shiftNumber += 1
	end

	state.timeRemaining = durationFor(state.phase, config)
	return transition(previous, state.phase)
end

function ShiftState.update(state: Types.ShiftState, dt: number, config: Types.ShiftConfig): Types.ShiftTransition
	local previous: Types.ShiftPhase = state.phase

	if dt <= 0 then
		return transition(previous, previous)
	end

	if dt >= state.timeRemaining then
		return ShiftState.advance(state, config)
	end

	state.timeRemaining = math.max(0, state.timeRemaining - dt)
	return transition(previous, previous)
end

return ShiftState
