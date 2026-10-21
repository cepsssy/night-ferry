--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local JestGlobals = require(Packages.JestGlobals)
local it = JestGlobals.it
local expect = JestGlobals.expect

local SeededRandom = require(Shared:WaitForChild("Util"):WaitForChild("SeededRandom"))
local ShiftConfig = require(Shared:WaitForChild("Config"):WaitForChild("ShiftConfig"))

it("adds 1 + 1", function()
	expect(1 + 1).toBe(2)
end)

it("loads the shared shift config", function()
	expect(ShiftConfig.MAX_PARTY_SIZE).toBe(4)
end)

it("repeats the same seeded sequence", function()
	local first = SeededRandom.new(1234)
	local second = SeededRandom.new(1234)

	for _ = 1, 5 do
		expect(first:NextInteger(1, 1000)).toBe(second:NextInteger(1, 1000))
	end
end)
