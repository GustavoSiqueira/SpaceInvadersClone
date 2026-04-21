# Space Invaders — Assets List & Artist Guidelines

This document describes the sprite set currently in the game and the audio/font assets still missing. The 10 sprite PNGs in `assets/sprites/` were generated in **Google Stitch** (project `15357383389845416607`, screen *"16-Bit Space Invaders Assets"*) and imported on 2026-04-21. The game still runs without sound.

---

## 1. Visual Style

**Aesthetic:** 16-bit pixel art in the style of Mega Drive / SNES era shooters (Gunstar Heroes, Gradius). Vibrant palette with bold outlines and smooth anti-aliased curves.

**Key constraints:**
- Logical viewport is **1600 × 1200 px** (4:3 ratio). The game letterboxes on wider screens.
- All sprites are displayed at **1:1 pixel scale** with nearest-neighbor filtering (project-wide `default_texture_filter = 0`). Keep edges crisp.
- The game renders on a near-black background (`#161616`, set via `environment/defaults/default_clear_color`). All sprites must have a transparent background (PNG alpha channel).
- A CRT scanline/vignette shader runs as a full-screen overlay. Design sprites to look good *with* scanlines, not against them — avoid very fine single-pixel horizontal detail that will disappear between scanlines.
- Hitboxes are smaller than sprite canvases for most entities (e.g. alien hitbox 48×40 while the widest alien sprite is 55 px); sprites are free to have expressive silhouettes that dangle past the collision shape.

---

## 2. Colour Palette

These are the dominant colours used by each entity in the imported Stitch sprite set. Sprites use shading and highlights around the dominant colour so CRT colour tinting still reads correctly.

| Entity | Dominant colour | Notes |
|---|---|---|
| Background | Near-black (`#161616`) | Set via `default_clear_color` |
| Player ship | Cyan/blue | Wedge-shaped fighter with white highlights |
| Alien type A (top 2 rows) | Red/magenta | Bug silhouette, antennae |
| Alien type B (middle 2 rows) | Green/lime | Squid silhouette with dangling tentacles |
| Alien type C (bottom row) | Yellow/orange | Crab / spider silhouette |
| UFO / mystery ship | Purple with pink highlights | Elongated flying saucer with dome |
| Player bullet | Bright yellow/cyan | Vertical laser beam with glow halo |
| Enemy bullet | Red/orange | Blobby plasma shot |
| Shields / bunkers | Cyan with white highlights | Built from a 16×16 shield_block tile |
| Alien explosion | Yellow → orange | 3-frame burst |
| Player explosion | Red with white core | 2-frame burst |
| HUD text — score | White | Rendered via theme font |
| HUD text — hi-score | Yellow | Rendered via theme font |

---

## 3. Sprite Assets

All 10 sprites live in `assets/sprites/` as PNG with alpha. Multi-frame sprites are packed as **horizontal sheets**: frame 0 at x = 0, frame 1 at x = frame_width, etc. The Godot side reads frames left-to-right via `Sprite2D.hframes` / `frame`.

### 3.1 Game Entity Sprites

| File | Canvas size | Frames | Total sheet | Used by | Notes |
|---|---|---|---|---|---|
| `player_ship.png` | 58 × 62 | 1 | 58 × 62 | `player.tscn` Sprite2D | Cyan/blue wedge. Idle frame only (Stitch had an exhaust frame too, unused). |
| `alien_a.png` | 48 × 40/frame | 2 | 96 × 40 | `alien.tscn` (type 0) | Red bug. Two-frame walk cycle. |
| `alien_b.png` | 45 × 78/frame | 2 | 90 × 78 | `alien.tscn` (type 1) | Green squid — tall due to dangling tentacles. |
| `alien_c.png` | 55 × 39/frame | 2 | 110 × 39 | `alien.tscn` (type 2) | Yellow crab. |
| `ufo.png` | 72 × 39 | 1 | 72 × 39 | `ufo.tscn` | Purple saucer. |
| `player_bullet.png` | 28 × 71 | 1 | 28 × 71 | `player_bullet.tscn` | Tall yellow laser beam with glow halo. |
| `enemy_bullet.png` | 43 × 30 | 1 | 43 × 30 | `enemy_bullet.tscn` | Red/orange plasma blob. |
| `shield_block.png` | 16 × 16 | 1 | 16 × 16 | `shield.gd._make_segment()` | One bunker cell (cyan). Assembled into 8×4 grid by `shield.gd`. |

