--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Jest = require(Packages:WaitForChild("Jest"))
local runCLI = Jest.runCLI

local status, result = runCLI(script.Parent, {
	verbose = true,
	ci = true,
}, { script.Parent }):awaitStatus()

if status == "Rejected" then
	print(result)
	error(result)
end

if not result.results.success then
	error("Tests failed")
end

print("[NightFerry] tests passed")
