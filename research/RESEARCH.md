# Research: getting more FPS out of alz deadlock cfg

Consolidated 2026-10-15, game build ~6779. Everything here was checked against Valve's own data (the convar dump,
the stock `gameinfo.gi`, the matchmaking strings) wherever possible. Player reports are labelled as such.

**Newer reports:** [QoLLock test branch and free FPS (2026-10-27)](reports/QoLLock%20test%20branch%20and%20free%20FPS.md): QOLLOCK's test branch, zero-visual proposals per variant, cleanup list and corrections.
[OptiLock 5.8 update (2026-10-21)](reports/OptiLock%205.8%20update%202026-10-21.md): what OptiLock changed and what suits alz.
[build 6801 changes (2026-10-20)](reports/Deadlock%20build%206801%20changes.md): the lighting
format change that broke every pre-6801 cfg, and what the patch means for FPS.

## TL;DR

1. **About 60 lines in the stable cfg do nothing.** 19 are settings the game no longer has, 5 are blocked from
   `gameinfo.gi`, 7 are overridden by `video.txt`, 26 just restate the default, and 3 are below the allowed minimum,
   so the game raises them. A further ~15 only work in bot matches, or the server overrides them online. None of these
   hurt, but they aren't giving you FPS either.
2. **Six lines in the stable cfg caused camera-turn stutter and lower FPS when another config author measured them.**
   They are the main new lead, and `experimental` (round 3) resets them to the game defaults.
3. **The real FPS levers still left are mostly outside `gameinfo.gi`:** `video.txt` (liv's is the least optimized of the
   packs), FPS mods (VPKs), and Windows/driver/BIOS settings (SMT off has the biggest player-reported gain).
4. **Deadlock is CPU-bound in fights for almost everyone,** even on a 9800X3D. Lighting, shadow and texture cuts help
   the GPU, but fight-time 1% lows come from CPU work: particles, animation, UI events.
5. **Stay on DX11.** Most reports put Vulkan 30-40 FPS lower and less stable. Some AMD systems are the exception, so test both.

## 1. Rules of the game (what can and can't be tuned)

| Fact | Source | What it means for this cfg |
| --- | --- | --- |
| Since build 6417 (2026-03-27) the matchmaking error reads: *"unsupported changes to the following sections of their gameinfo.gi: Engine2, MaterialSystem2, NetworkSystem, Particles, RenderSystem, SceneSystem, WorldRenderer"*. `ConVars` isn't on the list. | Valve localization file; DMM docs; ghempy53 research | Tweaks in `ConVars` are queue-safe. The stable cfg (from liv) edits the guarded sections in **23 places** (shadow and fog buffers zeroed, render pools resized). Queueing works today, so it isn't enforced, but it could be at any time. |
| 124 convars carry `gameinfo_cannot_override` (49 on 2026-09-24, 77 after City Never Sleeps, 124 since build 6769). The game reads them from `gameinfo.gi` but ignores them. | Valve convar dump | Includes `r_shadows`, fog master switches, `r_particle_max_detail_level`, `lb_enable_dynamic_lights`, `lb_enable_stationary_lights`, `lb_enable_baked_shadows`, `r_citadel_gpu_culling`. |
| Settings in the in-game video menu are saved to `video.txt`, and that value beats `gameinfo.gi`. | DMM catalog rules | `r_citadel_shadow_quality`, `r_citadel_ssao_quality`, bloom, DoF, `r_texture_stream_mip_bias`, `fps_max` in the cfg are dead weight. Liv's `video.txt` sets `fps_max 0`, so the cfg's 400 cap never applies. |
| `cheat`-flagged convars **do** apply from `gameinfo.gi` at startup; they just can't be changed live. | ghempy53 research; DMM includes them | (Earlier advice in this repo said otherwise; that was wrong.) |
| `replicated` convars: the server's value wins online. Server-only convars (`ai_*`, `citadel_melee_shake_*`, hideout, `nav_*`) only do anything in bot matches. | Valve dump flags | They're fine for the hideout but do nothing in real matches. |
| Values outside a convar's min/max are clamped. | Valve dump | `lb_dynamic_shadow_resolution_base 16` gets raised to 128, `lb_ssss_samples 0` to 3, `r_character_decal_resolution 4` to 256. Liv's `video.txt` `volume_fog_* 16` gets raised to 64/64/48. |

