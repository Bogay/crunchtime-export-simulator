# Game Jam Deadline Export Simulator (Godot)

## Project Overview
A satirical clicker game simulating the stress of the final hours of a Game Jam. Players click to "export" projects, earn "Player Feedback" (currency), and buy upgrades to eventually unlock full CI/CD automation.

### Core Technologies
- **Engine:** Godot 4.6 (Compatible with GL Compatibility renderer)
- **Physics:** Jolt Physics (configured in project settings)
- **Architecture:** Signal-based Decoupled Logic (GameManager) and UI (UIController).
- **Target Platform:** Web (configured in `export_presets.cfg`)

## Building and Running

### Prerequisites
- Godot Engine (Version 4.6 recommended based on `project.godot`).

### Running the Project
- **Editor:** Open `project.godot` in the Godot Editor and press F5 (or the Play button).
- **CLI:** `godot --main-scene res://scenes/Main.tscn`

### Exporting (Web)
To export the game for the web as configured:
```bash
mkdir -p dist
godot --headless --export-release "Web" dist/index.html
```

### Running Tests
Currently, the project uses a custom lightweight testing script in `tests/test_game_manager.gd`.
To run these tests (manual approach):
1. Instance the `test_game_manager.gd` node in a temporary scene.
2. Observe the console output for `PASS` or `FAIL` messages.

*TODO: Integrate a formal testing framework like GUT (Godot Unit Test) as suggested in SPEC.md.*

## Project Structure
- `res://scenes/Main.tscn`: The primary (and only) UI scene.
- `res://scripts/GameManager.gd`: Handles core game logic, state, and upgrade calculations. Pure logic, independent of UI.
- `res://scripts/UIController.gd`: Manages UI updates and user input by connecting to signals from `GameManager`.
- `res://tests/test_game_manager.gd`: Unit tests for `GameManager` logic.
- `export_presets.cfg`: Configuration for web builds.
- `SPEC.md`: Original game design and technical specification.

## Development Conventions

### Coding Style
- **Decoupling:** Keep logic in `GameManager` and UI in `UIController`. `GameManager` should not reference UI nodes directly.
- **Signals:** Use signals (`state_changed`, `export_started`, `export_finished`) for downward communication (Logic -> UI). Use direct function calls for upward communication (UI -> Logic).
- **Upgrade Costs:** Use the formula `cost = base_cost * (1.5 ^ level)` for exponential scaling.

### Testing Practices
- Logic changes in `GameManager.gd` should be accompanied by updates to `tests/test_game_manager.gd`.
- Always verify the "Auto-mode" (CI/CD) logic, as it modifies several core metrics (`fail_chance` to 0, `export_cooldown` to 0.2).

### UI Layout
- Use `Control` nodes with `VBoxContainer` for layout.
- The UI should remain responsive and "flat" as per `SPEC.md`.
