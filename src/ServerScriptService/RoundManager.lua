local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))
local LavaController = require(script.Parent:WaitForChild("LavaController"))

local EventsFolder = ReplicatedStorage:FindFirstChild("Events") or Instance.new("Folder")
EventsFolder.Name = "Events"
EventsFolder.Parent = ReplicatedStorage

local RoundStateEvent = EventsFolder:FindFirstChild("RoundState")
if not RoundStateEvent then
	RoundStateEvent = Instance.new("RemoteEvent")
	RoundStateEvent.Name = "RoundState"
	RoundStateEvent.Parent = EventsFolder
	print("[lava_birds] RoundState RemoteEvent creado")
end

local running = false
local roundEndTime = 0

local function broadcast(payload)
	RoundStateEvent:FireAllClients(payload)
end

local function respawnAll()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			player:LoadCharacter()
		end
	end
end

local function tickLoop()
	while running do
		local remaining = math.max(0, roundEndTime - os.clock())
		broadcast({ status = "tick", remaining = remaining })
		if remaining <= 0 then
			break
		end
		task.wait(1)
	end
end

local function runRound()
	if running then
		return
	end
	running = true

	LavaController.reset()
	LavaController.start()

	roundEndTime = os.clock() + Constants.RoundDuration
	broadcast({ status = "start", duration = Constants.RoundDuration })

	tickLoop()

	running = false
	LavaController.stop()

	broadcast({ status = "ended" })
	task.wait(Constants.RespawnDelay)
	respawnAll()
	task.wait(Constants.RoundIntermission)
end

local function roundLoop()
	while true do
		runRound()
	end
end

local RoundManager = {}

function RoundManager.start()
	if running then
		warn("[lava_birds] RoundManager ya está corriendo")
		return
	end
	print("[lava_birds] RoundManager start")
	task.spawn(roundLoop)
end

return RoundManager
