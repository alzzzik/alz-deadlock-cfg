# apex-testing: handoff notes

Read this first if you are an AI (or a person) picking up work on `apex-testing/`. It explains what the variant is,
why every line is there, what is still unknown, and how to continue. Last updated 2026-11-21, game build 6861.

## 1. The owner and the rules

- Owner: alz. PC: Ryzen 7 5700X (8 cores / 16 threads, one CCD, no hybrid cores), RTX 5070 12 GB, 1440p,
  DLSS at 1.7x (`r_citadel_upscaling 4`, `r_citadel_dlss_settings_mode 2`), DX11, runs uncapped.
  CPU-bound in team fights, like almost everyone in Deadlock.
- Plays with mods through Deadlock Mod Manager (DMM), including a Sinner light fix VPK. **Mod compatibility is a
  hard requirement**: the `FileSystem/SearchPaths` block (with `Game citadel/addons`, explicit `Mod`/`Write` lines
  and the DMM markers) must be kept exactly.
- The rule for a line: **more FPS with the same or better visuals.** Lines that hide gameplay information are out.
  Lines that cost a little visual detail are allowed only as off-by-default `[test]` lines.
- **Measured history on this PC** (see `README.md` "Experiment log"):
  - Changing engine sections (Engine2, RenderSystem, SceneSystem, ...) away from liv's values measured worse twice:
    "a bit less FPS" (round 1) and 30-40 FPS less (OptiLock's sections). So apex leaves liv's engine sections alone.
  - The old `experimental` bundle (rounds 2-5 together) measured about -40 FPS vs stable. It was never split, so
    nobody knows which part cost it. That is why apex adds very little and everything new is tagged.
- `stable/` and `alz/` are the proven files. Don't change them without being asked. `apex-testing/` is the place
  to try things.

## 2. What apex-testing is

`apex-testing/gameinfo.gi` = `alz/gameinfo.gi` with:
- liv's ConVars block replaced by the "apex block" (95 active lines + 8 `[test]` lines + 7 "Unused" lines),
- Valve's own stock ConVars block (85 lines, starting at `rate {`) kept byte for byte below it,
- four `RenderSystem` keys deleted that appear in no game binary (`GraphicsPipelineLibrary`,
  `SwapChainSampleableDepth`, `VulkanOnly_Linux`, `VulkanSteamShaderCache`),
- an off-by-default `//[test] ReflexLateWarp "1"` line in the `NVNGX` block (section 7).

`apex-testing/video.txt` = `alz/video.txt` minus `setting.r_particle_depth_feathering` (removed from the game).
The user must copy in their own `VendorID`, `DeviceID`, `setting.defaultres`, `setting.defaultresheight`.

**Status: first measured on alz's PC on 2026-11-20 (3 matches, see section 8b): not worse than alz, slightly better
so far, not yet significant.** Every per-line claim below is from Valve's data, community descriptions or other
people's measurements.

## 3. How the game treats a line (this decides whether a line can work at all)

| Flag / situation | Effect of a `gameinfo.gi` ConVars line | Source |
|---|---|---|
| `gameinfo_cannot_override` (124 cvars) | Ignored; the game uses Valve's default. All 124 are also `cheat` or `developmentonly`, so there is no other way to set them. | Valve dump; ghempy53 console probe (build 6842) |
| `archive` | Only a default. A value saved in `Steam/userdata/<id>/1422450/local/cfg/machine_convars.vcfg` wins, and the game writes it back on exit. Force with a launch option `+name value`. | ghempy53 `docs/research/OWNER-PROBE-2026-11-03.md` |
| `cheat` | Applies from the file at startup (probe: yes, in the Hideout). Whether it survives joining a real server is **untested**; the engine has the string "FCVAR_CHEAT and FCVAR_REPLICATED cvars reverted to defaults (remote connection)". | ghempy53 probe |
| `developmentonly` + `replicated` | Sources disagree. DMM: server-owned. CompLock's CVAR Index: settable from gameinfo.gi, not locked online. Some (`props_break_max_pieces_perframe`, `citadel_camera_see_distance_max`) have effects players see in real matches. | CVAR Index; DMM catalog |
| `cheat` + `replicated` | Locked online. | CVAR Index |
| Owned by the video menu | `video.txt` wins over `gameinfo.gi` (shadow quality, SSAO, bloom, DoF, mip bias, upscaler, `fps_max` slider, ...). | DMM rules |
| Outside min/max | Clamped to the limit. | Valve dump |
| Engine sections | `Engine2, MaterialSystem2, NetworkSystem, Particles, RenderSystem, SceneSystem, WorldRenderer` are named in Valve's matchmaking message (`Citadel_StartMatchmaking_UnverifiedPGI`, since build 6417). Not enforced today (ghempy53 queued a Street Brawl with edits on 2026-11-03), but could be. `NVNGX` and `ConVars` are not named. | Valve localization; DMM rules |

Uncapped FPS therefore needs launch options: `-novid +fps_max 0 +fps_max_ui 0`.

## 4. Every line in the apex block and why

Sources used for "what it does": CompLock's CVAR Index (`CL`), DMM's curated descriptions (`DMM`), Valve's own help
text, Sqooky's comments in OptimizationLock. Default = Valve's code default (build 6861).

### View and feel (alz's preferences, not FPS)
| Line | Default | What it does / why kept |
|---|---|---|
| `r_aspectratio 2.4` | 0 | Render aspect ratio; wider = more FOV. alz's choice. (Sqooky: 2.15 ≈ 90 FOV, 2.49 ≈ 100.) |
| `citadel_camera_use_vmdl_flatten_horizontal false` | true | Stops averaging the camera's sideways position across hero poses. ghempy53's owner said ADS felt "far too zoomed in" with it; alz kept it. |
| `citadel_camera_wobble_disable true` | false | No camera wobble. |
| `citadel_camera_listening_offset -1` | 0 | Moves the listening point 1 unit along the camera's forward axis. Negligible; from liv. |
| `citadel_camera_pitch_default 0` | 20 | Camera pitch after a reset. |
| `r_citadel_clip_sphere_min_opacity 0` `[cheat]` | 0.4 | Objects between camera and hero fade out fully. |
| `cam_idealdelta 0`, `cam_ideallag 0` `[arch]` | 4, 4 | Third-person camera follow lag. Archive: probably not applied on an existing profile. |
| `cc_captiontrace 0` | 1 | No missing-caption reports. |
| `mm_idle_enabled false` | true | No queue idle kick. |
| `mm_prefer_solo_only true` `[arch]` | false | Prefer solo players in matchmaking. |
| `citadel_show_survey true` | false | Forces the survey screen. liv's; harmless. |
| `steam_inputhandler_enabled false` | true | Steam Input off (no controller). |

### Input and frame pacing
| Line | Default | Why |
|---|---|---|
| `engine_accurate_input_processing_delta_time true` | false | Valve: only matters when input is processed several times per frame. Kept from alz. |
| `engine_max_ticks_to_simulate 2` | -1 | Caps ticks simulated per frame. ghempy53 reverted it once when "the camera felt wrong" (owner later invalidated those results). Remove if aim feels off. |

### Not drawn (deliberate, same as alz)
`r_drawropes false`, `r_render_hair false`, `r_hair_ao 0`, `r_rendersun 0`, `r_pixelvisibility_partial false`,
`cl_show_splashes 0`, `sc_clutter_enable false`, `r_grass_quality 0` + `r_grass_start_fade 0` + `r_grass_end_fade 0`,
`violence_*` 0 (`[arch]`). These are alz's accepted look. `r_rendersun 0` is what makes every sun-shadow line below
redundant.

### Culling and LOD
| Line | Default | Note |
|---|---|---|
| `r_size_cull_threshold 0.9` | 0.8 | Culls small on-screen objects. Upstream FAQ: high values hide crates and trooper bars at range; 0.9 is mild. |
| `sc_screen_size_lod_scale_override 0.55` | -1 | Earlier LOD switches. **Known cost:** holes in Victor/Paige at some angles, Sinner's Sacrifice lights become triangles. alz keeps it; delete if it bothers. |
| `sc_allow_dithered_lod false` | true | LOD switches without dithering. |
| `sc_instanced_mesh_opaque_fade false` | true | No fade support for opaque instanced meshes. |
| `sc_instanced_mesh_size_cull_bias_shadow 10` | 2 | Drops more small instanced meshes from shadow maps. |
| `r_strip_invisible_during_sceneobject_update 1` | false | Skips invisible objects during scene updates. All OptimizationLock-family configs set it. |

### Shadows (all redundant today, kept as belt and braces)
`lb_enable_shadow_casting 0`, `lb_barnlight_shadowmap_scale 0`, `lb_csm_cascade_size_override 1`,
`lb_csm_draw_alpha_tested 0`, `lb_csm_draw_translucent 0`, `lb_dynamic_shadow_resolution_base 128`,
`lb_sun_csm_size_cull_threshold_texels 60`, `r_citadel_sun_shadow_slope_scale_depth_bias 0`,
`sparseshadowtree_enable_rendering 0`.
CL on `lb_enable_shadow_casting`: "Shadows only draw with shadow quality above Off." `video.txt` has shadow quality 0
and the SceneSystem shadow atlases are zeroed, so these change nothing unless shadow quality is raised.
`lb_dynamic_shadow_resolution_base` was 16 in alz, which the engine clamps to 128; apex writes 128.

### Lighting and post
| Line | Default | Note |
|---|---|---|
| `cl_retire_low_priority_lights 1` | false | Low-priority dynamic lights give way to high-priority ones. |
| `mat_max_lighting_complexity 0` `[cheat]` | 8 | Shader lighting complexity cap. Sqooky: "doesn't seem to do anything". Kept from alz. |
| `r_ssao 0` | true | SSAO off (menu SSAO is also 0). |
| `lb_ssss_samples 3` | 11 | Skin subsurface samples; 3 is the engine minimum (alz had 0, clamped to 3). |
| `r_lightmap_size 2048`, `r_lightmap_size_directional_irradiance 0` | 65536, -1 | Smaller baked lightmaps. Part of alz's look. |
| `volume_fog_intermediate_textures_hdr false` | true | Lower-precision volumetric fog textures (fog is off anyway). |
| `r_character_decal_resolution 256` | 1024 | Character decal texture; 256 is the minimum (alz had 4, clamped). |
| `r_citadel_disable_particle_lights true` **`[fight]` new** | false | Particle effects stop lighting the world (unless an effect asks for it). Effects still draw. Valve dev tip relayed by Sqooky; OptiLock ships it. It was inside the -40 FPS experimental bundle, so never shown positive or negative on its own. `release` convar: flip `0/1` live in the console to compare. |

### Textures
`r_texturefilteringquality 5` (16x aniso, alz's choice over bilinear), `r_texture_budget_threshold 0.7`,
`r_texture_budget_update_period 0.5`. The last two were once blamed for camera-turn stutter by ghempy53's owner;
that report was later invalidated, so they stay as alz has them.

### Particles (the fight-time CPU cost)
| Line | Default | Note |
|---|---|---|
| `cl_particle_sim_fallback_threshold_ms 1`, `cl_particle_sim_fallback_base_multiplier 100` | 6, 5 | After 1 ms of particle sim per frame, new effects switch hard to Valve's cheaper fallback versions. Deliberate trade alz accepted. |
| `cl_particle_fallback_base 5`, `cl_particle_fallback_multiplier 10` | 0, 0 | Same idea; `video.txt` sets the same values and wins. |
| `r_limit_particle_job_duration true` | false | Limits how long particle jobs run per frame. |
| `r_particle_max_size_cull 600` | 1200 | Valve: systems bigger than this "skip culling to save CPU. They will be drawn anyway." Lower = more systems skip CPU culling. Suits a CPU-bound PC. |
| `r_particle_max_texture_layers 4` | -1 | **Never below 4** (Infernus afterburn, Paige fire, Drifter passive go blocky). |
| `r_particle_model_per_thread_count 64` | 32 | Fewer, larger particle-model jobs. Direction of effect on 16 threads unknown. |
| `r_physics_particle_op_spawn_scale 0` | 1 | Effects spawn no physics objects. |

### Scene batching / CPU
| Line | Default | Note |
|---|---|---|
| `sc_aggregate_bvh_threshold 256`, `sc_layer_batch_threshold 256` | 128, 128 | CL: only aggregates with more pieces than this get a culling hierarchy / batching threshold. Sqooky: "not fully sure". Kept from alz. |
| `cl_batch_entity_list_ops_during_latch true` | false | Valve: batches entity list ops "to avoid mutex contention". |
| `cl_simulate_dormant_entities false` | true | Doesn't simulate entities the server marked dormant. |
| `cl_fasttempentcollision 1000` | 5 | Collision checks for temp effects (tracers, sparks). Sources disagree on direction; kept from alz. |
| `r_vma_defrag_algorithm 0` | 1 | Vulkan memory defrag: fastest mode. Does nothing on DX11. |
| `rtx_dynamic_blas false`, `rtx_force_default_hitgroup true`, `rtx_texture_resolution 64` | | Ray tracing isn't used; harmless. |
| `v8_maximum_heap_size_mb 1024` | 512 | More JS heap for script HUD mods. |
| `cl_generate_postdataupdatepreserved false` **`[zv]` new** | true | Valve: skips "PostDataUpdatePreserved callbacks for entities that had no changes but are still in the PVS". CompLock and OptimizationLock 3.9 both ship it. Watch for idle things that stop updating. |
| `panorama_min_comp_layer_cache_cost 0` **`[zv]` new** | 4096 | UI caches every composition layer. Sqooky: about +300 MB VRAM. |
| `panorama_comp_layer_lru_lifetime 4` **`[zv]` new** | 1 | Cached UI layers live 4 s. liv had a similar line commented out for mod safety; watch HUD mods. |

### Wind and ropes (already invisible)
`r_world_wind_strength 0` (alz), plus **new `[zv]`**: `r_world_wind_frequency_grass 0`, `r_world_wind_frequency_trees 0`,
`wind_system_default_resolution_xy 0`, `wind_system_temporal_smoothing false`, `rope_collide 0`, `rope_wind_dist 0`.
Wind strength is 0 and ropes aren't drawn, so these only remove leftover simulation work. From CompLock.

### Sound
`audio_enable_vmix_mastering false` `[cheat]` (changes how the final mix sounds: a taste call),
`snd_steamaudio_max_occlusion_samples 32` and `snd_steamaudio_num_diffuse_samples 512` `[cheat]` (cheaper Steam Audio).

### Animation, physics, far health bars (developmentonly + replicated, see section 3)
| Line | Default | Note |
|---|---|---|
| `ik_final_fixup_enable 0` | true | Skips the final IK pass. Every pack sets it. |
| `skeleton_instance_lod_optimization true` **`[zv]` new** | false | Computes bones only for the model's current LOD. CompLock, Sqooky and ghempy53 all set it. Watch for odd poses at a distance. |
| `props_break_max_pieces_perframe 1` | 16 | Crates break into at most 1 piece per frame. |
| `phys_cull_internal_mesh_contacts true` | false | Skips physics contacts inside meshes. |
| `citadel_camera_see_distance_max 7000` | 20000 | Units farther than this lose their overhead health bar. |
| `debug_draw_enable false` | true | No debug drawing. |

### `[test]` lines (off; enable one at a time)
| Line | What it does | Risk |
|---|---|---|
| `r_particle_max_detail_level 2` | Skips effect parts that need detail level 3. Settable since build 6812. | Visual: top detail tier gone. Console must print 2. **Never 0.** |
| `r_late_particle_job_sync 1` | Waits for particle jobs later in the frame. In Sqooky, OptiLock, ghempy53. | ghempy53 removed it in a crash bisect without pinning the crash on it. |
| `citadel_npc_ticks_per_anim_update 3` | Troopers animate every 3rd tick, not every 2nd. Nobody ships it. | Choppier trooper animation. |
| `panorama_worldpanel_update_culling true` | Stops updating far/tiny world panels. | Health-bar numbers stale until close. |
| `phys_threaded_cloth_bone_update`, `phys_threaded_kinematic_bone_update`, `phys_threaded_transform_update`, `ragdoll_parallel_pose_control` (all `true`) | Move bone/physics work to several threads. Valve ships them off; OptiLock turns them on. | Valve leaving them off suggests unfinished. Crash risk. |

### Filed as "Unused" by CompLock's CVAR Index (kept, expect nothing)
`citadel_tightcamera_alternative 1`, `citadel_bullet_shot_offset_fade_time 0`, `r_drawtracers_firstperson false`,
`r_size_cull_threshold_shadow 2.4`, `r_particle_skip_postsim true`, `cloth_sim_on_tick 0`,
`snd_steamaudio_reverb_order_rendering 0`. The index doesn't publish how it decides "Unused".

## 5. Removed from alz, and why

**No effect (57 in alz by `tools/lint.py`):** 19 convars removed from the game, 5 blocked (`gameinfo_cannot_override`),
the `video.txt`-owned lines (`r_citadel_shadow_quality`, `r_citadel_ssao_quality`, bloom, DoF,
`r_texture_stream_mip_bias`, `lb_csm_override_staticgeo_cascades*`), liv's duplicates of Valve's block
(`sc_layer_batch_threshold_fullsort 120` and `snd_ui_positional false` were silently overridden by Valve's later
lines), and lines equal to the default.

**Removed because of what they do:**
| Line | Reason |
|---|---|
| `r_particle_min_timestep 0.00241` | Fast particles look jagged above ~415 FPS (ghempy53 bisect, 2026-10-17). alz is uncapped. |
| `sc_instanced_mesh_motion_vectors 0` | DLSS uses motion vectors; off invites ghosting. All four other packs set 0, but none use DLSS. |
| `snd_boxverb_simd false` | Turns the fast vector reverb path off. Can only cost CPU. OptimizationLock 3.9 reverted it too. |
| `snd_enable_subgraph_corenull_passthrough false` | Turns a sound-graph pass-through optimisation off. Backwards. |
| `audio_enable_spawn_mask_mix_layer false` | Only un-mutes sounds at map load. Not a cost. |
| `snd_steamaudio_num_threads 6` | Valve's 2 is plenty for a mostly-disabled feature. |
| `thread_pool_option 2` | Chooses a core type on hybrid Intel CPUs. Nothing to choose on a 5700X. |
| `cl_ragdoll_limit 0`, `enable_boneflex 0`, `snd_mixahead 0.05` | `archive`, so probably never applied; harmful if they did (Doorman ult indicator hidden, melee mispredictions, up to 50 ms later audio). |
| `citadel_shoot_forward_offset 0` | CL: "The server uses its own value, so changing it only makes your shots mispredict." Dead or harmful. **Also removed from stable, alz and alz-experimental on 2026-11-16.** |
| `r_particle_model_new8 false` | Its partner `r_particle_model_new` is already false by default. |
| `r_drawviewmodel`, `csm_viewmodel_*` (3), `sparseshadowtree_*_viewmodel` (2) | First-person view model, which Deadlock doesn't draw. |
| `r_ssao_strength`, `r_citadel_gpu_preview_denoise_passes`, `r_renderdoc_auto_shader_pdbs` | Tool-only. |
| `citadel_camera_height 0` | CL: "Changing it doesn't move the hero camera." |
| `engine_low_latency_sleep_after_client_tick` (was a `[test]` line) | Filed as Unused by the CVAR Index. |
| `citadel_melee_shake_*`, `nav_edit_use_camera`, hideout ball lines, `rpg_camera_yaw`, `snd_occlusion_*`, `citadel_stuck_camera_trace_extra_length` | Server-only, debug camera, or locked online. |
| `lb_dynamic_shadow_resolution_base 16`, `lb_ssss_samples 0`, `r_character_decal_resolution 4` | Rewritten to the minimums they were clamped to (128, 3, 256). |

## 6. What was considered and rejected

- Anything that hides information: `r_farz`/`r_mapextents` 7000, `cl_ragdoll_limit 0`, `cl_disable_ragdolls`,
  `citadel_boss_glow_disabled`, `panorama_disable_blur`/box shadow/transitions, `r_particle_max_detail_level 0`,
  `cl_particle_max_count`, `r_particle_timescale`, `r_morphing_enabled false`, `fx_drawmetalspark false`,
  bilinear filtering, `lb_precomputed_shadowmap_enable false`.
- `r_low_latency 2` (Reflex Boost): Valve says it may cost FPS.
- `cl_modifier_value_cache_enabled true`: Valve keeps it off; its own debug output calls stale values a correctness bug.
- `engine_allow_multiple_simulates_per_frame true`: runs simulation more than once in the worst frames.
- `r_frame_sync_enable 0` (OptiLock): removes CPU/GPU sync, lets the CPU run ahead = more latency.
- New engine-section keys (`ThreadPoolCoreTypeRequest`, `SetInitialStreamingPoolSizeFromBudget`,
  `ReserveMemoryForNonTextureUseMB`, `PerObjectLightingSetup`, `OpaqueFade`, ...): guarded sections, unknown
  defaults, and engine changes measured worse here twice.
- CompLock's whole pack: its installer overwrites `gameinfo.gi`, takes pak01-07 and replaces HUD files. Not mod
  compatible. Take single pieces only.

## 7. Open leads, in priority order

1. **Reflex 2 Frame Warp** (`research/reports/Reflex 2 Frame Warp key.md`). The DX11 and Vulkan renderers read
   `NVNGX/ReflexLateWarp` and contain a full NVIDIA Late Warp integration (same code in CS2 and Dota 2). Stock never
   sets it. Needs `nvngx_latewarp.dll`, which Valve doesn't ship. Step 1 (no DLL): enable the line, launch with
   `-condebug`, search `game/citadel/console.log` for `Late Warp`. Step 2 needs the DLL and `-insecure` because of VAC.
   Untested; nobody has reported it working.
2. **Sound stack update cap mod** (`soundcap.vpk` from deadlockconfig.com's Pack Builder, its own download row only).
   CompLock benchmark 2026-11-16: +9.7% avg / +11.1% 1% low, nothing looks or sounds different. Single file
   (`soundstacks/soundstacks_citadel_base_3d.vsndstck_c`). Largest invisible gain anyone has measured. Recheck after
   every patch.
3. The `[test]` lines in section 4.
4. Settle the replicated / cheat question: in a matchmade game, type `props_break_max_pieces_perframe` and
   `r_rendersun` in the console. If they print Valve's defaults, those groups are dead online.

## 8. How to test (the method that avoids the old -40 FPS mess)

- Hold `video.txt` fixed. Change one thing at a time.
- Compare **1% lows in team fights**, not averages, over 2-3 matches of the same mode.
- First test: apex-testing vs alz. If apex is equal or better, keep it (cleaner file).
- If worse, suspects in order: the three `[zv]` panorama/entity lines, `skeleton_instance_lod_optimization`,
  `r_citadel_disable_particle_lights`, the five restored replicated lines, then `sc_instanced_mesh_motion_vectors`
  (add `"0"` back).
- Promote a line to stable/alz only after it wins in real matches.

## 8b. Results log

Measured by alz with a frame-time tracker in real matches on `dl_midtown`, `video.txt` the same for both variants.

| Variant | Sessions | Minutes | Avg FPS | 1% low | p99 frame time |
|---|---|---|---|---|---|
| alz | 57 | 1491 | 268 | 82 | 12.14 ms |
| apex-testing (r2, 2026-11-20) | 3 | 93 | 277 (+3.4%) | 87 (+6.1%) | 11.48 ms (-5.4%) |

Per-session numbers shown: apex 296/100, 269/87, 277/83 (avg / 1% low, Nov 20); alz's last three 289/99, 273/86
(Nov 13) and 235/84 (Nov 20, same day as the apex runs).

**Reading (2026-11-21):** apex is **not worse**, which already clears the bar the old experimental bundle failed
(-40 FPS). The lead itself is **not yet distinguishable from match-to-match noise**: single alz sessions range from
235 to 289 avg and 84 to 99 1% low, so with only 3 apex sessions the standard error of apex's average is roughly
15 FPS for avg and 5 FPS for 1% low, about the size of the gap. The direction (avg, 1% low and p99 all better) is
encouraging.

**Next:** keep playing apex until about 8-10 sessions, ideally alternating with alz on the same days (patches and
server load shift both). If the 1% low lead holds, make apex the daily driver and only then start the `[test]` lines
or the sound cap mod, one at a time, each for several sessions. Don't change anything else while collecting this
baseline, or the comparison is confounded.

## 9. Tools and data sources for the next session

- `tools/lint.py <gameinfo.gi> [--video video.txt] [--catalog catalog.json]` classifies every ConVars line. Without
  `--catalog` it downloads DMM's catalog. Run it after every game patch. Expect "0 dead-weight lines" for apex.
- Valve data: `git clone --depth 60 https://github.com/SteamDatabase/GameTracking-Deadlock` (stock `gameinfo.gi`,
  `DumpSource2/convars.txt` with flags, binary string dumps under `game/bin/win64/*_strings.txt`). `git clone` and
  `raw.githubusercontent.com` work from cloud sessions; the GitHub REST API does not.
- Convar descriptions: CompLock's CVAR Index at https://deadlockconfig.com/docs/cvars/. The data is inlined in the
  page as `<script id="cvar-data" type="application/json">`. Plain curl gets 403 on some pages; a browser User-Agent
  works. Row format: `[name, default, description, category_index, flag_bitmask, min, max, valve_gameinfo_value,
  how_index, locked_online]`; the legend (`cats`, `flags`, `how`) is in the same JSON.
- DMM catalog: `https://raw.githubusercontent.com/deadlock-mod-manager/deadlock-mod-manager/main/packages/perf-catalog/data/catalog.json`
  (convars with flags/defaults/min/max, curated descriptions and side effects, stock gameinfo history, presets,
  deny list).
- Other packs: `github.com/Sqooky/OptimizationLock` (author comments on every line), `github.com/dacooderr/OptiLock`,
  `github.com/7liv/compylock`, `github.com/ghempy53/deadlock-config` (runtime probes, owner test logs).
- Benchmarks: https://deadlockconfig.com/docs/benchmarks/ (the only careful per-mod numbers; Linux, Vulkan, replays,
  9800X3D).

## 10. Related reports in this repo

- `research/reports/Apex rebuild 2026-11-15.md`: first pass (flags-based audit), CompLock gameinfo re-check.
- `research/reports/Convar review r2.md`: second pass (description-based), the three corrections.
- `research/reports/Reflex 2 Frame Warp key.md`: the Frame Warp lead, other hidden engine keys, sound cap numbers.
- `research/RESEARCH.md`: index of all older research.
