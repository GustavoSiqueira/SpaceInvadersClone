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
| Window | 800 × 600 px |

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

| Action | Key |
|---|---|
| Move left | Left Arrow |
| Move right | Right Arrow |
| Fire | Space or Enter |
| Pause / Resume | Escape |
| Restart (game over) | F5 |

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
| `tests/unit/` | 6 | 70 |
| `tests/integration/` | 1 | 7 |
| **Total** | **7** | **77** |

---

## Project Structure

```
space-invaders/
├── scenes/              # Scene files (.tscn)
│   ├── title_screen.tscn  # Entry point — title/menu screen
│   ├── main.tscn          # Root game scene
│   ├── player.tscn
│   ├── alien.tscn
│   ├── alien_formation.tscn
│   ├── player_bullet.tscn
│   ├── enemy_bullet.tscn
│   ├── shield.tscn
│   ├── ufo.tscn
│   └── hud.tscn
├── scripts/             # GDScript files (.gd), one per scene
│   ├── title_screen.gd
│   ├── main.gd
│   ├── player.gd
│   ├── alien.gd
│   ├── alien_formation.gd
│   ├── player_bullet.gd
│   ├── enemy_bullet.gd
│   ├── shield.gd
│   ├── ufo.gd
│   └── hud.gd
├── tests/
│   ├── unit/            # GUT unit tests (one file per script under test)
│   └── integration/     # GUT integration tests (bullet collision scenarios)
├── addons/gut/          # GUT 9.6.0 test framework
├── assets/
│   ├── sprites/         # PNG sprite sheets (not yet created — see below)
│   ├── audio/           # WAV/OGG sound effects and music
│   └── fonts/           # TTF arcade font for HUD
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
└── HUD (CanvasLayer)            ← hud.gd  [PROCESS_MODE_ALWAYS]
	├── ScoreLabel
	├── HiScoreLabel
	├── LivesLabel
	├── GameOverPanel
	└── PausePanel
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

- **Grid**: 5 rows × 11 columns (55 aliens). Rows 0–1 → type 0 (cyan, 30 pts), rows 2–3 → type 1 (green, 20 pts), row 4 → type 2 (white, 10 pts).
- **Step movement**: accumulates `delta` in `_physics_process`; when `step_timer` exceeds `step_interval`, the whole formation node shifts `STEP_X = 11 px` horizontally. Moving the parent node moves all aliens together with no per-alien position math.
- **Boundary detection**: checks the global X of the leftmost and rightmost living alien each step. On crossing 20 px (left) or 770 px (right) the direction reverses and the formation drops `DROP_Y = 16 px`.
- **Speed scaling**: after every kill, `_recalc_speed()` interpolates `step_interval` and `shoot_interval` from their minimum values (0.04 s / 0.3 s) toward their maximum values (1.0 s / 3.0 s) based on how many aliens remain, then divides by `wave` for extra difficulty per wave.
- **Shooting**: fires from the bottom-most living alien in a randomly selected column.
- **Animation**: calls `toggle_frame()` on every living alien on each step tick, swapping between the two `Polygon2D` children (`Frame0` / `Frame1`).

To tune formation feel, adjust these constants in `alien_formation.gd`:

```gdscript
const COLS       = 11      # aliens per row
const ROWS       = 5       # number of rows
const SPACING_X  = 48.0    # horizontal gap between alien centers
const SPACING_Y  = 40.0    # vertical gap between rows
const STEP_X     = 11.0    # pixels moved per step
const DROP_Y     = 16.0    # pixels dropped on boundary hit
```

---

## Adding Sprite Art

All visuals currently use `Polygon2D` nodes as placeholders. To replace them with real pixel art:

1. Export sprites as **PNG** at the native size (suggested 32×32 px for aliens, 48×16 for the player cannon). Use indexed or RGBA color mode. Pixel art looks sharpest with nearest-neighbor filtering.

2. In the Godot editor, import each PNG and set its **Import** settings:
   - Filter: **Nearest** (disables blending between pixels)
   - Compress Mode: **Lossless**

3. Open the relevant scene and replace each `Polygon2D` node with a `Sprite2D` node. Assign the imported texture.

4. For the two-frame alien animation, either:
   - Use a **horizontal spritesheet** (two frames side by side in one PNG) and set `Sprite2D.hframes = 2`. In `alien.gd`, replace the `toggle_frame()` body with `$Sprite2D.frame = anim_frame`.
   - Or keep two separate `Sprite2D` children (`Frame0`, `Frame1`) and toggle `visible` — the existing `toggle_frame()` works without changes.

**Expected asset filenames** (for reference; `docs/plan.md` has the full checklist):

```
assets/sprites/player_ship.png
assets/sprites/alien_a.png      # top-row, 2 frames
assets/sprites/alien_b.png      # mid-row, 2 frames
assets/sprites/alien_c.png      # bottom-row, 2 frames
assets/sprites/ufo.png
assets/sprites/player_bullet.png
assets/sprites/enemy_bullet.png
assets/sprites/shield_block.png
assets/sprites/explosion.png
assets/sprites/player_explosion.png
```

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

## Adding a Custom Font

1. Drop a TTF or OTF file into `assets/fonts/` (e.g., `arcade.ttf`).
2. In the Godot editor, create a **FontFile** resource or reference the TTF directly in each `Label`'s **Theme Overrides → Fonts → Font** property.
3. Set font size under **Theme Overrides → Font Sizes**.

To apply the font project-wide, create a `Theme` resource (`Project → Project Settings → GUI → Theme → Custom`) and set the default Label font there.

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

The title screen (`scenes/title_screen.tscn`) is the game entry point. It shows a "SPACE INVADERS" logo and a menu with **New Game**, **Options** (disabled stub), and **Exit** buttons. Keyboard navigation works via Godot's built-in focus system (`ui_up`/`ui_down`/`ui_accept`).

Pressing **New Game** calls:

```gdscript
get_tree().change_scene_to_file("res://scenes/main.tscn")
```

`project.godot` points `run/main_scene` at `res://scenes/title_screen.tscn`.

---

## Known Limitations / Future Work

See `docs/plan.md` for the full tracked checklist. High-level items still open:

- Sprite art (all visuals are `Polygon2D` placeholder shapes)
- Sound effects and music
- Explosion animations
