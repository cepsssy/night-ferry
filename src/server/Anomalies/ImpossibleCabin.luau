--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local ImpossibleCabin = {}

local function makePart(model: Model, name: string, size: Vector3, cframe: CFrame, color: Color3): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Color = color
	part.Material = Enum.Material.WoodPlanks
	part.Parent = model
	return part
end

function ImpossibleCabin.start(ctx: Types.AnomalyContext)
	local gap = Instance.new("Part")
	gap.Name = "ImpossibleGap"
	gap.Size = Vector3.new(0.4, 5.2, 0.2)
	gap.CFrame = ctx.anchor.CFrame * CFrame.new(0.2, 0, 0)
	gap.Anchored = true
	gap.CanCollide = false
	gap.CanQuery = false
	gap.Color = Color3.fromRGB(255, 236, 170)
	gap.Material = Enum.Material.Neon
	gap.Transparency = 0.15
	gap.Parent = ctx.model

	local door = makePart(
		ctx.model,
		"ImpossibleDoor",
		Vector3.new(0.4, 6, 3),
		ctx.anchor.CFrame * CFrame.new(0, 0, 3),
		Color3.fromRGB(82, 56, 38)
	)

	makePart(
		ctx.model,
		"ImpossibleFrameTop",
		Vector3.new(0.5, 0.4, 3.8),
		ctx.anchor.CFrame * CFrame.new(0, 3.2, 0),
		Color3.fromRGB(48, 50, 56)
	)
	makePart(
		ctx.model,
		"ImpossibleFrameLeft",
		Vector3.new(0.5, 6.4, 0.4),
		ctx.anchor.CFrame * CFrame.new(0, 0, -1.9),
		Color3.fromRGB(48, 50, 56)
	)
	makePart(
		ctx.model,
		"ImpossibleFrameRight",
		Vector3.new(0.5, 6.4, 0.4),
		ctx.anchor.CFrame * CFrame.new(0, 0, 1.9),
		Color3.fromRGB(48, 50, 56)
	)

	ctx.state.door = door
	ctx.state.gap = gap
	ctx.state.resolved = false
end

function ImpossibleCabin.onInteract(ctx: Types.AnomalyContext, _player: Player)
	ctx.resolve()
end

function ImpossibleCabin.resolve(ctx: Types.AnomalyContext)
	if ctx.state.resolved then
		return
	end
	ctx.state.resolved = true

	local door = ctx.state.door :: BasePart?
	local gap = ctx.state.gap :: BasePart?

	if door then
		local tween = TweenService:Create(
			door,
			TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = ctx.anchor.CFrame }
		)
		ctx.state.tween = tween
		tween:Play()
	end

	if gap then
		gap.Transparency = 0.9
	end

	ctx.log("impossible cabin door closed")
end

function ImpossibleCabin.cleanup(ctx: Types.AnomalyContext)
	local tween = ctx.state.tween :: Tween?
	if tween then
		tween:Cancel()
	end
end

return ImpossibleCabin
