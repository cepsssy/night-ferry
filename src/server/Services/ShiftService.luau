--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types"))
local ShiftConfig = require(Shared:WaitForChild("Config"):WaitForChild("ShiftConfig"))
local ShiftState = require(Shared:WaitForChild("ShiftState"))
local InteractionRules = require(Shared:WaitForChild("Util"):WaitForChild("InteractionRules"))

type ShiftService = {
	_state: Types.ShiftState,
	_config: Types.ShiftConfig,
	_analyticsService: any?,
	_worldService: any?,
	_anomalyService: any?,
	_dayPrompts: { ProximityPrompt },
	_dayPromptConnections: { RBXScriptConnection },
	_connections: { RBXScriptConnection },
	_promptColors: { [ProximityPrompt]: Color3 },
	_cooldowns: { [Player]: number },
	_dayDone: number,
	_dayTotal: number,
	_nightActive: boolean,
	_running: boolean,
	_shiftSeed: number,
	_lastSecond: number?,
	_lastRemaining: number?,
	Init: (self: ShiftService, services: { [string]: any }) -> (),
	Start: (self: ShiftService) -> (),
}

local ShiftService: ShiftService = {
	_state = ShiftState.new(ShiftConfig),
	_config = ShiftConfig,
	_analyticsService = nil,
	_worldService = nil,
	_anomalyService = nil,
	_dayPrompts = {},
	_dayPromptConnections = {},
	_connections = {},
	_promptColors = {},
	_cooldowns = {},
	_dayDone = 0,
	_dayTotal = 0,
	_nightActive = false,
	_running = false,
	_shiftSeed = 0,
	_lastSecond = nil,
	_lastRemaining = nil,
} :: any

local function nextSeed(): number
	local seed = DateTime.now().UnixTimestampMillis % 2147483647
	if seed == 0 then
		return 1
	end
	return seed
end

local function objectiveFor(phase: Types.ShiftPhase, success: boolean): string
	if phase == "Lobby" then
		return "Get ready for the next crossing"
	elseif phase == "Day" then
		return "Check tickets and secure cargo"
	elseif phase == "Night" then
		return "Find and fix the anomalies"
	end
	return success and "Crossing complete" or "Crossing failed"
end

local function publish(self: ShiftService, phase: Types.ShiftPhase)
	local success = self._state.lastSuccess
	local remaining = 0
	if self._anomalyService then
		remaining = self._anomalyService:GetRemainingCount()
	end

	local result = ""
	if phase == "Results" then
		result = success and "complete" or "failed"
	end

	workspace:SetAttribute("ShiftPhase", phase)
	workspace:SetAttribute("ShiftNumber", self._state.shiftNumber)
	workspace:SetAttribute("ShiftSeed", self._shiftSeed)
	workspace:SetAttribute("ShiftDayTasksDone", self._dayDone)
	workspace:SetAttribute("ShiftDayTasksTotal", self._dayTotal)
	workspace:SetAttribute("ShiftAnomaliesRemaining", remaining)
	workspace:SetAttribute("ShiftTimeRemaining", self._state.timeRemaining)
	workspace:SetAttribute("ShiftObjective", objectiveFor(phase, success))
	workspace:SetAttribute("ShiftResult", result)

	self._lastSecond = math.ceil(self._state.timeRemaining)
	self._lastRemaining = remaining
end

local function setDayPromptsEnabled(self: ShiftService, enabled: boolean)
	for _, prompt in self._dayPrompts do
		prompt.Enabled = enabled
	end
end

local function resetDayPrompts(self: ShiftService)
	for _, prompt in self._dayPrompts do
		prompt.Enabled = false
		prompt:SetAttribute("Completed", false)
		local parent = prompt.Parent
		local original = self._promptColors[prompt]
		if original and parent and parent:IsA("BasePart") then
			parent.Color = original
		end
	end
end

local enterPhase: (self: ShiftService, phase: Types.ShiftPhase) -> ()
enterPhase = function(self: ShiftService, phase: Types.ShiftPhase)
	if phase == "Lobby" then
		setDayPromptsEnabled(self, false)
		resetDayPrompts(self)
		self._dayDone = 0
		self._nightActive = false
		self._shiftSeed = 0
		if self._anomalyService then
			self._anomalyService:EndNight()
		end
		print(string.format("[NightFerry] phase=Lobby shift=%d", self._state.shiftNumber))
	elseif phase == "Day" then
		self._dayDone = 0
		resetDayPrompts(self)
		setDayPromptsEnabled(self, true)
		self._nightActive = false
		self._shiftSeed = nextSeed()
		print(string.format("[NightFerry] phase=Day shift=%d seed=%d", self._state.shiftNumber, self._shiftSeed))
	elseif phase == "Night" then
		setDayPromptsEnabled(self, false)
		self._nightActive = false

		local spawned = 0
		if self._anomalyService then
			spawned = self._anomalyService:BeginNight(self._shiftSeed, self._config.ANOMALIES_PER_NIGHT)
		end
		self._nightActive = spawned > 0

		if not self._nightActive then
			warn("[NightFerry] night spawned no anomalies; skipping to results")
			ShiftState.advance(self._state, self._config)
			enterPhase(self, "Results")
			return
		end

		print(string.format("[NightFerry] phase=Night shift=%d seed=%d", self._state.shiftNumber, self._shiftSeed))
	else
		setDayPromptsEnabled(self, false)
		self._nightActive = false
		if self._anomalyService then
			self._anomalyService:EndNight()
		end

		if self._state.lastSuccess and self._analyticsService then
			for _, player in Players:GetPlayers() do
				self._analyticsService:LogShiftComplete(player)
			end
		end

		print(
			string.format(
				"[NightFerry] phase=Results shift=%d success=%s seed=%d",
				self._state.shiftNumber,
				tostring(self._state.lastSuccess),
				self._shiftSeed
			)
		)
	end

	publish(self, phase)
