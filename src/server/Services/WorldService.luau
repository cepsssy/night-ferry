--!strict

local GreyboxFerry = require(script.Parent.Parent.World.GreyboxFerry)

export type WorldService = {
	_ferry: Model?,
	Init: (self: WorldService, services: { [string]: any }) -> (),
	Start: (self: WorldService) -> (),
	GetAnomalyAnchors: (self: WorldService) -> { BasePart },
	GetDayPrompts: (self: WorldService) -> { ProximityPrompt },
	GetAnomalyContainer: (self: WorldService) -> Folder?,
}

local WorldService: WorldService = {
	_ferry = nil,
} :: any

function WorldService:Init(_services: { [string]: any }) end

function WorldService:Start()
	local existing = workspace:FindFirstChild("Ferry")
	if existing then
		existing:Destroy()
	end

	self._ferry = GreyboxFerry.build(workspace)

	local anchors = self:GetAnomalyAnchors()
	local prompts = self:GetDayPrompts()
	print(string.format("[NightFerry] world ready anchors=%d dayTasks=%d", #anchors, #prompts))
end

function WorldService:GetAnomalyAnchors(): { BasePart }
	local anchors = {}
	if not self._ferry then
		return anchors
	end

	local folder = self._ferry:FindFirstChild("Anchors")
	if not folder then
		return anchors
	end

	for _, child in folder:GetChildren() do
		if child:IsA("BasePart") then
			table.insert(anchors, child)
		end
	end

	return anchors
end

function WorldService:GetDayPrompts(): { ProximityPrompt }
	local prompts = {}
	if not self._ferry then
		return prompts
	end

	local folder = self._ferry:FindFirstChild("DayTasks")
	if not folder then
		return prompts
	end

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ProximityPrompt") then
			table.insert(prompts, descendant)
		end
	end

	return prompts
end

function WorldService:GetAnomalyContainer(): Folder?
	if not self._ferry then
		return nil
	end

	local folder = self._ferry:FindFirstChild("Anomalies")
	if folder and folder:IsA("Folder") then
		return folder
	end

	return nil
end

return WorldService
