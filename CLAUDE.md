# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Space Invaders clone built with **Godot 4.6** using **GDScript**. The game is 2D and uses Godot's default physics engine.

## Running the Game

Open the project in the Godot editor and press F5, or run from CLI:

```bash
godot --path /home/gustavo/src/space-invaders
```

To run headless (e.g., for testing):

```bash
godot --headless --path /home/gustavo/src/space-invaders
```

## Project Configuration

- `project.godot` — engine settings (renderer, physics, app name, main scene)
- `.editorconfig` — UTF-8 encoding enforced for all files
- `.gitignore` — ignores `.godot/` (generated cache) and `/android/`

## Architecture Notes

- **Language**: GDScript — all scripts should use `.gd` files
- **Physics**: Godot's default 2D physics engine — use `PhysicsBody2D`, `Area2D`, etc.
- **Renderer**: Use the Compatibility renderer (best suited for 2D) — update in project settings if not already set
- **Scene structure**: Not yet established — create scenes as `.tscn` files with paired `.gd` scripts following Godot node conventions
