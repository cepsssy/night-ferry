--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local JestGlobals = require(Packages.JestGlobals)
local it = JestGlobals.it
local expect = JestGlobals.expect

local SeededRandom = require(Shared:WaitForChild("Util"):WaitForChild("SeededRandom"))

it("NextNumber is deterministic and stays in range", function()
	local first = SeededRandom.new(4242)
	local second = SeededRandom.new(4242)

	for _ = 1, 10 do
		local value = first:NextNumber(-3, 7)
		expect(value).toBe(second:NextNumber(-3, 7))
		expect(value >= -3 and value < 7).toBe(true)
	end
end)
