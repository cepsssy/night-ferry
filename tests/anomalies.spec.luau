--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")

local JestGlobals = require(ReplicatedStorage:WaitForChild("Packages").JestGlobals)
local it = JestGlobals.it
local expect = JestGlobals.expect

local AnomalyDefs = require(Shared:WaitForChild("Config"):WaitForChild("AnomalyDefs"))
local Registry = require(Server:WaitForChild("Anomalies"):WaitForChild("Registry"))

local function makeContext(definition)
	local model = Instance.new("Model")
	local anchor = Instance.new("Part")
	anchor.Name = "Anchor"
	anchor.Anchored = true
	anchor.CFrame = CFrame.new(0, 4, 0)
	anchor.Parent = model

	local prompt = Instance.new("ProximityPrompt")
	prompt.Parent = anchor

	local resolved = false
	local context = {
		definition = definition,
		model = model,
		anchor = anchor,
		prompt = prompt,
		state = {},
		resolve = function()
			resolved = true
		end,
		log = function() end,
	}

	return context, model, function()
		return resolved
	end
end

it("registers every definition with the four anomaly hooks", function()
	for _, definition in AnomalyDefs do
		local behavior = Registry[definition.id]
		expect(behavior ~= nil).toBe(true)
		if behavior then
			expect(typeof(behavior.start)).toBe("function")
			expect(typeof(behavior.onInteract)).toBe("function")
			expect(typeof(behavior.resolve)).toBe("function")
			expect(typeof(behavior.cleanup)).toBe("function")
		end
	end
end)

it("starts, resolves, and cleans up every behavior", function()
	for _, definition in AnomalyDefs do
		local behavior = Registry[definition.id]
		if behavior then
			local context, model, wasResolved = makeContext(definition)

			behavior.start(context)
			expect(#model:GetChildren() > 1).toBe(true)

			behavior.onInteract(context, nil)
			expect(wasResolved()).toBe(true)

			behavior.resolve(context)
			behavior.cleanup(context)
			model:Destroy()
		end
	end
end)
