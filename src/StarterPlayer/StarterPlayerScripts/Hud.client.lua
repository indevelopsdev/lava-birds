local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local eventsFolder = ReplicatedStorage:WaitForChild("Events", 5)
local roundEvent = eventsFolder and eventsFolder:WaitForChild("RoundState", 5)
local glideEvent = eventsFolder and eventsFolder:FindFirstChild("GlideStatus")

if not roundEvent then
	warn("[lava_birds] RoundState RemoteEvent no encontrado; HUD no se inicializa")
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "LavaBirdsHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "Timer"
timerLabel.Size = UDim2.new(0, 220, 0, 40)
timerLabel.Position = UDim2.new(0.5, -110, 0, 10)
timerLabel.BackgroundTransparency = 0.25
timerLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextScaled = true
timerLabel.Text = "Esperando ronda..."
timerLabel.Parent = gui

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(0, 220, 0, 30)
statusLabel.Position = UDim2.new(0.5, -110, 0, 55)
statusLabel.BackgroundTransparency = 0.35
statusLabel.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
statusLabel.TextColor3 = Color3.fromRGB(255, 200, 120)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true
statusLabel.Text = ""
statusLabel.Parent = gui

local countdownLabel = Instance.new("TextLabel")
countdownLabel.Name = "Countdown"
countdownLabel.Size = UDim2.new(0, 260, 0, 80)
countdownLabel.Position = UDim2.new(0.5, -130, 0.2, 0)
countdownLabel.BackgroundTransparency = 0.2
countdownLabel.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
countdownLabel.TextColor3 = Color3.fromRGB(255, 230, 180)
countdownLabel.Font = Enum.Font.GothamBlack
countdownLabel.TextScaled = true
countdownLabel.Text = ""
countdownLabel.Visible = false
countdownLabel.Parent = gui

local glideLabel = Instance.new("TextLabel")
glideLabel.Name = "Glide"
glideLabel.Size = UDim2.new(0, 220, 0, 24)
glideLabel.Position = UDim2.new(0.5, -110, 0, 90)
glideLabel.BackgroundTransparency = 0.45
glideLabel.BackgroundColor3 = Color3.fromRGB(20, 40, 60)
glideLabel.TextColor3 = Color3.fromRGB(200, 230, 255)
glideLabel.Font = Enum.Font.Gotham
glideLabel.TextScaled = true
glideLabel.Text = "Planeo listo"
glideLabel.Parent = gui

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "Coins"
coinsLabel.Size = UDim2.new(0, 160, 0, 30)
coinsLabel.Position = UDim2.new(0, 10, 0, 10)
coinsLabel.BackgroundTransparency = 0.25
coinsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
coinsLabel.TextColor3 = Color3.fromRGB(255, 255, 120)
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.TextScaled = true
coinsLabel.Text = "Monedas: 0"
coinsLabel.Parent = gui

local function formatSeconds(sec: number)
	sec = math.max(0, math.floor(sec + 0.5))
	local minutes = math.floor(sec / 60)
	local seconds = sec % 60
	return string.format("%02d:%02d", minutes, seconds)
end

roundEvent.OnClientEvent:Connect(function(payload)
	if payload.status == "prestart" then
		timerLabel.Text = string.format("Comienza en: %s", formatSeconds(payload.remaining or 0))
		statusLabel.Text = string.format("El piso es lava en %ds", math.max(0, math.floor(payload.remaining or 0)))
		statusLabel.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
		countdownLabel.Text = string.format("El piso es lava en %d", math.max(0, math.floor(payload.remaining or 0)))
		countdownLabel.Visible = true
	elseif payload.status == "start" then
		timerLabel.Text = "Ronda: " .. formatSeconds(payload.duration or 0)
		statusLabel.Text = "¡Sobrevive!"
		statusLabel.BackgroundColor3 = Color3.fromRGB(20, 60, 20)
		countdownLabel.Visible = false
	elseif payload.status == "tick" then
		timerLabel.Text = "Ronda: " .. formatSeconds(payload.remaining or 0)
	elseif payload.status == "ended" then
		timerLabel.Text = "Ronda: 00:00"
		local winners = payload.winners or {}
		local youWon = table.find(winners, player.Name) ~= nil
		if youWon then
			statusLabel.Text = "¡Ganaste la ronda!"
			statusLabel.BackgroundColor3 = Color3.fromRGB(20, 80, 40)
		else
			statusLabel.Text = "Ronda terminada"
			statusLabel.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
		end
		countdownLabel.Visible = false
	end
end)

if glideEvent then
	glideEvent.Event:Connect(function(payload)
		if payload.status == "ready" then
			glideLabel.Text = "Planeo listo"
			glideLabel.BackgroundColor3 = Color3.fromRGB(20, 60, 20)
		elseif payload.status == "cooldown" then
			glideLabel.Text = string.format("Planeo CD: %.1fs", payload.remaining or 0)
			glideLabel.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
		elseif payload.status == "gliding" then
			glideLabel.Text = "Planeando..."
			glideLabel.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
		end
	end)
else
	warn("[lava_birds] GlideStatus BindableEvent no encontrado; HUD sin indicador de planeo")
end

-- Monedas
local coinsEvent = eventsFolder:FindFirstChild("Coins")
if coinsEvent then
	coinsEvent.OnClientEvent:Connect(function(amount)
		coinsLabel.Text = string.format("Monedas: %d", amount or 0)
	end)
else
	warn("[lava_birds] Coins RemoteEvent no encontrado; HUD sin monedas")
end
