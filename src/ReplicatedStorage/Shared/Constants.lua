local Constants = {
	-- Ronda y lava
	RoundDuration = 60, -- segundos
	RoundIntermission = 3,
	Lava = {
		PartName = "Lava", -- nombre del part en Workspace
		StartY = -5,
		MaxY = 50,
		Phase2StartTime = 40, -- segundo en el que acelera
		Phase1Speed = 1.5, -- studs/s
		Phase2Speed = 3.0, -- studs/s
		Size = Vector3.new(200, 5, 200),
		Color = Color3.fromRGB(255, 80, 30),
		Material = Enum.Material.Neon,
	},

	RespawnDelay = 1.5,
	LavaTouchDamage = 5000, -- suficiente para eliminar

	-- Movilidad de ave
	Glide = {
		MaxMidAirActivations = 1, -- cuántas veces por salto se puede activar
		Duration = 1.2, -- segundos
		GravityScale = 0.25, -- 0.25 significa 25% de la gravedad normal mientras planea
		Cooldown = 2.5, -- segundos
		HorizontalBoost = 8, -- impulso horizontal al activar
	},
}

return Constants
