local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundManager = require(script.Parent:WaitForChild("RoundManager"))

-- Garantiza que la carpeta de eventos exista antes de iniciar rondas
local eventsFolder = ReplicatedStorage:FindFirstChild("Events") or Instance.new("Folder")
eventsFolder.Name = "Events"
eventsFolder.Parent = ReplicatedStorage

print("[lava_birds] Server bootstrap")
RoundManager.start()
