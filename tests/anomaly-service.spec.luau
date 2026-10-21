--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")

local JestGlobals = require(ReplicatedStorage:WaitForChild("Packages").JestGlobals)
local it = JestGlobals.it
local expect = JestGlobals.expect

local AnomalyDefs = require(Shared:WaitForChild("Config"):WaitForChild("AnomalyDefs"))
local AnomalyService = require(Server:WaitForChild("Services"):WaitForChild("AnomalyService"))

local function setup()
	local anchorsFolder = Instance.new("Folder")
	anchorsFolder.Name = "TestAnchors"
	anchorsFolder.Parent = workspace

	local container = Instance.new("Folder")
	container.Name = "TestAnomalies"
	container.Parent = workspace

	local anchors = {}
	for _, definition in AnomalyDefs do
		local anchor = Instance.new("Part")
		anchor.Name = definition.anchorTag
		anchor.Anchored = true
		anchor.CFrame = CFrame.new(0, 4, 0)
		anchor:SetAttribute("AnchorTag", definition.anchorTag)
		anchor.Parent = anchorsFolder
		table.insert(anchors, anchor)
	end

	local fakeWorld = {}
	function fakeWorld:GetAnomalyContainer()
		return container
	end
	function fakeWorld:GetAnomalyAnchors()
		return anchors
	end

	AnomalyService:Init({ WorldService = fakeWorld })
	AnomalyService:Start()

	return anchorsFolder, container, anchors
end

it("spawns the requested anomalies and cleans them up", function()
	local anchorsFolder, container, anchors = setup()
	AnomalyService:EndNight()

	local spawned = AnomalyService:BeginNight(1234, 3)
	expect(spawned).toBe(3)
	expect(AnomalyService:GetRemainingCount()).toBe(3)
	expect(#container:GetChildren()).toBe(3)

	local ids = AnomalyService:GetActiveIds()
	expect(#ids).toBe(3)
	local unique = {}
	for _, id in ids do
		unique[id] = true
	end
	local uniqueCount = 0
	for _ in unique do
		uniqueCount += 1
	end
	expect(uniqueCount).toBe(3)

	for _, anchor in anchors do
		local promptCount = 0
		for _, child in anchor:GetChildren() do
			if child:IsA("ProximityPrompt") then
				promptCount += 1
			end
		end
		expect(promptCount).toBe(1)
	end

	AnomalyService:EndNight()
	expect(AnomalyService:GetRemainingCount()).toBe(0)
	expect(#container:GetChildren()).toBe(0)

	for _, anchor in anchors do
		for _, child in anchor:GetChildren() do
			expect(child:IsA("ProximityPrompt")).toBe(false)
		end
	end

	anchorsFolder:Destroy()
	container:Destroy()
end)

it("is deterministic for a seed and caps at the anchor count", function()
	local anchorsFolder, container = setup()
	AnomalyService:EndNight()

	expect(AnomalyService:BeginNight(4321, 3)).toBe(3)
	local firstIds = AnomalyService:GetActiveIds()
	AnomalyService:EndNight()

	expect(AnomalyService:BeginNight(4321, 3)).toBe(3)
	local secondIds = AnomalyService:GetActiveIds()
	expect(#firstIds).toBe(#secondIds)
	for index = 1, #firstIds do
		expect(firstIds[index]).toBe(secondIds[index])
	end
	AnomalyService:EndNight()

	expect(AnomalyService:BeginNight(99, 10)).toBe(3)
	AnomalyService:EndNight()

	anchorsFolder:Destroy()
	container:Destroy()
end)
