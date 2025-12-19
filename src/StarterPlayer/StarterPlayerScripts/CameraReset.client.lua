-- Garantiza que la cámara siga al personaje al reaparecer o al moverlo de lobby.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function resetCamera(char: Model)
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		cam.CameraType = Enum.CameraType.Custom
		cam.CameraSubject = hum
	end
end

player.CharacterAdded:Connect(function(char)
	-- Espera un momento a que se ajusten CFrame y atributos en server
	task.wait(0.1)
	resetCamera(char)
end)

if player.Character then
	resetCamera(player.Character)
end
