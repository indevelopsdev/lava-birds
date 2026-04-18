local RunService = game:GetService("RunService")

local BASE_STEP_SPEED = 9
local SPRINT_STEP_SPEED = 16
local IDLE_STEP_SPEED = 1.5

local ChickenMovement = {}
ChickenMovement.__index = ChickenMovement

function ChickenMovement.new(character, getIsSprinting)
	local self = setmetatable({}, ChickenMovement)
	self._character = character
	self._getIsSprinting = getIsSprinting or function() return false end
	self._connection = nil
	return self
end

function ChickenMovement:start()
	local character = self._character
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

	self._connection = RunService.Heartbeat:Connect(function(dt)
		if not character.Parent then
			self:destroy()
			return
		end

		t = t + dt

		local isMoving = humanoid.MoveDirection.Magnitude > 0.1
		local isSprinting = self._getIsSprinting()
		local state = humanoid:GetState()
		local isInAir = state == Enum.HumanoidStateType.Freefall
			or state == Enum.HumanoidStateType.Jumping

		local stepSpeed
		if not isMoving then
			stepSpeed = IDLE_STEP_SPEED
		elseif isSprinting then
			stepSpeed = SPRINT_STEP_SPEED
		else
			stepSpeed = BASE_STEP_SPEED
		end

		local headBob = math.sin(t * stepSpeed) * (isMoving and 0.18 or 0.03)
		neck.C0 = neckC0 * CFrame.Angles(headBob, 0, 0)

		if leftHip and rightHip and leftHipC0 and rightHipC0 then
			local stepAmount = isMoving and (isSprinting and 0.5 or 0.35) or 0
			local step = math.sin(t * stepSpeed) * stepAmount
			leftHip.C0 = leftHipC0 * CFrame.Angles(0, 0, step)
			rightHip.C0 = rightHipC0 * CFrame.Angles(0, 0, step)
		end

		if leftShoulder and rightShoulder and leftShoulderC0 and rightShoulderC0 then
			if isInAir then
				local flapSpeed = isSprinting and 18 or 12
				local flap = math.sin(t * flapSpeed) * 1.0
				leftShoulder.C0 = leftShoulderC0 * CFrame.Angles(0, 0, flap)
				rightShoulder.C0 = rightShoulderC0 * CFrame.Angles(0, 0, -flap)
			else
				leftShoulder.C0 = leftShoulderC0
				rightShoulder.C0 = rightShoulderC0
			end
		end
	end)
end

function ChickenMovement:destroy()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

return ChickenMovement
