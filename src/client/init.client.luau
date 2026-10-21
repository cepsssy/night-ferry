--!strict

local Controllers = script:WaitForChild("Controllers")
local HudController = require(Controllers:WaitForChild("HudController"))
local LightingController = require(Controllers:WaitForChild("LightingController"))

HudController:Start()
LightingController:Start()

print("[NightFerry] client boot")
