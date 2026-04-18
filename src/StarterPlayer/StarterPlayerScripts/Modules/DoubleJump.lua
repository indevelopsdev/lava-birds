local UserInputService = game:GetService("UserInputService")

local JUMP_VELOCITY = 55

local DoubleJump = {}
DoubleJump.__index = DoubleJump

function DoubleJump.new(character)
	local self = setmetatable({}, DoubleJump)
	self._character = character
	self._humanoid = character:WaitForChild("Humanoid")
	self._hrp = character:WaitForChild("HumanoidRootPart")
	self._hasDoubleJumped = false
	self._connections = {}
	return self
end

function DoubleJump:_isGrounded()
	return self._humanoid.FloorMaterial ~= Enum.Material.Air
end

function DoubleJump:_tryJump()
	if not self._character.Parent then return end
	if self:_isGrounded() or self._hasDoubleJumped then return end
	self._hasDoubleJumped = true
	local vel = self._hrp.AssemblyLinearVelocity
	self._hrp.AssemblyLinearVelocity = Vector3.new(vel.X, JUMP_VELOCITY, vel.Z)
end

function DoubleJump:start()
	table.insert(self._connections, self._humanoid.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Landed
			or new == Enum.HumanoidStateType.Running
			or new == Enum.HumanoidStateType.RunningNoPhysics then
			self._hasDoubleJumped = false
		end
	end))

	table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Space then
			self:_tryJump()
		end
	end))

	table.insert(self._connections, UserInputService.JumpRequest:Connect(function()
		if not UserInputService.TouchEnabled then return end
		self:_tryJump()
	end))
end

function DoubleJump:destroy()
	for _, conn in ipairs(self._connections) do
		conn:Disconnect()
	end
	self._connections = {}
end

return DoubleJump