`alien.gd` keeps `const ALIEN_TEXTURES: Array[Texture2D] = [alien_a, alien_b, alien_c]` and assigns `sprite.texture = ALIEN_TEXTURES[alien_type]` in `_ready()` — so the type-to-colour mapping lives in one place. The Sprite2D node has `hframes = 2`; `toggle_frame()` flips `sprite.frame` between 0 and 1 on each formation step beat.

### 3.2 Explosion Sprites

Explosions spawn as independent scenes at the entity's global position and free themselves when the animation ends. The generic driver is `scripts/explosion.gd`.

| File | Frame size | Frames | Total sheet | Scene | Spawned by |
|---|---|---|---|---|---|
| `explosion.png` | 68 × 67/frame | 3 | 204 × 67 | `scenes/explosion.tscn` | `alien.kill()`, `ufo.hit()` |
| `player_explosion.png` | 66 × 69/frame | 2 | 132 × 69 | `scenes/player_explosion.tscn` | `player.hit()` |

Frame durations: `explosion.tscn` = 0.08 s/frame (~0.24 s total); `player_explosion.tscn` = 0.15 s/frame (~0.30 s total). `explosion.gd` exports `frame_duration` so it can be tuned per scene.

---

## 4. Font Asset

| File | Format | Description |
|---|---|---|
| `assets/fonts/arcade.ttf` | TTF or OTF | Pixel / arcade-style font for all in-game UI |

**Requirements:**
- Uppercase characters only is fine (the HUD uses all-caps); lowercase is a bonus.
- Required characters: `A–Z`, `0–9`, and punctuation: `: . , / ! ? - ( ) %`
- Must be legible at sizes between **14 px and 28 px** on a dark background.
- Monospaced or fixed-width is strongly preferred so score digits don't jump around.
- The font will render through the CRT shader — avoid very thin strokes (< 2 px at target size).

**Where it is used:** score display, hi-score, lives counter, "GAME OVER", "PAUSED", menu items, key-binding labels, and the title screen logo.

---

## 5. Audio Assets

All audio goes in `assets/audio/`. Preferred formats: **WAV (PCM) or OGG Vorbis**. Spec: **44100 Hz, 16-bit, mono** (stereo is acceptable for the music bed if one is added, but all SFX should be mono).

Keep levels consistent: normalise SFX peaks to –6 dBFS so the programmer can balance buses without clipping.

### 5.1 One-Shot Sound Effects

| File | Target duration | Description |
|---|---|---|
| `sfx_shoot.wav` | ~0.15 s | Player fires a bullet. Short, high-pitched electronic zap or pew. |
| `sfx_alien_explode.wav` | ~0.30 s | An alien is hit. Mid-frequency crunch or pop — classic arcade noise burst. |
| `sfx_player_explode.wav` | ~1.00 s | Player ship is destroyed. Descending pitch noise, longer and more impactful than the alien death. |
| `sfx_ufo_hit.wav` | ~0.40 s | UFO is shot. A rising-then-falling pitched crash or retro "score" jingle. |

### 5.2 Looping Sound Effect

| File | Loop duration | Description |
|---|---|---|
| `sfx_ufo_loop.wav` | ~1.0 s (seamless loop) | Eerie, repeating two-tone oscillating drone that plays while the UFO is on screen. Must loop cleanly with no click at the boundary. |

### 5.3 Alien March Beats (4 files)

