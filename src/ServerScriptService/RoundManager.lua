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

local LobbyEvent = EventsFolder:FindFirstChild("LobbyState")
if not LobbyEvent then
	LobbyEvent = Instance.new("RemoteEvent")
	LobbyEvent.Name = "LobbyState"
	LobbyEvent.Parent = EventsFolder
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
local respawning = false
local hasRunOnce = false

local function moveLobbyPlayersToGame()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp and hrp:GetAttribute("InLobby") then
				placeCharacterSafely(character)
			end
		end
	end
end

local function getWaitLobby()
	local waitLobby = game.Workspace:FindFirstChild("WaitLobby")
	if waitLobby then
		return waitLobby
	end
	local generated = game.Workspace:FindFirstChild("MapGenerated")
	if generated then
		return generated:FindFirstChild("WaitLobby")
	end
	return nil
end

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

	hrp:SetAttribute("InLobby", false)
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(spawnPos.X, safeY, spawnPos.Z)

	if humanoid then
		humanoid.Sit = false
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local function placeInLobby(character: Model)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local waitLobby = getWaitLobby()
	local pos = waitLobby and waitLobby.Position or Vector3.new(400, 10, 0)
	hrp:SetAttribute("InLobby", true)
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z)
	if humanoid then
		humanoid.Sit = false
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	-- Mensaje para el jugador de que está esperando
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		RoundStateEvent:FireClient(player, { status = "waiting", message = "Esperando siguiente ronda" })
		player:SetAttribute("InLobby", true)
		local remaining
		if running and roundEndTime > 0 then
			remaining = roundEndTime - os.clock()
		else
			remaining = Constants.LobbyWaitNoRound or 20
		end
		sendLobbyUpdate(player, remaining)
	end
end

local function sendLobbyUpdate(player: Player, remaining: number)
	LobbyEvent:FireClient(player, {
		status = "waiting",
		remaining = math.max(0, math.floor(remaining or 0)),
	})
end

local function broadcastLobby(remaining: number)
	LobbyEvent:FireAllClients({
		status = "waiting",
		remaining = math.max(0, math.floor(remaining or 0)),
	})
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
	respawning = true
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
	-- Dar tiempo a que CharacterAdded dispare con respawning=true
	task.wait(0.5)
	respawning = false
end

local function tickLoop()
	while running do
		local remaining = math.max(0, roundEndTime - os.clock())
		broadcast({ status = "tick", remaining = remaining })
		broadcastLobby(remaining)
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

	-- Trae a todos al campo de juego antes del countdown
	respawnAll()
	moveLobbyPlayersToGame()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp and hrp:GetAttribute("InLobby") then
				placeCharacterSafely(character)
			end
		end
	end

	-- Cuenta regresiva antes de iniciar la lava (jugable)
	for t = Constants.RoundStartDelay, 1, -1 do
		print(string.format("[lava_birds] prestart %d", t))
		broadcast({ status = "prestart", remaining = t })
		broadcastLobby(t)
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
			local inLobby = false
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			if hrp and hrp:GetAttribute("InLobby") then
				inLobby = true
			end
			if alive and not inLobby then
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
		-- Si no hay ronda, esperar en lobby antes de iniciar
		if not running then
			local waitTime
			if hasRunOnce then
				waitTime = Constants.RespawnDelay + Constants.RoundIntermission
			else
				waitTime = Constants.LobbyWaitNoRound or 20
			end
			for t = math.floor(waitTime), 1, -1 do
				broadcastLobby(t)
				task.wait(1)
			end
		end
		runRound()
		hasRunOnce = true
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
				-- Por defecto al lobby; solo durante respawn activo va al campo
				if respawning then
					placeCharacterSafely(char)
				else
					placeInLobby(char)
				end
			end)
		end)
		player:LoadCharacter()
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		setWins(player, wins[player.UserId] or 0)
		player.CharacterAdded:Connect(function(char)
			task.defer(function()
				task.wait(0.05)
				if respawning then
					placeCharacterSafely(char)
				else
					placeInLobby(char)
				end
			end)
		end)
		player:LoadCharacter()
	end

	task.spawn(roundLoop)
end

return RoundManager
