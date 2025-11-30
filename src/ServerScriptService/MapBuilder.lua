local Workspace = game:GetService("Workspace")

local MapBuilder = {}

-- Layout sencillo generado por código para no depender de edición en Studio.
-- Estructura: una base de lobby y varias plataformas/perchas en distintos niveles.
local PARTS = {
	{
		name = "Lobby",
		size = Vector3.new(50, 2, 50),
		cframe = CFrame.new(0, 0, 0),
		color = Color3.fromRGB(60, 60, 60),
		material = Enum.Material.Slate,
	},
	{
		name = "Perch1",
		size = Vector3.new(20, 2, 10),
		cframe = CFrame.new(0, 12, 30), -- movida lejos del spawn
		color = Color3.fromRGB(90, 120, 170),
		material = Enum.Material.SmoothPlastic,
	},
	{
		name = "Perch2",
		size = Vector3.new(14, 2, 8),
		cframe = CFrame.new(25, 16, -10),
		color = Color3.fromRGB(160, 120, 90),
		material = Enum.Material.WoodPlanks,
	},
	{
		name = "Perch3",
		size = Vector3.new(10, 2, 10),
		cframe = CFrame.new(-25, 18, 12),
		color = Color3.fromRGB(100, 180, 120),
		material = Enum.Material.Grass,
	},
	{
		name = "Beam1",
		size = Vector3.new(2, 2, 24),
		cframe = CFrame.new(0, 22, -25),
		color = Color3.fromRGB(200, 160, 80),
		material = Enum.Material.Metal,
	},
	{
		name = "Pillar1",
		size = Vector3.new(4, 14, 4),
		cframe = CFrame.new(12, 7, 18),
		color = Color3.fromRGB(150, 150, 180),
		material = Enum.Material.Concrete,
	},
	{
		name = "Pillar2",
		size = Vector3.new(4, 10, 4),
		cframe = CFrame.new(-12, 5, -18),
		color = Color3.fromRGB(180, 140, 140),
		material = Enum.Material.Concrete,
	},
	{
		name = "PerchTop",
		size = Vector3.new(18, 2, 12),
		cframe = CFrame.new(0, 28, -25),
		color = Color3.fromRGB(120, 100, 200),
		material = Enum.Material.Fabric,
	},
}

local function ensureFolder()
	local folder = Workspace:FindFirstChild("MapGenerated")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "MapGenerated"
		folder.Parent = Workspace
	end
	return folder
end

local function ensureSpawn()
	-- Remueve el Baseplate por defecto para evitar z-fighting
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end

	-- Crea o ajusta el SpawnLocation y lo coloca encima del lobby
	local spawn = Workspace:FindFirstChild("SpawnLocation")
	if not spawn then
		spawn = Instance.new("SpawnLocation")
		spawn.Name = "SpawnLocation"
		spawn.Parent = Workspace
	end

	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Color = Color3.fromRGB(200, 200, 200)
	spawn.Material = Enum.Material.Neon
	spawn.Transparency = 0
	spawn.Enabled = true
	-- El lobby tiene altura 2 y está en Y=0, ubicamos el spawn un poco encima
	spawn.CFrame = CFrame.new(0, 3, 0)

	-- Elimina decals predeterminados si existen
	for _, child in ipairs(spawn:GetChildren()) do
		if child:IsA("Decal") then
			child:Destroy()
		end
	end
end

function MapBuilder.build()
	local folder = ensureFolder()
	ensureSpawn()

	for _, spec in ipairs(PARTS) do
		local existing = folder:FindFirstChild(spec.name)
		local part = existing
		if not existing then
			part = Instance.new("Part")
			part.Name = spec.name
			part.Parent = folder
		end
		part.Anchored = true
		part.CanCollide = true
		part.Size = spec.size
		part.CFrame = spec.cframe
		part.Color = spec.color
		part.Material = spec.material
	end
end

return MapBuilder
