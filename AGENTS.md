# CrunchTime: The Export Simulator (Godot)

## Project Overview
A satirical clicker game simulating the stress of the final hours of a Game Jam. Players click to "export" projects, earn "Player Feedback" (currency), and buy upgrades to eventually unlock full CI/CD automation.

### Core Technologies
- **Engine:** Godot 4.6 (Compatible with GL Compatibility renderer)
- **Physics:** Jolt Physics (configured in project settings)
- **Architecture:** Signal-based Decoupled Logic (GameManager) and UI (UIController).
- **Target Platform:** Web (configured in `export_presets.cfg`)
- **CI/CD:** GitHub Actions using `chickensoft-games/setup-godot` and `gdscript-formatter`.

## Building and Running

### Prerequisites
- Godot Engine 4.6
- [just](https://github.com/casey/just) (command runner)
- [gdscript-formatter](https://github.com/GDQuest/GDScript-formatter) (for linting/formatting)

### Key Commands (via `justfile`)
- `just run`: Run the game.
- `just test`: Run all GUT unit tests (headless).
- `just lint`: Lint scripts and tests using `gdscript-formatter`.
- `just format`: Auto-format scripts and tests.
- `just build`: Export the game for Web to the `dist/` directory.

### Manual CLI
- **Run:** `godot --main-scene res://scenes/Main.tscn`
- **Test:** `godot --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/ -ginclude_subdirs -gexit`

## Project Structure
- `res://addons/gut/`: The GUT plugin for unit testing.
- `res://scenes/Main.tscn`: The primary (and only) UI scene.
- `res://scripts/GameManager.gd`: Handles core game logic, state, and upgrade calculations.
- `res://scripts/UIController.gd`: Manages UI updates and user input.
- `res://tests/test_game_manager_gut.gd`: GUT unit tests for `GameManager` logic.
- `res://.github/workflows/ci.yml`: GitHub Actions configuration for automated testing and linting.
- `justfile`: Task runner configuration.

## Development Conventions

### Coding Style
- **Formatter:** Strictly use [GDQuest/GDScript-formatter](https://github.com/GDQuest/GDScript-formatter).
- **Decoupling:** Keep logic in `GameManager` and UI in `UIController`.
- **Signals:** Use signals for downward communication (Logic -> UI).

### Mandatory Pre-Commit Checks
Before committing and pushing any changes, agents **MUST** run the following commands and ensure they pass:
1. `just format`: To ensure all code follows the style guide.
2. `just lint`: To verify no linting rules are broken.
3. `just test`: To ensure all unit tests pass and no regressions are introduced.

### Testing Practices
- All game logic should be testable without the SceneTree where possible.
- New features must include GUT tests in the `res://tests/` directory.
- CI will fail if formatting/linting rules are violated or tests fail.