The formation plays these four notes in sequence (1→2→3→4→1→…) each time it takes a step. The tempo increases as the alien count drops — the same four samples are reused at higher frequency.

| File | Target duration | Pitch | Description |
|---|---|---|---|
| `march_1.wav` | ~0.10 s | Lowest | The lowest of the four march tones. Deep, bass-register blip. |
| `march_2.wav` | ~0.10 s | Low-mid | Second step. Slightly higher pitch. |
| `march_3.wav` | ~0.10 s | High-mid | Third step. |
| `march_4.wav` | ~0.10 s | Highest | Fourth step. The highest of the four. |

**Design note:** the four pitches should form a recognisable repeating pattern. The classic arcade used square-wave tones approximately a minor third apart. Keep each sample very short with a clean tail so rapid playback at high alien-death rate does not sound cluttered.

---

## 6. Visual Effects (Code-Driven — No Separate Asset Required)

These effects are already implemented in code using tweens and colour modulation. They are documented here so artists understand the full visual context and can design sprites that complement them.

| Effect | Duration | Description |
|---|---|---|
| Alien death flash | 0.25 s | Alien sprite modulates to yellow then fades to transparent over 0.25 s. The `explosion.png` sprite sheet will eventually replace this tween. |
| Player hit flash | ~0.5 s | Player ship modulates to red on hit, then fades back to white before respawning. The `player_explosion.png` sheet will play alongside or replace this. |
| Shield erosion | Immediate | Each 8×8 shield segment is destroyed (freed) when hit. No fade — instant disappearance. The remaining segments visually define the bunker shape. |

---

## 7. Asset Checklist

### Sprites (`assets/sprites/`) — delivered via Google Stitch
- [x] `player_ship.png` — 58 × 62, 1 frame
- [x] `alien_a.png` — 96 × 40, 2 frames
- [x] `alien_b.png` — 90 × 78, 2 frames
- [x] `alien_c.png` — 110 × 39, 2 frames
- [x] `ufo.png` — 72 × 39, 1 frame
- [x] `player_bullet.png` — 28 × 71, 1 frame
- [x] `enemy_bullet.png` — 43 × 30, 1 frame
- [x] `shield_block.png` — 16 × 16, 1 frame
- [x] `explosion.png` — 204 × 67, 3 frames (Stitch provided 3, not the originally-specified 4)
- [x] `player_explosion.png` — 132 × 69, 2 frames (Stitch provided 2, not the originally-specified 6)

### Font (`assets/fonts/`)
- [ ] `arcade.ttf`

### Audio (`assets/audio/`)
- [ ] `sfx_shoot.wav`
- [ ] `sfx_alien_explode.wav`
- [ ] `sfx_player_explode.wav`
- [ ] `sfx_ufo_hit.wav`
- [ ] `sfx_ufo_loop.wav`
- [ ] `march_1.wav`
- [ ] `march_2.wav`
- [ ] `march_3.wav`
- [ ] `march_4.wav`

**Total: 10 sprites (delivered) + 1 font (pending) + 9 audio files (pending) = 20 assets; 10 delivered, 10 remaining.**

---

## 8. Delivery & Integration Notes

- Drop finished files into the matching subdirectory of `assets/`. The Godot project will auto-import them on the next editor launch.
- For audio, the engine supports both `.wav` and `.ogg`. Either format is fine; `.ogg` will produce a smaller file for the UFO loop.
- Sprites are already integrated (all `Polygon2D` placeholders have been replaced with `Sprite2D` nodes pointing at the PNGs in `assets/sprites/`). See `README.md` → "Sprite Art" for how the integration works.
- The font file must be placed at exactly `assets/fonts/arcade.ttf`; the UI theme references that path.
- Audio buses named **"Music"** and **"SFX"** will need to be created by the developer in Godot's AudioServer (Project → Project Settings → Audio Buses) before the Options screen volume sliders become functional. Notify the developer when audio files are ready.
