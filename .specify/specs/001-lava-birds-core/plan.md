# Implementation Plan: Lava Birds Core Loop

**Branch**: `001-lava-birds-core` | **Date**: 2025-11-29 | **Spec**: `.specify/specs/001-lava-birds-core/spec.md`  
**Input**: Feature specification from `/specs/001-lava-birds-core/spec.md`

## Summary

Construir el loop base “el piso es lava” con aves: rondas de 60–180 s, lava ascendente en fases, eliminación/respawn al tocar lava, movimiento especial de ave (doble salto/planeo), HUD simple (tiempo, lava, monedas). Servidor autoritativo para daño/puntos; cliente solo muestra y maneja input/FX. Sin servicios externos.

## Technical Context

**Language/Version**: Luau (Roblox)  
**Primary Dependencies**: Roblox services (`Players`, `RunService`, `TweenService`, `CollectionService`, `ReplicatedStorage` remotes), Rojo para sync código  
**Storage**: DataStore solo para stats esenciales (monedas), con fallbacks; no requerido para prototipo inicial  
**Testing**: Play/Start Server en Studio (2–4 jugadores locales); asserts ligeros en módulos críticos  
**Target Platform**: Roblox (PC y móvil); StreamingEnabled opcional si el mapa crece  
**Project Type**: Single experience con scripts compartidos via Rojo  
**Performance Goals**: 60 fps en PC/móvil; part count bajo; sin loops sin `task.wait()`  
**Constraints**: Servidor autoritativo para daño/puntos; remotes filtrados con límites/cooldowns; HUD legible en español  
**Scale/Scope**: Prototipo de ronda corta con 3 historias P1–P3

## Constitution Check

- P1 Diversión/loop corto: ronda 60–180 s, TtF < 30 s. ✅  
- P2 Autoridad servidor: lava/daño/puntos en server; remotes validados. ✅  
- P3 Rendimiento: evitar bucles sin `task.wait()`, part count bajo. ✅  
- P4 Playtest rápido: probar en Start Server con 2+ jugadores por cambio. ✅  
- P5 UX clara: HUD con tiempo/lava/monedas en español. ✅

## Project Structure

### Documentation (this feature)

```text
specs/001-lava-birds-core/
├── spec.md
├── plan.md              # este archivo
├── research.md          # futuro: notas técnicas si se requieren
├── data-model.md        # futuro: definiciones de RoundState/PlayerState
├── quickstart.md        # futuro: guía rápida de prueba en Studio
├── contracts/           # futuro: remotes/events si se formaliza
└── tasks.md             # saldrá de /speckit.tasks
```

### Source Code (repository root)

```text
default.project.json
src/
├── ReplicatedStorage/
│   └── Shared/           # módulos compartidos, remotes, constantes
├── ServerScriptService/  # lógica de rondas, lava, rewards
└── StarterPlayer/
    ├── StarterPlayerScripts/      # HUD, input de planeo
    └── StarterCharacterScripts/   # ajustes de personaje si aplica
assets/                   # opcional: fuentes de imagen/sonido con sus assetIds
```

**Structure Decision**: Single-experience con carpetas Rojo mapeadas a servicios de Roblox; código compartido en `ReplicatedStorage/Shared`.

## Complexity Tracking

N/A (plan sigue la constitución sin violaciones adicionales).
