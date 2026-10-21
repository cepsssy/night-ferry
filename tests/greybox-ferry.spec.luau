--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")

local JestGlobals = require(ReplicatedStorage:WaitForChild("Packages").JestGlobals)
local it = JestGlobals.it
local expect = JestGlobals.expect

local GreyboxFerry = require(Server:WaitForChild("World"):WaitForChild("GreyboxFerry"))
local ShiftConfig = require(Shared:WaitForChild("Config"):WaitForChild("ShiftConfig"))

it("builds the greybox ferry with the M1 interaction contract", function()
	local container = Instance.new("Folder")
	container.Name = "GreyboxFerryTest"
	container.Parent = workspace

	local ferry = GreyboxFerry.build(container)
	expect(ferry:IsA("Model")).toBe(true)
	expect(ferry.Name).toBe("Ferry")
	expect(ferry:FindFirstChildOfClass("SpawnLocation") ~= nil).toBe(true)

	local anchors = ferry:FindFirstChild("Anchors")
	expect(anchors ~= nil).toBe(true)
	if not anchors then
		container:Destroy()
		return
	end

	local anchorParts = {}
	local tags = {}
	for _, part in anchors:GetChildren() do
		if part:IsA("BasePart") then
			table.insert(anchorParts, part)
			expect(part.Transparency).toBe(1)
			expect(part.CanCollide).toBe(false)
			expect(part.Anchored).toBe(true)
			expect(part.CanQuery).toBe(true)
			local tag = part:GetAttribute("AnchorTag")
			if tag then
				tags[tag] = true
			end
		end
	end

	expect(#anchorParts).toBe(3)
	expect(tags.bench).toBe(true)
	expect(tags.cabin).toBe(true)
	expect(tags.cargo).toBe(true)

	local dayTasks = ferry:FindFirstChild("DayTasks")
	expect(dayTasks ~= nil).toBe(true)
	if dayTasks then
		local promptCount = 0
		for _, descendant in dayTasks:GetDescendants() do
			if descendant:IsA("ProximityPrompt") then
				promptCount += 1
			end
		end
		expect(promptCount).toBe(ShiftConfig.DAY_TASK_COUNT)
	end

	expect(ferry:FindFirstChild("Anomalies") ~= nil).toBe(true)
	expect(ferry:FindFirstChild("Cabin") ~= nil).toBe(true)
	expect(ferry:FindFirstChild("Bench") ~= nil).toBe(true)
	expect(ferry:FindFirstChild("TicketBooth") ~= nil).toBe(true)
	expect(ferry:FindFirstChild("CargoArea") ~= nil).toBe(true)
	expect(ferry:FindFirstChild("Water") ~= nil).toBe(true)

	local lightCount = 0
	for _, descendant in ferry:GetDescendants() do
		if descendant:IsA("PointLight") then
			lightCount += 1
		end
	end
	expect(lightCount).toBe(3)

	container:Destroy()
end)
