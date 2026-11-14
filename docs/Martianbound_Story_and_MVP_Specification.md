# MARTIANBOUND — Story & MVP Game Specification

**Document type:** Game design + MVP implementation brief  
**Project:** Martianbound  
**Version:** 1.0  
**Date:** 12 November 2026  
**Engine:** Godot 4  
**Language:** GDScript  
**Target:** Desktop first; Web export may be considered after the core game is stable  
**Visual direction:** 2D, top-down, 16-bit pixel art  
**Primary purpose:** A playable Mars astronaut mission trainer built around exploration, crew safety, resource management, scientific decisions, and a mystery-driven mission.

---

## 1. Instructions for the AI Development Agent

You are helping build **Martianbound**, a 2D top-down pixel-art Mars mission trainer. Treat this document as the current product and MVP specification.

The user will provide **five existing UI reference screens**. Those references are the visual source of truth. Study them before implementing screens or shared UI components.

### Non-negotiable reference-matching rules

1. Reproduce the supplied references as closely as possible: layout, spacing, proportions, alignment, hierarchy, typography style, colors, borders, panels, buttons, icon treatment, and pixel-art presentation.
2. Do not redesign, modernize, simplify, or replace the reference style with a generic game UI or modern web dashboard.
3. Treat the five references as one coherent design system. Extract reusable colors, typography sizes, panel styles, button states, spacing rules, icon sizes, borders, and margins, then reuse them across every new screen.
4. For the six screens without references, extend the same visual language. Do not introduce a new visual style.
5. Use pixel-art assets with consistent pixel density and scale. Avoid mixing smooth vector illustrations, realistic 3D assets, blurry images, and unrelated asset packs.
6. Preserve the visual hierarchy and functional intent of each reference. Do not add decorative UI that makes the game harder to read.
7. Build reusable scenes/components for repeated elements such as panels, buttons, resource indicators, crew cards, tabs, tooltips, dialogs, and navigation.
8. Before implementing a screen, inspect the reference and identify its major regions and interactions. After implementation, compare the result against the reference and correct mismatches.
9. Do not invent additional screens or major features outside this MVP without asking the user.
10. If a reference conflicts with a detail in this document, preserve the reference's visual design while following this document for gameplay behavior. Ask the user if the conflict changes the intended feature.

### Development workflow

- First inspect the project directory, existing assets, and all five reference images.
- Do not overwrite or delete existing user work without permission.
- Create a short implementation plan and proposed scene structure before large-scale coding.
- Implement the game in small, testable milestones.
- Keep gameplay logic separate from UI presentation.
- Use clear names, typed GDScript where practical, signals for communication, and reusable scenes.
- Run the project and fix parser/runtime errors after each milestone.
- Do not claim a feature is complete until it has been tested in the running game.
- Use placeholder assets only when a final matching asset is unavailable; keep placeholders easy to replace.
- Do not generate fake NASA data or claim that fictional game events are real mission data. The game is an educational simulation inspired by Mars science.

---

## 2. Game Overview

**Martianbound** is a single-player, 2D top-down Mars expedition simulator. The player takes responsibility for an astronaut crew sent to investigate a remote region of Mars. The player plans the expedition, selects a crew, chooses a mission duration and landing/outpost location, then manages daily operations while responding to environmental events and scientific discoveries.

The experience should feel like an astronaut mission trainer with a mystery-driven narrative—not a colony builder, city builder, or combat game.

### Core experience

- Plan a Mars expedition.
- Select a capable crew.
- Choose a mission duration and Mars outpost/operational region.
- Explore a 2D pixel-art Mars environment.
- Monitor crew condition and mission-critical resources.
- Respond to changing environmental conditions and unexpected events.
- Make science and safety decisions with trade-offs.
- Complete mission objectives and send a final report to Mission Control / NASA HQ (fictionalized in-game reporting).

### Design pillars

