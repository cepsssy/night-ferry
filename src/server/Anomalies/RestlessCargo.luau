--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local RestlessCargo = {}

function RestlessCargo.start(ctx: Types.AnomalyContext)
	local crate = Instance.new("Part")
	crate.Name = "RestlessCargoCrate"
	crate.Size = Vector3.new(3, 3, 3)
	crate.CFrame = ctx.anchor.CFrame
	crate.Anchored = true
	crate.CanCollide = false
	crate.CanQuery = false
	crate.Color = Color3.fromRGB(122, 84, 52)
	crate.Material = Enum.Material.WoodPlanks
	crate.Parent = ctx.model

	local tween = TweenService:Create(
		crate,
		TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ CFrame = ctx.anchor.CFrame * CFrame.new(0, 1.2, 0) }
	)

	ctx.state.crate = crate
	ctx.state.tween = tween
	ctx.state.resolved = false

	tween:Play()
end

function RestlessCargo.onInteract(ctx: Types.AnomalyContext, _player: Player)
	ctx.resolve()
end

function RestlessCargo.resolve(ctx: Types.AnomalyContext)
	if ctx.state.resolved then
		return
	end
	ctx.state.resolved = true

	local tween = ctx.state.tween :: Tween?
	if tween then
		tween:Cancel()
	end

	local crate = ctx.state.crate :: BasePart?
	if crate then
		crate.CFrame = ctx.anchor.CFrame
		crate.Color = Color3.fromRGB(92, 64, 40)
	end

	ctx.log("restless cargo settled")
end

function RestlessCargo.cleanup(ctx: Types.AnomalyContext)
	local tween = ctx.state.tween :: Tween?
	if tween then
		tween:Cancel()
	end
end

return RestlessCargo