## 2. Audit of `stable/gameinfo.gi`

**No effect at all (safe to delete, no FPS change):**
- Removed from the game (19): `r_citadel_enable_pano_world_blur`, `citadel_damage_text_batching_window_ability`,
  `citadel_distance_mouse_move_for_minimap_drawing`, `citadel_unit_status_old_update_rate`,
  `citadel_unit_status_single_bar_mode`, `citadel_camera_height_ceiling_distance`, `mat_async_shader_load`,
  `r_citadel_ssao_thin_occluder_compensation`, `r_lightmap_bicubic_filtering`, `r_multiscattering`,
  `r_citadel_screenspace_particles_full_res`, `cl_enable_eye_occlusion`, `csm_viewmodel_farz`, `r_async_compute_fog`,
  `r_citadel_depth_prepass_dynamic_objects`, `cl_async_usercmd_send_disabled_recvmargin_min`,
  `panorama_classes_perf_warning_threshold_ms`, `snd_event_browser_default_stack`, `snd_event_browser_focus_events`
- Blocked from `gameinfo.gi` (5): `lb_enable_dynamic_lights`, `lb_enable_baked_shadows`, `lb_enable_stationary_lights`,
  `sc_fade_distance_scale_override`, `r_citadel_gpu_culling`
- Overridden by `video.txt` (7): `r_texture_stream_mip_bias`, `r_citadel_shadow_quality`, `r_citadel_ssao_quality`,
  `r_depth_of_field`, `r_effects_bloom`, `r_post_bloom`, `fps_max`
- Clamped (3): see the table above.
- Online, server value wins / bot matches only: `citadel_melee_shake_*`, `citadel_hideout_ball_*`, `nav_edit_use_camera`,
  `citadel_camera_see_distance_max`, `citadel_shoot_forward_offset`, `citadel_stuck_camera_trace_extra_length`,
  `rpg_camera_yaw`, `debug_draw_enable`, `ik_final_fixup_enable`, `phys_cull_internal_mesh_contacts`,
  `snd_occlusion_bounces`, `snd_occlusion_rays`

**Gameplay costs in the stable cfg (your call):**

| Line | Cost (upstream FAQ / Valve) | Fix if you care |
| --- | --- | --- |
| `cl_ragdoll_limit "0"` | Hides Doorman's ultimate indicator. | `"-1"` |
| `enable_boneflex "0"` | More melee mispredictions on Venator and others. | remove the line |
| `sc_screen_size_lod_scale_override "0.55"` | Holes in Victor and Paige at some angles; Sinner's Sacrifice lights turn into triangles. | remove the line |
| `r_size_cull_threshold "0.9"` | High values hide crates and trooper health bars at range (0.9 is mild). | `"0.8"` |
| `r_particle_max_texture_layers "4"` | Fine at 4. Below 4, Infernus afterburn, Paige's fire and Drifter look blocky. | keep |
| `engine_max_ticks_to_simulate "2"`, `engine_accurate_input_processing_delta_time "true"` | Camera/input feel. Another author reverted both when the camera "felt wrong". | remove if aiming feels off |
| `r_drawviewmodel`, `r_render_hair`, `r_drawropes`, grass fades, `r_rendersun 0` | Cosmetic removals. | keep (deliberate) |

## 3. Round history and the test queue

| Round | Change | Status |
| --- | --- | --- |
| 1 | 7 engine lines back on (`HDRFrameBuffer 0`, `EnableMixedResolution 1`, …) | Tested: slightly **less** FPS. Dropped. |
| - | OptiLock engine sections + this cfg's ConVars | Tested: 30-40 FPS **less**. Dropped. |
| 2 | 29 consensus convars (3+ config families, 75%+ agree; nothing hidden, nothing menu-owned), `r_distancefield_enable 0`, `r_update_particles_on_render_only_frames true` | In `experimental`, untested |
| 3 | Reset 6 lines to the defaults: `r_limit_particle_job_duration`, `r_particle_max_size_cull`, `r_texture_budget_threshold`, `r_texture_budget_update_period`, `sc_aggregate_bvh_threshold`, `sc_layer_batch_threshold` | In `experimental`, untested. Another author measured camera-turn stutter and lower FPS with these on. |

