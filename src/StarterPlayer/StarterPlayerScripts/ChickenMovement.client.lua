local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function setupChickenMovement(character)
	-- Esperar a que sea el BirdCharacter real (el servidor lo reemplaza después de CharacterAdded)
	if not character:GetAttribute("IsBirdCharacter") then
		character:GetAttributeChangedSignal("IsBirdCharacter"):Wait()
		-- El servidor reemplazó el personaje; la nueva instancia llegará por CharacterAdded
		return
	end

	local humanoid = character:WaitForChild("Humanoid")
	local torso = character:WaitForChild("Torso")

	local neck = torso:FindFirstChild("Neck")
	local leftShoulder = torso:FindFirstChild("Left Shoulder")
	local rightShoulder = torso:FindFirstChild("Right Shoulder")
	local leftHip = torso:FindFirstChild("Left Hip")
	local rightHip = torso:FindFirstChild("Right Hip")

	if not neck then
		warn("[ChickenMovement] No se encontró Neck en Torso")
		return
	end

	local neckC0 = neck.C0
	local leftShoulderC0 = leftShoulder and leftShoulder.C0
	local rightShoulderC0 = rightShoulder and rightShoulder.C0
	local leftHipC0 = leftHip and leftHip.C0
	local rightHipC0 = rightHip and rightHip.C0

	local t = 0
	local conn

	conn = RunService.Heartbeat:Connect(function(dt)
		if not character.Parent then
			conn:Disconnect()
			return
		end

		t = t + dt

		local isMoving = humanoid.MoveDirection.Magnitude > 0.1
		local state = humanoid:GetState()
		local isInAir = state == Enum.HumanoidStateType.Freefall
			or state == Enum.HumanoidStateType.Jumping

		local stepSpeed = isMoving and 9 or 1.5

		-- Cabeza: picoteo hacia adelante/atrás
		local headBob = math.sin(t * stepSpeed) * (isMoving and 0.18 or 0.03)
		neck.C0 = neckC0 * CFrame.Angles(headBob, 0, 0)

		-- Piernas: waddle alternado (el espejo del joint derecho hace la alternancia)
		if leftHip and rightHip and leftHipC0 and rightHipC0 then
			local stepAmount = isMoving and 0.35 or 0
			local step = math.sin(t * stepSpeed) * stepAmount
			leftHip.C0 = leftHipC0 * CFrame.Angles(0, 0, step)
			rightHip.C0 = rightHipC0 * CFrame.Angles(0, 0, step)
		end

		-- Alas: aleteo al estar en el aire
		if leftShoulder and rightShoulder and leftShoulderC0 and rightShoulderC0 then
			if isInAir then
				local flap = math.sin(t * 12) * 1.0
				leftShoulder.C0 = leftShoulderC0 * CFrame.Angles(0, 0, flap)
				rightShoulder.C0 = rightShoulderC0 * CFrame.Angles(0, 0, -flap)
			else
				leftShoulder.C0 = leftShoulderC0
				rightShoulder.C0 = rightShoulderC0
			end
		end
	end)
end

player.CharacterAdded:Connect(setupChickenMovement)

local char = player.Character
if char then
	setupChickenMovement(char)
end
