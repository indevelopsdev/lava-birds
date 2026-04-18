local UserInputService = game:GetService("UserInputService")

local WALK_SPEED = 16
local SPRINT_SPEED = 28

local Sprint = {}
Sprint.__index = Sprint

function Sprint.new(character)
	local self = setmetatable({}, Sprint)
	self._character = character
	self._humanoid = character:WaitForChild("Humanoid")
	self._sprinting = false
	self._connections = {}
	return self
end

function Sprint:_setSprint(active)
	if self._sprinting == active then return end
	self._sprinting = active
	self._humanoid.WalkSpeed = active and SPRINT_SPEED or WALK_SPEED
end

function Sprint:setSprintActive(active)
	self:_setSprint(active)
end

function Sprint:isSprinting()
	return self._sprinting
end

function Sprint:start()
	table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			self:_setSprint(true)
		end
	end))

	table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			self:_setSprint(false)
		end
	end))
end

function Sprint:destroy()
	self:_setSprint(false)
	for _, conn in ipairs(self._connections) do
		conn:Disconnect()
	end
	self._connections = {}
end

return Sprint