1. **Mission authenticity:** Resources, hazards, crew needs, and decisions should feel grounded in the challenges of a Mars expedition.
2. **Readable strategy:** The player should understand current conditions, risks, and consequences without needing to inspect complicated menus constantly.
3. **Exploration and mystery:** Discoveries should gradually reveal a larger unanswered question about the selected region.
4. **Consequential decisions:** Decisions should affect resources, crew condition, science results, mission progress, or future events.
5. **Consistent pixel-art presentation:** World, characters, environment, objects, and UI should look like they belong to the same 2D game.

---

## 3. Story

### 3.1 Premise

In the near future, a human expedition is deployed to Mars to investigate an isolated region that has produced unusual scientific readings. Previous orbital observations and remote instruments have recorded inconsistent signals beneath the surface. The readings are not enough to prove anything extraordinary, but they are unusual enough to justify a carefully planned crewed investigation.

The player leads the expedition. Their assignment is to establish a safe operational presence, investigate the region, collect reliable scientific evidence, and report findings to Mission Control.

As the crew explores, they discover patterns that do not fit the initial explanation of the region. Each discovery raises new questions. The player must decide how far to investigate while protecting the crew and preserving the mission's ability to return safely.

### 3.2 Narrative tone

- Scientific mystery, isolation, curiosity, and measured tension.
- Grounded science-fiction; avoid supernatural explanations presented as fact.
- No unnecessary action-movie tone.
- The mystery should unfold through environmental clues, research findings, logs, and mission events.
- The story must remain Mars-only. Do not introduce Moon missions or lunar locations.

### 3.3 Narrative structure for the MVP

**Act 1 — Deployment**
- The player receives the expedition briefing.
- Mission objectives, constraints, and the unexplained regional readings are introduced.
- The player selects crew members, mission duration, and an operational outpost.

**Act 2 — Surface Operations**
- The crew begins daily operations.
- The player explores nearby terrain, manages resources, performs research, and handles environmental events.
- Early clues suggest that the unusual readings may be connected to more than one location or measurement.

**Act 3 — The Anomaly**
- A significant discovery gives the player a new research lead.
- The player must choose between a conservative mission plan and a riskier investigation.
- The decision changes the mission's science outcome and resource/crew consequences.

**Act 4 — Mission Report**
- The expedition concludes when the mission duration ends, the primary objectives are completed, or the mission can no longer safely continue.
- The player reviews crew safety, resources, objectives, discoveries, and scientific results.
- A final report is prepared for Mission Control / NASA HQ.
- The report summarizes what was confirmed, what remains uncertain, and the consequences of the player's decisions.

### 3.4 Story implementation boundaries

For the MVP, implement a compact, complete story arc with:
- One primary Mars region.
- One central mystery thread.
- A small set of discoveries and mission-log entries.
- A few branching decisions with visible consequences.
- One final mission report with outcome variations.

Do not build a large branching narrative, cinematic dialogue system, or multiple planets in the MVP.

---

## 4. Player Role and Mission Setup

The player acts as the expedition commander / mission operator. The player is responsible for planning and operational decisions; the game should not require the player to control every crew member individually.

### Mission setup

The player should be able to:
- Start a new expedition.
- Read the mission briefing.
- Select a crew from the available crew roster.
- Choose a mission duration from the options presented by the game.
- Review mission constraints and starting resources.
- Select the available Mars outpost/operational region.
- Review the mission plan before deployment.

### Crew

Crew members should have:
- Name and pixel-art portrait/sprite.
- Mission role or specialization.
- Short background/description.
- A small set of gameplay-relevant attributes or strengths.
- A current condition/status during the mission.

Keep crew selection understandable. Crew attributes must have meaningful effects in gameplay; do not add decorative statistics that do nothing.

Suggested role categories (final names can follow the supplied UI reference):
- Commander / mission leadership
- Engineering / systems maintenance
- Science / geology and research
- Medical / crew health

The MVP may use a small fixed roster. A complex recruitment or staffing system is out of scope.

---

## 5. MVP Feature Scope

The MVP must deliver one complete, playable expedition loop from the main menu to a mission report.

### 5.1 Must-have features

#### A. Main Menu
- New Mission.
- Continue, only when a valid saved mission exists.
- Settings.
- Credits.
- Clear game title and visual identity consistent with the reference.

