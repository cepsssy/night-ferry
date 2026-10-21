--!strict

local SeededRandom = {}
SeededRandom.__index = SeededRandom

export type SeededRandom = typeof(setmetatable({} :: { _random: Random }, SeededRandom))

function SeededRandom.new(seed: number): SeededRandom
	return setmetatable({ _random = Random.new(seed) }, SeededRandom) :: SeededRandom
end

function SeededRandom.NextInteger(self: SeededRandom, min: number, max: number): number
	return self._random:NextInteger(min, max)
end

function SeededRandom.NextNumber(self: SeededRandom, min: number, max: number): number
	return self._random:NextNumber(min, max)
end

return SeededRandom
