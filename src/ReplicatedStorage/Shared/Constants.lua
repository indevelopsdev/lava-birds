local Constants = {
	-- Ronda y lava
RoundDuration = 60, -- segundos
RoundIntermission = 3,
RoundStartDelay = 20, -- segundos antes de que la lava suba (contador visible)
	Lava = {
		PartName = "Lava", -- nombre del part en Workspace
		StartY = -8,
		MaxY = 45, -- lava no llega al nido alto
		Phase2StartTime = 40, -- segundo en el que acelera
		Phase1Speed = 1.5, -- studs/s
		Phase2Speed = 3.0, -- studs/s
		Size = Vector3.new(220, 12, 220), -- más gruesa y amplia para cubrir la base
		Color = Color3.fromRGB(255, 60, 20),
		Material = Enum.Material.SmoothPlastic, -- superficie sólida (sin fuerza de campo)
	},

	RespawnDelay = 1.5,
	LavaTouchDamage = 5000, -- suficiente para eliminar
	SafeRespawnOffset = 20, -- distancia por encima de la lava para reubicar al jugador al respawnear

	-- Movilidad de ave
	Glide = {
		Enabled = false, -- desactiva el planeo para volver a salto normal
		MaxMidAirActivations = 0,
		Duration = 0,
		GravityScale = 1,
		Cooldown = 0,
		HorizontalBoost = 0,
	},

	-- Recompensas
	Rewards = {
		BasePerRound = 10,
		SurvivorBonus = 15,
	},

	-- Power-ups (ejemplo: resistencia a lava por pocos segundos)
	PowerUps = {
		SpawnPositions = {
			Vector3.new(0, 5, 0),
			Vector3.new(30, 8, 20),
			Vector3.new(-25, 10, -15),
		},
		RespawnTime = 15, -- segundos para reaparecer
		Duration = 5, -- duración de la resistencia
		Template = {
			Size = Vector3.new(4, 2, 4),
			Color = Color3.fromRGB(80, 200, 255),
			Material = Enum.Material.Neon,
		},
	},
}

return Constants