#### B. Mission Briefing
- Mission title and short story setup.
- Primary mission objective.
- Secondary objectives, if applicable.
- Mission duration or duration selection entry point.
- Region/mission information.
- Clear action to continue to crew selection/planning.

#### C. Crew Selection
- Display available crew members.
- Show portrait, name, role, short background, and relevant attributes.
- Allow the player to select the required crew composition.
- Clearly show selected crew.
- Prevent starting the mission if required crew selection rules are not met.

#### D. Mission Planner
- Show the selected mission configuration.
- Show duration, objectives, starting conditions, and relevant constraints.
- Allow the player to review or confirm the plan.
- Do not add complex scheduling or a spreadsheet-like planning system.

#### E. Outpost / Region Selection
- Display the available Mars operational region(s).
- Show useful information such as terrain, environmental risk, scientific interest, and resource considerations.
- The MVP needs only one fully playable region; additional locations can be locked or marked unavailable.
- Confirm the selected region before deployment.

#### F. Main Simulation HUD
This is the most important gameplay screen.

It must include:
- A playable 2D top-down pixel-art Mars environment.
- The player/crew presence in the world.
- Terrain and environmental objects appropriate to the selected region.
- Top-level resource telemetry for Oxygen, Water, Food, Energy, and Habitat condition.
- Current Sol/day and mission time.
- Weather/environment status, including dust-storm conditions where relevant.
- Radiation status.
- Crew status summary.
- Current mission objectives.
- Contextual interaction prompts for nearby usable objects or points of interest.
- A minimap or compact area map if it fits the supplied reference design.
- Alerts for important resource, crew, and environmental conditions.
- A bottom or side navigation/action dock consistent with the existing HUD reference.

Suggested HUD navigation categories:
- Explore
- Crew
- Equipment
- Research
- Mission Log

The world view must remain the visual focus. UI panels should not cover so much of the screen that exploration becomes difficult.

#### G. Exploration and Interaction
- Allow the player to move around a compact 2D Mars map using keyboard controls.
- Support collision with world geometry.
- Allow interaction with selected objects/points of interest.
- Interactions may reveal information, collect samples, use equipment, or trigger an event.
- Use clear interaction feedback.
- Keep the MVP map compact and purposeful; do not attempt a huge open world.

#### H. Resource Management
Track these mission resources/conditions:
- Oxygen
- Water
- Food
- Energy
- Habitat condition
- Radiation exposure/risk

Requirements:
- Resources must have clear current values and understandable status indicators.
- Time progression should affect relevant resources in a controlled, predictable way.
- Specific actions/events may consume or restore resources.
- Critical thresholds should trigger clear warnings and meaningful consequences.
- Avoid arbitrary resource loss that the player cannot understand or respond to.

#### I. Crew Condition
- Track each selected crew member's condition.
- Use a small, readable condition model for the MVP (for example: health/medical condition, fatigue, and morale only if each is used meaningfully).
- Environmental hazards and player decisions can affect crew condition.
- Crew condition should influence mission performance or available choices where appropriate.
- Communicate risks clearly and avoid hidden punishment.

#### J. Events and Decisions
- Show event popups for significant environmental, equipment, crew, or scientific events.
- Each event should provide context and a small number of meaningful choices.
- Explain likely trade-offs before the player confirms a decision.
- Apply the selected outcome to game state.
- Include a limited set of authored events for the MVP; do not build a general-purpose procedural narrative engine.

Example event categories:
- Dust storm warning.
- Equipment malfunction.
- Unexpected terrain or geological finding.
- Resource shortage.
- Crew fatigue or medical concern.
- Unusual scientific reading.

#### K. Research and Discoveries
- Allow the player to investigate selected points of interest.
- Record discoveries in a research log.
- Give discoveries a clear relationship to the central mystery.
- Award science progress or mission evidence when appropriate.
- Do not present fictional discoveries as real NASA findings.

#### L. Mission Objectives
- Show primary and secondary objectives.
- Track objective status: not started, in progress, completed, or failed.
- Update objective progress after relevant actions and events.
- Make the next useful action clear to the player.

