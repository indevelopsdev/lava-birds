local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid: Humanoid = character:WaitForChild("Humanoid")
local rootPart: BasePart = character:WaitForChild("HumanoidRootPart")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))

-- Si el planeo está deshabilitado en constants, salimos.
if not Constants.Glide.Enabled then
	return
end

local eventsFolder = ReplicatedStorage:FindFirstChild("Events") or Instance.new("Folder")
eventsFolder.Name = "Events"
eventsFolder.Parent = ReplicatedStorage

local glideStatus = eventsFolder:FindFirstChild("GlideStatus")
if not glideStatus then
	glideStatus = Instance.new("BindableEvent")
	glideStatus.Name = "GlideStatus"
	glideStatus.Parent = eventsFolder
end

local glideUsedThisJump = false
local grounded = true
local inCooldown = false
local gliding = false
local force: VectorForce?
local attachment: Attachment?
local cooldownEnd = 0

local function setGlideStatus(status: string, remaining: number?)
	glideStatus:Fire({ status = status, remaining = remaining })
end

local function endGlide()
	gliding = false
	if force then
		force:Destroy()
		force = nil
	end
	if attachment then
		attachment:Destroy()
		attachment = nil
	end
end

local function startCooldown()
	inCooldown = true
	cooldownEnd = os.clock() + Constants.Glide.Cooldown
	setGlideStatus("cooldown", Constants.Glide.Cooldown)
	task.delay(Constants.Glide.Cooldown, function()
		inCooldown = false
		setGlideStatus("ready", 0)
	end)
end

local function startGlide()
	if gliding or glideUsedThisJump or inCooldown then
		return
	end
	if not rootPart or not humanoid then
		return
	end

	gliding = true
	glideUsedThisJump = true

	attachment = Instance.new("Attachment")
	attachment.Name = "GlideAttachment"
	attachment.Parent = rootPart

	force = Instance.new("VectorForce")
	force.Attachment0 = attachment
	force.ApplyAtCenterOfMass = true
	force.RelativeTo = Enum.ActuatorRelativeTo.World
	force.Force = Vector3.new(
		0,
		rootPart.AssemblyMass * workspace.Gravity * (1 - Constants.Glide.GravityScale),
		0
	)
	force.Parent = rootPart

	-- Impulso horizontal ligero hacia la dirección de movimiento actual
	local vel = rootPart.AssemblyLinearVelocity
	local moveDir = humanoid.MoveDirection.Magnitude > 0 and humanoid.MoveDirection or vel.Unit
	if moveDir.Magnitude > 0 then
		rootPart.AssemblyLinearVelocity = vel + moveDir.Unit * Constants.Glide.HorizontalBoost
	end

	setGlideStatus("gliding", Constants.Glide.Duration)

	task.delay(Constants.Glide.Duration, function()
		endGlide()
		startCooldown()
	end)
end

-- Reset del planeo al tocar suelo
humanoid.StateChanged:Connect(function(_, new)
	if new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running then
		grounded = true
		glideUsedThisJump = false
	elseif new == Enum.HumanoidStateType.Freefall then
		grounded = false
	end
end)

-- Escucha el segundo salto en el aire
UserInputService.JumpRequest:Connect(function()
	-- Solo permitir si ya saltó y está en el aire
	if grounded then
		return
	end
	startGlide()
end)

-- Reinicia referencias si respawnea
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	glideUsedThisJump = false
	inCooldown = false
	gliding = false
	setGlideStatus("ready", 0)
end)

-- Estado inicial
setGlideStatus("ready", 0)
