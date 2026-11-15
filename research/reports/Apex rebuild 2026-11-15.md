# apex: an audited rebuild of alz (2026-11-15, build 6861)

`apex/` is alz's setup with every line checked by a script against Valve's data, the dead weight removed, four
harmful lines dropped, and a small set of new lines added. Nothing in it has been benchmarked on alz's PC yet.
It was built to be the best starting point for testing, not as a measured result.

## What was checked, and how

- **Game state:** current build is 6861 (2026-11-11). Stock `gameinfo.gi` has not changed since build 6801. The convar
  dump last changed in 6857; between 6801 and 6861 the only config-relevant change is that
  `r_particle_max_detail_level` lost `gameinfo_cannot_override` in build 6812 (min 0, max 3). 124 convars are still blocked.
  Source: [SteamDatabase/GameTracking-Deadlock](https://github.com/SteamDatabase/GameTracking-Deadlock) history.
- **Every ConVars line** was classified with `tools/lint.py` against Deadlock Mod Manager's catalog
  (2026.11.13-1, convar build 6857): removed, blocked, server-replicated, outside min/max, equal to default, duplicate,
  `archive`, or owned by `video.txt`.
- **Every non-stock engine key** was searched for in the game's binary string dumps. Four `RenderSystem` keys appear
  in no binary and were deleted: `GraphicsPipelineLibrary`, `SwapChainSampleableDepth`, `VulkanOnly_Linux`,
  `VulkanSteamShaderCache`.
- **All 85 lines of Valve's own ConVars block** are byte-for-byte present (checked by script).

| | stable / alz | apex |
|---|---|---|
| Active ConVars lines (non-default, applied) | 122 | 108 |
| Dead-weight lines | 61 | 0 |
| Edits in sections named by the matchmaking message | 20 | 16 |

## New finding: saved `archive` values beat `gameinfo.gi`

[ghempy53's runtime probe](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/OWNER-PROBE-2026-11-03.md)
(build 6842, console reads in the Hideout) showed that for `archive`-flagged convars the game uses the value saved in
`Steam/userdata/<id>/1422450/local/cfg/machine_convars.vcfg`, not the file: `fps_max`, `fps_max_ui`, `cam_ideallag`,
`cl_ragdoll_limit` and `snd_mixahead` all read the saved value, and the game wrote the same values back on exit.
The same probe confirmed blocked lines read Valve's default, and that plain and `cheat` lines do apply (locally;
online is untested, see "Open questions").

What this means for alz's file: `cl_ragdoll_limit 0`, `enable_boneflex 0` and `snd_mixahead 0.05` have probably never
applied on an existing profile. All three are harmful if they do apply (Doorman's ult indicator hidden, more melee
mispredictions, up to 50 ms later audio), so apex deletes them. The nine harmless `archive` lines (camera lag, blood,
first-person tracers, solo queue) stay, tagged `[arch]`. To force an `archive` value, use a launch option
(`+name value`); the game then saves it.

## What changed from alz

**Removed, no effect (61 lines):** 19 convars that no longer exist, 5 blocked, 11 server-replicated, the
`video.txt`-owned lines (`r_citadel_shadow_quality`, `r_citadel_ssao_quality`, bloom, DoF, mip bias, the static-geo
cascade pair), liv's duplicates of Valve's block, and lines that only restate the default.

**Removed, changes behaviour (9 lines):**

| Line | Why |
|---|---|
| `r_particle_min_timestep 0.00241` | Makes fast particles jagged above about 415 FPS (ghempy53 bisect, 2026-10-17). alz runs uncapped. |
| `sc_instanced_mesh_motion_vectors 0` | DLSS uses motion vectors. Turning them off for instanced meshes invites ghosting. |
| `snd_boxverb_simd false` | Turns off the fast vector path for reverb. It can only cost CPU. |
| `snd_steamaudio_num_threads 6` | Valve's 2 is enough for a feature its own block mostly switches off. |
| `thread_pool_option 2` | Picks a core type on hybrid Intel CPUs. Nothing to pick on a 5700X. |
| `cl_ragdoll_limit 0`, `enable_boneflex 0`, `snd_mixahead 0.05` | See the `archive` section. |
| `citadel_melee_shake_*`, hideout ball, `nav_edit_use_camera` | Server-side; bot matches only. |

**Changed (3):** `lb_dynamic_shadow_resolution_base` 16 → 128, `lb_ssss_samples` 0 → 3,
`r_character_decal_resolution` 4 → 256. These are the engine minimums the old values were being raised to.

**Added, zero visual change, tag `[zv]` (9):** the CompLock lines already sitting in `alz-experimental`:
`cl_generate_postdataupdatepreserved false`, `panorama_min_comp_layer_cache_cost 0`,
`panorama_comp_layer_lru_lifetime 4`, and six wind/rope lines for things alz already hides.

**Added, small visual cost, tag `[fight]` (1):** `r_citadel_disable_particle_lights true`. Ability effects still
draw; they stop casting light on the floor and heroes. It is a `release` convar, so `0`/`1` can be flipped live.

**Off by default, tag `[test]` (2):** `r_particle_max_detail_level 2` and
`engine_low_latency_sleep_after_client_tick true`.

**`video.txt`:** alz's file minus `setting.r_particle_depth_feathering` (removed from the game).

**Kept on purpose:** all of liv's engine-section edits that the game reads (zeroed shadow atlases, fog switches,
bigger buffer pools). Engine-section changes have measured worse on this PC twice, so apex does not touch what works.