#### M. Mission Log
- Record important events, decisions, discoveries, and objective updates.
- Display entries in chronological order.
- Keep entries concise and readable.

#### N. Mission Report
At mission end, show:
- Mission outcome/status.
- Crew condition summary.
- Remaining resources and habitat condition.
- Objectives completed/failed.
- Scientific discoveries and evidence collected.
- Important decisions and their consequences.
- A concise narrative summary.
- A final report submission/return-to-menu action.

#### O. Settings and Pause
- Pause/resume.
- Audio volume controls if audio is implemented.
- Display options appropriate to the target platform.
- Return to main menu with confirmation.
- Save/resume behavior appropriate to the current mission state.

#### P. Save and Continue
- Save the current expedition state locally.
- Continue a valid saved expedition from the main menu.
- Save mission setup, current Sol/time, player/world position, resources, crew condition, objective progress, discoveries, event state, and mission log.
- Handle missing or invalid save data safely.
- No online account or backend is required for the MVP.

### 5.2 Explicitly out of scope

Do **not** implement these in the MVP:
- Colony building or base construction.
- Workforce/employee management.
- Building upgrades or technology-tree base upgrades.
- Combat, weapons, enemies, or zombie mechanics.
- Multiplayer or online co-op.
- Online accounts, authentication, cloud saves, or backend services.
- Multiple planets or Moon content.
- A huge open world.
- Complex crafting, farming, or economy systems.
- Large procedural story generation.
- Real-time NASA mission control integration.
- Complex vehicle driving or flight simulation.
- A full cinematic cutscene system.

---

## 6. Full Screen Inventory and Reference Plan

The complete planned UI contains 11 screens. Five screens already have user-created visual references. The other six must be designed by extending the same visual system.

| # | Screen | Reference status | Main responsibility |
|---|---|---|---|
| 1 | Main Menu | Existing reference | Start/continue mission, settings, credits |
| 2 | Mission Briefing | Existing reference | Introduce mission, objectives, constraints |
| 3 | Crew Selection | Existing reference | Select the expedition crew |
| 4 | Mission Planner | Existing reference | Review and confirm mission configuration |
| 5 | Outpost Selection | Existing reference | Choose Mars operational region |
| 6 | Main Simulation HUD | No reference yet / implement from project direction | Main playable world and mission telemetry |
| 7 | Event & Decision Popup | No reference yet | Present events and player choices |
| 8 | Crew & Resource Dashboard | No reference yet | Inspect crew condition and mission resources |
| 9 | Mission Objectives | No reference yet | Track primary and secondary objectives |
| 10 | Mission Report | No reference yet | Summarize expedition outcome |
| 11 | Settings & Pause | No reference yet | Pause, configure, save, and exit |

### Navigation flow

Main Menu  
→ Mission Briefing  
→ Crew Selection  
→ Mission Planner  
→ Outpost Selection  
→ Main Simulation HUD

During the simulation, the player can open:
- Event & Decision Popup when an event is triggered.
- Crew & Resource Dashboard.
- Mission Objectives.
- Mission Log / Research views through the HUD navigation.

The simulation ends when the mission duration is reached, the main objectives are resolved, or a mission-ending condition occurs.  
→ Mission Report  
→ Main Menu

Settings & Pause can be opened from appropriate screens, especially the simulation.

---

## 7. Gameplay Loop

### 7.1 Main loop

1. Review the mission briefing.
2. Select the crew.
3. Confirm the mission plan and duration.
4. Select the Mars region/outpost.
5. Deploy to the surface.
6. Explore and interact with points of interest.
7. Monitor resources, crew condition, and environmental conditions.
8. Respond to events and make decisions.
9. Complete objectives and collect scientific evidence.
10. Finish the expedition and review the mission report.

### 7.2 Time progression

- Use a clear in-game time unit such as Sol (a Martian day).
- Time should advance through deliberate player actions or defined simulation steps, not unpredictably while the player reads menus.
- The player must be able to understand when and why resource consumption occurs.
- Events should be triggered by authored conditions, mission progress, or controlled random selection.
- Keep the first playable version deterministic enough to test and balance.

