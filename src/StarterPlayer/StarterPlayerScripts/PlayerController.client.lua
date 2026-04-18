local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Modules = script.Parent:WaitForChild("Modules")

local DoubleJump = require(Modules:WaitForChild("DoubleJump"))
local Sprint = require(Modules:WaitForChild("Sprint"))
local SprintButton = require(Modules:WaitForChild("SprintButton"))
local ChickenMovement = require(Modules:WaitForChild("ChickenMovement"))

local activeModules = {}

local function teardown()
	for _, mod in ipairs(activeModules) do
		mod:destroy()
	end
	activeModules = {}
end

local function setup(character)
	if not character:GetAttribute("IsBirdCharacter") then
		character:GetAttributeChangedSignal("IsBirdCharacter"):Wait()
		return
	end

	teardown()

	local sprint = Sprint.new(character)
	local doubleJump = DoubleJump.new(character)
	local chickenMovement = ChickenMovement.new(character, function()
		return sprint:isSprinting()
	end)
	local sprintButton = SprintButton.new(
		function() sprint:setSprintActive(true) end,
		function() sprint:setSprintActive(false) end
	)

	sprint:start()
	doubleJump:start()
	chickenMovement:start()
	sprintButton:start()

	table.insert(activeModules, sprint)
	table.insert(activeModules, doubleJump)
	table.insert(activeModules, chickenMovement)
	table.insert(activeModules, sprintButton)
end

player.CharacterAdded:Connect(setup)
if player.Character then
	setup(player.Character)
end
