--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types"))
local AnomalyDefs = require(Shared:WaitForChild("Config"):WaitForChild("AnomalyDefs"))
local ShiftConfig = require(Shared:WaitForChild("Config"):WaitForChild("ShiftConfig"))
local AnomalySelection = require(Shared:WaitForChild("AnomalySelection"))
local SeededRandom = require(Shared:WaitForChild("Util"):WaitForChild("SeededRandom"))
local InteractionRules = require(Shared:WaitForChild("Util"):WaitForChild("InteractionRules"))

local Registry = require(script.Parent.Parent.Anomalies.Registry)

type ActiveAnomaly = {
	id: string,
	definition: Types.AnomalyDefinition,
	model: Model,
	anchor: BasePart,
	prompt: ProximityPrompt,
	behavior: Types.AnomalyBehavior,
	ctx: Types.AnomalyContext?,
	connection: RBXScriptConnection?,
	active: boolean,
}

type AnomalyService = {
	_active: { ActiveAnomaly },
	_cooldowns: { [Player]: number },
	_worldService: any?,
	_analyticsService: any?,
	_playerRemovingConnection: RBXScriptConnection?,
	Init: (self: AnomalyService, services: { [string]: any }) -> (),
	Start: (self: AnomalyService) -> (),
	BeginNight: (self: AnomalyService, seed: number, count: number) -> number,
	EndNight: (self: AnomalyService) -> (),
	GetRemainingCount: (self: AnomalyService) -> number,
	GetActiveIds: (self: AnomalyService) -> { string },
	_onPrompt: (self: AnomalyService, active: ActiveAnomaly, player: Player) -> (),
}

local AnomalyService: AnomalyService = {
	_active = {},
	_cooldowns = {},
	_worldService = nil,
	_analyticsService = nil,
	_playerRemovingConnection = nil,
} :: any

local function destroyActive(active: ActiveAnomaly, callResolve: boolean)
	if not active.active then
		return
	end
	active.active = false

	if active.connection then
		active.connection:Disconnect()
		active.connection = nil
	end

	local ctx = active.ctx
	if ctx then
		if callResolve then
			local ok = pcall(active.behavior.resolve, ctx)
			if not ok then
				warn(string.format("[NightFerry] anomaly resolve failed id=%s", active.id))
			end
		end

		local ok = pcall(active.behavior.cleanup, ctx)
		if not ok then
			warn(string.format("[NightFerry] anomaly cleanup failed id=%s", active.id))
		end
	end

	active.prompt:Destroy()
	active.model:Destroy()
end

local function removeActive(self: AnomalyService, active: ActiveAnomaly)
	for index = #self._active, 1, -1 do
		if self._active[index] == active then
			table.remove(self._active, index)
			break
		end
	end
end

function AnomalyService:Init(services: { [string]: any })
	self._worldService = services.WorldService
	self._analyticsService = services.AnalyticsService
end

function AnomalyService:Start()
	self._playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		self._cooldowns[player] = nil
	end)
end

function AnomalyService:BeginNight(seed: number, count: number): number
	self:EndNight()

	local worldService = self._worldService
	if not worldService then
		warn("[NightFerry] anomaly service has no world service")
		return 0
	end

	local container = worldService:GetAnomalyContainer()
	local anchors = worldService:GetAnomalyAnchors()
	if not container or #anchors == 0 then
		warn("[NightFerry] no anomaly anchors available")
		return 0
	end

	local anchorsByTag: { [string]: BasePart } = {}
	for _, anchor in anchors do
		local tag = anchor:GetAttribute("AnchorTag")
		if typeof(tag) == "string" then
			anchorsByTag[tag] = anchor
		end
	end

	local definitionsById: { [string]: Types.AnomalyDefinition } = {}
	local candidates: { Types.AnomalyDefinition } = {}
	for _, definition in AnomalyDefs do
		definitionsById[definition.id] = definition
		if anchorsByTag[definition.anchorTag] then
			table.insert(candidates, definition)
		end
	end

	local rng = SeededRandom.new(seed)
	local chosenIds = AnomalySelection.pick(function(min, max)
		return rng:NextNumber(min, max)
	end, candidates, math.max(0, count))

	local spawned = {}
	for _, id in chosenIds do
		local definition = definitionsById[id]
		if not definition then
			continue
		end

		local anchor = anchorsByTag[definition.anchorTag]
		local behavior = Registry[id]

		if not anchor or not behavior then
			warn("[NightFerry] no behavior or anchor for anomaly " .. id)
			continue
		end

		local model = Instance.new("Model")
		model.Name = id
		model.Parent = container

		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = id .. "Prompt"
		prompt.ActionText = definition.promptText
		prompt.ObjectText = definition.displayName
		prompt.HoldDuration = 0.5
		prompt.MaxActivationDistance = definition.maxDistance
		prompt.RequiresLineOfSight = false
		prompt.Parent = anchor

		local active: ActiveAnomaly = {
			id = id,
			definition = definition,
			model = model,
			anchor = anchor,
			prompt = prompt,
			behavior = behavior,
			ctx = nil,
			connection = nil,
			active = true,
		}

		local ctx: Types.AnomalyContext = {
			definition = definition,
			model = model,
			anchor = anchor,
			prompt = prompt,
			state = {},
			resolve = function()
				destroyActive(active, true)
				removeActive(self, active)
			end,
			log = function(message: string)
				print(string.format("[NightFerry] anomaly %s: %s", id, message))
			end,
		}
		active.ctx = ctx

		local ok = pcall(behavior.start, ctx)
		if not ok then
			warn(string.format("[NightFerry] anomaly start failed id=%s", id))
			prompt:Destroy()
			model:Destroy()
			continue
		end

		active.connection = prompt.Triggered:Connect(function(player)
			if not active.active then
				return
			end
			self:_onPrompt(active, player)
		end)

		table.insert(self._active, active)
		table.insert(spawned, id)
	end

	print(string.format("[NightFerry] night seed=%d anomalies=%s", seed, table.concat(spawned, ",")))
	return #self._active
end

function AnomalyService:_onPrompt(active: ActiveAnomaly, player: Player)
	if not active.active then
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
	if not InteractionRules.cooldownReady(self._cooldowns[player], now, ShiftConfig.INTERACTION_COOLDOWN_SECONDS) then
		return
	end

	if not InteractionRules.isInRange(root.Position, active.anchor.Position, active.definition.maxDistance) then
		return
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local direction = active.anchor.Position - root.Position
	local result = workspace:Raycast(root.Position, direction, params)
	if result and result.Instance ~= active.anchor and not result.Instance:IsDescendantOf(active.model) then
		return
	end

	self._cooldowns[player] = now

	if self._analyticsService then
		pcall(function()
			self._analyticsService:LogFirstInteraction(player)
		end)
	end

	local ctx = active.ctx
	if not ctx then
		return
	end

	local ok = pcall(active.behavior.onInteract, ctx, player)
	if not ok then
		warn(string.format("[NightFerry] anomaly interact failed id=%s", active.id))
	end
end

function AnomalyService:EndNight()
	for _, active in self._active do
		destroyActive(active, false)
	end
	self._active = {}
end

function AnomalyService:GetRemainingCount(): number
	return #self._active
end

function AnomalyService:GetActiveIds(): { string }
	local ids = {}
	for _, active in self._active do
		table.insert(ids, active.id)
	end
	return ids
end

return AnomalyService
