# alz deadlock cfg

A Deadlock `gameinfo.gi` FPS config by alz.

**Goal:** as much FPS as possible while staying **mod compatible**: skins, HUD/QoL mods and
particle mods installed through Deadlock Mod Manager (DMM) should keep working.

## Variants

| Folder | Status |
|---|---|
| `stable/gameinfo.gi` | **Use this one.** Works with mods. Best FPS so far. |
| `experimental/gameinfo.gi` | Testing ground. Round 2: stable + 31 community-consensus convars. Not tested yet. |

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
- **Round 2 (current `experimental`)**: stable + 31 ConVars that the big config families agree on
  (the Deadlock Mod Manager "DMM Clean" consensus: 3+ families, 75%+ agreement), plus
  `r_distancefield_enable 0` and `r_update_particles_on_render_only_frames true`. All of them
  render the same things more cheaply. None hides objects, changes the camera, or is controlled by `video.txt`.
  - Shadows: `csm_max_num_cascades_override 0`, `csm_res_override_0-3 1`, `lb_dynamic_shadow_*`,
    `lb_precomputed_shadowmap_enable false`, `r_citadel_distancefield_shadows false`, …
  - Lighting/post: `r_directional_lightmaps false`, `r_light_flickering_enabled false`, `r_ssao_blur false`,
    `mat_tonemap_bloom_scale 0`, `volume_fog_enable_jitter false`
  - Models/animation: `r_morphing_enabled false`, `r_smooth_morph_normals false`,
    `r_hair_indirect_transmittance false`, `animgraph_footlock_enabled false`, `animgraph_slowdownonslopes_enabled false`
  - World/particles: `fx_drawmetalspark false`, `r_world_wind_frequency_grass/trees 0`
  - UI: `panorama_disable_blur true`, `panorama_allow_transitions false`, `panorama_disable_box_shadow true`
  - Result: _not tested yet._

## Research notes (for later rounds)

How it was researched: every setting in 10 configs (Sqooky's OptimizationLock family: Sqooky, Eskay,
max-fps, boot, Piggy, Kaizuchaneru x2; OptiLock FPS/Potato/Ultra Potato) was compared against the
current stock `gameinfo.gi`, using the Deadlock Mod Manager catalog for convar flags and defaults.

- **`video.txt` beats `gameinfo.gi`** for settings in the in-game video menu (`r_citadel_shadow_quality`,
  `r_citadel_ssao_quality`, bloom, depth of field, `r_texture_stream_mip_bias`, `fps_max`, …).
  This cfg's values for those don't matter if `video.txt` sets them.
- **Next candidates** (fewer configs agree, test separately): `skeleton_instance_lod_optimization 1`,
  `phys_threaded_transform_update/kinematic_bone_update/cloth_bone_update 1`,
  `wind_system_temporal_smoothing 0`, `r_aoproxy_cull_dist 0.01`, `r_monitor_3dskybox 0`,
  `r_character_decal_monitor_render_res 64`, `r_texturefilteringquality` (this cfg uses 5 = 16x aniso;
  all 10 configs use 0 = bilinear, which is blurrier).
- **Not worth it:** settings marked `gameinfo_cannot_override` (`r_particle_max_detail_level`,
  `r_rainparticledensity`, `csm_max_shadow_dist_override`, …) are ignored by the game when set here.
- **FPS mods (VPKs) that pair well** (from Sqooky's "Various Addons Relating to Performance" and
  OptiLock's "Essential Fixes"): Optimized Soul Container (low-poly soul orbs), Vindicta Scope Downscale
  (4096² scope texture → 1080p), Optimized McGinnis Wall, Clutter be Gone "Screenspace" (removes
  screen-edge smoke/glow particles; upstream reports a 30 FPS drop on vents without it).
  Skip Blur Disabler: `panorama_disable_blur` already does it without touching HUD files.

## Credits

- **liv** ([7liv/compylock](https://github.com/7liv/compylock)): the original cfg this one started from.
- [dacooderr / OptiLock](https://github.com/dacooderr/OptiLock): used as the mod-compatible reference.
- [Sqooky / OptimizationLock](https://github.com/Sqooky/OptimizationLock): the config family liv's cfg comes from.

Both upstream projects are GPL-3.0, so this repo is too (see `LICENSE`).
