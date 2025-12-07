# Feature Specification: Lava Birds Core Loop

**Feature Branch**: `001-lava-birds-core`  
**Created**: 2025-11-29  
**Status**: Draft  
**Input**: User description: "Juego 'el piso es lava' con aves inspirado en Lava Chicken; rondas cortas con lava ascendente, planeo y perchas."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sobrevive a la lava (Priority: P1)
Como jugador ave, debo sobrevivir una ronda de 60–180 s manteniéndome fuera de la lava mientras sube en oleadas.

**Why this priority**: Es el loop central; sin supervivencia y lava ascendente no hay juego.

**Independent Test**: Iniciar una ronda local con 1 jugador; la lava sube y el jugador puede ganar o perder según contacto con lava.

**Acceptance Scenarios**:
1. **Given** una ronda nueva y el jugador en spawn, **When** la lava inicia y sube, **Then** tocar la lava elimina/penaliza y reaparece en spawn.
2. **Given** el temporizador de ronda corre, **When** llega a 0 con el jugador vivo, **Then** el jugador gana la ronda y recibe recompensa básica.

---

### User Story 2 - Movilidad de ave (Priority: P2)
Como jugador, puedo usar un doble salto/planeo breve para reposicionarme en perchas y evitar la lava.

**Why this priority**: Diferencia el juego de un obby normal y habilita atajos/riesgo.

**Independent Test**: En mapa de prueba, activar doble salto 1 vez en el aire con cooldown; la gravedad se reduce durante planeo por corto tiempo.

**Acceptance Scenarios**:
1. **Given** el jugador está en el aire tras un salto, **When** pulsa saltar de nuevo, **Then** se activa planeo (velocidad de caída reducida) con cooldown visible.
2. **Given** el cooldown no ha terminado, **When** intenta saltar de nuevo en el aire, **Then** no se activa el planeo y se muestra feedback (sonido o texto).

---

### User Story 3 - Riesgo/recompensa y power-ups (Priority: P3)
Como jugador, puedo recoger power-ups y ganar monedas por sobrevivir más cerca de la lava para comprar cosméticos.

**Why this priority**: Incentiva rejugabilidad y progreso ligero.

**Independent Test**: Un power-up spawnea, otorga efecto temporal; al final de ronda se entregan monedas según tiempo y cercanía a lava.

**Acceptance Scenarios**:
1. **Given** aparece un power-up en el mapa, **When** el jugador lo toca, **Then** obtiene el efecto (ej. resistencia a lava por 5 s) y desaparece del mapa.
2. **Given** termina la ronda, **When** se calculan recompensas, **Then** el jugador recibe monedas y éstas se muestran en HUD y se acumulan en servidor.

---

### Edge Cases
- ¿Qué pasa si la lava sobrepasa el spawn? → Forzar respawn seguro y ajustar altura base al reiniciar ronda.
- ¿Cómo se maneja desconexión en medio de ronda? → Remover del round state sin afectar a otros.
- ¿Qué ocurre si dos power-ups se recogen al mismo tiempo? → Aplicar uno y poner cooldown de respawn para evitar stacking no deseado.
- ¿Qué pasa si un jugador entra a mitad de ronda? → Debe quedar en un lobby seguro y unirse solo al iniciar la siguiente ronda tras el countdown.

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: El servidor inicia y reinicia rondas de 60–180 s con temporizador visible para el cliente.
- **FR-002**: La lava sube en al menos 2 fases (ej. lenta, luego rápida) y toca-elimina/penaliza al jugador.
- **FR-003**: El movimiento de ave permite un doble salto/planeo por ronda de salto con cooldown configurado en servidor.
- **FR-004**: Power-ups spawnean en ubicaciones predefinidas, tienen duración y respawn configurables desde servidor.
- **FR-005**: El servidor calcula monedas/puntos por supervivencia y cercanía a la lava; el cliente solo muestra.
- **FR-006**: El HUD muestra tiempo restante, altura/estado de lava y monedas actuales; es legible en español.
- **FR-007**: Soporta prueba local en Studio con Start Server (2+ jugadores) sin dependencias externas.
- **FR-008**: Jugadores que se unen a mitad de ronda permanecen en un lobby seguro y solo ingresan al área de juego al iniciar la siguiente ronda (ven el countdown).

### Key Entities *(include if feature involves data)*
- **RoundState**: temporizador, fase de lava, jugadores vivos, spawn points.
- **PlayerState**: monedas, cooldown de planeo, estado (vivo/eliminado), rewards pendientes.
- **Hazard (Lava)**: altura actual, velocidad por fase, daño/efecto.
- **PowerUp**: tipo, duración, posición, estado (activo/consumido), cooldown de respawn.

## Success Criteria *(mandatory)*

### Measurable Outcomes
- **SC-001**: Un jugador solo puede ganar si el temporizador llega a 0 sin tocar la lava (verificable en 3 rondas consecutivas).
- **SC-002**: Doble salto/planeo respeta cooldown 100% de las veces en pruebas locales (sin activarse dos veces por salto).
- **SC-003**: Power-ups aplican y expiran en el tiempo configurado con variación < 0.25 s.
- **SC-004**: HUD permanece legible y actualizado (< 0.2 s de retraso perceptible) durante pruebas con 4 jugadores locales.
