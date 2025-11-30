# Lava Birds Constitution

## Core Principles

### P1. Diversión primero, sesiones cortas
Rondas claras de 60–180 s con tiempo-a-diversión < 30 s. Cada cambio debe proteger el loop central: subir lava, movilidad de aves y perchas con riesgo/recompensa.

### P2. Autoridad de servidor y equidad
El servidor decide daño, puntuación y progresión. Todo dato que afecta estado se valida en `ServerScriptService`. Los remotes se filtran con límites y cooldowns.

### P3. Simplicidad y rendimiento en Roblox
Part count bajo; sin `while true do` sin `task.wait()`. Usa `CollectionService` para hazards/power-ups y streaming habilitado si el mapa crece. Evitar dependencias externas.

### P4. Pruebas y playtest rápido
Cada cambio debe probarse en Studio (Play y Start Server con 2+ jugadores locales). Para módulos clave, añade asserts ligeros o escenarios reproducibles.

### P5. UX clara y accesible
UI legible (fuentes y contraste), mensajes cortos en español. Indicadores de ronda, altura de lava y estado del jugador visibles sin estorbar el juego.

## Restricciones y lineamientos
- Plataforma: Roblox Studio + Rojo; lenguaje Luau. Datos persistentes limitados a stats esenciales vía DataStore (con manejo de fallos).
- Seguridad: ningún cálculo final en cliente para monedas/puntos/vida. Usa `RemoteEvent`/`RemoteFunction` con parámetros acotados.
- Arte/sonido: assets subidos a Roblox; guarda fuentes en `assets/` y referencia por `assetId`.

## Flujo de trabajo y calidad
- Especificar antes de construir: seguir `/speckit.constitution` → `/speckit.specify` → `/speckit.plan` → `/speckit.tasks` → `/speckit.implement`.
- Branching/tareas: nombrar ramas `###-nombre-corto`; cada historia debe ser demostrable de forma independiente.
- Revisiones: ningún merge sin validación en Studio y sin que los criterios de aceptación estén satisfechos; evita over-engineering fuera del plan.

## Governance
La constitución manda sobre decisiones técnicas. Cambios requieren actualizar este documento, explicar impacto en gameplay/seguridad y fecha de enmienda.

**Version**: 1.0.0 | **Ratified**: 2025-11-29 | **Last Amended**: 2025-11-29
