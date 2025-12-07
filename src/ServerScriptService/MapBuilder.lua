local Workspace = game:GetService("Workspace")

local MapBuilder = {}

-- Layout sencillo generado por código para no depender de edición en Studio.
-- Estructura: una base de lobby y varias plataformas/perchas en distintos niveles.
local PARTS = {
	-- Lobby base
	{
		name = "Lobby",
		size = Vector3.new(50, 2, 50),
		cframe = CFrame.new(0, 0, 0),
		color = Color3.fromRGB(120, 120, 120),
		material = Enum.Material.Cobblestone,
	},
	-- Ruta en espiral hacia arriba
	{ name = "Step1", size = Vector3.new(14, 2, 14), cframe = CFrame.new(0, 8, 18), color = Color3.fromRGB(90, 120, 170), material = Enum.Material.SmoothPlastic },
	{ name = "Step2", size = Vector3.new(12, 2, 12), cframe = CFrame.new(18, 12, 12), color = Color3.fromRGB(160, 120, 90), material = Enum.Material.WoodPlanks },
	{ name = "Step3", size = Vector3.new(10, 2, 10), cframe = CFrame.new(24, 16, -4), color = Color3.fromRGB(100, 180, 120), material = Enum.Material.Grass },
	{ name = "Step4", size = Vector3.new(8, 2, 10), cframe = CFrame.new(14, 20, -20), color = Color3.fromRGB(200, 160, 80), material = Enum.Material.Metal },
	{ name = "Step5", size = Vector3.new(10, 2, 10), cframe = CFrame.new(-2, 24, -26), color = Color3.fromRGB(140, 100, 180), material = Enum.Material.Fabric },
	{ name = "Step6", size = Vector3.new(12, 2, 12), cframe = CFrame.new(-18, 28, -16), color = Color3.fromRGB(120, 160, 200), material = Enum.Material.SmoothPlastic },
	{ name = "Step7", size = Vector3.new(10, 2, 10), cframe = CFrame.new(-24, 32, 2), color = Color3.fromRGB(180, 140, 140), material = Enum.Material.Concrete },
	{ name = "Step8", size = Vector3.new(8, 2, 10), cframe = CFrame.new(-16, 36, 18), color = Color3.fromRGB(100, 140, 200), material = Enum.Material.Metal },
	{ name = "Step9", size = Vector3.new(10, 2, 10), cframe = CFrame.new(0, 42, 24), color = Color3.fromRGB(120, 200, 140), material = Enum.Material.Grass },
	{ name = "Step10", size = Vector3.new(12, 2, 12), cframe = CFrame.new(0, 50, 8), color = Color3.fromRGB(200, 180, 120), material = Enum.Material.Wood },
	-- Meta alta (más accesible; lava MaxY=45)
	{ name = "NestTop", size = Vector3.new(20, 2, 20), cframe = CFrame.new(0, 55, 0), color = Color3.fromRGB(255, 200, 80), material = Enum.Material.WoodPlanks },
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
