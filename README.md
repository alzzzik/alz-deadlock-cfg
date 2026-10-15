# alz deadlock cfg

A Deadlock `gameinfo.gi` FPS config by alz.

**Goal:** as much FPS as possible while staying **mod compatible**: skins, HUD/QoL mods and
particle mods installed through Deadlock Mod Manager (DMM) should keep working.

## Variants

| Folder | Status |
|---|---|
| `stable/gameinfo.gi` | **Use this one.** Works with mods. Best FPS so far. |
| `experimental/gameinfo.gi` | Testing ground. Stable + round 2 (consensus convars) + round 3 (stutter fixes). Not tested yet. |

**Full research:** [RESEARCH.md](RESEARCH.md), with what still gives FPS (cfg, `video.txt`, mods, launch options,
Windows/driver), what's dead weight, and what costs gameplay.

Every variant's file is named `gameinfo.gi`, so you can drop it straight into the game folder.

## Install

1. Back up `steamapps/common/Deadlock/game/citadel/gameinfo.gi`.
2. Copy the variant's `gameinfo.gi` over it.
3. Launch with mods on (DMM or Steam).
4. Game patches can overwrite `gameinfo.gi`. After an update, copy it in again.

## How it stays mod compatible

The base cfg ran fine without mods but broke when mods were enabled. The stable cfg changes:

- **SearchPaths** updated to the current format (`Game_UILanguage`, `Game_LowViolence`) and
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
  `sc_aggregate_bvh_threshold`, `sc_layer_batch_threshold`. Another config author measured camera-turn stutter and
  lower FPS with these on.
- Result: _not tested yet._ If `experimental` is worse, test round 3 alone first.

## Top actions outside the cfg (details in RESEARCH.md)

1. **FPS mods:** Screenspace Particle Disabler ("Clutter be Gone"), Optimized Soul Container, Vindicta Scope Downscale.
2. **`video.txt`:** add the shadow/particle cuts every other pack has. Set `r_render_portals` to `1` (0 breaks Doorman's door).
3. **Windows/driver:** shader cache 10 GB or Unlimited, HAGS on, windowed optimizations on, unused overlays off. Optionally SMT off.
4. **Renderer:** stay on DX11 unless `-vulkan` measurably beats it on your PC.

## Credits

- **liv** ([7liv/compylock](https://github.com/7liv/compylock)): the original cfg this one started from.
- [dacooderr / OptiLock](https://github.com/dacooderr/OptiLock): used as the mod-compatible reference.
- [Sqooky / OptimizationLock](https://github.com/Sqooky/OptimizationLock): the config family liv's cfg comes from.
- Research help: [Deadlock Mod Manager](https://github.com/deadlock-mod-manager/deadlock-mod-manager) perf catalog,
  [ghempy53/deadlock-config](https://github.com/ghempy53/deadlock-config) (measured A/B tests),
  [simulieren/deadtune](https://github.com/simulieren/deadtune).

Both upstream projects are GPL-3.0, so this repo is too (see `LICENSE`).
