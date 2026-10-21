--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local WrongPassenger = {}

local function addFace(head: Part)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Face"
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.CanvasSize = Vector2.new(200, 200)

	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundTransparency = 1
	background.Parent = gui

	for _, x in { 0.28, 0.6 } do
		local eye = Instance.new("Frame")
		eye.Size = UDim2.fromScale(0.12, 0.12)
		eye.Position = UDim2.fromScale(x, 0.35)
		eye.BackgroundColor3 = Color3.fromRGB(24, 20, 20)
		eye.BorderSizePixel = 0
		eye.Parent = background
	end

	local mouth = Instance.new("Frame")
	mouth.Size = UDim2.fromScale(0.3, 0.05)
	mouth.Position = UDim2.fromScale(0.35, 0.62)
	mouth.BackgroundColor3 = Color3.fromRGB(24, 20, 20)
	mouth.BorderSizePixel = 0
	mouth.Parent = background

	gui.Parent = head
end

function WrongPassenger.start(ctx: Types.AnomalyContext)
	local torso = Instance.new("Part")
	torso.Name = "WrongPassengerTorso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.CFrame = ctx.anchor.CFrame
	torso.Anchored = true
	torso.CanCollide = false
	torso.CanQuery = false
	torso.Color = Color3.fromRGB(128, 68, 78)
	torso.Parent = ctx.model

	local head = Instance.new("Part")
	head.Name = "WrongPassengerHead"
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.CFrame = ctx.anchor.CFrame * CFrame.new(0, 1.6, 0)
	head.Anchored = true
	head.CanCollide = false
	head.CanQuery = false
	head.Color = Color3.fromRGB(226, 188, 150)
	head.Parent = ctx.model

	addFace(head)

	ctx.state.torso = torso
	ctx.state.head = head
	ctx.state.resolved = false
end

function WrongPassenger.onInteract(ctx: Types.AnomalyContext, _player: Player)
	ctx.resolve()
end

function WrongPassenger.resolve(ctx: Types.AnomalyContext)
	if ctx.state.resolved then
		return
	end
	ctx.state.resolved = true

	local head = ctx.state.head :: BasePart?
	if head then
		local tween = TweenService:Create(
			head,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = head.CFrame * CFrame.Angles(0, math.pi, 0) }
		)
		ctx.state.tween = tween
		tween:Play()
	end

	ctx.log("wrong passenger turned around")
end

function WrongPassenger.cleanup(ctx: Types.AnomalyContext)
	local tween = ctx.state.tween :: Tween?
	if tween then
		tween:Cancel()
	end
end

return WrongPassenger
