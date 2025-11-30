# Tasks: Lava Birds Core Loop

## P1 - Sobrevive a la lava (ronda y hazard) - prioridad máxima
- Definir constantes compartidas en `src/ReplicatedStorage/Shared/Constants.lua` (duración de ronda, alturas/velocidades de lava, cooldowns).
- Crear RemoteEvents en `ReplicatedStorage/Shared` (p. ej. `Events`) mapeados con Rojo; exponer `RoundStateChanged`, `HudUpdate`.
- Implementar módulo de estado de ronda en `src/ServerScriptService/RoundManager.lua`: temporizador 60–180 s, fases de lava, reinicio de ronda y respawn seguro.
- Script de lava en `src/ServerScriptService/LavaController.lua`: mueve la parte de lava según fases (TweenService o CFrame), elimina/penaliza al tocar; respawn del jugador.
- HUD básico en `src/StarterPlayer/StarterPlayerScripts/Hud.client.lua`: muestra tiempo restante y estado de lava (usa eventos remotos).
- Pruebas: Play (1 jugador) y Start Server (2 jugadores). Verificar que tocar lava elimina y respawnea; que el temporizador termina la ronda.

## P2 - Movilidad de ave (doble salto/planeo)
- Añadir módulo de movimiento en `src/StarterPlayer/StarterPlayerScripts/GlideController.client.lua`: doble salto una vez por aire, planeo con gravedad reducida y cooldown visible.
- Si se requiere validación, añadir comprobación ligera en server (`RoundManager` o módulo aparte) para no exceder intentos por salto; rechazar valores fuera de rango.
- Actualizar `Constants.lua` con tiempos y fuerzas de planeo; reutilizar en cliente.
- Pruebas: mapa de prueba; confirmar que el planeo no se dispara dos veces por salto y respeta cooldown.

## P3 - Riesgo/recompensa y power-ups
- Crear módulo de power-ups en `src/ServerScriptService/PowerUps.lua`: spawn en posiciones predefinidas, duración y respawn configurables; efecto temporal (ej. resistencia a lava por 5 s).
- Ajustar `RoundManager` para otorgar monedas al finalizar ronda según supervivencia y proximidad a lava; mantener conteo en servidor.
- Extender HUD (`Hud.client.lua`) para mostrar monedas y feedback de power-up activo.
- Pruebas: recoger un power-up y ver expiración; terminar ronda y recibir monedas visibles en HUD.

## Operativo
- `rojo serve` desde el root del proyecto y conectar plugin Rojo en Studio.
- No commitear `.rbxl` binario; usar `.gitignore` actual.***
