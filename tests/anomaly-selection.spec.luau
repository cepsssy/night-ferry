--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local JestGlobals = require(ReplicatedStorage:WaitForChild("Packages").JestGlobals)
local it = JestGlobals.it
local expect = JestGlobals.expect

local AnomalyDefs = require(Shared:WaitForChild("Config"):WaitForChild("AnomalyDefs"))
local AnomalySelection = require(Shared:WaitForChild("AnomalySelection"))

local function stream(values: { number }): (number, number) -> number
	local index = 0
	return function(_min: number, _max: number): number
		index += 1
		return values[index]
	end
end

it("defines exactly three unique M1 anomalies", function()
	local seen = {}
	expect(#AnomalyDefs).toBe(3)

	for _, definition in AnomalyDefs do
		expect(definition.weight > 0).toBe(true)
		expect(seen[definition.id]).toBe(nil)
		seen[definition.id] = true
	end

	expect(seen.wrong_passenger).toBe(true)
	expect(seen.impossible_cabin).toBe(true)
	expect(seen.restless_cargo).toBe(true)
end)

it("picks each definition once for a full count", function()
	local picked = AnomalySelection.pick(stream({ 0, 0, 0 }), AnomalyDefs, 3)

	expect(#picked).toBe(3)
	expect(picked[1]).toBe("wrong_passenger")
	expect(picked[2]).toBe("impossible_cabin")
	expect(picked[3]).toBe("restless_cargo")
end)

it("caps the pick count at the available pool", function()
	local picked = AnomalySelection.pick(stream({ 0, 0, 0, 0, 0 }), AnomalyDefs, 10)

	expect(#picked).toBe(3)
end)

it("excludes zero-weight definitions", function()
	local definitions = {
		{ id = "zero", weight = 0 },
		{ id = "one", weight = 1 },
	}
	local picked = AnomalySelection.pick(stream({ 0, 0 }), definitions, 2)

	expect(#picked).toBe(1)
	expect(picked[1]).toBe("one")
end)

it("picks the last entry when the roll is just below the total", function()
	local definitions = {
		{ id = "a", weight = 1 },
		{ id = "b", weight = 1 },
		{ id = "c", weight = 1 },
	}
	local picked = AnomalySelection.pick(stream({ 0, 2 - 1e-9 }), definitions, 2)

	expect(picked[1]).toBe("a")
	expect(picked[2]).toBe("c")
end)

it("returns an empty list for an empty pool", function()
	local picked = AnomalySelection.pick(stream({ 0 }), {}, 3)

	expect(#picked).toBe(0)
end)
