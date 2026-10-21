--!strict

export type WeightedDefinition = {
	id: string,
	weight: number,
	[string]: any,
}

local AnomalySelection = {}

function AnomalySelection.pick(
	nextNumber: (min: number, max: number) -> number,
	definitions: { WeightedDefinition },
	count: number
): { string }
	local pool: { WeightedDefinition } = {}
	for _, definition in definitions do
		if definition.weight > 0 then
			table.insert(pool, definition)
		end
	end

	local picked = {}
	local pickCount = math.max(0, math.min(math.floor(count), #pool))

	for _ = 1, pickCount do
		local total = 0
		for _, definition in pool do
			total += definition.weight
		end

		local roll = nextNumber(0, total)
		local cumulative = 0
		local index = #pool

		for candidateIndex, definition in pool do
			cumulative += definition.weight
			if roll < cumulative then
				index = candidateIndex
				break
			end
		end

		local chosen = table.remove(pool, index)
		if chosen then
			table.insert(picked, chosen.id)
		end
	end

	return picked
end

return AnomalySelection
