--!strict

local Players = game:GetService("Players")
local RobloxAnalytics = game:GetService("AnalyticsService")

type AnalyticsService = {
	_logged: { [Player]: { [string]: boolean } },
	_connection: RBXScriptConnection?,
	Init: (self: AnalyticsService, services: { [string]: any }) -> (),
	Start: (self: AnalyticsService) -> (),
	LogStep: (self: AnalyticsService, player: Player, step: string, stepNumber: number) -> (),
	LogFirstInteraction: (self: AnalyticsService, player: Player) -> (),
	LogShiftComplete: (self: AnalyticsService, player: Player) -> (),
	_logOnce: (self: AnalyticsService, player: Player, step: string, stepNumber: number) -> (),
}

local AnalyticsService: AnalyticsService = {
	_logged = {},
	_connection = nil,
} :: any

function AnalyticsService:Init(_services: { [string]: any }) end

function AnalyticsService:Start()
	self._connection = Players.PlayerRemoving:Connect(function(player)
		self._logged[player] = nil
	end)
end

function AnalyticsService:_logOnce(player: Player, step: string, stepNumber: number)
	local flags = self._logged[player]
	if not flags then
		flags = {}
		self._logged[player] = flags
	end

	if flags[step] then
		return
	end
	flags[step] = true

	print(string.format("[NightFerry] funnel step=%s player=%s", step, player.Name))
	pcall(function()
		RobloxAnalytics:LogOnboardingFunnelStepEvent(player, stepNumber, step)
	end)
end

function AnalyticsService:LogStep(player: Player, step: string, stepNumber: number)
	self:_logOnce(player, step, stepNumber)
end

function AnalyticsService:LogFirstInteraction(player: Player)
	self:_logOnce(player, "first_interaction", 2)
end

function AnalyticsService:LogShiftComplete(player: Player)
	self:_logOnce(player, "shift_1_complete", 3)
end

return AnalyticsService
