# Space Invaders Clone — Implementation Plan & Checklist

## Status Legend
- [x] Done
- [ ] Todo / In progress

---

## Scenes & Scripts

| Scene | Root Node | Script | Status |
|---|---|---|---|
| `scenes/main.tscn` | Node2D | `scripts/main.gd` | [x] |
| `scenes/player.tscn` | CharacterBody2D | `scripts/player.gd` | [x] |
| `scenes/alien.tscn` | Area2D | `scripts/alien.gd` | [x] |
| `scenes/alien_formation.tscn` | Node2D | `scripts/alien_formation.gd` | [x] |
| `scenes/player_bullet.tscn` | Area2D | `scripts/player_bullet.gd` | [x] |
| `scenes/enemy_bullet.tscn` | Area2D | `scripts/enemy_bullet.gd` | [x] |
| `scenes/shield.tscn` | Node2D | `scripts/shield.gd` | [x] |
| `scenes/ufo.tscn` | Area2D | `scripts/ufo.gd` | [x] |
| `scenes/hud.tscn` | CanvasLayer | `scripts/hud.gd` | [x] |
| `scenes/title_screen.tscn` | Control | `scripts/title_screen.gd` | [x] |

---

## Collision Layers

| Layer | Bit | Used by |
|---|---|---|
| 1 | 1 | Player |
| 2 | 2 | Aliens |
| 3 | 4 | PlayerBullet |
| 4 | 8 | EnemyBullet |
| 5 | 16 | Shield segments |
| 6 | 32 | UFO |
| 7 | 64 | Boundaries |

- **PlayerBullet** mask = 2+16+32+64 = **114**
- **EnemyBullet** mask = 1+16+64 = **81**

---

## Assets

### Sprites (placeholder — replace with pixel art)
- [ ] `assets/sprites/player_ship.png`
- [ ] `assets/sprites/alien_a.png` (top row, 2 frames)
- [ ] `assets/sprites/alien_b.png` (mid row, 2 frames)
- [ ] `assets/sprites/alien_c.png` (bottom row, 2 frames)
- [ ] `assets/sprites/ufo.png`
- [ ] `assets/sprites/player_bullet.png`
- [ ] `assets/sprites/enemy_bullet.png`
- [ ] `assets/sprites/shield_block.png`
- [ ] `assets/sprites/explosion.png`
- [ ] `assets/sprites/player_explosion.png`

### Audio
- [ ] `assets/audio/sfx_shoot.wav`
- [ ] `assets/audio/sfx_alien_explode.wav`
- [ ] `assets/audio/sfx_player_explode.wav`
- [ ] `assets/audio/sfx_ufo_loop.wav`
- [ ] `assets/audio/sfx_ufo_hit.wav`
- [ ] `assets/audio/march_1.wav`
- [ ] `assets/audio/march_2.wav`
- [ ] `assets/audio/march_3.wav`
- [ ] `assets/audio/march_4.wav`

### Font
- [ ] `assets/fonts/arcade.ttf` (pixel/arcade font for HUD)

---

## Game Logic Checklist

### Core Gameplay
- [x] Player moves left/right (arrow keys), shoots (Space/Enter)
- [x] One player bullet in flight at a time
- [x] Alien formation — 5×11 grid, step movement, direction reverse + drop on boundary
- [x] Formation speed increases as aliens are killed
- [x] Enemy shoots from bottom-most alien per column, rate increases as count drops
- [x] Shields — 4 bunkers with segment-based destruction
- [x] Both player and enemy bullets destroy shield segments
- [x] UFO — random spawn 15–30s, flies across, awards 50/100/150/300 pts
- [x] Player loses a life on hit; game over at 0 lives
- [x] Score and hi-score update in HUD
- [x] Wave resets when all aliens cleared (speed/difficulty increases)

### Polish / Nice-to-have
- [ ] Sprite art (replace Polygon2D placeholders)
- [ ] Sound effects (AudioStreamPlayer nodes)
- [ ] Alien march beat (4-note cycle, tempo tracks speed)
- [ ] Explosion animations (brief flash or sprite frames)
- [ ] Player explosion animation
- [ ] UFO loop sound while on screen
- [X] Persistent hi-score via ConfigFile
- [x] Start/title screen
- [X] Pause menu
- [ ] Translations
- [ ] Joystick support
- [ ] Custom key mappings
- [ ] CRT effect
- [ ] Adjust aspect ratio and handle different resolutions or screen resizes

---

## Verification Checklist

- [X] F5 launches game, HUD visible, player at bottom, alien grid at top
- [X] Left/right arrows move player; Space fires bullet
- [X] Second bullet blocked while first is in flight
- [X] Aliens step left/right, drop and reverse on boundary hit
- [X] Killing aliens speeds up formation
- [X] Enemy bullet destroys a shield segment on contact
- [X] Player bullet destroys alien + shield segment on contact
- [X] UFO appears periodically, score added on kill
- [X] Player flashes red on hit, respawns after delay
- [X] Game Over shown at 0 lives
- [X] New wave spawns after all aliens killed