`experimental` = stable + round 2 + round 3. If it beats stable, it gets promoted. If it's worse, split it: round 3
alone first (it's the one with measured evidence), then round 2 in halves (shadows, then the rest).

**Next candidates (one at a time):**
- `r_strip_invisible_during_sceneobject_update`: already `1` here (all 7 OptimizationLock-family configs set it).
- `engine_low_latency_sleep_after_client_tick "true"`: forum users report more FPS, but another author got keyboard
  input lag. It's a `release` convar, so A/B it live in the console during a fight before touching the cfg.
- `r_texturefilteringquality "0"` (bilinear): all 10 configs use it. Yours is 5 (16x aniso). Blurrier textures at an angle,
  for a small GPU gain.
- Reset the 23 guarded engine-section edits to stock: queue-proof. FPS effect unknown, since some of those zeroed
  shadow/fog buffers may be real GPU savings. Test only if Valve starts enforcing the guard.

**Not worth it / don't:**
- Anything `gameinfo_cannot_override` (`r_shadows`, `r_particle_max_detail_level`, `csm_max_shadow_dist_override`,
  `r_rainparticledensity`, `lb_shadow_map_cull_empty_mixed` since build 6769, …).
- `cpu_level` / `gpu_level` / `gpu_mem_level` / `mem_level` below liv's values: particle systems have a minimum level
  and get **skipped** below it, so ability effects can disappear.
- `lb_enable_envmaps false`: characters render black.
- `Engine2/RenderingPipeline/DistanceField 0`: crashes after the hideout loads.
- `r_render_portals 0`: breaks Doorman's door. **Liv's `video.txt` sets this**, see section 4.
- `-threads N`, `-m_rawinput`, `+cl_forcepreload`, `-noaafonts`, `-dx12`: they only limit the engine, or don't exist.
- Valve already turns the multithreading switches on (`r_threaded_*`, `*_parallel*`, `phys_step_threaded`, …),
  so there is nothing left there.

## 4. `video.txt` (the second config layer)

Liv's `video.txt` compared with OptiLock FPS/Potato, Sqooky max-FPS and Piggy's:
- Every other pack sets `csm_max_num_cascades_override 0`, `csm_viewmodel_shadows 0`, `lb_enable_shadow_casting false`,
  `lb_shadow_texture_width/height_override 0`, `r_particle_shadows 0`, `r_env_map_uses_height_map 0`, `r_reduce_flash 1`.
  Liv's doesn't. All are FPS-only cuts, worth adding.
- `volume_fog_width/height/depth "16"` gets raised to the minimum 64/64/48, so it does nothing below that.
- `"setting.r_render_portals" "0"` **breaks Doorman's door** (DMM deny list). Set it to `1` unless you never play against Doorman.
- `csm_max_shadow_dist_override "2048"`: the others use 0. It's blocked from `gameinfo.gi`, and whether `video.txt`
  can still set it is untested. Check with `csm_max_shadow_dist_override` in the console.
- One open question worth a 2-minute test: does `video.txt` still apply convars that `gameinfo.gi` can't? Add
  `"setting.r_particle_max_detail_level" "2"`, launch, and type `r_particle_max_detail_level` in the console. If it prints 2, that's a
  big particle lever. Use 2, not 0: 0 drops effects.

## 5. Launch options

Checked against the engine's own option list (1,536 entries).
- **Use:** `-novid` (skip the intro). `-high` is harmless and gives a small priority bump.
- **Test:** `-dx11` vs `-vulkan`. DX11 is the default and wins in most reports. Vulkan can win on some AMD cards,
  but it has reports of VRAM leaks over long sessions.
- **Test:** `-noreflex` plus an NVIDIA Control Panel cap slightly above your refresh rate, with Low Latency Ultra. One forum test reports
  better 0.1% lows than in-game Reflex. Trade-off: a little more latency.
- **Skip:** `-threads` (it can only limit the thread pool), `-preload` (no documented benefit in Source 2).

## 6. FPS mods (VPKs) that stay mod-compatible

From Sqooky's "Various Addons Relating to Performance" and OptiLock's "Essential Fixes":
- **Screenspace Particle Disabler / Clutter be Gone "Screenspace"**: removes screen-edge smoke and glow (low health,
  vents, Shiv bleed). Its author measured a 30 FPS drop standing on vents without it. Biggest single mod gain.
- **Optimized Soul Container**: low-poly soul orbs (everywhere, all match).
- **Vindicta Scope Downscale**: the 4096×4096 un-mipmapped scope texture cut to 1080p. Fixes frame drops on low-VRAM
  cards when you or an enemy Vindicta scopes.
- **Optimized McGinnis Wall** (OptiLock).
- Skip **Blur Disabler**: `panorama_disable_blur` (round 2) does the same without replacing HUD files, so it can't
  clash with QOL Lock or Always Show Passive Items.
- Keep liv's **sinners LOD fix** while mip bias is 4.

## 7. Windows, driver and hardware (biggest wins live here)

- **SMT / Hyper-Threading off** (BIOS): player reports of unstable 150 → 200-300 FPS with GPU use going from low to
  90-100%. Costs performance in other heavily threaded apps. Worth one test.
- **Shader cache:** NVIDIA Shader Cache Size 10 GB or Unlimited. After big patches, clear DXCache/GLCache once and play
  a few minutes in Sandbox to rebuild it.
- **Windows 11:** Game Mode on, Hardware-accelerated GPU scheduling on, "Optimizations for windowed games" on (DX11
  borderless then gets flip-model latency), Xbox Game Bar capture off, unused overlays off (Discord, NVIDIA app).
- **Input-triggered frame spikes:** disable fullscreen optimizations on `deadlock.exe` or run it as administrator. Also turn off Discord
  hardware acceleration and stream capture.
- **Memory:** DDR5 EXPO/XMP instability is the most-cited crash cause (`0xc0000005`). If you crash, test one speed step lower.
  Keep the BIOS current.
- **Long sessions:** memory/VRAM leaks are reported, mostly on Vulkan. Restart if FPS sinks late in a session.
- **Known unfixable:** a City Never Sleeps FPS drop when looking toward the blue lane or mid; voice lines, the Tab
  scoreboard and the kill feed cost frames. No config moves these.

## Sources

- Valve data: [SteamDatabase/GameTracking-Deadlock](https://github.com/SteamDatabase/GameTracking-Deadlock) (stock `gameinfo.gi`, convar dump)
- [Deadlock Mod Manager perf catalog and docs](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog) (5,136 convars, flags, deny list, DMM Clean consensus)
- [ghempy53/deadlock-config](https://github.com/ghempy53/deadlock-config) (measured A/B tests, matchmaking-guard and `gameinfo_cannot_override` research, forum digest)
- [simulieren/deadtune](https://github.com/simulieren/deadtune) (convar catalogue with impact ratings)
- Configs compared: [Sqooky/OptimizationLock](https://github.com/Sqooky/OptimizationLock) (Sqooky, Eskay, max-fps, boot, Piggy, Kaizuchaneru x2) and forks
  ([adamescj](https://github.com/adamescj/OptimizationLock), [KubilayUlucay](https://github.com/KubilayUlucay/OptimizationLock)),
  [dacooderr/OptiLock](https://github.com/dacooderr/OptiLock) (FPS, Potato, Ultra Potato), [7liv/compylock](https://github.com/7liv/compylock)
- Player reports: [Vulkan vs DX11](https://forums.playdeadlock.com/threads/vulkan-graphics-significantly-underutilising-cpu-compared-to-dx11.74504/),
  [-noreflex + driver cap](https://forums.playdeadlock.com/threads/disable-reflex-and-use-nvidia-control-panel-fps-limiter-and-low-latency-mode-for-best-performance-in-deadlock.54456),
  [SMT off](https://forums.playdeadlock.com/threads/hyper-threading-or-smt-off-give-more-stable-fps-and-better-gpu-utilization.91848/),
  [dodge.gg 2026 guide](https://www.dodge.gg/en-US/deadlock/news/deadlock-system-requirements-optimization-guide-2026),
  [ultimatemove.eu](https://ultimatemove.eu/en/deadlock-optimization/)
