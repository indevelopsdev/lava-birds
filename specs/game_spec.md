# Lava Birds — Game Spec

## Concepto
Juego multijugador de supervivencia en Roblox. Los jugadores controlan pollos-pájaro y deben sobrevivir en un mapa donde el suelo es lava.

---

## Personaje
- **Modelo:** BirdCharacter (R6 custom) cargado desde ReplicatedStorage/Characters
- **Atributo:** `IsBirdCharacter = true` — usado por scripts cliente para sincronizar inicialización

### Habilidades
| Habilidad | Estado | Detalles |
|-----------|--------|----------|
| Doble salto | ✅ Implementado | Espacio (PC) / botón salto (mobile) en el aire |
| Correr | ✅ Implementado | Shift (PC) / botón RUN (mobile), velocidad 28 vs 16 |
| Animación pollo | ✅ Implementado | Pies, cabeza y alas animadas; se aceleran al correr |

---

## Arquitectura cliente

```
StarterPlayerScripts/
  PlayerController.client.lua   ← inicializa y conecta todos los módulos
  Modules/
    DoubleJump.lua              ← doble salto PC + mobile
    Sprint.lua                  ← sprint con Shift, expone isSprinting()
    SprintButton.lua            ← botón táctil RUN para mobile
    ChickenMovement.lua         ← animación del personaje, recibe getter de sprint
```

**Patrón:** cada módulo es una clase con `new()`, `start()`, `destroy()`. `PlayerController` los instancia, conecta dependencias y hace teardown en cada respawn.

---

## Arquitectura servidor

```
ServerScriptService/
  Main.server.lua               ← carga SetBirdCharacter
  SetBirdCharacter.lua          ← reemplaza personaje por BirdCharacter, setea atributo
  AdminCommands.lua             ← /matar [radio] — solo indevelops_games
  RoundManager.lua              ← (por construir)
  MapBuilder.lua                ← (por construir)
  LavaController.lua            ← (por construir)
```

---

## Mapa
- **Estado actual:** por construir desde cero
- **Concepto:** campo horizontal, suelo es lava, plataformas para saltar
- **Lobby:** zona separada, puerta abre al iniciar ronda
- **Obstáculos:** plataformas móviles, zonas de peligro

---

## Ronda (por construir)
- Lobby de espera → cuenta regresiva → puerta abre → ronda comienza
- Lava siempre presente (no sube, es el suelo)
- Último jugador en pie gana
- Contador de victorias por jugador

---

## Pendiente
- [ ] Mapa: lobby + campo de juego + plataformas
- [ ] RoundManager: flujo de ronda completo
- [ ] LavaController: lava como suelo permanente con efectos
- [ ] HUD: timer, victorias, indicadores
- [ ] Efectos al morir / ganar
