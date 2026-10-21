--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local JestGlobals = require(ReplicatedStorage:WaitForChild("Packages").JestGlobals)
local it = JestGlobals.it
local expect = JestGlobals.expect

local InteractionRules = require(Shared:WaitForChild("Util"):WaitForChild("InteractionRules"))

it("accepts a target exactly at max distance", function()
	expect(InteractionRules.isInRange(Vector3.new(0, 0, 0), Vector3.new(10, 0, 0), 10)).toBe(true)
end)

it("rejects a target just beyond max distance", function()
	expect(InteractionRules.isInRange(Vector3.new(0, 0, 0), Vector3.new(10.0001, 0, 0), 10)).toBe(false)
end)

it("accepts the same position", function()
	expect(InteractionRules.isInRange(Vector3.new(4, 2, 7), Vector3.new(4, 2, 7), 0)).toBe(true)
end)

it("allows a first interaction", function()
	expect(InteractionRules.cooldownReady(nil, 100, 0.5)).toBe(true)
end)

it("accepts the exact cooldown boundary", function()
	expect(InteractionRules.cooldownReady(1, 2, 1)).toBe(true)
end)

it("rejects an interaction inside the cooldown", function()
	expect(InteractionRules.cooldownReady(1, 1.49, 0.5)).toBe(false)
end)

it("allows every interaction when cooldown is zero", function()
	expect(InteractionRules.cooldownReady(1, 1, 0)).toBe(true)
end)
