# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Rules

- Always implement unit tests for code that makes sense to test in this way.
- Keep `README.md` updated whenever new functionality is added or design decisions change.
- After completing a feature, mark it done in `docs/plan.md`.

## Project Overview

Space Invaders clone built with **Godot 4.6** using **GDScript**. 2D, GL Compatibility renderer, 800×600 viewport.

## Godot Executable

```bash
/home/bin/godot/Godot_v4.6.1-stable_mono_linux.x86_64
```

(`/home/bin/godot` is a directory, not a symlink.)

## Running the Game

```bash
# Interactive (opens window)
/home/bin/godot/Godot_v4.6.1-stable_mono_linux.x86_64 --path /home/gustavo/src/space-invaders

# Headless (no window, useful for syntax checks)
/home/bin/godot/Godot_v4.6.1-stable_mono_linux.x86_64 --headless --path /home/gustavo/src/space-invaders
```

## Running Tests

Tests use **GUT 9.6.0** (installed in `addons/gut/`, configured in `.gutconfig.json`).

```bash
# Run all tests (headless, with JUnit XML output)
/home/bin/godot/Godot_v4.6.1-stable_mono_linux.x86_64 --headless \
  -s addons/gut/gut_cmdln.gd \
  -gdir=res://tests \
  -ginclude_subdirs \
  -gjunit_xml_file=res://test_results.xml \
  -gexit

# Run a single test script
/home/bin/godot/Godot_v4.6.1-stable_mono_linux.x86_64 --headless \
  -s addons/gut/gut_cmdln.gd \
  -gtest=res://tests/unit/test_alien.gd \
  -gexit
```

Test files live in `tests/unit/` and `tests/integration/`. Each file extends `GutTest`; test methods are prefixed `test_`.

**GDScript gotcha in tests**: accessing elements of an untyped `Array` (like `formation.aliens[i]`) requires `var x = arr[i]` (not `:=`) to avoid parse errors. Helper functions that return scene instances should omit the return-type annotation so callers can access script-defined properties dynamically.

**Group ownership**: `"alien"` group is added by `alien_formation.gd`, not `alien.gd`. Tests that instantiate aliens standalone must call `alien.add_to_group("alien")` manually.

## Architecture

### Scene / Script Map

| Scene | Root | Script | Role |
|---|---|---|---|
| `title_screen.tscn` | Control | `title_screen.gd` | Entry point — logo + menu (New Game / Options stub / Exit) |
| `main.tscn` | Node2D | `main.gd` | Game controller — owns all other nodes, handles input, score, lives, wave |
| `player.tscn` | CharacterBody2D | `player.gd` | Player ship — movement, shooting, hit/respawn |
| `alien.tscn` | Area2D | `alien.gd` | Single alien — type, points, 2-frame animation |
| `alien_formation.tscn` | Node2D | `alien_formation.gd` | 5×11 grid — step movement, shooting, speed scaling |
| `player_bullet.tscn` | Area2D | `player_bullet.gd` | Player projectile — moves up, destroys aliens/shields/UFO |
| `enemy_bullet.tscn` | Area2D | `enemy_bullet.gd` | Enemy projectile — moves down, destroys player/shields |
| `shield.tscn` | Node2D | `shield.gd` | Bunker — builds 8×4 grid of `Area2D` segments at runtime |
| `ufo.tscn` | Area2D | `ufo.gd` | Bonus UFO — flies across top, awards random points |
| `hud.tscn` | CanvasLayer | `hud.gd` | Score, hi-score, lives, game-over panel, pause panel |

### Signal Flow

Game objects emit signals upward; `main.gd` is the single aggregator:
- `player.player_hit` → `main._on_player_hit()`
- `alien_formation.alien_killed(pts)` → `main._on_alien_killed(pts)`
- `alien_formation.formation_cleared` → `main._on_formation_cleared()`
- `alien_formation.aliens_reached_bottom` → `main._on_aliens_reached_bottom()`
- `ufo.ufo_destroyed(pts)` → `main._on_ufo_destroyed(pts)`
- `ufo_timer.timeout` → `main._on_ufo_timer_timeout()`

Bullets call methods directly on what they hit (`area.kill()`, `body.hit()`, `area.queue_free()`).

### Collision Layers

| Layer | Bit | Node |
|---|---|---|
| 1 — player | 1 | Player (CharacterBody2D) |
| 2 — aliens | 2 | Alien (Area2D) |
| 3 — player_bullet | 4 | PlayerBullet (Area2D) |
| 4 — enemy_bullet | 8 | EnemyBullet (Area2D) |
| 5 — shields | 16 | Shield segments (Area2D, built at runtime) |
| 6 — ufo | 32 | UFO (Area2D) |
| 7 — boundary | 64 | Boundary (Area2D, built at runtime) |

- **PlayerBullet** mask = 114 (aliens + shields + ufo + boundary)
- **EnemyBullet** mask = 81 (player + shields + boundary)
- Next free layer: 8 (bit 128)

### Scene Flow

`title_screen.tscn` is the `run/main_scene`. "New Game" calls `get_tree().change_scene_to_file("res://scenes/main.tscn")`. After game-over the player presses F5 to restart (reloads `main.tscn`); there is no automatic return to title yet.

### Key Implementation Details

- **Visuals**: All use `Polygon2D` — no external textures yet. Sprites in `assets/sprites/` are planned placeholders.
- **Input actions** are registered at runtime in `main.gd._setup_input_actions()`: `move_left` (←), `move_right` (→), `shoot` (Space), `restart` (F5), `pause` (Escape).
- **Pause**: `get_tree().paused = true` freezes all `PROCESS_MODE_PAUSABLE` nodes. `main.gd` and `hud.tscn` root use `PROCESS_MODE_ALWAYS` so input and HUD remain live while paused.
- **`alien.set_type()`** must be called **before** `add_child()` — colors are applied in `_ready()`.
- **`player.bullets_container`** is injected by `main.gd._ready()` (parent `_ready` runs after children in Godot).
- **Formation speed** scales with `alive_count / total` and `wave` number via `_recalc_speed()`.
- **Boundaries** (top/bottom walls) are `Area2D` nodes built in code by `main.gd._ready()`, layer 64, used to despawn out-of-bounds bullets.
- **Hi-score** is persisted to `user://hi_score.cfg` via `ConfigFile`.
- **Groups used**: `"player"`, `"alien"`, `"shield_segment"`, `"ufo"`, `"boundary"` — bullets use `is_in_group()` for hit detection.
