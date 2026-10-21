--!strict

local JestGlobals = require(game:GetService("ReplicatedStorage").Packages.JestGlobals)
local it = JestGlobals.it
local expect = JestGlobals.expect

it("adds 1 + 1", function()
	expect(1 + 1).toBe(2)
end)
