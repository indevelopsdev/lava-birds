local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local SprintButton = {}
SprintButton.__index = SprintButton

function SprintButton.new(onSprintStart, onSprintEnd)
	local self = setmetatable({}, SprintButton)
	self._onSprintStart = onSprintStart
	self._onSprintEnd = onSprintEnd
	self._button = nil
	self._connections = {}
	return self
end

function SprintButton:_buildUI()
	local player = Players.LocalPlayer
	local gui = player.PlayerGui

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SprintButtonGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = gui

	local button = Instance.new("ImageButton")
	button.Name = "SprintButton"
	button.Size = UDim2.new(0, 80, 0, 80)
	button.Position = UDim2.new(1, -110, 1, -110)
	button.AnchorPoint = Vector2.new(0, 0)
	button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundTransparency = 0.3
	button.Image = ""
	button.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "RUN"
	label.TextColor3 = Color3.fromRGB(30, 30, 30)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = button

	self._button = button
	self._screenGui = screenGui
end

function SprintButton:start()
	if not UserInputService.TouchEnabled then return end

	self:_buildUI()

	table.insert(self._connections, self._button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			self._button.BackgroundTransparency = 0.1
			self._onSprintStart()
		end
	end))

	table.insert(self._connections, self._button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			self._button.BackgroundTransparency = 0.3
			self._onSprintEnd()
		end
	end))
end

function SprintButton:destroy()
	for _, conn in ipairs(self._connections) do
		conn:Disconnect()
	end
	self._connections = {}
	if self._screenGui then
		self._screenGui:Destroy()
	end
end

return SprintButton
