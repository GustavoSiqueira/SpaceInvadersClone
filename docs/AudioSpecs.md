# Audio Asset Specifications

**Format:** OGG Vorbis preferred (Godot-native). Mono for SFX, stereo for music.
**Style reference:** Retro arcade, 8-bit / chiptune aesthetic.
**Directory in project:** `assets/audio/`

---

## Sound Effects (SFX)

| # | Asset filename | Description | Duration | Notes |
|---|---|---|---|---|
| 1 | `player_shoot.ogg` | Player laser fire | ~0.2s | Sharp, high-pitched "pew" or zap. Distinct from enemy. |
| 2 | `enemy_shoot.ogg` | Alien fires a bullet | ~0.2s | Lower-pitched or buzzier than player shot. |
| 3 | `alien_step_1.ogg` | Alien formation footstep A | ~0.1s | Deep bass "thump" or "boop". Four variants (1–4) alternated in sequence to recreate the classic Space Invaders march. |
| 4 | `alien_step_2.ogg` | Alien formation footstep B | ~0.1s | Slightly higher pitch than step 1. |
| 5 | `alien_step_3.ogg` | Alien formation footstep C | ~0.1s | |
| 6 | `alien_step_4.ogg` | Alien formation footstep D | ~0.1s | |
| 7 | `alien_explosion.ogg` | Alien killed | ~0.3s | Crunchy retro explosion. Short and punchy. |
| 8 | `player_explosion.ogg` | Player ship destroyed | ~0.8s | More dramatic than alien explosion. Layered crunch + low rumble. |
| 9 | `ufo_loop.ogg` | UFO flying across the screen | ~1–2s looping | Eerie, high-pitched oscillating tone. Looped while UFO is alive. Must loop seamlessly — no gap at start/end. |
| 10 | `ufo_explosion.ogg` | UFO destroyed | ~0.5s | Satisfying high-value hit — sparkly + big crunch. |
| 11 | `shield_hit.ogg` | Shield segment destroyed | ~0.15s | Short fizz or crumble. Used for both player bullet and enemy bullet hitting a shield. |
| 12 | `wave_clear.ogg` | All aliens cleared | ~1.5s | Short triumphant fanfare or ascending chime. Plays once before the next wave loads. |
| 13 | `game_over.ogg` | Game over | ~2s | Descending, deflating jingle. |
| 14 | `player_respawn.ogg` | Player ship respawns | ~0.5s | Soft "ready" chime or rising tone. |
| 15 | `ui_select.ogg` | Menu button hover/focus | ~0.05s | Subtle blip. |
| 16 | `ui_confirm.ogg` | Menu button pressed / setting changed | ~0.1s | Slightly brighter blip than select. |

---

## Music

| # | Asset filename | Description | Duration | Notes |
|---|---|---|---|---|
| 17 | `music_title.ogg` | Title screen background music | 60–90s loop | Chill retro loop. Should feel like an attract screen. |
| 18 | `music_gameplay.ogg` | In-game background music | 60–90s loop | Driving, uptempo. Should stay energetic but not intrusive. Can be layered or replaced by the alien march SFX if preferred. |

---

## Implementation Notes

- The **alien march** (assets 3–6) is the most iconic element. Four short percussive sounds are played in rotating sequence (`step_1 → 2 → 3 → 4 → 1 → …`), getting faster as aliens die. Keep each sound very short and rhythmically neutral.
- The **UFO loop** (`ufo_loop.ogg`) must loop seamlessly — leave no gap at the start/end.
- All SFX should be **normalized** and kept under 0 dB peak. The game handles per-bus volume via `"Music"` and `"SFX"` AudioServer buses.

---

## Where Each Sound Triggers (for implementers)

| Sound | Script | Trigger |
|---|---|---|
| `player_shoot.ogg` | `player.gd` | `_shoot()` |
| `enemy_shoot.ogg` | `alien_formation.gd` | `_try_shoot()` |
| `alien_step_1–4.ogg` | `alien_formation.gd` | `_step()` — rotate through 4 variants, tempo tied to `step_interval` |
| `alien_explosion.ogg` | `alien.gd` | `kill()` |
| `player_explosion.ogg` | `player.gd` | `hit()` |
| `ufo_loop.ogg` | `ufo.gd` | `_ready()` → loop; stop on `ufo_exited` or `hit()` |
| `ufo_explosion.ogg` | `ufo.gd` | `hit()` |
| `shield_hit.ogg` | `player_bullet.gd` / `enemy_bullet.gd` | `_on_area_entered()` — shield branch |
| `wave_clear.ogg` | `alien_formation.gd` | `formation_cleared` signal |
| `game_over.ogg` | `main.gd` | `_game_over()` |
| `player_respawn.ogg` | `player.gd` | `respawn()` |
| `ui_select.ogg` | `title_screen.gd` / `options_screen.gd` | button focus |
| `ui_confirm.ogg` | `title_screen.gd` / `options_screen.gd` | button pressed |
| `music_title.ogg` | `title_screen.gd` | `_ready()` — loop |
| `music_gameplay.ogg` | `main.gd` | `_ready()` — loop; pause/resume with `_toggle_pause()` |
