# Mission MartianBound

**Mission MartianBound** is a Mars outpost survival and expedition management simulator developed in **Godot Engine 4** (with an interactive web prototype included). Players take command of an Ares habitat on Mars (Jezero Crater), managing life support, resource budgets, critical random events, and crew health across mission sols.

---

## 🚀 Overview

In **Mission MartianBound**, players act as mission commander responsible for sustaining a Mars surface habitat:
- **Resource Management**: Monitor and balance critical supplies including Power, Water, Oxygen, and Food.
- **Crew Health & Safety**: Protect astronauts against Martian hazards such as radiation, dust storms, equipment degradation, and environmental threats.
- **Event Engine & Decisions**: Respond to dynamic scenario events with strategic choices that impact mission sustainability and resources.
- **Mission Scoring**: Evaluates resource conservation, crew survival, and mission objectives upon completion.

---

## 🛠 Project Structure

```text
mission-martian-bound/
├── scenes/
│   ├── ui/                   # Godot UI screens (Home, Briefing, Planner, Simulation, Events, Reports)
│   ├── components/           # Reusable UI widgets and elements
│   └── main/                 # Core scene definitions
├── scripts/
│   ├── autoload/             # Global Singletons (MissionSession, NavigationCoordinator)
│   ├── domain/               # Core business logic (MissionState, SimulationEngine, EventEngine, Scoring)
│   ├── data/                 # Data containers (ScenarioData, EventData, DecisionData)
│   └── services/             # Persistence & state management services
├── prototype/                # Web-based prototype (HTML5 / JS / CSS)
├── project.godot             # Godot 4 project configuration file
└── icon.svg                  # Application icon
```

---

## 🎮 Getting Started

### Prerequisites

- [Godot Engine 4.x](https://godotengine.org/download) (Forward+ / Jolt Physics support recommended)

### Running in Godot

1. Clone or download this repository.
2. Open the **Godot Project Manager**.
3. Click **Import** and browse to the repository folder containing `project.godot`.
4. Click **Import & Edit**.
5. Press **F5** (or click the **Play** button in the top right) to launch the project.

### Running the Web Prototype

The repository includes a standalone web prototype in `prototype/`:
1. Navigate to the `prototype/` directory.
2. Open `index.html` directly in any modern web browser, or serve it via a local static HTTP server (e.g., `python3 -m http.server`).

---

## ⚙️ Architecture & Core Systems

- **`MissionSession` (Autoload)**: Central coordinator orchestrating mission lifecycle, state transitions, scenario bootstrapping, and persistence.
- **`NavigationCoordinator` (Autoload)**: Manages UI transitions across screens (Home → Briefing → Planner → Simulation → Events → Reports).
- **`MissionState`**: Stores live telemetry including crew health, resource reserves (Power, Water, O₂, Food), radiation shielding, and win/loss states.
- **`SimulationEngine` & `EventEngine`**: Handles step-by-step simulation ticks, event triggers, and decision consequence resolution.
- **`Scoring`**: Calculates performance metrics based on habitat condition, survival duration, and resource efficiency.

---

## 📜 License

This project is licensed under the terms specified in the repository or applicable open-source license.
