-- Reemplaza el personaje por defecto por `ReplicatedStorage/Characters/BirdCharacter`.
-- Asegúrate de que el modelo tenga Humanoid (R15), Animator y el script Animate con animaciones válidas.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CHAR_FOLDER = ReplicatedStorage:WaitForChild("Characters", 5)
local BIRD_TEMPLATE = CHAR_FOLDER and CHAR_FOLDER:FindFirstChild("BirdCharacter")

if not BIRD_TEMPLATE then
	warn("[lava_birds] BirdCharacter no encontrado en ReplicatedStorage/Characters; se usarán avatares por defecto.")
	return
end

local function replaceCharacter(player: Player, original: Model?)
	if original and original:GetAttribute("IsBirdCharacter") then
		return
	end

	local clone = BIRD_TEMPLATE:Clone()
	clone.Name = player.Name
	clone:SetAttribute("IsBirdCharacter", true)
	clone.Parent = workspace
	player.Character = clone
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(char)
		replaceCharacter(player, char)
	end)
	if player.Character then
		replaceCharacter(player, player.Character)
	end
end

for _, plr in ipairs(Players:GetPlayers()) do
	onPlayerAdded(plr)
end

Players.PlayerAdded:Connect(onPlayerAdded)

return true
