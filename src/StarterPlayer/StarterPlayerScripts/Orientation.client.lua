local StarterGui = game:GetService("StarterGui")

-- Intenta forzar orientación horizontal en móviles; no siempre se respeta en todos los dispositivos.
pcall(function()
	StarterGui:SetCore("PreferredScreenOrientation", Enum.ScreenOrientation.LandscapeLeft)
	StarterGui:SetCore("DeviceOrientationMode", Enum.DeviceOrientationMode.LandscapeLock)
end)
