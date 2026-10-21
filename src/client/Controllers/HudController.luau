--!strict

local Players = game:GetService("Players")

type HudController = {
	_gui: ScreenGui?,
	_phaseLabel: TextLabel?,
	_timerLabel: TextLabel?,
	_objectiveLabel: TextLabel?,
	_statusLabel: TextLabel?,
	_seedLabel: TextLabel?,
	_resultsFrame: Frame?,
	_resultsTitle: TextLabel?,
	_resultsSeed: TextLabel?,
	_connections: { RBXScriptConnection },
	Start: (self: HudController) -> (),
	_refresh: (self: HudController) -> (),
}

local HudController: HudController = {
	_gui = nil,
	_phaseLabel = nil,
	_timerLabel = nil,
	_objectiveLabel = nil,
	_statusLabel = nil,
	_seedLabel = nil,
	_resultsFrame = nil,
	_resultsTitle = nil,
	_resultsSeed = nil,
	_connections = {},
} :: any

local function formatTime(seconds: number): string
	local total = math.max(0, math.floor(seconds + 0.5))
	return string.format("%d:%02d", math.floor(total / 60), total % 60)
end

local function makeLabel(parent: Instance, name: string, size: UDim2, position: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(236, 240, 244)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextWrapped = true
	label.Parent = parent
	return label
end

function HudController:_refresh()
	local phase = tostring(workspace:GetAttribute("ShiftPhase") or "Lobby")
	local remaining = tonumber(workspace:GetAttribute("ShiftTimeRemaining")) or 0
	local objective = tostring(workspace:GetAttribute("ShiftObjective") or "Get ready for the next crossing")
	local seed = tonumber(workspace:GetAttribute("ShiftSeed")) or 0
	local done = tonumber(workspace:GetAttribute("ShiftDayTasksDone")) or 0
	local total = tonumber(workspace:GetAttribute("ShiftDayTasksTotal")) or 0
	local anomalies = tonumber(workspace:GetAttribute("ShiftAnomaliesRemaining")) or 0

	local phaseLabel = self._phaseLabel
	local timerLabel = self._timerLabel
	local objectiveLabel = self._objectiveLabel
	local statusLabel = self._statusLabel
	local seedLabel = self._seedLabel
	local resultsFrame = self._resultsFrame
	local resultsTitle = self._resultsTitle
	local resultsSeed = self._resultsSeed

	if phaseLabel then
		phaseLabel.Text = string.upper(phase)
	end
	if timerLabel then
		timerLabel.Text = formatTime(remaining)
	end
	if objectiveLabel then
		objectiveLabel.Text = objective
	end
	if seedLabel then
		seedLabel.Text = string.format("seed %d", seed)
	end
	if statusLabel then
		if phase == "Day" then
			statusLabel.Text = string.format("tasks %d/%d", done, total)
		elseif phase == "Night" then
			statusLabel.Text = string.format("anomalies %d", anomalies)
		else
			statusLabel.Text = string.format("tasks %d", total)
		end
	end
	if resultsFrame and resultsTitle and resultsSeed then
		resultsFrame.Visible = phase == "Results"
		if phase == "Results" then
			local result = tostring(workspace:GetAttribute("ShiftResult") or "")
			if result == "complete" then
				resultsTitle.Text = "CROSSING COMPLETE"
				resultsTitle.TextColor3 = Color3.fromRGB(120, 220, 150)
			else
				resultsTitle.Text = "CROSSING FAILED"
				resultsTitle.TextColor3 = Color3.fromRGB(235, 120, 120)
			end
			resultsSeed.Text = string.format("seed %d", seed)
		end
	end
end

function HudController:Start()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local gui = Instance.new("ScreenGui")
	gui.Name = "NightFerryHud"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 10
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui
	self._gui = gui

	local top = Instance.new("Frame")
	top.Name = "TopBar"
	top.Size = UDim2.new(0.9, 0, 0, 86)
	top.Position = UDim2.new(0.5, 0, 0, 12)
	top.AnchorPoint = Vector2.new(0.5, 0)
	top.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
	top.BackgroundTransparency = 0.18
	top.BorderSizePixel = 0
	top.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = top

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = top

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(280, 78)
	sizeConstraint.MaxSize = Vector2.new(480, 96)
	sizeConstraint.Parent = top

	local phaseLabel = makeLabel(top, "Phase", UDim2.fromScale(0.5, 0.36), UDim2.fromScale(0, 0))
	phaseLabel.Font = Enum.Font.GothamBold
	phaseLabel.TextSize = 20
	phaseLabel.Text = "LOBBY"
	self._phaseLabel = phaseLabel

	local timerLabel = makeLabel(top, "Timer", UDim2.fromScale(0.5, 0.36), UDim2.fromScale(0.5, 0))
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.TextSize = 22
	timerLabel.TextXAlignment = Enum.TextXAlignment.Right
	timerLabel.Text = "0:08"
	self._timerLabel = timerLabel

	local objectiveLabel = makeLabel(top, "Objective", UDim2.fromScale(0.7, 0.32), UDim2.fromScale(0, 0.5))
	objectiveLabel.TextSize = 13
	objectiveLabel.TextColor3 = Color3.fromRGB(196, 206, 216)
	objectiveLabel.Text = "Get ready for the next crossing"
	self._objectiveLabel = objectiveLabel

	local statusLabel = makeLabel(top, "Status", UDim2.fromScale(0.3, 0.32), UDim2.fromScale(0.7, 0.5))
	statusLabel.TextSize = 12
	statusLabel.TextColor3 = Color3.fromRGB(150, 165, 180)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Right
	statusLabel.Text = "tasks 5"
	self._statusLabel = statusLabel

	local seedLabel = Instance.new("TextLabel")
	seedLabel.Name = "Seed"
	seedLabel.Size = UDim2.new(1, 0, 0, 14)
	seedLabel.Position = UDim2.fromScale(0, 0.84)
	seedLabel.BackgroundTransparency = 1
	seedLabel.Font = Enum.Font.Gotham
	seedLabel.TextSize = 10
	seedLabel.TextColor3 = Color3.fromRGB(120, 135, 150)
	seedLabel.TextXAlignment = Enum.TextXAlignment.Right
	seedLabel.Text = "seed 0"
	seedLabel.Parent = top
	self._seedLabel = seedLabel

	local resultsFrame = Instance.new("Frame")
	resultsFrame.Name = "Results"
	resultsFrame.Size = UDim2.fromScale(0.82, 0.4)
	resultsFrame.Position = UDim2.fromScale(0.5, 0.5)
	resultsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	resultsFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
	resultsFrame.BackgroundTransparency = 0.08
	resultsFrame.BorderSizePixel = 0
	resultsFrame.Visible = false
	resultsFrame.Parent = gui
	self._resultsFrame = resultsFrame

	local resultsCorner = Instance.new("UICorner")
	resultsCorner.CornerRadius = UDim.new(0, 12)
	resultsCorner.Parent = resultsFrame

	local resultsTitle = makeLabel(resultsFrame, "Title", UDim2.fromScale(1, 0.5), UDim2.fromScale(0, 0.16))
	resultsTitle.Font = Enum.Font.GothamBold
	resultsTitle.TextSize = 20
	resultsTitle.TextXAlignment = Enum.TextXAlignment.Center
	resultsTitle.Text = "CROSSING COMPLETE"
	self._resultsTitle = resultsTitle

	local resultsSeed = makeLabel(resultsFrame, "Seed", UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.7))
	resultsSeed.TextSize = 12
	resultsSeed.TextColor3 = Color3.fromRGB(150, 165, 180)
	resultsSeed.TextXAlignment = Enum.TextXAlignment.Center
	resultsSeed.Text = "seed 0"
	self._resultsSeed = resultsSeed

	local function connect(attributeName: string)
		table.insert(
			self._connections,
			workspace:GetAttributeChangedSignal(attributeName):Connect(function()
				self:_refresh()
			end)
		)
	end

	connect("ShiftPhase")
	connect("ShiftTimeRemaining")
	connect("ShiftObjective")
	connect("ShiftResult")
	connect("ShiftSeed")
	connect("ShiftDayTasksDone")
	connect("ShiftDayTasksTotal")
	connect("ShiftAnomaliesRemaining")

	self:_refresh()
end

return HudController
