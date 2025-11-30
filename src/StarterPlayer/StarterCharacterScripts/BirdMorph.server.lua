local Players = game:GetService("Players")

local function getTorso(character: Model)
	return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
end

local function clearOld(character: Model)
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("BasePart") and child:GetAttribute("BirdMorph") then
			child:Destroy()
		end
	end
end

local function weld(part: BasePart, target: BasePart)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = part
	weldConstraint.Part1 = target
	weldConstraint.Parent = part
	part.Anchored = false
	part.CanCollide = false
	part.Massless = true
end

local function createWing(character: Model, torso: BasePart, side: "Left" | "Right")
	local wing = Instance.new("Part")
	wing.Name = side .. "Wing"
	wing:SetAttribute("BirdMorph", true)
	wing.Size = Vector3.new(1, 0.2, 3.5)
	wing.Color = Color3.fromRGB(255, 170, 80)
	wing.Material = Enum.Material.SmoothPlastic
	wing.Parent = character

	local offset = side == "Left" and -1.5 or 1.5
	local angle = side == "Left" and -15 or 15
	wing.CFrame = torso.CFrame * CFrame.new(offset, 0.2, -0.2) * CFrame.Angles(0, math.rad(angle), math.rad(15))

	weld(wing, torso)
end

local function createBeak(character: Model, head: BasePart)
	local beak = Instance.new("WedgePart")
	beak.Name = "Beak"
	beak:SetAttribute("BirdMorph", true)
	beak.Size = Vector3.new(0.4, 0.4, 1)
	beak.Color = Color3.fromRGB(255, 140, 0)
	beak.Material = Enum.Material.Neon
	beak.Parent = character

	beak.CFrame = head.CFrame * CFrame.new(0, -0.1, -0.9)
	weld(beak, head)
end

local function onCharacterAdded(character: Model)
	local torso = getTorso(character)
	local head = character:FindFirstChild("Head")
	if not torso or not head then
		return
	end

	clearOld(character)
	createWing(character, torso, "Left")
	createWing(character, torso, "Right")
	createBeak(character, head)
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
