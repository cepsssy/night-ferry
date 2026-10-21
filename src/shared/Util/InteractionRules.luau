--!strict

local InteractionRules = {}

function InteractionRules.isInRange(from: Vector3, to: Vector3, maxDistance: number): boolean
	return (from - to).Magnitude <= maxDistance
end

function InteractionRules.cooldownReady(lastUsedAt: number?, now: number, cooldown: number): boolean
	return lastUsedAt == nil or now - lastUsedAt >= cooldown
end

return InteractionRules
