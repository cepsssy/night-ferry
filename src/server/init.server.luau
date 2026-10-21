--!strict

local Services = script:WaitForChild("Services")

local AnalyticsService = require(Services:WaitForChild("AnalyticsService"))
local WorldService = require(Services:WaitForChild("WorldService"))
local AnomalyService = require(Services:WaitForChild("AnomalyService"))
local ShiftService = require(Services:WaitForChild("ShiftService"))

local services = {
	AnalyticsService = AnalyticsService,
	WorldService = WorldService,
	AnomalyService = AnomalyService,
	ShiftService = ShiftService,
}

AnalyticsService:Init(services)
WorldService:Init(services)
AnomalyService:Init(services)
ShiftService:Init(services)

AnalyticsService:Start()
WorldService:Start()
AnomalyService:Start()
ShiftService:Start()

print("[NightFerry] server boot")
