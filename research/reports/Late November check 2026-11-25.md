# Late November check (2026-11-25, builds 6863-6868)

What changed in the game and in the other config packs since the apex rebuild (build 6861, 2026-11-15), and what it
means for this repo. Checked against Valve's data in SteamDatabase/GameTracking-Deadlock, CompLock's changelog and
benchmarks (deadlockconfig.com), OptimizationLock's commits up to `c636bda` (2026-11-23) and ghempy53/deadlock-config.

## TL;DR

1. **Nothing broke.** No convar that any variant sets was removed, blocked or re-flagged in builds 6863-6868.
   apex-testing still lints at 95 active lines, 0 dead weight.
2. **Valve changed its own stock `gameinfo.gi` once (build 6863, 2026-11-18):** `rate` min and `sv_minrate` went from
   98304 to 133120. All four variants copy Valve's stock ConVars block, so all four now carry the new value. No FPS
   effect (the client's `rate` default is 786432); it keeps the file identical to stock so tools that diff against
   Valve's file (`tools/lint.py`, Deadlock Config Manager's ranked check) don't report it as a user change.
   OptimizationLock and ghempy53 took the same change.
3. **Three new candidates from CompLock, added to apex-testing as off-by-default `[test]` lines.** None has a per-line
   measurement, and alz's baseline collection (NOTES section 8b) is still running, so none is switched on.
4. **No enforcement news.** The matchmaking guard on engine sections is still not enforced; no reports of bans for
   `gameinfo.gi` edits.

## Valve's builds

| Build | Date | Config-relevant change |
|---|---|---|
| 6863 | 2026-11-18 | Stock `gameinfo.gi`: `rate` min and `sv_minrate` 98304 -> 133120. New Vulkan shader `luminaire.slang`. |
| 6864 | 2026-11-20 | Animation schema updates. No convar or `gameinfo.gi` change. |
| 6865 | 2026-11-23 | `citadel_melee_hit_delay_max_time` 0.1 -> 0.16, new `citadel_melee_lagcomp_debug` (both server-side). |
| 6866 | 2026-11-24 | Soul bag pickups replace neutral gold (gameplay convars only). |
| 6868 | 2026-11-24 | `heroes.vdata` only. |

## New candidates

| Line | Source | What it does (Valve's text) | Status here |
|---|---|---|---|
| `citadel_camera_soft_collision 0` | CompLock 2026-11-18 ("camera trace spray off") | Default 1: "Soften the camera to wall collision distance by using the gaussian weight of fibbonnaci cone of line traces." That is 128 traces per frame, split into 8 jobs by `citadel_camera_soft_collision_multi_thread`. | `[test]` in apex. Costs camera feel: the camera snaps in at walls instead of easing. `developmentonly` + `replicated`, so it may be server-owned; check the console value in a real match. CompLock also sets `_multi_thread 0`, which only matters while soft collision is on, so it isn't added. |
| `cloth_update false` | CompLock 2026-11-08 / 11-20 | Stops cloth simulation. | `[test]` in apex. On its own, capes and coats freeze in their default pose. CompLock's +2.8% avg / +3.4% 1% low was measured together with a model mod that removes the cloth meshes (and conflicts with skin mods). |
| `sc_layer_batch_threshold_fullsort 80` | CompLock 2026-11-18 (20 -> 80) | No description. 80 is Valve's code default; Valve's stock `gameinfo.gi` sets 20. | Comment in apex only: Valve's later stock line wins, so testing it means changing the `20` in Valve's block. liv's `120` in stable/alz is overridden by that same stock line and does nothing. |

## Considered and rejected

- `citadel_unit_status_breakpoint_line_small_amt 1000000` (CompLock "Health tick lines off", +1.0% / +1.2%): removes
  the tick lines on health bars, which is information. CompLock itself only offers it for custom HP bar mods.
- `cl_disable_ragdolls true`: already rejected (Doorman's ult). CompLock turned it back off by default on 2026-11-22.
- `citadel_use_pvs_for_players` (OptimizationLock 4.0): a `gamedll` convar, so it does nothing on a client.
- `citadel_portrait_world_renderer_off true` (OptimizationLock Maxfps 2.0): hides hero models in the shop and end
  screen. Menu-only, no in-fight effect.
- `citadel_trooper_outline_enabled 1` (CompLock 2026-11-19): a readability choice, not FPS.

## Still the biggest measured gain nobody here has tried

The **sound stack update cap** (`soundcap.vpk`, deadlockconfig.com Pack Builder): +9.7% avg / +11.1% 1% low, ±1.1-1.2
(95% interval), CPU-bound 9800X3D, nothing looks or sounds different. It's a single replaced file
(`soundstacks/soundstacks_citadel_base_3d.vsndstck_c`) loaded through `addons`, so it fits the mod-compatibility rule.
It stays queued behind the apex baseline (NOTES section 7).
