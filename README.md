# Space Invaders Clone

A faithful Space Invaders clone built with Godot 4.6 and GDScript. The game features a 5×11 alien formation, segment-based destructible shields, a mystery UFO, and wave-based difficulty scaling.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Engine | [Godot 4.6](https://godotengine.org/) |
| Language | GDScript (`.gd`) |
| Renderer | GL Compatibility (OpenGL 3 / OpenGL ES 3) |
| Physics | Godot Physics 2D |
| Scene format | Godot TSCN (text-based) |
| Window | 1600 × 1200 px logical viewport (letterboxed on non-4:3 screens) |

The game uses Godot's **canvas_items** stretch mode with **keep** aspect ratio. The entire scene is rendered at 1600 × 1200 and scaled uniformly to the window; black bars appear on the sides of 16:9 or wider displays. The 4:3 ratio is intentional — Space Invaders was originally a fixed-display arcade game.

The **GL Compatibility** renderer is the right choice here: it targets the widest range of hardware (including integrated GPUs and low-end devices) and has no overhead for features a 2D game does not use. Forward+ and Mobile renderers add GPU instancing and clustered lighting that this project does not need.

---

## Running the Game

Open the project folder in the Godot editor and press **F5**, or from a terminal:

```bash
# Normal run
/home/bin/godot/Godot_v4.6.1-stable_mono_linux.x86_64 --path /home/gustavo/src/space-invaders

# Headless (no window, useful for CI or scripted tests)
/home/bin/godot/Godot_v4.6.1-stable_mono_linux.x86_64 --headless --path /home/gustavo/src/space-invaders
```

**Controls**

| Action | Default Key |
|---|---|
| Move left | Left Arrow |
| Move right | Right Arrow |
| Fire | Space |
| Pause / Resume | Escape |
| Restart (game over) | F5 |

All five actions can be rebound from the **Options** menu on the title screen or pause menu.

---

## Running Tests

Tests use **GUT 9.6.0** (already installed in `addons/gut/`).

```bash
# Run all tests headless
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

| Suite | Scripts | Tests |
|---|---|---|
| `tests/unit/` | 10 | 145 |
| `tests/integration/` | 1 | 7 |
| **Total** | **11** | **152** |

---

## Project Structure

```
space-invaders/
├── scenes/              # Scene files (.tscn)
│   ├── title_screen.tscn  # Entry point — title/menu screen
│   ├── options_screen.tscn # Options menu — key bindings, CRT toggle, audio stubs
│   ├── main.tscn          # Root game scene
│   ├── player.tscn
│   ├── alien.tscn
│   ├── alien_formation.tscn
│   ├── player_bullet.tscn
│   ├── enemy_bullet.tscn
│   ├── shield.tscn
│   ├── ufo.tscn
│   ├── hud.tscn
│   └── crt_effect.tscn    # CRT post-processing overlay (scanlines + vignette)
├── scripts/             # GDScript files (.gd), one per scene
│   ├── title_screen.gd
│   ├── options_screen.gd
│   ├── settings.gd        # Static class — user settings persistence (user://settings.cfg)
│   ├── main.gd
│   ├── player.gd
│   ├── alien.gd
│   ├── alien_formation.gd
│   ├── player_bullet.gd
│   ├── enemy_bullet.gd
│   ├── shield.gd
│   ├── ufo.gd
│   ├── hud.gd
│   ├── crt_effect.gd
│   └── explosion.gd         # Generic hframes advancer used by both explosion scenes
├── shaders/             # GLSL shader files (.gdshader)
│   └── crt_effect.gdshader
├── tests/
│   ├── unit/            # GUT unit tests (one file per script under test)
│   └── integration/     # GUT integration tests (bullet collision scenarios)
├── addons/gut/          # GUT 9.6.0 test framework
├── assets/
│   ├── sprites/         # PNG sprite sheets — 16-bit pixel art (see Sprite Art)
│   ├── audio/           # WAV/OGG sound effects and music (not yet created)
│   ├── fonts/           # TTF font files
│   │   └── monogram-extended.ttf  # project-wide UI font
│   └── theme/
│       └── default_theme.tres     # Godot Theme — sets default font project-wide
├── docs/
│   └── plan.md          # Implementation checklist
├── .gutconfig.json      # GUT CLI configuration
├── project.godot        # Godot project configuration
└── README.md
```

Each scene file and its paired script share the same base name. Scenes are standalone — no scene directly references another at design time except `main.tscn`, which instances `player.tscn` and `hud.tscn` statically. All other scenes (`alien_formation`, `shield`, `ufo`) are instantiated at runtime by `main.gd`.

---

## Architecture

### Scene Tree (runtime)

```
Main (Node2D)                    ← main.gd
├── Player (CharacterBody2D)     ← player.gd
├── Shields (Node2D)
│   └── Shield × 4 (Node2D)     ← shield.gd  [spawned at _ready]
│       └── Segment × 28 (Area2D)             [built by shield.gd]
├── PlayerBullets (Node2D)       ← bullet container (max 1 child)
│   └── PlayerBullet (Area2D)?  ← player_bullet.gd
├── EnemyBullets (Node2D)        ← bullet container (unlimited)
│   └── EnemyBullet (Area2D)*   ← enemy_bullet.gd
├── AlienFormation (Node2D)      ← alien_formation.gd [spawned at _ready]
│   └── Alien × 55 (Area2D)     ← alien.gd
├── UFO (Area2D)?                ← ufo.gd            [spawned on timer]
├── Boundary × 2 (Area2D)       ← built by main.gd   [top + bottom edges]
├── HUD (CanvasLayer)            ← hud.gd  [PROCESS_MODE_ALWAYS]
│   ├── ScoreLabel
│   ├── HiScoreLabel
│   ├── LivesLabel
│   ├── GameOverPanel
│   └── PausePanel               ← Resume / Options / Exit buttons
└── CRTEffect (CanvasLayer)      ← crt_effect.gd  [layer 100, PROCESS_MODE_ALWAYS]
	└── Overlay (ColorRect)      ← ShaderMaterial using crt_effect.gdshader
```

### Design Patterns

**Signal-based decoupling** — game objects communicate upward through signals, never downward through direct node references. For example:

- `alien.gd` emits `killed(pts)` → `alien_formation.gd` aggregates and re-emits `alien_killed(pts)` → `main.gd` updates the score via `hud.update_score()`.
- `player.gd` emits `player_hit` → `main.gd` handles life loss and respawn timing.
- `ufo.gd` emits `ufo_destroyed(pts)` or `ufo_exited` → `main.gd` clears the reference and adds score.

This means individual game objects know nothing about the game state. Replacing the HUD, changing scoring, or adding a leaderboard only requires changes in `main.gd`.

**Dependency injection** — objects that need runtime context receive it as plain properties before entering the scene tree, avoiding tight coupling through singletons or hard-coded paths:

```gdscript
# main.gd sets these before add_child():
formation.wave = wave
formation.enemy_bullets_container = enemy_bullets

player.bullets_container = player_bullets  # set in main._ready()
```

**Procedural construction** — nodes with many identical children build themselves in code rather than in the scene editor. `shield.gd` constructs its ~26 segment `Area2D` nodes in `_ready()`. `main.gd` builds the two invisible boundary `Area2D` nodes at startup. This keeps scene files small and makes the grid geometry easy to tweak via constants.

**Deferred instantiation** — `AlienFormation` and `UFO` are never present in the scene file. `main.gd` instantiates, configures, and frees them as needed. This makes wave resets clean: free the old formation, instantiate a fresh one with `wave` incremented.

**`is_instance_valid` guards** — because `queue_free()` is deferred, references to freed nodes remain non-null for the remainder of the current frame. All cross-object null checks use `is_instance_valid(node)` rather than `node != null`.

---

## Collision System

Godot Physics 2D uses integer bitmasks for layers and masks. Each bit position represents one named layer.

| Layer | Bit value | Who uses it |
|---|---|---|
| 1 — player | 1 | `Player` (CharacterBody2D) |
| 2 — aliens | 2 | `Alien` (Area2D) |
| 3 — player_bullet | 4 | `PlayerBullet` (Area2D) |
| 4 — enemy_bullet | 8 | `EnemyBullet` (Area2D) |
| 5 — shields | 16 | Shield segment (Area2D, built at runtime) |
| 6 — ufo | 32 | `UFO` (Area2D) |
| 7 — boundary | 64 | Boundary (Area2D, built at runtime) |

**Masks** control what each object can detect:

```
PlayerBullet.collision_mask = 2 + 16 + 32 + 64  = 114  (aliens, shields, ufo, boundary)
EnemyBullet.collision_mask  = 1 + 16 + 64        = 81   (player, shields, boundary)
Player.collision_mask       = 8                         (enemy bullets)
```

Detection is handled entirely by bullet scripts via `area_entered` and `body_entered` signals. Aliens, shields, and the UFO are passive (`monitoring = false`, `monitorable = true`); bullets are active (`monitoring = true`). The `Player` is a `CharacterBody2D`, so enemy bullets detect it via `body_entered`.

When a bullet enters a matching object it calls a method on that object (`area.kill()`, `area.hit()`, `area.queue_free()`) then frees itself.

---

## Alien Formation

`alien_formation.gd` owns the entire formation. Key mechanics:

- **Grid**: 5 rows × 11 columns (55 aliens). Rows 0–1 → type 0 (red bug, 30 pts), rows 2–3 → type 1 (green squid, 20 pts), row 4 → type 2 (yellow crab, 10 pts).
- **Step movement**: accumulates `delta` in `_physics_process`; when `step_timer` exceeds `step_interval`, the whole formation node shifts `STEP_X = 22 px` horizontally. Moving the parent node moves all aliens together with no per-alien position math.
- **Boundary detection**: checks the global X of the leftmost and rightmost living alien each step. On crossing 40 px (left) or 1540 px (right) the direction reverses and the formation drops `DROP_Y = 32 px`.
- **Speed scaling**: after every kill, `_recalc_speed()` interpolates `step_interval` and `shoot_interval` from their minimum values (0.04 s / 0.3 s) toward their maximum values (1.0 s / 3.0 s) based on how many aliens remain, then divides by `wave` for extra difficulty per wave.
- **Shooting**: fires from the bottom-most living alien in a randomly selected column.
- **Animation**: calls `toggle_frame()` on every living alien on each step tick, which flips `Sprite2D.frame` between `0` and `1` on the alien's 2-frame horizontal sprite sheet.

To tune formation feel, adjust these constants in `alien_formation.gd`:

```gdscript
const COLS       = 11      # aliens per row
const ROWS       = 5       # number of rows
const SPACING_X  = 96.0    # horizontal gap between alien centers
const SPACING_Y  = 80.0    # vertical gap between rows
const STEP_X     = 22.0    # pixels moved per step
const DROP_Y     = 32.0    # pixels dropped on boundary hit
```

---

## Sprite Art

The game ships with a 16-bit pixel-art sprite set generated in **Google Stitch**. All 10 PNGs live in `assets/sprites/`. `docs/Assets List.md` documents the palette, canvas sizes, and frame counts.

| File | Canvas | Frames | Used by |
|---|---|---|---|
| `player_ship.png` | 58 × 62 | 1 | `player.tscn` — Sprite2D child |
| `alien_a.png` | 96 × 40 | 2 | `alien.tscn` — Sprite2D (hframes = 2), texture assigned per-type in `alien.gd` |
| `alien_b.png` | 90 × 78 | 2 | same |
| `alien_c.png` | 110 × 40 | 2 | same |
| `ufo.png` | 72 × 39 | 1 | `ufo.tscn` |
| `player_bullet.png` | 28 × 71 | 1 | `player_bullet.tscn` |
| `enemy_bullet.png` | 43 × 30 | 1 | `enemy_bullet.tscn` |
| `shield_block.png` | 16 × 16 | 1 | `shield.gd._make_segment()` — one block per shield cell |
| `explosion.png` | 204 × 67 | 3 | `explosion.tscn` — spawned by `alien.kill()` / `ufo.hit()` |
| `player_explosion.png` | 132 × 69 | 2 | `player_explosion.tscn` — spawned by `player.hit()` |

All PNGs are imported with **Filter = Nearest** (set project-wide via `rendering/textures/canvas_textures/default_texture_filter = 0` in `project.godot`) so pixel art stays crisp under the 4:3 letterbox scale.

Two-frame alien animation uses a horizontal sprite sheet with `Sprite2D.hframes = 2`. `alien.gd.toggle_frame()` flips `sprite.frame` between 0 and 1, called by `alien_formation.gd._step()` on every step beat.

Explosion playback is driven by `scripts/explosion.gd`: a simple `Sprite2D` subclass that advances `frame` on a timer and `queue_free`s after the last frame. Both `explosion.tscn` and `player_explosion.tscn` reuse this script with different textures and frame counts.

---

## Adding Sound

Each sound should be an `AudioStreamPlayer` node (or `AudioStreamPlayer2D` for positional audio). The recommended workflow:

1. Place WAV or OGG files in `assets/audio/`.
2. Add an `AudioStreamPlayer` to the relevant scene (e.g., inside `player.tscn`) and assign the stream in the Inspector.
3. Call `$SoundShoot.play()` at the right moment in the script.

For the UFO loop, use `AudioStreamPlayer` with **Loop** enabled on the `AudioStream`, started in `ufo.gd`'s `_ready()` and stopped (or the node freed) when the UFO exits.

For the alien march, cycle through four short percussive hits (`march_1.wav` … `march_4.wav`) in sync with each formation step. Add a beat index counter in `alien_formation.gd` and advance it in `_step()`.

**Expected audio filenames:**

```
assets/audio/sfx_shoot.wav
assets/audio/sfx_alien_explode.wav
assets/audio/sfx_player_explode.wav
assets/audio/sfx_ufo_loop.wav
assets/audio/sfx_ufo_hit.wav
assets/audio/march_1.wav
assets/audio/march_2.wav
assets/audio/march_3.wav
assets/audio/march_4.wav
```

---

## Custom Font

The game uses **monogram-extended** (`assets/fonts/monogram-extended.ttf`) for all UI text. It is applied project-wide via a Godot `Theme` resource at `assets/theme/default_theme.tres`, registered in `project.godot` under `[gui] theme/custom`. This means every `Label`, `Button`, `CheckBox`, `OptionButton`, and other `Control` node inherits the font automatically — no per-node overrides needed.

Individual nodes can still override font size via `theme_override_font_sizes/font_size` (used in `hud.tscn` and `options_screen.gd` for titles and separator labels).

---

## Expanding the Game

### Adding a New Enemy Type

1. Create `scenes/enemy_x.tscn` (root `Area2D`) with a paired `scripts/enemy_x.gd`.
2. Set `collision_layer = 2` (reuses the aliens layer) so player bullets already detect it.
3. Emit a `killed(pts: int)` signal — `alien_formation.gd` or a new formation script can connect to it identically to the existing alien.

### Adding a Power-Up

1. Create a new scene with a distinct collision layer (extend the table — next free bit is layer 8, value 128).
2. Add layer 128 to `PlayerBullet.collision_mask` in `player_bullet.tscn`.
3. Handle the new `area_entered` case in `player_bullet.gd`.

### Start Screen / Scene Transitions

The title screen (`scenes/title_screen.tscn`) is the game entry point. It shows a "SPACE INVADERS" logo and a menu with **New Game**, **Options**, and **Exit** buttons. Keyboard navigation works via Godot's built-in focus system (`ui_up`/`ui_down`/`ui_accept`).

| Button | Action |
|---|---|
| New Game | `change_scene_to_file("res://scenes/main.tscn")` |
| Options | `change_scene_to_file("res://scenes/options_screen.tscn")` |
| Exit | `get_tree().quit()` |

`project.godot` points `run/main_scene` at `res://scenes/title_screen.tscn`.

---

## Pause Menu

Press **Escape** during gameplay to open the pause menu. The game freezes and a centered overlay appears with three choices:

| Button | Action |
|---|---|
| Resume | Continue the game from where it was paused (Escape also works) |
| Options | Open the Options screen as an overlay — game state is preserved |
| Exit to Desktop | Quit the application |

Keyboard navigation works via the built-in focus system (`ui_up`/`ui_down`/`ui_accept`). Focus is placed on **Resume** automatically when the menu opens.

---

## Options Menu

Accessible from the title screen **Options** button or from the in-game **Pause → Options**. Settings are saved to `user://settings.cfg` (a `ConfigFile`) and loaded automatically on the next launch.

### Key Bindings

The key bindings section shows a two-column table — **KEYBOARD** and **GAMEPAD** — for each of the five actions. Both columns are independently rebindable.

**Keyboard column:**
1. Click the button next to the action you want to rebind — it shows **"Press a key..."**
2. Press the desired key. The binding is saved immediately.
3. Press **Escape** to cancel without changing anything.
4. If the chosen key is already used by another action, **"In use!"** is shown briefly and the old binding is kept.

**Gamepad column:**
1. Click the gamepad button for the action — it shows **"Press a button..."**
2. Press any gamepad button or move an axis past 50% — the binding is saved immediately.
3. Press **Escape** to cancel without changing anything.
4. Gamepad bindings do not conflict-check (the same button may be assigned to multiple actions, which is intentional for context-dependent inputs like Start = Pause during gameplay and Restart on game over).

Default gamepad bindings:

| Action | Default |
|---|---|
| Move Left | D-pad ← |
| Move Right | D-pad → |
| Shoot | A |
| Pause | Start |
| Restart | Start |

### CRT Effect Toggle

A checkbox turns the scanline/vignette overlay on or off. The preference is persisted across sessions.

### Audio Volume (coming soon)

Music and SFX volume sliders are visible but inactive until audio assets are added.

### Language

Choose the display language from the **-- LANGUAGE --** section. Available options:

| Option | Locale |
|---|---|
| System Default | Matches the OS locale; falls back to English if unsupported |
| English | `en` |
| Português (Brasil) | `pt_BR` |
| Español | `es` |
| Français | `fr` |
| Deutsch | `de` |
| Italiano | `it` |

When **System Default** is selected, the game reads `OS.get_locale()` at startup and picks the closest supported language. If none matches, English is used. The selected language is saved to `user://settings.cfg` and applied immediately — the Options menu rebuilds itself in the new language when you change the setting.

---

## CRT Effect

A post-processing overlay (`scenes/crt_effect.tscn`) renders a scanline and vignette effect on top of all game content. It is present in the title screen, options screen, and the main game scene.

Three properties are exposed in the Godot Inspector and can be tuned without touching code:

| Property | Range | Default | Effect |
|---|---|---|---|
| `scanline_count` | 50 – 1000 | 300 | Density of horizontal scanline bands |
| `scanline_intensity` | 0 – 1 | 0.35 | How dark the scanline troughs are |
| `vignette_intensity` | 0 – 1 | 0.45 | How dark the screen edges are |

The on/off state is controlled from the **Options** menu and persisted to `user://settings.cfg`.

The implementation lives in:

```
shaders/crt_effect.gdshader   — GLSL shader (scanlines + vignette)
scripts/crt_effect.gd         — exported properties, reads CRT preference from Settings
scenes/crt_effect.tscn        — CanvasLayer (layer 100) + ColorRect
```

---

## Known Limitations / Future Work

See `docs/plan.md` for the full tracked checklist. High-level items still open:

- Sound effects and music
