--!strict

local GreyboxFerry = {}

local COLORS = {
	deck = Color3.fromRGB(120, 112, 100),
	hull = Color3.fromRGB(34, 52, 68),
	water = Color3.fromRGB(38, 92, 128),
	wall = Color3.fromRGB(190, 182, 166),
	roof = Color3.fromRGB(78, 72, 66),
	wood = Color3.fromRGB(118, 82, 52),
	metal = Color3.fromRGB(48, 50, 56),
	skin = Color3.fromRGB(226, 188, 150),
	lamp = Color3.fromRGB(255, 218, 150),
}

local function makePart(
	parent: Instance,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material?
): Part
	local part = Instance.new("Part")
	part.Size = size
	part.CFrame = CFrame.new(position)
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeAnchor(anchors: Folder, name: string, position: Vector3, tag: string): Part
	local anchor = makePart(anchors, Vector3.new(1, 1, 1), position, Color3.new(1, 1, 1))
	anchor.Name = name
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.CanQuery = true
	anchor.CanTouch = false
	anchor:SetAttribute("AnchorTag", tag)
	return anchor
end

local function makeLamp(parent: Folder, position: Vector3)
	local post = makePart(parent, Vector3.new(0.4, 5, 0.4), position, COLORS.metal, Enum.Material.Metal)
	post.Name = "LampPost"
	post.CanCollide = true

	local bulb =
		makePart(parent, Vector3.new(1, 0.6, 1), position + Vector3.new(0, 2.8, 0), COLORS.lamp, Enum.Material.Neon)
	bulb.Name = "LampBulb"

	local light = Instance.new("PointLight")
	light.Name = "LampLight"
	light.Color = COLORS.lamp
	light.Brightness = 1.6
	light.Range = 26
	light.Shadows = true
	light.Parent = bulb
end

local function makePassenger(parent: Folder, name: string, position: Vector3, color: Color3, actionText: string)
	local torso = makePart(parent, Vector3.new(2, 2, 1), position, color)
	torso.Name = name
	torso.CFrame = CFrame.new(position) * CFrame.Angles(0, math.pi, 0)

	local head = makePart(parent, Vector3.new(1.2, 1.2, 1.2), position + Vector3.new(0, 1.6, 0), COLORS.skin)
	head.Name = name .. "Head"
	head.CFrame = CFrame.new(position + Vector3.new(0, 1.6, 0)) * CFrame.Angles(0, math.pi, 0)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = name .. "Prompt"
	prompt.ActionText = actionText
	prompt.ObjectText = "Passenger"
	prompt.HoldDuration = 0.6
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = true
	prompt.Parent = torso
end

local function makeCargo(parent: Folder, name: string, position: Vector3, actionText: string)
	local crate = makePart(parent, Vector3.new(3, 3, 3), position, COLORS.wood, Enum.Material.WoodPlanks)
	crate.Name = name
	crate.CanCollide = true

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = name .. "Prompt"
	prompt.ActionText = actionText
	prompt.ObjectText = "Cargo crate"
	prompt.HoldDuration = 0.8
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = true
	prompt.Parent = crate
end

