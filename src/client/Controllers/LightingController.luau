--!strict

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

type LightingController = {
	_current: string?,
	_connection: RBXScriptConnection?,
	Start: (self: LightingController) -> (),
	_apply: (self: LightingController, phase: string) -> (),
}

local LightingController: LightingController = {
	_current = nil,
	_connection = nil,
} :: any

type LightingPreset = {
	ClockTime: number,
	Brightness: number,
	Ambient: Color3,
	OutdoorAmbient: Color3,
	FogEnd: number,
	FogColor: Color3,
}

local PRESETS: { [string]: LightingPreset } = {
	Lobby = {
		ClockTime = 17.2,
		Brightness = 2,
		Ambient = Color3.fromRGB(70, 70, 80),
		OutdoorAmbient = Color3.fromRGB(120, 125, 140),
		FogEnd = 300,
		FogColor = Color3.fromRGB(150, 160, 175),
	},
	Day = {
		ClockTime = 14,
		Brightness = 2.5,
		Ambient = Color3.fromRGB(80, 80, 85),
		OutdoorAmbient = Color3.fromRGB(135, 140, 150),
		FogEnd = 400,
		FogColor = Color3.fromRGB(160, 175, 190),
	},
	Night = {
		ClockTime = 0.2,
		Brightness = 0.6,
		Ambient = Color3.fromRGB(20, 24, 32),
		OutdoorAmbient = Color3.fromRGB(35, 40, 55),
		FogEnd = 100,
		FogColor = Color3.fromRGB(20, 25, 35),
	},
	Results = {
		ClockTime = 0.2,
		Brightness = 0.6,
		Ambient = Color3.fromRGB(20, 24, 32),
		OutdoorAmbient = Color3.fromRGB(35, 40, 55),
		FogEnd = 100,
		FogColor = Color3.fromRGB(20, 25, 35),
	},
}

function LightingController:_apply(phase: string)
	if phase == self._current then
		return
	end
	self._current = phase

	local preset = PRESETS[phase] or PRESETS.Lobby
	local tween =
		TweenService:Create(Lighting, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), preset)
	tween:Play()
end

function LightingController:Start()
	self._connection = workspace:GetAttributeChangedSignal("ShiftPhase"):Connect(function()
		self:_apply(tostring(workspace:GetAttribute("ShiftPhase") or "Lobby"))
	end)
	self:_apply(tostring(workspace:GetAttribute("ShiftPhase") or "Lobby"))
end

return LightingController
