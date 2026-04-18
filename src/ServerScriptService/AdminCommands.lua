-- Comandos de admin via chat
-- /matar [radio] — mata jugadores cercanos (radio por defecto: 80)

local Players = game:GetService("Players")

-- Pon aquí tu nombre de usuario de Roblox para que solo tú puedas usarlo
local ADMINS = {
	"indevelops_games", -- reemplaza con tu usuario
}

local function isAdmin(player)
	for _, name in ipairs(ADMINS) do
		if player.Name == name then return true end
	end
	return false
end

local function killNearby(player, radius)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local killed = 0
	for _, target in ipairs(Players:GetPlayers()) do
		if target == player then continue end
		local tc = target.Character
		if not tc then continue end
		local thrp = tc:FindFirstChild("HumanoidRootPart")
		local hum = tc:FindFirstChildOfClass("Humanoid")
		if not thrp or not hum then continue end

		local dist = (thrp.Position - hrp.Position).Magnitude
		if dist <= radius then
			hum:TakeDamage(hum.MaxHealth)
			killed += 1
		end
	end

	print(string.format("[Admin] %s usó /matar radio=%d → %d eliminados", player.Name, radius, killed))
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		if not isAdmin(player) then return end

		local lower = msg:lower()
		local radius = 80

		-- /matar [radio]
		local customRadius = lower:match("^/matar%s+(%d+)")
		if customRadius then
			radius = tonumber(customRadius)
		elseif lower == "/matar" then
			radius = 80
		else
			return
		end

		killNearby(player, radius)
	end)
end)
