# Godot Project Justfile

set shell := ["bash", "-c"]

godot := "flatpak run org.godotengine.Godot"
dist_dir := "dist"

# Default action: run the game
default: run

# Run the game
run:
    {{godot}} --main-scene res://scenes/Main.tscn

# Run the game in headless mode
run-headless:
    {{godot}} --headless --main-scene res://scenes/Main.tscn

# Run all GUT unit tests
test:
    {{godot}} --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/ -ginclude_subdirs -gexit

# Lint scripts and tests
lint:
    gdscript-formatter lint $(find scripts/ tests/ -name "*.gd")

# Format scripts and tests
format:
    gdscript-formatter $(find scripts/ tests/ -name "*.gd")

# Format check (useful for CI)
format-check:
    gdscript-formatter --check $(find scripts/ tests/ -name "*.gd")

# Export the game for Web
build: clean
    mkdir -p {{dist_dir}}
    {{godot}} --headless --export-release "Web" {{dist_dir}}/index.html

# Remove build artifacts
clean:
    rm -rf {{dist_dir}}

# Open the project in the Godot editor
edit:
    {{godot}} -e
