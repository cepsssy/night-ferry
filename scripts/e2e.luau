local ServerScriptService = game:GetService("ServerScriptService")
local Tests = ServerScriptService:WaitForChild("Tests")
local spec = require(Tests:WaitForChild("spec"))

spec()
print("[NightFerry] e2e tests passed")
