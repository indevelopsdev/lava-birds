# Tasks: Lava Birds Core Loop

## P1 - Sobrevive a la lava (ronda y hazard) - prioridad máxima
- Definir constantes compartidas en `src/ReplicatedStorage/Shared/Constants.lua` (duración de ronda, alturas/velocidades de lava, cooldowns).
- Crear RemoteEvents en `ReplicatedStorage/Shared` (p. ej. `Events`) mapeados con Rojo; exponer `RoundStateChanged`, `HudUpdate`.
- Implementar módulo de estado de ronda en `src/ServerScriptService/RoundManager.lua`: temporizador 60–180 s, fases de lava, reinicio de ronda y respawn seguro.
- Script de lava en `src/ServerScriptService/LavaController.lua`: mueve la parte de lava según fases (TweenService o CFrame), elimina/penaliza al tocar; respawn del jugador.
- HUD básico en `src/StarterPlayer/StarterPlayerScripts/Hud.client.lua`: muestra tiempo restante y estado de lava (usa eventos remotos).
- Pruebas: Play (1 jugador) y Start Server (2 jugadores). Verificar que tocar lava elimina y respawnea; que el temporizador termina la ronda.
- NUEVO: Lobby de espera para jugadores que se unan a mitad de ronda, fuera de la zona de lava; teletransportar al área de juego solo al inicio de la siguiente ronda (mostrar estado “esperando”).

## P2 - Movilidad de ave (doble salto/planeo)
- Añadir módulo de movimiento en `src/StarterPlayer/StarterPlayerScripts/GlideController.client.lua`: doble salto una vez por aire, planeo con gravedad reducida y cooldown visible.
- Si se requiere validación, añadir comprobación ligera en server (`RoundManager` o módulo aparte) para no exceder intentos por salto; rechazar valores fuera de rango.
- Actualizar `Constants.lua` con tiempos y fuerzas de planeo; reutilizar en cliente.
- Pruebas: mapa de prueba; confirmar que el planeo no se dispara dos veces por salto y respeta cooldown.

## P3 - Riesgo/recompensa y power-ups
- (En pausa) Power-ups deshabilitados por ahora; `PowerUps.lua` no se usa en runtime.
- `RoundManager` ahora cuenta victorias de sobrevivientes (no monedas) y las envía a `Events/Wins`.
- HUD (`Hud.client.lua`) muestra victorias acumuladas y banner de ganador; countdown a la siguiente ronda.
- Si se reactivan power-ups más adelante, revisar `PowerUps.lua` y reintegrar HUD de efectos.
- Eliminado `AvatarApplier`/`BirdDescription` y `StarterCharacterScripts/BirdMorph.server.lua` (pico/alas por script); el avatar se controla ahora con el `StarterCharacter` que tengas en Studio.
- Fix: `RoundManager` reordena `sendLobbyUpdate` (evita llamada nil).

## Operativo
- `rojo serve` desde el root del proyecto y conectar plugin Rojo en Studio.
- No commitear `.rbxl` binario; usar `.gitignore` actual.***
