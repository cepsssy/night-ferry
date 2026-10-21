--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local WrongPassenger = require(script.Parent.WrongPassenger)
local ImpossibleCabin = require(script.Parent.ImpossibleCabin)
local RestlessCargo = require(script.Parent.RestlessCargo)

local Registry: { [string]: Types.AnomalyBehavior } = {
	wrong_passenger = WrongPassenger,
	impossible_cabin = ImpossibleCabin,
	restless_cargo = RestlessCargo,
}

return Registry
