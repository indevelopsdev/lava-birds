local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))

local PowerUps = {}

local container = Workspace:FindFirstChild("PowerUps")
if not container then
	container = Instance.new("Folder")
	container.Name = "PowerUps"
	container.Parent = Workspace
end

local activePowerUps = {}

local function createPowerUp(position: Vector3)
	local part = Instance.new("Part")
	part.Name = "PowerUp_LavaResist"
	part.Size = Constants.PowerUps.Template.Size
	part.Color = Constants.PowerUps.Template.Color
	part.Material = Constants.PowerUps.Template.Material
	part.Anchored = true
	part.CanCollide = true -- que sirva de apoyo mínimo
	part.CFrame = CFrame.new(position)
	part.Parent = container

	local touchConn
	touchConn = part.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		-- aplica inmunidad
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp:SetAttribute("LavaImmuneUntil", os.clock() + Constants.PowerUps.Duration)
		end

		part:Destroy()
		if touchConn then
			touchConn:Disconnect()
		end

		-- respawn futuro
		task.delay(Constants.PowerUps.RespawnTime, function()
			createPowerUp(position)
		end)
	end)

	table.insert(activePowerUps, part)
end

function PowerUps.start()
	for _, pos in ipairs(Constants.PowerUps.SpawnPositions) do
		createPowerUp(pos)
	end
end

function PowerUps.stop()
	for _, obj in ipairs(activePowerUps) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	table.clear(activePowerUps)
end

return PowerUps