end

local function onDayPrompt(self: ShiftService, prompt: ProximityPrompt, player: Player)
	if self._state.phase ~= "Day" then
		return
	end
	if prompt:GetAttribute("Completed") then
		return
	end

	local parent = prompt.Parent
	if not parent or not parent:IsA("BasePart") then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return
	end

	local now = os.clock()
	if not InteractionRules.cooldownReady(self._cooldowns[player], now, self._config.INTERACTION_COOLDOWN_SECONDS) then
		return
	end
	if not InteractionRules.isInRange(root.Position, parent.Position, self._config.INTERACTION_MAX_DISTANCE) then
		return
	end

	self._cooldowns[player] = now
	prompt:SetAttribute("Completed", true)
	prompt.Enabled = false
	parent.Color = Color3.fromRGB(80, 170, 110)
	self._dayDone += 1
	workspace:SetAttribute("ShiftDayTasksDone", self._dayDone)

	if self._analyticsService then
		self._analyticsService:LogFirstInteraction(player)
	end

	print(string.format("[NightFerry] day task done player=%s done=%d/%d", player.Name, self._dayDone, self._dayTotal))

	if self._dayTotal > 0 and self._dayDone >= self._dayTotal then
		ShiftState.advance(self._state, self._config)
		enterPhase(self, "Night")
	end
end

local function update(self: ShiftService, dt: number)
	if #Players:GetPlayers() == 0 then
		return
	end

	local transition = ShiftState.update(self._state, dt, self._config)
	if transition.changed then
		enterPhase(self, self._state.phase)
		return
	end

	local phase = self._state.phase

	if phase == "Day" and self._dayTotal > 0 and self._dayDone >= self._dayTotal then
		ShiftState.advance(self._state, self._config)
		enterPhase(self, "Night")
		return
	end

	if phase == "Night" and self._nightActive and self._anomalyService then
		if self._anomalyService:GetRemainingCount() == 0 then
			ShiftState.advance(self._state, self._config, true)
			enterPhase(self, "Results")
			return
		end
	end

	local second = math.ceil(self._state.timeRemaining)
	if second ~= self._lastSecond then
		self._lastSecond = second
		workspace:SetAttribute("ShiftTimeRemaining", self._state.timeRemaining)
	end

	if phase == "Night" and self._anomalyService then
		local remaining = self._anomalyService:GetRemainingCount()
		if remaining ~= self._lastRemaining then
			self._lastRemaining = remaining
			workspace:SetAttribute("ShiftAnomaliesRemaining", remaining)
		end
	end
end

function ShiftService:Init(services: { [string]: any })
	self._analyticsService = services.AnalyticsService
	self._worldService = services.WorldService
	self._anomalyService = services.AnomalyService
end

function ShiftService:Start()
	local worldService = self._worldService
	if not worldService then
		warn("[NightFerry] shift service has no world service")
		return
	end

	self._dayPrompts = worldService:GetDayPrompts()
	self._dayTotal = #self._dayPrompts
	self._dayDone = 0

	for _, prompt in self._dayPrompts do
		local parent = prompt.Parent
		if parent and parent:IsA("BasePart") then
			self._promptColors[prompt] = parent.Color
		end

		local connection = prompt.Triggered:Connect(function(player)
			onDayPrompt(self, prompt, player)
		end)
		table.insert(self._dayPromptConnections, connection)
	end

	table.insert(
		self._connections,
		Players.PlayerAdded:Connect(function(player)
			if self._analyticsService then
				self._analyticsService:LogStep(player, "joined", 1)
			end
		end)
	)
	table.insert(
		self._connections,
		Players.PlayerRemoving:Connect(function(player)
			self._cooldowns[player] = nil
		end)
	)

	for _, player in Players:GetPlayers() do
		if self._analyticsService then
			self._analyticsService:LogStep(player, "joined", 1)
		end
	end

	self._running = true
	enterPhase(self, "Lobby")

	task.spawn(function()
		local last = os.clock()
		while self._running do
			task.wait(0.25)
			local now = os.clock()
			update(self, now - last)
			last = now
		end
	end)
end

return ShiftService
