# History

Older notes moved out of the README on 2026-11-28. Nothing here describes the current configs;
see [apex-complock/NOTES.md](../apex-complock/NOTES.md) for that.

## How it stays mod compatible

The base cfg ran fine without mods but broke when mods were enabled. The stable cfg changes:

- **SearchPaths** updated to the current format (`Game_UILanguage`, `Game_LowViolence`), with explicit `Mod`/`Write` lines (without them the game crashes with "Unable to read default keybinding configuration" when launched without Deadlock Mod Manager) and
  `Game citadel/addons` kept, so mods load. This is the most likely fix.
- **34 lines commented out** with a `//[mods]` prefix, so they're easy to find and restore:
  - 10 are settings the current game no longer reads (`MaxPreloadTextureResolution`, the
    `Aggregate*` lines, `PostSimulate`, `r_particle_explicit_fetch`, …), so they did nothing.
  - 9 set the game's default anyway (`panorama_*` fixes, `r_particle_allowprerender`, …).
  - 8 were risky with mods or not useful: `r_particle_newinput`, `r_skip_precache_validation_check`,
    `r_update_particles_on_render_only_frames`, `r_particle_fixedrandomseeds`,
    `r_draw_particle_children_with_parents`, `default_fov 0` and `viewmodel_fov 0` (conflict with
    FOV mods), `citadel_video_preset 9` (max is 3).
    Correction: `r_update_particles_on_render_only_frames true` turned out to be community consensus,
    so `experimental` turns it back on.
  - 7 are real engine tweaks. Tested in round 1 and they cost FPS, so they stay off.

## Experiment log

Rounds 2–5 were tested in the `experimental` variant (now on the
[`experimental` branch](https://github.com/alzzzik/alz-deadlock-cfg/tree/experimental)).


- **Round 1** (7 engine lines back on: `HDRFrameBuffer 0`, `EnableMixedResolution 1`,
  `ParticlesFoggedByDefault 0`, `PerVertexLighting 0`, `LayerBatchThresholdFullsort 200`,
  `LPVEdgeBlending 0`, `EnvironmentMapCacheSize 1024`): works with mods, **a bit less FPS** than stable.
  Dropped. These stay off.
- **OptiLock engine sections + this cfg's ConVars**: worked with mods but was 30-40 FPS worse. Dropped.
- **Round 2 (in `experimental`)**: 29 ConVars that the big config families agree on (the Deadlock Mod Manager
  "DMM Clean" consensus: 3+ families, 75%+ agreement) plus `r_distancefield_enable 0` and
  `r_update_particles_on_render_only_frames true`. They render the same things more cheaply. Nothing is hidden,
  nothing is menu-owned, everything works online. Shadows (cascades, `lb_dynamic_shadow_*`, precomputed shadow maps),
  lighting/post (directional lightmaps, flickering lights, SSAO blur, bloom scale, fog jitter), models (morphs, hair),
  world (metal sparks, grass/tree wind), UI (blur, transitions, box shadows).
- **Round 3 (in `experimental`)**: 6 lines reset to the defaults, marked `//[r3]`: `r_limit_particle_job_duration`,
  `r_particle_max_size_cull`, `r_texture_budget_threshold`, `r_texture_budget_update_period`,
  `sc_aggregate_bvh_threshold`, `sc_layer_batch_threshold`. The stutter report behind this was withdrawn by its
  author on 2026-10-15, so these just sit at Valve's defaults now, with no evidence either way.
- **Round 4 (in `experimental`, 2026-10-16, build 6785)**, from
  [the research report](reports/Deadlock%20FPS%20gains%20with%20good%20visuals.md):
  - Added: `r_citadel_disable_particle_lights true` (new Valve convar; ability effects still show, they just stop
    lighting the floor; toggle `0`/`1` live in the console to A/B), `csm_max_visible_dist 0` + `csm_cascade0-3_override_dist 0`
    (sun-shadow pass off; the sun is already off), volume fog 64/64/48 (engine minimum).
  - Fixed: `cl_ragdoll_limit -1` (Doorman's ult indicator is back), `snd_steamaudio_num_threads 2` (Valve default).
  - Removed (dead or wrong): `r_update_particles_on_render_only_frames`, `thread_pool_option` (hybrid Intel CPUs only),
    `snd_mixahead 0.05` (up to 50 ms later audio), the duplicate `sc_layer_batch_threshold_fullsort 120` and
    `snd_ui_positional false`, `lb_csm_override_staticgeo_cascades_value "true"` (parse error), `volume_fog_enable_jitter`,
    `lb_cubemap_normalization_roughness_begin`, `r_texture_stream_mip_bias` (`video.txt` wins).
  - New `experimental/video.txt`: puts the RTX 5070's idle fight-time capacity into looks: DLAA, mip bias 0,
    `shaderquality 1`, soft particles, area lights, correct `mem_level 2` / `gpu_mem_level 3`. Shadow cuts and particle
    fallbacks stay. 12 keys that no longer exist in the game were deleted (`r_render_portals`, `r_reduce_flash`, …).
    **Fill in your own VendorID, DeviceID and resolution before using it.** If fights lose FPS, revert in this order:
    DLAA → FXAA (`r_citadel_upscaling 0`), then `shaderquality 0`, then `r_particle_depth_feathering false`.
- **Result (2026-10-20, rounds 2–5 together, with mods via DMM): about −40 FPS vs stable. Not recommended; use stable.**
  Not split further, so it's unknown whether `video.txt` (DLAA at full render scale) or the `gameinfo.gi` changes cost the FPS.
