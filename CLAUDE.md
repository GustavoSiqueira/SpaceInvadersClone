# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Rules

- Always implement unit tests for code that makes sense to test in this way.
- Keep `README.md` updated whenever new functionality is added or design decisions change.
- After completing a feature, mark it done in `docs/plan.md`.

## Project Overview

Space Invaders clone built with **Godot 4.6** using **GDScript**. 2D, GL Compatibility renderer, 800×600 logical viewport. Stretch mode: `canvas_items` / aspect: `keep` (letterbox on non-4:3 screens).

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

## Reimporting Assets (e.g. after editing translation CSVs)

```bash
/home/bin/godot/Godot_v4.6.1-stable_mono_linux.x86_64 --headless --editor --quit \
  --path /home/gustavo/src/space-invaders
```

This triggers Godot's importer headlessly and regenerates all `.translation` binary files from the CSV source.

## Architecture

### Scene / Script Map

| Scene | Root | Script | Role |
|---|---|---|---|
| `title_screen.tscn` | Control | `title_screen.gd` | Entry point — logo + menu (New Game / Options / Exit) |
| `options_screen.tscn` | Control | `options_screen.gd` | Key rebinding UI (keyboard + gamepad columns) + CRT toggle + audio stubs + language selector; supports `overlay_mode` for use from the pause menu |
| `main.tscn` | Node2D | `main.gd` | Game controller — owns all other nodes, handles input, score, lives, wave |
| `player.tscn` | CharacterBody2D | `player.gd` | Player ship — movement, shooting, hit/respawn |
| `alien.tscn` | Area2D | `alien.gd` | Single alien — type, points, 2-frame animation |
| `alien_formation.tscn` | Node2D | `alien_formation.gd` | 5×11 grid — step movement, shooting, speed scaling |
| `player_bullet.tscn` | Area2D | `player_bullet.gd` | Player projectile — moves up, destroys aliens/shields/UFO |
| `enemy_bullet.tscn` | Area2D | `enemy_bullet.gd` | Enemy projectile — moves down, destroys player/shields |
| `shield.tscn` | Node2D | `shield.gd` | Bunker — builds 8×4 grid of `Area2D` segments at runtime |
| `ufo.tscn` | Area2D | `ufo.gd` | Bonus UFO — flies across top, awards random points |
| `hud.tscn` | CanvasLayer | `hud.gd` | Score, hi-score, lives, game-over panel, pause menu (Resume / Options / Exit) |
| `crt_effect.tscn` | — | *(shader only)* | Full-screen CRT scanline/vignette overlay; belongs to group `"crt_effect"` |

`settings.gd` declares `class_name Settings` — a static class (no autoload needed) that persists preferences to `user://settings.cfg`. Stored values: key bindings (`[keybindings]`), gamepad bindings (`[gamepad_bindings]`), `crt_enabled`, `music_volume`, `sfx_volume`, `language`. Gamepad bindings are stored as Dictionaries with `{"type": "button", "button": int}` or `{"type": "axis", "axis": int, "axis_value": float}`. Call `Settings.load()` before reading values; call `Settings.save()` after writing. In unit tests: call `Settings._delete_file_for_test()` then `Settings._reset_for_test()` in `before_each` to ensure a fully clean state.

### Signal Flow

Game objects emit signals upward; `main.gd` is the single aggregator:
- `player.player_hit` → `main._on_player_hit()`
- `alien_formation.alien_killed(pts)` → `main._on_alien_killed(pts)`
- `alien_formation.formation_cleared` → `main._on_formation_cleared()`
- `alien_formation.aliens_reached_bottom` → `main._on_aliens_reached_bottom()`
- `ufo.ufo_destroyed(pts)` → `main._on_ufo_destroyed(pts)`
- `ufo_timer.timeout` → `main._on_ufo_timer_timeout()`
- `hud.pause_toggled` → `main._toggle_pause()` (emitted by Escape key or Resume button)
- `hud.options_requested` → `main._on_options_requested()` (opens options as CanvasLayer overlay)
- `hud.exit_requested` → `get_tree().quit()`

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

