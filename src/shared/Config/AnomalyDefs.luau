--!strict

local Types = require(script.Parent.Parent.Types)

local definitions: { Types.AnomalyDefinition } = {
	{
		id = "wrong_passenger",
		displayName = "The Wrong Passenger",
		weight = 1,
		maxDistance = 10,
		promptText = "Turn the passenger around",
		anchorTag = "bench",
	},
	{
		id = "impossible_cabin",
		displayName = "The Impossible Cabin",
		weight = 1,
		maxDistance = 10,
		promptText = "Close the impossible door",
		anchorTag = "cabin",
	},
	{
		id = "restless_cargo",
		displayName = "The Restless Cargo",
		weight = 1,
		maxDistance = 10,
		promptText = "Settle the cargo",
		anchorTag = "cargo",
	},
}

for _, definition in definitions do
	table.freeze(definition)
end

return table.freeze(definitions)
