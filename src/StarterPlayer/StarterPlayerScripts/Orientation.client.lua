local StarterGui = game:GetService("StarterGui")

-- Intenta forzar orientación horizontal en móviles (no afecta PC/console).
pcall(function()
	StarterGui:SetCore("PreferredScreenOrientation", Enum.ScreenOrientation.LandscapeLeft)
	StarterGui:SetCore("DeviceOrientationMode", Enum.DeviceOrientationMode.LandscapeLock)
end)
