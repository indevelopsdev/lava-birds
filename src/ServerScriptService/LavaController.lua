local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants"))

local LavaController = {}

local lavaPart: BasePart?
local running = false
local heartbeatConn: RBXScriptConnection?
local touchConn: RBXScriptConnection?
local textureA: Texture?
local textureB: Texture?
local surface: SurfaceAppearance?

local function ensureLavaPart()
	-- Busca el part; si no existe, crea uno con los valores de Constants.
	local part = Workspace:FindFirstChild(Constants.Lava.PartName)
	if part and part:IsA("BasePart") then
		return part
	end

	local newPart = Instance.new("Part")
	newPart.Name = Constants.Lava.PartName
	newPart.Anchored = true
	newPart.CanCollide = true
	newPart.Size = Constants.Lava.Size or Vector3.new(100, 5, 100)
	newPart.Color = Constants.Lava.Color or Color3.fromRGB(255, 80, 30)
	newPart.Material = Constants.Lava.Material or Enum.Material.Neon
	newPart.CFrame = CFrame.new(0, Constants.Lava.StartY, 0)
	newPart.Parent = Workspace
	print(string.format("[lava_birds] Lava part creado en runtime con tamaño %s", tostring(newPart.Size)))

	return newPart
end

function LavaController.getHeight()
	local part = lavaPart or Workspace:FindFirstChild(Constants.Lava.PartName)
	if part and part:IsA("BasePart") then
		return part.Position.Y, part.Size.Y
	end
	return Constants.Lava.StartY, Constants.Lava.Size.Y
end

local function ensureEffects(part: BasePart)
	-- Simple FX sin assets externos: fuego + chispas/nube.
	local fire = part:FindFirstChildOfClass("Fire")
	if not fire then
		fire = Instance.new("Fire")
		fire.Size = 8
		fire.Heat = 6
		fire.Color = Color3.fromRGB(255, 140, 60)
		fire.SecondaryColor = Color3.fromRGB(255, 50, 10)
		fire.Parent = part
	end

	local emitter = part:FindFirstChildOfClass("ParticleEmitter")
	if not emitter then
		emitter = Instance.new("ParticleEmitter")
		emitter.Name = "LavaEmber"
		emitter.Texture = "rbxassetid://244221613" -- spark texture builtin
		emitter.Rate = 15
		emitter.Lifetime = NumberRange.new(1.2, 1.8)
		emitter.Speed = NumberRange.new(2, 5)
		emitter.Rotation = NumberRange.new(0, 360)
		emitter.RotSpeed = NumberRange.new(-60, 60)
		emitter.LightEmission = 0.7
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(0.5, 0.4),
			NumberSequenceKeypoint.new(1, 0),
		})
		emitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 80)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 30)),
		})
		emitter.Parent = part
	end

	-- Textura desplazada para simular flujo
	if not textureA then
		textureA = Instance.new("Texture")
		textureA.Name = "LavaTexA"
		textureA.Texture = "rbxasset://textures/terrain/Lava/Lava_BaseColor.png"
		textureA.StudsPerTileU = 12
		textureA.StudsPerTileV = 12
		textureA.Face = Enum.NormalId.Top
		textureA.Transparency = 0
		textureA.Parent = part
	end
	if not textureB then
		textureB = Instance.new("Texture")
		textureB.Name = "LavaTexB"
		textureB.Texture = "rbxasset://textures/terrain/Lava/Lava_BaseColor.png"
		textureB.StudsPerTileU = 12
		textureB.StudsPerTileV = 12
		textureB.Face = Enum.NormalId.Top
		textureB.Transparency = 0.3
		textureB.Parent = part
	end
end

function LavaController.reset()
	lavaPart = lavaPart or ensureLavaPart()
	if not lavaPart then
		return
	end
	-- Reposiciona la lava al nivel inicial y detiene movimiento
	lavaPart.AssemblyLinearVelocity = Vector3.zero
	lavaPart.Anchored = true
	if Constants.Lava.Size then
		lavaPart.Size = Constants.Lava.Size
	end
	if Constants.Lava.Color then
		lavaPart.Color = Constants.Lava.Color
	end
	if Constants.Lava.Material then
		lavaPart.Material = Constants.Lava.Material
	end
	lavaPart.Transparency = 0 -- sin transparencia para tapar el fondo
	lavaPart.Reflectance = 0
	ensureEffects(lavaPart)
	local pos = lavaPart.Position
	lavaPart.CFrame = CFrame.new(pos.X, Constants.Lava.StartY, pos.Z)
	print(string.format("[lava_birds] Lava reset a Y=%.2f", Constants.Lava.StartY))
end

local function onTouched(otherPart: BasePart)
	local character = otherPart.Parent
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid:TakeDamage(Constants.LavaTouchDamage)
	end
end

local function killPlayersBelowSurface()
	local surfaceY = Constants.Lava.StartY
	if lavaPart then
		surfaceY = lavaPart.Position.Y + (lavaPart.Size.Y * 0.5)
	end

	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			local hum = character:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				if hrp.Position.Y <= surfaceY + 1 then
					hum:TakeDamage(Constants.LavaTouchDamage)
				end
			end
		end
	end
end

function LavaController.start()
	lavaPart = lavaPart or ensureLavaPart()
	if not lavaPart then
		return
	end

	if touchConn then
		touchConn:Disconnect()
	end
	touchConn = lavaPart.Touched:Connect(onTouched)

	running = true
	local phase2Time = Constants.Lava.Phase2StartTime
	local startTime = os.clock()

	if heartbeatConn then
		heartbeatConn:Disconnect()
	end

	heartbeatConn = RunService.Heartbeat:Connect(function(dt)
		if not running or not lavaPart then
			return
		end

		local elapsed = os.clock() - startTime
		local speed = elapsed >= phase2Time and Constants.Lava.Phase2Speed or Constants.Lava.Phase1Speed

		local pos = lavaPart.Position
		local nextY = math.min(Constants.Lava.MaxY, pos.Y + speed * dt)
		lavaPart.CFrame = CFrame.new(pos.X, nextY, pos.Z)

		killPlayersBelowSurface()

		-- Animar desplazamiento de textura
		if textureA then
			textureA.OffsetStudsU = textureA.OffsetStudsU + dt * 2
			textureA.OffsetStudsV = textureA.OffsetStudsV + dt * 1
		end
		if textureB then
			textureB.OffsetStudsU = textureB.OffsetStudsU - dt * 1.5
			textureB.OffsetStudsV = textureB.OffsetStudsV + dt * 0.8
		end
	end)

	print(string.format("[lava_birds] LavaController start (Phase2 @ %ds, speed1=%.2f, speed2=%.2f)", phase2Time, Constants.Lava.Phase1Speed, Constants.Lava.Phase2Speed))
end

function LavaController.stop()
	running = false
	if heartbeatConn then
		heartbeatConn:Disconnect()
		heartbeatConn = nil
	end
	if touchConn then
		touchConn:Disconnect()
		touchConn = nil
	end
end

return LavaController
