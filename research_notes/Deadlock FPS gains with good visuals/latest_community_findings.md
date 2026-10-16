# Latest community findings on Deadlock FPS configs (2026-09-29 to 2026-10-16), only what is new or corrected compared with RESEARCH.md

Method: I updated the local clones of Sqooky/OptimizationLock, dacooderr/OptiLock, ghempy53, the DMM forks and compylock
on 2026-10-16. I made a blobless clone of SteamDatabase/GameTracking-Deadlock and diffed `DumpSource2/convars.txt` across
all 11 dumps from 2026-09-25 to build 6779, plus the stock `gameinfo.gi`. Then I checked every config's `ConVars`
block against the build 6779 dump (`research_tmp/scripts/cvcheck.py`). The GitHub API was blocked (403). I read the
issue pages through web fetch instead. forums.playdeadlock.com and ultimatemove.eu could not be reached (DNS failure
or proxy 403), so forum evidence below comes only from search snippets.

## Q1. What Valve changed in builds 6711 to 6785 that matters for performance (convars, stock gameinfo.gi, patch notes)

### Takeaway
After build 6779 (2026-10-13), Valve added one new client-side performance convar that you can set,
`r_citadel_disable_particle_lights`. It also added `citadel_player_model_force_highest_lod` in 6769. Neither is in the
alz cfg. Build 6769 also changed two things RESEARCH.md missed: `r_texture_lod_scale` can no longer be set from
`gameinfo.gi`, and `sc_screen_size_lod_scale_override` became developmentonly. The stock `gameinfo.gi` only changed in
a section that tools use, and the matchmaking guard string is unchanged.