## What the other packs did since late October

- **OptimizationLock 3.9 (2026-11-04)** moved the same way as apex on three lines: `snd_boxverb_simd` false → true,
  `snd_mixahead` 0.05 → 0.01, and it added `cl_generate_postdataupdatepreserved false` and
  `panorama_min_comp_layer_cache_cost 0` (both also in CompLock and in apex's `[zv]` group).
- **CompLock** dropped its own `r_particle_min_timestep` line (no reason given).
- **OptiLock** and **compylock** have had no `gameinfo.gi` change since 2026-10-26 and 2026-10-10.
- All four packs still set `sc_instanced_mesh_motion_vectors 0`. apex goes against them on purpose because it ships
  DLSS; if you run without an upscaler, adding the line back is reasonable.

## Evidence status

There is still almost no per-line FPS data for Deadlock. The only careful benchmark is
[CompLock's](https://deadlockconfig.com/docs/benchmarks/) (build 6860, 9800X3D + RX 9070, Linux, Vulkan, replayed
fights, 95% intervals). Its isolated results: cloth off +4.0% average when CPU-bound and about 0 when GPU-bound;
client physics and ragdolls off +2.6% average with no gain in 1% lows; sound-stack update cap mod +6.7% / +6.3%;
particle pruning mod +8.4 to +10.1%. Everything else, including every line apex adds, is reasoned from Valve's own
descriptions, not measured.

## Test plan

Hold `video.txt` fixed. Use the same mode and a comparable fight-heavy stretch; compare 1% lows, not averages.

1. **apex vs alz**, two or three matches each. If apex is equal or better, keep it: it is the cleaner file.
2. If apex is worse, the suspects are, in order: the three `[zv]` panorama/entity lines, then
   `r_citadel_disable_particle_lights`, then `sc_instanced_mesh_motion_vectors` (add `"0"` back).
3. Then one `[test]` line at a time. `engine_low_latency_sleep_after_client_tick` can be flipped live in the console.
   `r_particle_max_detail_level 2` needs a restart; check the console prints 2 and watch big ults for missing pieces.
4. Run `r_farz` (or `r_drawviewmodel`) in the console **during a matchmade game**. If it prints Valve's default,
   cheat-flagged lines are reverted online and the `[cheat]` lines are dead too.

## Open questions

- Do `cheat`-flagged lines survive joining a real server? The engine has the string "FCVAR_CHEAT and
  FCVAR_REPLICATED cvars reverted to defaults (remote connection)". Nobody has published a console read from a matchmade game. A quick visual check: if your
  weapon viewmodel is hidden in a real match, `r_drawviewmodel false` survived, and so did the other `[cheat]` lines.
- Does a profile with nothing saved for an `archive` name take the `gameinfo.gi` value? Untested.
- Matchmaking still accepts engine-section edits (ghempy53 queued a Street Brawl on 2026-11-03 with edits). Valve's
  message names those sections, so this can change in any patch. A fallback is to copy apex's ConVars block into a
  stock `gameinfo.gi` with the mod SearchPaths.