function GreyboxFerry.build(parent: Instance): Model
	local ferry = Instance.new("Model")
	ferry.Name = "Ferry"

	local deck = makePart(ferry, Vector3.new(64, 1, 32), Vector3.new(0, 0, 0), COLORS.deck)
	deck.Name = "Deck"
	deck.CanCollide = true
	ferry.PrimaryPart = deck

	local hull = makePart(ferry, Vector3.new(64, 5, 32), Vector3.new(0, -2.5, 0), COLORS.hull)
	hull.Name = "Hull"

	local water = makePart(ferry, Vector3.new(240, 1, 240), Vector3.new(0, -5.5, 0), COLORS.water)
	water.Name = "Water"
	water.Transparency = 0.15
	water.CanQuery = false
	water.CanTouch = false

	local cabin = Instance.new("Model")
	cabin.Name = "Cabin"
	cabin.Parent = ferry

	local cabinFloor =
		makePart(cabin, Vector3.new(26, 0.5, 14), Vector3.new(0, 0.75, -8), COLORS.wood, Enum.Material.WoodPlanks)
	cabinFloor.Name = "CabinFloor"
	cabinFloor.CanCollide = true

	local backWall = makePart(cabin, Vector3.new(26, 10, 0.5), Vector3.new(0, 5.5, -15), COLORS.wall)
	backWall.Name = "CabinBackWall"
	backWall.CanCollide = true

	local leftWall = makePart(cabin, Vector3.new(0.5, 10, 14), Vector3.new(-13, 5.5, -8), COLORS.wall)
	leftWall.Name = "CabinLeftWall"
	leftWall.CanCollide = true

	local rightWall = makePart(cabin, Vector3.new(0.5, 10, 14), Vector3.new(13, 5.5, -8), COLORS.wall)
	rightWall.Name = "CabinRightWall"
	rightWall.CanCollide = true

	local frontLeft = makePart(cabin, Vector3.new(9, 10, 0.5), Vector3.new(-8.5, 5.5, -1), COLORS.wall)
	frontLeft.Name = "CabinFrontLeft"
	frontLeft.CanCollide = true

	local frontRight = makePart(cabin, Vector3.new(9, 10, 0.5), Vector3.new(8.5, 5.5, -1), COLORS.wall)
	frontRight.Name = "CabinFrontRight"
	frontRight.CanCollide = true

	local roof = makePart(cabin, Vector3.new(26, 0.5, 14), Vector3.new(0, 10.75, -8), COLORS.roof)
	roof.Name = "CabinRoof"
	roof.CanCollide = true

	local strip = makePart(cabin, Vector3.new(18, 0.2, 0.4), Vector3.new(0, 10.3, -8), COLORS.lamp, Enum.Material.Neon)
	strip.Name = "CabinLightStrip"

	local bench = Instance.new("Model")
	bench.Name = "Bench"
	bench.Parent = ferry

	local seat =
		makePart(bench, Vector3.new(8, 0.5, 2), Vector3.new(-22, 1.75, 4), COLORS.wood, Enum.Material.WoodPlanks)
	seat.Name = "BenchSeat"
	seat.CanCollide = true

	local back =
		makePart(bench, Vector3.new(8, 1.5, 0.5), Vector3.new(-22, 2.75, 3.25), COLORS.wood, Enum.Material.WoodPlanks)
	back.Name = "BenchBack"
	back.CanCollide = true

	for _, x in { -25, -19 } do
		local leg = makePart(bench, Vector3.new(0.6, 1.5, 0.6), Vector3.new(x, 1, 4), COLORS.metal, Enum.Material.Metal)
		leg.Name = "BenchLeg"
		leg.CanCollide = true
	end

	local booth = Instance.new("Model")
	booth.Name = "TicketBooth"
	booth.Parent = ferry

	local boothBase =
		makePart(booth, Vector3.new(14, 3, 3), Vector3.new(0, 2, 8.5), COLORS.wood, Enum.Material.WoodPlanks)
	boothBase.Name = "BoothBase"
	boothBase.CanCollide = true

	local counter =
		makePart(booth, Vector3.new(15, 0.3, 3.5), Vector3.new(0, 3.65, 8.5), COLORS.wood, Enum.Material.WoodPlanks)
	counter.Name = "BoothCounter"
	counter.CanCollide = true

	local sign =
		makePart(booth, Vector3.new(10, 1.5, 0.3), Vector3.new(0, 5.5, 10.1), COLORS.metal, Enum.Material.Metal)
	sign.Name = "BoothSign"
	sign.CanCollide = false

	local cargoArea = Instance.new("Model")
	cargoArea.Name = "CargoArea"
	cargoArea.Parent = ferry

	local cargoFloor = makePart(
		cargoArea,
		Vector3.new(14, 0.2, 10),
		Vector3.new(-19, 1.1, 12),
		Color3.fromRGB(86, 74, 62),
		Enum.Material.Concrete
	)
	cargoFloor.Name = "CargoPallet"
	cargoFloor.CanCollide = true

	local railings = Instance.new("Folder")
	railings.Name = "Railings"
	railings.Parent = ferry

	for _, spec in
		{
			{ size = Vector3.new(64, 2.5, 0.5), position = Vector3.new(0, 1.75, 16) },
			{ size = Vector3.new(64, 2.5, 0.5), position = Vector3.new(0, 1.75, -16) },
			{ size = Vector3.new(0.5, 2.5, 32), position = Vector3.new(-32, 1.75, 0) },
			{ size = Vector3.new(0.5, 2.5, 32), position = Vector3.new(32, 1.75, 0) },
		}
	do
		local rail = makePart(railings, spec.size, spec.position, COLORS.metal, Enum.Material.Metal)
		rail.Name = "Rail"
		rail.CanCollide = true
	end

	local lamps = Instance.new("Folder")
	lamps.Name = "Lamps"
	lamps.Parent = ferry

	makeLamp(lamps, Vector3.new(-26, 3, 12))
	makeLamp(lamps, Vector3.new(0, 3, 0))
	makeLamp(lamps, Vector3.new(26, 3, 12))

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Size = Vector3.new(4, 1, 3)
	spawn.CFrame = CFrame.new(0, 1, 14.5)
	spawn.Color = Color3.fromRGB(80, 150, 190)
	spawn.Transparency = 0.35
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Enabled = true
	spawn.Parent = ferry

	local anchors = Instance.new("Folder")
	anchors.Name = "Anchors"
	anchors.Parent = ferry
	makeAnchor(anchors, "BenchAnchor", Vector3.new(-22, 3.5, 7), "bench")
	makeAnchor(anchors, "CabinAnchor", Vector3.new(14, 4, -8), "cabin")
	makeAnchor(anchors, "CargoAnchor", Vector3.new(20, 2.5, 12), "cargo")

	local dayTasks = Instance.new("Folder")
	dayTasks.Name = "DayTasks"
	dayTasks.Parent = ferry

	makePassenger(dayTasks, "TicketPassengerA", Vector3.new(-4, 3.5, 11.5), Color3.fromRGB(170, 92, 82), "Check ticket")
	makePassenger(dayTasks, "TicketPassengerB", Vector3.new(0, 3.5, 11.5), Color3.fromRGB(92, 128, 170), "Check ticket")
	makePassenger(dayTasks, "TicketPassengerC", Vector3.new(4, 3.5, 11.5), Color3.fromRGB(120, 156, 96), "Check ticket")
	makeCargo(dayTasks, "DayCargoA", Vector3.new(-20, 2, 12), "Secure cargo")
	makeCargo(dayTasks, "DayCargoB", Vector3.new(-15, 2, 12), "Secure cargo")

	local anomalies = Instance.new("Folder")
	anomalies.Name = "Anomalies"
	anomalies.Parent = ferry

	ferry.Parent = parent
	return ferry
end

return GreyboxFerry