`title_screen.tscn` is the `run/main_scene`. `title_screen.gd._ready()` calls `Settings.load()` and `Settings.apply_language()` to set the locale before anything is displayed. "New Game" → `main.tscn`; "Options" → `options_screen.tscn` → back to `title_screen.tscn`. After game-over the player presses F5 to restart (reloads `main.tscn`); there is no automatic return to title yet.

During gameplay, pressing Escape opens the pause menu. "Options" from the pause menu does **not** switch scenes — it instantiates `options_screen.tscn` with `overlay_mode = true` as a child of the HUD `CanvasLayer`, preserving all game state. When the overlay closes it emits `closed` and is freed.

### Key Implementation Details

- **Visuals**: All use `Polygon2D` — no external textures yet. Sprites in `assets/sprites/` are planned placeholders.
- **Font**: `assets/fonts/monogram-extended.ttf` is the project-wide font, applied via `assets/theme/default_theme.tres` (registered in `project.godot` under `[gui] theme/custom`).
- **Background color**: viewport clear color is `#161616` (set in `project.godot` as `environment/defaults/default_clear_color`). The options screen `ColorRect` background matches this color.
- **Input actions** are registered at runtime in two passes: `main.gd._setup_input_actions()` maps keyboard keys from `Settings`, then `_setup_joypad_actions()` maps gamepad bindings from `Settings.DEFAULT_GAMEPAD_BINDINGS` / `Settings.get_gamepad_binding()`. Both keyboard and gamepad bindings are user-rebindable via the Options screen. `options_screen.gd._sync_action_input_map()` re-applies both bindings together whenever either changes, preventing stale events.
- **Pause**: `get_tree().paused = true` freezes all `PROCESS_MODE_PAUSABLE` nodes. `main.gd` and `hud.tscn` root use `PROCESS_MODE_ALWAYS` so input and HUD remain live while paused. The pause menu (Resume / Options / Exit to Desktop) is built into `hud.tscn`'s `PausePanel`. Options opened from the pause menu inherits `PROCESS_MODE_ALWAYS` via the HUD CanvasLayer parent.
- **`alien.set_type()`** must be called **before** `add_child()` — colors are applied in `_ready()`.
- **`player.bullets_container`** is injected by `main.gd._ready()` (parent `_ready` runs after children in Godot).
- **Formation speed** scales with `alive_count / total` and `wave` number via `_recalc_speed()`.
- **Boundaries** (top/bottom walls) are `Area2D` nodes built in code by `main.gd._ready()`, layer 64, used to despawn out-of-bounds bullets.
- **Hi-score** is persisted to `user://hi_score.cfg` via `ConfigFile`.
- **Groups used**: `"player"`, `"alien"`, `"shield_segment"`, `"ufo"`, `"boundary"` — bullets use `is_in_group()` for hit detection.
- **Freeing nodes from signal callbacks**: never call `node.free()` or `node.queue_free()` on a node that is currently executing a signal (e.g. an `OptionButton` whose `item_selected` is still on the call stack). Use `call_deferred("_your_method")` to defer destruction until after the signal completes.

### Translation System

Translations live in `assets/translations/en.csv`. The first column is `keys`; subsequent columns are locale codes (`en`, `pt_BR`, `es`, `fr`, `de`, `it`). Godot's CSV importer compiles one binary `.translation` file per locale; all are registered in `project.godot` under `[internationalization]`.

To add a new locale or string:
1. Add a column / row to `en.csv`.
2. Update the `dest_files` list in `en.csv.import`.
3. Run the headless import command above to regenerate the `.translation` binaries.
4. Add the new `.translation` path to `locale/translations` in `project.godot`.
5. Add the locale to `Settings.SUPPORTED_LOCALES` and expose it in `options_screen.gd`'s `LANGUAGE_LOCALES` / `LANGUAGE_LABELS` arrays.

`Settings.apply_language()` resolves the active locale: uses the stored preference if set, otherwise falls back to the OS locale (`OS.get_locale()`), matched against `SUPPORTED_LOCALES` by exact code then by 2-letter language prefix. Falls back to `"en"` if nothing matches. The options screen calls `call_deferred("_rebuild_ui")` after applying a language change so the UI refreshes without crashing mid-signal.