### Cited Findings
- **Build timeline** (GameTracking commits): 6711 is City Never Sleeps (09-29). The convar dump changed in 6726, 6728,
  6730, 6731, 6736, 6753 (10-05), 6757 (10-06), 6769 (10-09, the "Solomon" update) and 6779 (10-13). The latest build
  is 6785 (10-15), with balance and Deadpack changes only and no convars.txt change. — [GameTracking-Deadlock commits](https://github.com/SteamDatabase/GameTracking-Deadlock/commits/master)
- **NEW in 6779 (2026-10-13): `r_citadel_disable_particle_lights`**, default `false`. Flags are `clientdll release`,
  so it is not cheat, not blocked and not developmentonly. Its description reads "Disable particle lights except when
  explicitly overriden in particle renderer ops." Because it is `release`, you can change it live in the console for
  an A/B test. The same build added only three other convars (Deadpack, HUD and zipline binds). — [GameTracking 0c38f9d](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/0c38f9d)
- **NEW in 6769 (2026-10-09): `citadel_player_model_force_highest_lod`**, default `true`, flags `clientdll release`.
  Its description reads "Forces the local player pawn to render using the highest LOD level." It applies to your own
  hero only, so expect a small gain from setting it to `false`. — [GameTracking 8f572f6](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/8f572f6)
- **Valve's stated reason for 6769 and the hint about new performance convars:** in OptimizationLock issue #88 (10-13),
  Sqooky relays a developer-forum reply. About 40 lighting commands were locked "so streamers could keep their
  artistic vision", Valve "would improve performance elsewhere before adding more restrictions", and "some performance
  cvars would come soon." Four days later, `r_citadel_disable_particle_lights` shipped in 6779, and Sqooky credits it:
  "Thank you Dohn VALVe for pushing and telling me about this command". — [OptimizationLock #88](https://github.com/Sqooky/OptimizationLock/issues/88); comment in [Sqooky's .gi line 976](https://github.com/Sqooky/OptimizationLock/blob/main/Sqooky's%20.gi/gameinfo.gi)
- **Blocked or changed in 6769 but missing from RESEARCH.md:**
  - `r_texture_lod_scale` and `r_fallback_texture_lod_scale` → `gameinfo_cannot_override`.
  - `lb_max_visible_envmaps_override`, `lb_max_visible_barn_lights_override`, `lb_enable_envmaps`, `lb_enable_lights`
    and `lb_enable_sunlight` → blocked.
  - Also blocked: `lb_mixed_shadows`, `lb_enable_fog_mixed_shadows`, `lb_shadow_map_culling`,
    `lb_cull_on/offscreen_bounce_light_shadows`, `lb_allow_shadow_rotation`, `lb_csm_fov_override`, `sc_disable_culling_boxes`,
    `sc_fog_cull`, `sc_force_lod_level` and `sc_disable_procedural_layer_rendering`.
  - `sc_screen_size_lod_scale_override` went from `cheat` to `developmentonly defensive`. The same happened to
    `sc_disableThreading`, `sc_disable_shadow_fastpath`, `sc_reject_all_objects` and `sc_skip_traversal`.
  - `lb_low_quality_shader_fade_region_rescale` lost its `cheat` flag.

  — [GameTracking 8f572f6](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/8f572f6) (my diff of convars.txt 7148202→8f572f6)
- **Whether developmentonly lines still apply:** ghempy53's notes say `cheat` and `developmentonly` convars are "still
  applied from this file at startup. The console hides developmentonly convars". So `sc_screen_size_lod_scale_override`
  probably still works from `gameinfo.gi`, but you can no longer read or change it in the console. — [ghempy53 docs/CLAUDE.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/CLAUDE.md)
- **Changes in City Never Sleeps (6711) that RESEARCH.md may not list:**
  - Default changes: `sparseshadowtree_enable_rendering` false→**true**,
    `panorama_skip_composition_layer_content_paint` false→true, `save_parallel` false→true and `hud_free_cursor` -1→0.
  - Removed: `animgraph_enable_parallel_op_evaluation/preupdate/update`. Configs that still set them get nothing.
  - Blocked: `r_citadel_cloak_*` became developmentonly (`r_citadel_cloak_refract_amount` is also blocked), and so did
    all `r_citadel_distancefield_*` lines, `r_postprocess_enable`, `r_nearz` and `r_citadel_mboit_quality`.
  - Seven `fog_*skybox`/`fog_maxdensity` convars were removed in 6728.
  - `r_particle_explicit_fetch` was removed in 6736.

  — [GameTracking 58b3529](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/58b3529), [573a412](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/573a412), [2a29281](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/2a29281)
- **Stock `gameinfo.gi`:** since CNS it changed only once, in 6779, which added `ResourceCompiler { ForceVulkanForMapBuild 1 }`.
  That setting is for map compiling, does nothing at runtime and has no FPS effect. Sqooky 3.5.2 copied it. — [GameTracking 0c38f9d diff of game/citadel/gameinfo.gi](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/0c38f9d)
- **Patch notes:** none of the October patches lists performance changes. 10-06 was Rat King/Sinclair balance and a
  trooper fix, 10-14/15 was Baba nerfs and Deadman Danny buffs. — [SteamDB 10-14 minor update](https://steamdb.info/patchnotes/25950029/), [deadlock.one 10-06](https://deadlock.one/en/news/deadlock-update-patch-october-6-2026-rat-king-nerfs-sinclair-changes-and-trooper-fixes), [deadlock.one 10-14](https://deadlock.one/en/news/deadlock-update-patch-october-14-2026-valve-nerfs-baba-and-buffs-deadman-danny)
- **Matchmaking guard (still not enforced):** in build 6785 (10-15) the localization string still names the same 7
  sections (`Citadel_StartMatchmaking_UnverifiedPGI`). Sqooky 3.5.2, OptiLock 5.7 and Kaizu all keep editing those
  sections, and none of their issues reports a confirmed guard kick. Issue #79 (10-07, "Cannot join match after Baba
  release", kicked to the hideout) has no error text and no reply, so its cause is unknown. —
  [GameTracking 4e0f960 citadel_main_english.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/4e0f960), [OptimizationLock #79](https://github.com/Sqooky/OptimizationLock/issues/79)

### Inferences
- The alz cfg (alz-pc and experimental) has 0 lines using `r_texture_lod_scale` and 5 blocked lines, the same 5 already
  in RESEARCH.md. The 6769 blocks therefore add no new dead lines to it, except that `sc_screen_size_lod_scale_override "0.55"`
  is now hidden from the console. Treat that one as "probably still applied, can't be checked live".
- Valve's message reads as: lighting is off limits, while particle and LOD knobs are being provided on purpose. New
  release-flagged performance convars are worth checking for in every convars.txt diff from now on.

### Gaps
- No Valve developer-forum post was found directly; it is relayed second-hand by Sqooky in #88, because the forum is
  unreachable from here. Builds 6782 and 6785 have no convars.txt update in GameTracking yet (6785 changed only strings and network).

## Q2. What the major configs changed in the last ~3 weeks and why

### Takeaway
The convars that several configs newly adopted after 6779 are `r_citadel_disable_particle_lights true` and
`citadel_player_model_force_highest_lod false`. Sqooky main, Sqooky max-FPS and Kaizu both versions adopted the first;
Sqooky max-FPS, Kaizu and all OptiLock presets the second. OptimizationLock 3.5.x moved its former test_cfg into the
main file. OptiLock 5.7 (10-15/16) added a "TEST" block of about 40 lines, but most of them are dead or restate the
defaults. ghempy53 dropped its own tuning and now uses Sqooky 3.5.2 as its stable base.

### Cited Findings
**Sqooky OptimizationLock 3.4 (10-03) → 3.5 (10-10) → 3.5.1 (10-11) → 3.5.2 (10-13), plus max-FPS 1.4 (10-13)**
- 3.5 merged the test config into the main file as a live "Testing Version Commands" block of about 148 lines, then
  deleted `test_cfg` (commit "removed the old testcfg folder", 10-13). Main-config changes from 3.4:
  - `csm_max_num_cascades_override 0→2`, which brings some sun shadows back.
  - `snd_steamaudio_num_threads 6→4`, the default.
  - `r_aspectratio 2.9→2.5`.
  - `citadel_camera_use_vmdl_flatten_vertical true→false`, for mouse responsiveness, at the cost of ADS camera drift on
    Rem, Venator and Rat King.
  - Added `r_citadel_disable_particle_lights "true"`.
  - Removed `sc_fade_distance_scale_override` (blocked), `sc_allow_dithered_lod`, `enable_boneflex` and `ik_final_fixup_enable`.

  — [OptimizationLock commits](https://github.com/Sqooky/OptimizationLock/commits/main) (local diff 2b994f6..1691141)
- The 3.5 test block includes `ai_think_interval*`, `cl_bone_cache_optimization 1`, `cl_phys_sleep_enable`,
  `lb_dynamic_shadow_resolution_quantization 8`, `r_citadel_fog_quality 0`, `r_enable_*_fog false` (cheat, so these
  apply), `r_late_particle_job_sync 1`, `r_texture_stream_max_resolution 128`, `r_texture_pool_size 256`,
  `r_world_wind_frequency_* 0`, `r_haircull_percent 100`, `r_morphing_enabled false`, `cl_interp_parallel 1`,
  `parallel_update_surrounding_bounds_in_spatial_partition_update 1` and `sv_parallel_checktransmit 2`.
  Against build 6779, my check found:
  - **44 nonexistent lines**, among them `dsd_slow_cpu`, `lb_enable_newsum`, `r_citadel_ssao_radius/denoise_passes`,
    `r_texture_stream_resolution_bias`, `citadel_enable_new_ping_particle` and `citadel_portrait_unit_ag2_enable`.
  - **16 blocked lines**, among them `r_texture_lod_scale "8"`, `lb_enable_lights 0`, `lb_mixed_shadows`,
    `lb_max_visible_barn_lights_override` and `r_citadel_depthoffield_enable`.

  — local check against [GameTracking convars.txt @0c38f9d](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/0c38f9d/DumpSource2/convars.txt)
- **3.5.1 fix (10-11):** a value pushed by mistake, `r_lightmap_size "1"`, made "the map … black when textures are
  set to be high or higher". It was set back to `2048`. (The alz cfg already uses 2048.) — [commit 7d560c5](https://github.com/Sqooky/OptimizationLock/commit/7d560c5)
- **Max-FPS 1.4** credits `citadel_player_model_force_highest_lod "false"` as "courtesy of dohn valve too, allows the
  player model to render lowest LoD". — [maximumfps gameinfo.gi](https://github.com/Sqooky/OptimizationLock/tree/main/maximumfps%20or%20minimum%20spec%20config%20and%20resources%20here)
- **Kaizuchaneru (10-12 and 10-14):** the "ultimate fps" variant was removed "due to the commands being removed". The
  10-14 update adds `citadel_player_model_force_highest_lod false` and `r_citadel_disable_particle_lights 1`, adds a
  `gameinfo-EXTREME-LOW.gi`, and raises `EnvironmentMapFaceSize` from 256 to 2048 (stock is 256) with no reason given.
  Kaizu still carries **34 blocked lines**. — [commits f6fdab7, 0298945](https://github.com/Sqooky/OptimizationLock/commits/main)
- **Other configs:**
  - Piggy and Eskay were last updated 10-05; Eskay was added as a preset that day.
  - boot's max-FPS was last touched 2026-09-03, before CNS.
  - adamescj light config: the only commit is 10-01, with no later changes.
  - DeadTune v0.28.0 (10-08) only changed its live-HUD tooling.

  — [OptimizationLock commits](https://github.com/Sqooky/OptimizationLock/commits/main), [adamescj fork](https://github.com/adamescj/OptimizationLock), [deadtune](https://github.com/simulieren/deadtune)
- **DMM perf catalog** was last refreshed 10-09 (#848), so it predates 6779 and does not yet know
  `r_citadel_disable_particle_lights`. DMM gained a "performance configs" feature on 10-08 (#835). — [DMM commits](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commits/main)

**dacooderr OptiLock 5.6 → 5.7 (10-15/16) and the "Ultra Potato Testing Config" (10-15)**
- FPS (Recommended) changes:
  - `mat_colorcorrection true→false`, `r_particle_max_draw_distance 300000→5000`, `r_particle_max_size_cull 126→64`
    and `citadel_trooper_outline_enabled true→false`.
  - Shadow lines: `lb_csm_draw_translucent 0→1`, `lb_csm_override_staticgeo_cascades 0→1`, plus a duplicate
    `r_texture_lod_scale "0"`, which is blocked.
  - In `video.txt`: `"setting.r_render_portals" 1→2` (commit "portals to 2") and
    `lb_csm_override_staticgeo_cascades_value -1→0`.
  - Commit messages give no reasons beyond "removed duped dynamic resolution convars and disabled trooper outline".

  — [OptiLock commits](https://github.com/dacooderr/OptiLock/commits/main) (local diff 95485f6..e3c48af)
- OptiLock 5.7 adds the same `// --TEST--` block of about 40 lines to all presets. Against build 6779:
  - **Blocked:** `lb_cull_offscreen/onscreen_bounce_light_shadows`, `r_citadel_distancefield_occlusion_length`,
    `r_citadel_distancefield_max_distance` and `..._ray_origin_bias_*`.
  - **Restate the defaults:** all seven `sc_*_gpu_*culling` and `sc_mesh_backface_culling "true"`, plus
    `citadel_trooper_outline_enabled false`.
  - **Notable values:** `sc_screen_size_lod_scale_override` 0.30 / 0.1 / 0.01 (FPS / Potato / Ultra Potato);
    `sc_clutter_density_full/none_size 0.0001` with `sc_clutter_desity_override true` (Valve's spelling, which is real);
    `sc_shadow_depth_bias 0`; `r_particle_model_per_thread_count 1` (default 32); `r_size_cull_threshold_shadow 1.2`;
    `citadel_video_preset 0`.
  - The FPS preset carries 52 blocked lines and 70 nonexistent ones.

  — local check, [GameTracking convars.txt @0c38f9d](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/0c38f9d/DumpSource2/convars.txt)
- `r_render_portals` does not exist as a convar in the 6779 dump. The value in `video.txt` is a menu "setting" key, and
  nothing documents what 2 means. — same dump
- The Ultra Potato Testing readme says: "This will make your game look horrendous in the hideout but it's actually not
  too bad in a live match". — [OptiLock repo](https://github.com/dacooderr/OptiLock)

**ghempy53/deadlock-config (10-10 to 10-15)**
- 10-10: adopted OptimizationLock 3.5 "group A" (retire minor lights, UI hitch fixes, LOD fades off, lighter lightmaps).
  The same day it adopted "group B" (particle, physics, light binner, threads) and **reverted group B within the hour**;
  the log records no reason.
- 10-12: Eskay's config became stable v1.0.
- 10-14/15: stable v1.1 and v1.2 = "Sqooky 3.5.2 as tested in game". The owner tested v1.2 "and called it truth".

— [ghempy53 commits](https://github.com/ghempy53/deadlock-config/commits/main), [TESTED-CHANGES.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/TESTED-CHANGES.md)

### Inferences
- Of all recent upstream changes, the two Valve-provided `release` convars are the only well-founded, cheap additions
  for the alz cfg: `r_citadel_disable_particle_lights` and `citadel_player_model_force_highest_lod`. Neither touches
  the lighting that Valve now protects. The first could make ability flashes look flatter; the second only lowers the
  detail of your own hero.
- OptiLock 5.7's TEST block is low-value: about a quarter is dead or restates defaults, and the live parts are aggressive
  LOD and clutter cuts that hurt visuals. Don't copy it wholesale.

### Gaps
- No config author published reasoning or measurements for OptiLock's `r_render_portals 2`, `mat_colorcorrection false`,
  `r_particle_max_draw_distance 5000`, or Kaizu's `EnvironmentMapFaceSize 2048`.

## Q3. Measured benchmarks or credible reports since September 2026

### Takeaway
I found no new measured A/B numbers for specific convars in the window. The most important correction to
RESEARCH.md is about its round 3: the "another author measured camera-turn stutter and lower FPS" evidence came from
ghempy53's 10-07 test. On 10-15 its owner retracted the 10-06/07 results as distorted by problems with the owner's PC.
The 10-07 keyboard-lag result for `engine_low_latency_sleep_after_client_tick` was retracted the same way.

### Cited Findings
- ghempy53 TESTED-CHANGES (compiled 10-15): "The 2026-10-06 and 10-07 results in sections 1 and 3 were distorted by
  problems with the owner's PC, so they are history, not evidence (owner, 2026-10-15)." Section 3 is the one that held
  "Batching thresholds 256, `r_particle_max_size_cull 900`, `r_limit_particle_job_duration true`,
  `r_texture_budget_update_period 0.5` → stutter when turning the camera and clearly lower FPS (2026-10-07)" and
  "`engine_low_latency_sleep_after_client_tick true` → keyboard input felt laggy (2026-10-07)". Those results were also
  subjective ("clearly lower FPS"), not frame-time captures. — [TESTED-CHANGES.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/TESTED-CHANGES.md), [commit ca3bae8](https://github.com/ghempy53/deadlock-config/commit/ca3bae8)
- ghempy53's new stable v1.2 has all four of those "turn-stutter" lines active, and the owner accepts v1.2 ("Section 4
  is settled"). The only subjective verdicts left are "Performance felt excellent" for Eskay's config (10-13) and v1.2
  accepted after in-game testing (10-14/15). — same source
- OptiLock #13 (10-10): an MX110 laptop running the Potato config went from about 60 to about 40 FPS after the
  "Solomon update" (6769). There was no maintainer reply, and the reporter closed it on 10-11. The reporter is
  second-hand (a friend's PC). — [OptiLock #13](https://github.com/dacooderr/OptiLock/issues/13)
- OptimizationLock #93 (10-15, a Chinese-language bug summary) lists config side effects (black hero portraits,
  missing in-world item text, ADS crosshair drift on Rem/Venator/Rat King, distant buildings popping out with a small
  far-Z, a flat look with no fog). It gives one fix, `citadel_in_world_item_panel_dpi "2"`, and no FPS numbers. — [OptimizationLock #93](https://github.com/Sqooky/OptimizationLock/issues/93)
- Search-level summaries of forum threads (not verified first-hand, because the forum was unreachable):
  - A "City never sleeps performance degradation" thread.
  - A report of 220-240 → 60 FPS on a high-end system after CNS.
  - Hardware in the reports ranges from Ryzen 5 3600 + RTX 3070 to 9950X3D + RTX 5080.
  - Claims that the game became heavily CPU-bound with an idle GPU, where lowering resolution doesn't help.

  — [forum thread 170725](https://forums.playdeadlock.com/threads/city-never-sleeps-performance-degredation.170725/) (search snippet only)

### Inferences
- With round 3's only evidence retracted, round 3 in `experimental` now rests on no measured evidence either way. Treat
  it as a normal untested candidate. Test `engine_low_latency_sleep_after_client_tick` again live; its "keyboard lag"
  verdict is no longer evidence.

### Gaps
- I found no frame-time capture (PresentMon/CapFrameX) for any Deadlock convar dated after 09-29. Reddit and YouTube
  searches returned nothing dated in the window. I could not read the forum threads directly.

## Q4. Known issues, regressions and config-level workarounds

### Takeaway
No Valve fix for the CNS performance regression has shipped up to build 6785. Most reports still describe CPU-bound
fights, view-dependent drops and long-session leaks. The new particle-light convar is the only Valve-provided config
lever aimed at fight load.

### Cited Findings
- None of the October patch notes mentions performance. A search summary says that as of 10-08 Valve had not released
  a performance fix. — [SteamDB 10-14](https://steamdb.info/patchnotes/25950029/), [unDeadlock 6785 notes](https://undeadlock.com/patches/2026-10-15-6785)
- Search snippets of older forum threads report FPS drops when standing in or looking toward the blue lane or mid, and a
  memory/VRAM-leak thread where FPS falls to 13-15 after long play and recovers after a restart. These match RESEARCH.md
  §7 and add no new workaround. — [Massive FPS drops (memory leak?)](https://forums.playdeadlock.com/threads/massive-fps-drops-memory-leak.166548/), [Performance issues](https://forums.playdeadlock.com/threads/performance-issues.98611)
- Config-caused regressions reported in the window:
  - Black map with high textures from `r_lightmap_size 1` (OptimizationLock 3.5, fixed in 3.5.1).
  - Issues #82 "Lights are back?" (10-10) and #88 are the visible result of the 6769 lighting block.
  - Issue #91: the Sinners light mod conflicts with the "Texture Downscaler" VPK.
  - Issue #70: Rat King camera bug.
  - Issue #87: Eskay config GPU crash.

  — [OptimizationLock issues](https://github.com/Sqooky/OptimizationLock/issues)
- OptimizationLock added laund's "Clutter be Gone" VPK set on 10-10 (All / City Ambient / Clean Doorway / Graves /
  Walker) and a work-in-progress "Texture Downscaler". No FPS numbers are given for the new parts. — [commit 8dbe451](https://github.com/Sqooky/OptimizationLock/commit/8dbe451)

### Inferences
- For a 5700X + RTX 5070 that is CPU-bound in fights, the most sensible new test is a live console A/B of
  `r_citadel_disable_particle_lights 1` during a teamfight or in the Sandbox with ability spam, using a frame-time overlay.
  If it helps, add it to `ConVars`. It is not in the guarded sections, so it is queue-safe.

### Gaps
- There is no dated evidence that the view-dependent drop changed in 6769-6785. I found no report on whether the new
  convar actually raises FPS: Sqooky gives none, and it is too new.