### 7.3 Win, partial success, and failure

The MVP should support multiple understandable outcomes:
- **Successful mission:** Main objectives achieved and crew/missions systems remain within acceptable limits.
- **Partial success:** Some objectives or discoveries achieved, but the mission ends early or important goals remain incomplete.
- **Unsuccessful mission:** Critical mission conditions prevent safe continuation or the primary mission cannot be completed.

Do not make failure depend on an unexplained random event. Explain the reason in the mission report.

---

## 8. Pixel-Art and UI Art Direction

### World presentation
- 2D top-down perspective.
- 16-bit-inspired pixel-art presentation.
- Mars terrain should use a coherent palette and tile scale.
- Use readable silhouettes for astronauts, equipment, structures, rocks, and points of interest.
- Use consistent sprite scale, pixel density, outline treatment, and animation style.
- Keep movement and interaction readable at the game's chosen resolution.

### UI presentation
The five supplied reference screens define the UI style. The agent must inspect them and extract a small design system before building additional screens.

Record:
- Base/background colors.
- Panel and card colors.
- Accent colors and warning colors.
- Font family/style and text hierarchy.
- Border thickness and corner treatment.
- Button dimensions and states.
- Spacing scale and screen margins.
- Icon style and pixel scale.
- Modal/dialog treatment.
- Navigation and selected-state treatment.

### Pixel-art quality rules
- Use nearest-neighbor texture filtering for pixel-art assets.
- Avoid unintended texture smoothing or fractional scaling that makes pixel edges blurry.
- Prefer integer scaling where practical.
- Keep UI text crisp and legible.
- Do not stretch sprites non-uniformly.
- Use consistent tile dimensions within a tileset.
- Keep collision shapes aligned with gameplay geometry, not decorative pixels.

---

## 9. Technical Direction

### Recommended project structure

Use a modular Godot 4 project. Adjust names to match the existing project if one already exists; do not duplicate systems unnecessarily.

```text
res://
├── assets/
│   ├── characters/
│   ├── environment/
│   ├── tilesets/
│   ├── props/
│   ├── ui/
│   ├── icons/
│   ├── portraits/
│   ├── audio/
│   └── fonts/
├── scenes/
│   ├── main/
│   ├── screens/
│   ├── simulation/
│   ├── world/
│   ├── events/
│   └── components/
├── scripts/
│   ├── autoload/
│   ├── data/
│   ├── systems/
│   ├── managers/
│   └── ui/
├── data/
│   ├── crew/
│   ├── missions/
│   ├── events/
│   ├── objectives/
│   └── discoveries/
├── resources/
└── project.godot
```

### Suggested core systems

- **GameState:** Current screen, mission phase, selected mission setup, and global game state.
- **MissionManager:** Starts, updates, and ends an expedition.
- **CrewManager:** Selected crew and crew condition.
- **ResourceManager:** Resource values, consumption, thresholds, and alerts.
- **TimeManager:** Sol/time progression.
- **EventManager:** Event conditions, event presentation, and decision outcomes.
- **ObjectiveManager:** Objective state and progress.
- **ResearchManager:** Discoveries and research log.
- **SaveManager:** Local save/load and validation.
- **Scene/UI navigation:** Screen transitions and modal handling.

Use autoload singletons only for genuinely global state/services. Avoid placing all gameplay logic in one large script.

### Data-driven content

Where practical, store crew, mission, event, objective, and discovery definitions as Godot Resources or structured local data. Keep content separate from UI code so new authored content can be added without rewriting core systems.

### Input

- Keyboard movement for the initial desktop build.
- Interact key for nearby objects.
- Escape for pause/back behavior where appropriate.
- Keep input actions configurable through Godot's Input Map.
- Do not hardcode movement or interaction into UI scripts.

### Resolution and scaling

- Choose a consistent internal resolution after inspecting the supplied references.
- Use Godot's appropriate 2D stretch/scaling settings.
- Test the UI at the intended aspect ratio and at common desktop window sizes.
- Avoid layout breakage, blurry pixel art, and clipped text.

---
