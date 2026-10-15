# alz deadlock cfg

A Deadlock `gameinfo.gi` FPS config by alz.

**Goal:** as much FPS as possible while staying **mod compatible**: skins, HUD/QoL mods and
particle mods installed through Deadlock Mod Manager (DMM) should keep working.

## Variants

| Folder | Status |
|---|---|
| `stable/gameinfo.gi` | **Use this one.** Works with mods. Best FPS so far. |
| `experimental/gameinfo.gi` | Testing ground. Works with mods, but slightly **lower** FPS than stable right now. |

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
    `r_update_particles_on_render_only_frames` (more particle work = less FPS),
    `r_particle_fixedrandomseeds`, `r_draw_particle_children_with_parents`, `default_fov 0` and
    `viewmodel_fov 0` (conflict with FOV mods), `citadel_video_preset 9` (max is 3).
  - 7 are real engine tweaks, being tested in `experimental` (below).

## Experiment log

- **`experimental`**: turned back on `HDRFrameBuffer 0`, `EnableMixedResolution 1`,
  `ParticlesFoggedByDefault 0`, `PerVertexLighting 0`, `LayerBatchThresholdFullsort 200`,
  `LPVEdgeBlending 0`, `EnvironmentMapCacheSize 1024`.
  Result: works with mods, **a bit less FPS** than stable. Next step: bring them back one at a time
  to find which one costs FPS.
- **OptiLock engine sections + this cfg's ConVars**: worked with mods but was 30-40 FPS worse. Dropped.

## Credits

- **liv** ([7liv/compylock](https://github.com/7liv/compylock)): the original cfg this one started from.
- [dacooderr / OptiLock](https://github.com/dacooderr/OptiLock): used as the mod-compatible reference.
- [Sqooky / OptimizationLock](https://github.com/Sqooky/OptimizationLock): the config family liv's cfg comes from.

Both upstream projects are GPL-3.0, so this repo is too (see `LICENSE`).
