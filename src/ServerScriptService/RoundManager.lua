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

local WinsEvent = EventsFolder:FindFirstChild("Wins")
if not WinsEvent then
	WinsEvent = Instance.new("RemoteEvent")
	WinsEvent.Name = "Wins"
	WinsEvent.Parent = EventsFolder
end

local running = false
local roundEndTime = 0
local wins = {}

local function placeCharacterSafely(character: Model)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local spawnPart = game.Workspace:FindFirstChild("SpawnLocation")
	local spawnPos = spawnPart and spawnPart.Position or Vector3.new(0, Constants.Lava.StartY + Constants.SafeRespawnOffset, 0)

	local lavaY = LavaController.getHeight()
	-- +5 extra para evitar quedar incrustado en el suelo
	local safeY = math.max(spawnPos.Y + 5, lavaY + Constants.SafeRespawnOffset)

	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(spawnPos.X, safeY, spawnPos.Z)

	if humanoid then
		humanoid.Sit = false
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local function broadcast(payload)
	RoundStateEvent:FireAllClients(payload)
end

local function updateWins(player: Player, amount: number)
	wins[player.UserId] = (wins[player.UserId] or 0) + amount
	WinsEvent:FireClient(player, wins[player.UserId])
end

local function setWins(player: Player, amount: number)
	wins[player.UserId] = amount
	WinsEvent:FireClient(player, amount)
end

local function respawnAll()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			player:LoadCharacter()
			task.defer(function()
				if player.Character then
					task.wait(0.05)
					placeCharacterSafely(player.Character)
				end
			end)
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
	print("[lava_birds] runRound start")

	LavaController.reset()

	-- Reubica a todos antes de que la lava suba
	respawnAll()

	-- Cuenta regresiva antes de iniciar la lava
	for t = Constants.RoundStartDelay, 1, -1 do
		print(string.format("[lava_birds] prestart %d", t))
		broadcast({ status = "prestart", remaining = t })
		task.wait(1)
	end

	LavaController.start()

	roundEndTime = os.clock() + Constants.RoundDuration
	broadcast({ status = "start", duration = Constants.RoundDuration })
	print("[lava_birds] round started")

	tickLoop()

	running = false
	LavaController.stop()

	-- Recompensas: suma 1 victoria a los vivos
	local winners = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			local alive = hum and hum.Health > 0
			if alive then
				table.insert(winners, player.Name)
				updateWins(player, 1)
			end
		end
	end

	local nextRound = Constants.RespawnDelay + Constants.RoundIntermission
	broadcast({ status = "ended", winners = winners, nextRound = nextRound })
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
	Players.CharacterAutoLoads = false

	if running then
		warn("[lava_birds] RoundManager ya está corriendo")
		return
	end
	print("[lava_birds] RoundManager start")

	-- Reubica de forma segura cuando aparece un personaje
	Players.PlayerAdded:Connect(function(player)
		setWins(player, wins[player.UserId] or 0)
		player.CharacterAdded:Connect(function(char)
			task.defer(function()
				task.wait(0.05)
				placeCharacterSafely(char)
			end)
		end)
		player:LoadCharacter()
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		setWins(player, wins[player.UserId] or 0)
		player.CharacterAdded:Connect(function(char)
			task.defer(function()
				task.wait(0.05)
				placeCharacterSafely(char)
			end)
		end)
		player:LoadCharacter()
	end

	task.spawn(roundLoop)
end

return RoundManager
