# OptiLock Community Config review (2026-10-27)

Source: [dacooderr/OptiLock › OptiLock Community Config](https://github.com/dacooderr/OptiLock/tree/HEAD/OptiLock%20Community%20Config),
checked at OptiLock commit `8b78c0f` (2026-10-26). Every line was compared against Valve's stock `gameinfo.gi` and the
convar dump for build 6821 (SteamDatabase GameTracking `d251cf9`, 2026-10-26), against OptiLock's own FPS Config
(Recommended), and against alz's `alz/gameinfo.gi`. Nobody has published FPS measurements for this preset. Nothing in
the alz repo's cfg files was changed.

## What it is

- An **"Ultra Low" preset made by the community**, added in one commit (`174fc95`, 2026-10-21, "added community
  variant") and not touched since. Its header says OptiLock **ver. 5.9**, so it lacks the OptiLock 6.0/6.1 changes.
- The readme is upfront: *"This will make your game look horrendous in the hideout but it's actually not too bad in a
  live match."* It is a maximum-FPS, low-looks preset, the opposite of alz's goal.
- It already has the 6801 fix (`BakedLighting Version 5`, `sh2_lum`, new `PGIVersion`) and a SearchPaths block with
  explicit `Mod`/`Write` and the Deadlock Mod Manager markers. It loads and works with mods.

## How much of it actually does something

ConVars lines, classified against build 6821:

| Class | Lines |
|---|---|
| Real client-side changes | 226 |
| Same as Valve's default (no effect) | 68 |
| `replicated` (the server's value wins online) | 44 |
| Server-only (does nothing in your client) | 21 |
| Blocked from `gameinfo.gi` | 19 |
| Don't exist in the game | 17 |

So about 170 of ~395 lines do nothing in a real match. Its `video.txt` also has 11 keys that aren't game settings
(`r_citadel_mboit`, `r_screen_space_shadows`, `r_citadel_half_res_noisy_effects`, `r_reduce_flash`, `r_particle_shadows`,
`r_citadel_motion_blur`, and others), so the game ignores them.

## Where the FPS comes from: big visual cuts

These are the lines doing most of the work. They are why it looks "horrendous", and why none of them fit alz:

| Line | What you'd see |
|---|---|
| `sc_disable_baked_lighting true` | Turns off the maps' baked lighting: flat, washed-out world |
| `video.txt` `r_texture_stream_mip_bias 8` + `r_texture_stream_max_resolution 1` (engine clamps to 512) | Very blurry textures |
| `r_particle_max_detail_level 0` (in both files; works from gameinfo since build 6812) | Lowest-detail ability effects |
| `video.txt` `shaderquality 0`, `r_arealights false`, `r_citadel_antialiasing 0`, volume fog 0/0/0 | Low shading, no area lights, no anti-aliasing |
| `r_particle_timescale 0.7` | Effects animate at 70% speed (OptiLock's own presets now use 1.2) |
| `sc_screen_size_lod_scale_override 0.001`, `sc_instanced_mesh_lod_bias 0.001`, `r_propsmaxdist 600`, `r_farz 7000` | Aggressive LOD and draw-distance changes |
| `r_character_decal_resolution 0.001`, `r_decals 0`, impact-decal lines | No hero or bullet decals |
| `citadel_camera_hero_fov 100` | Changes your field of view, a gameplay change, not FPS |
| `cl_ragdoll_limit 1`, `citadel_boss_glow_disabled 1`, `citadel_in_world_item_panel_dpi 0.75` | Readability and UI cuts |

## What's different from OptiLock's main FPS preset

Compared with OptiLock FPS Config (Recommended), the Community preset mostly cuts *more*: lower texture cap, decals off,
particle timescale 0.7, color correction off, shorter draw distance, a 100 FOV. It also *drops* a few things the main preset
has, because it predates 6.x: the sun-shadow (`csm_*`) block, particle lights off, `r_texture_pool_size 256`,
`RenderSystem/MinDXLevel 80`. Nothing here is a new discovery the main preset lacks. It's the same family pushed further.

## Ideas worth borrowing for alz (zero visual change expected, all unmeasured)

These are the only parts that might give FPS without changing alz's picture, because the features they touch are
already off in alz's cfg. They are **engine-section keys**, and on this PC engine-section edits have cost FPS before
(liv's round 1, OptiLock's sections). So each one needs its own test, with `video.txt` held fixed, in real matches. All
of them exist in the build-6821 engine DLLs (`scenesystem.dll` strings), so the game does read them.

| # | Line (in `SceneSystem { }`) | Why it should look identical for alz | Possible gain |
|---|---|---|---|
| 1 | `PointLightShadowsEnabled 0` | alz already has light shadow casting off (`lb_enable_shadow_casting false`, shadow quality 0) | Skips setup for shadows that are never drawn |
| 2 | `SparseShadowTrees 0` | alz already has `sparseshadowtree_enable_rendering 0` | Skips building data that's never used |
| 3 | `DisableShadowFullSort 1` | Only affects how shadow draws are sorted, and alz draws almost none | Tiny CPU saving at most |
| 4 | `GpuLightBinnerBinEnvMaps 1` + `GpuLightBinnerBinLPVs 1` | Moves sorting of reflection probes and lighting volumes onto the GPU light binner. Same result, different processor | Could help a CPU-bound PC. Also the riskiest of these: watch reflections and lighting for glitches |

And one ConVar:

| # | Line (in `ConVars`) | Why it should look identical | Possible gain |
|---|---|---|---|
| 5 | `citadel_player_model_force_highest_lod "false"` | Valve: "forces the **local player** pawn to render using the highest LOD". Your own hero is always right in front of the camera, so it picks the top LOD anyway | Tiny |

Skipped on purpose: `r_citadel_drop_shadow_update_frequency 0` (undocumented, nobody knows if 0 means "never" or "every
frame"), `sc_force_materials_batchable true` (a `cheat` convar with no description; rendering-bug risk),
`sc_force_single_display_list_per_layer 1` (undocumented), `r_frame_sync_enable 0` (undocumented, may affect frame
pacing and latency), `RenderSystem/MinStreamingPoolSizeMB 512` and `IndexBufferPoolSizeMB 64` (alz's bigger pools suit
12 GB VRAM), `UseHardwareGammaRamp 0` (only matters in exclusive fullscreen; alz runs borderless), and `NetworkSystem/
BetaUniverse FakeLag/FakeLoss 0` (only apply in Valve's internal beta universe, not live matches).

## Bottom line

- The Community Config is a "make it ugly, make it fast" preset. It's a fine choice for very weak PCs, but it goes
  against alz's "looks decent" rule, and it's stuck at OptiLock 5.9.
- About 170 of its lines do nothing in real matches, and most of its FPS comes from the visual cuts above.
- The only borrowable parts are the five zero-visual tests listed above. Try them on the experimental variant one at a
  time, once that variant is rebuilt on the current stable `gameinfo.gi` (the experimental branch still has the
  pre-6801 lighting format; see `research/reports/QoLLock test branch and free FPS.md`).
