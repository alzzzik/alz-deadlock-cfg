# apex-complock: notes

> 2026-11-27: apex-complock replaced apex-testing in this repo. apex-testing's per-line notes now live in
> [apex-testing-NOTES.md](apex-testing-NOTES.md); the old files are in git history (commit 8042cb9).

**What it is:** `apex-testing/gameinfo.gi` with CompLock's CPU-side `gameinfo.gi` lines added (tagged `[cl2]`), meant to
run **together with CompLock's mod paks** in `game/citadel/addons`. Built 2026-11-25 against build 6868.

**Why:** alex's measurements (frame-time tracker, real matches):

| Setup | Sessions | Avg FPS | 1% low |
|---|---|---|---|
| apex-testing gameinfo, no CompLock mods | 15 (Nov 23-24) | 280 (247-342) | 84 (68-113) |
| CompLock gameinfo + CompLock mods, DLSS 1.7 | 5 (Nov 25) | 195 (188-207) | 107 (99-116) |

1% lows matter most to alex. CompLock's setup gave about +27% 1% lows but about -30% average, with the average stuck in
a narrow band. Working theory (unconfirmed): CompLock's mods (sound cap, HUD++, Particle Pruning) cut fight-time CPU
work and lift the lows, while CompLock's `gameinfo.gi` keeps Valve's stock engine sections and most GPU-side defaults
(sun on, particle lights on, stock shadow atlases, full lightmaps), so quiet scenes hit a GPU ceiling around 200.
This PC measured 30-40 FPS lower once before when liv's engine sections were swapped out (README experiment log).

**What's in it**
- Everything in apex-testing (liv's engine sections, GPU-side cuts, particle CPU fallback, the `[zv]` lines).
- `[cl2]` CompLock lines: HUD++ support lines, IK / foot lock / facial morphs off, camera soft collision off,
  `cloth_update false`, props break with no pieces, small render extras, and Valve's
  `sc_layer_batch_threshold_fullsort` at 80 instead of 20. These were all on during alex's CompLock sessions, so the
  only real change from those sessions is apex's lines and engine sections coming back.
- Left out of CompLock's file on purpose: `r_farz`/`r_mapextents 7000` (distant players pop in), bilinear filtering,
  `citadel_boss_glow_disabled`, damage-indicator size tweaks and `audio_viewing_damage_*` (hide information),
  `sc_instanced_mesh_motion_vectors 0` (DLSS ghosting), lines that do nothing (`default_fov`, `viewmodel_fov`,
  `r_drawviewmodel`, `citadel_camera_height`, `rpg_camera_yaw`, `r_character_decal_resolution 4`).
- `video.txt` = the CompLock pack's `video.txt` with DLSS 1.7x (`r_citadel_upscaling 4`, `mat_viewportscale 0.58`,
  `r_citadel_antialiasing 1`): the same video settings the CompLock sessions ran with. Fill in VendorID/DeviceID.

**How to test**
1. Keep CompLock's three paks in `addons` (Particle Pruning stock tracers, Sound stack update cap, HUD++ cumulative).
2. Swap only `gameinfo.gi` (and use this `video.txt` or keep the one you played the CompLock sessions with).
3. Play 3-5 sessions. Compare **1% low** against the CompLock sessions (107).
   - Lows hold (about 100+) and average rises: keep it.
   - Lows drop: go back to CompLock's `gameinfo.gi`. Then the suspects are apex's input/particle lines
     (`engine_max_ticks_to_simulate`, `cl_particle_sim_fallback_*`, `r_limit_particle_job_duration`) and
     `panorama_min_comp_layer_cache_cost 0` interacting with HUD++'s own caching.
4. Quick check for the GPU-ceiling theory with CompLock's own file: GPU usage in a quiet lane moment. Near 99% = theory holds.

## Results log

| Date | Map | Minutes | Avg FPS | 1% low | p99 frame time |
|---|---|---|---|---|---|
| 2026-11-25 | dl_midtown | 28 | 354 | 105 | 9.6 ms |

Reading after 1 session: average 354 vs CompLock's 191-195 (+80%), 1% low 105 vs ~107 (same, within CompLock's
99-116 range). Supports the GPU-ceiling theory. One session only; keep going to 3-5.
