# GPU/render-side, video.txt and engine-section options with no visual loss, plus an audit of alz's files (Deadlock build 6821, 2026-10-27)

Scope: render-side ConVars in `gameinfo.gi`, `video.txt` keys, and the guarded engine sections (RenderSystem, SceneSystem,
MaterialSystem2, WorldRenderer, Particles, Engine2). The target PC is a Ryzen 7 5700X with an RTX 5070 12 GB at 2560x1440 on DX11.
It is CPU-bound in fights. The files audited:
- `alz/` (personal): DLSS (`r_citadel_upscaling 4`), 1.7x (`r_citadel_dlss_settings_mode 2`), `mat_viewportscale 0.58`, `r_dlss_preset 10`.
- `stable/` (public): Stretch (`r_citadel_upscaling 0`), `mat_viewportscale 1`.

The two `gameinfo.gi` files differ only in the header comment, so every gameinfo finding applies to both. The old
experimental variant is `git show 834e588:experimental/...`; the `experimental` branch tip is 834e588.

This note extends `research/RESEARCH.md`, `research/reports/*.md` and
`research/notes/Deadlock FPS gains with good visuals/gpu_render_convars.md`. It does not repeat them, and it corrects
them in four places (marked **Correction**).

**Pinned sources.**
- **Valve data:** SteamDatabase/GameTracking-Deadlock commit `d251cf9` = **build 6821, 2026-10-26 20:03 UTC**, the newest
  build. Call it GT6821 = `https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/`.
  Earlier builds were compared through the commit log (6801 `37f9aeb` → 6802, 6803, 6805, 6806, 6807, 6810, 6812, 6813,
  6814, 6815, 6817, 6819, 6821).
- **Audit method:** a local Python audit (`python3 -I`) of both cfgs against the 6821 `convars.txt`. It covered existence,
  `gameinfo_cannot_override`, `replicated`/server-only, min/max, equality with the default, duplicates and `video.txt`
  overlap. Script and outputs are in the scratchpad `scripts/` and `b6821/`.
- **NVIDIA:** DLSS Super Resolution Programming Guide **310.6.0 (released March 2026)**, downloaded from NVIDIA's DLSS GitHub repo.
- **Community:** OptiLock at `8b78c0f` (2026-10-26); ghempy53/deadlock-config at `7231a9e` (2026-10-23); DMM perf catalog
  `2026.10.26-1` (convar build 6812).

**Evidence caveat:**
- **No per-line FPS figures:** no source has a reproducible per-line FPS measurement for any render ConVar or engine key
  in this note. ghempy53's owner reports from 2026-10-06/07 were later declared invalid by the owner. Every "gain" below is
  either Valve or NVIDIA documentation, or an inference from what the line does.
- **The ~-40 FPS of experimental is confounded** (see Q1 Inferences). Experimental switched `video.txt` to DLAA, so that
  result can't be blamed on any single convar round.

---

## Q1. Which render ConVars cut GPU/CPU render cost and still give an identical image at alz's settings?

### Takeaway
Very little is left that is both free and real. At these settings the sun is off, CSM is off, dynamic light shadows are
off, SSAO is off, DF AO/shadows are off, volumetric/cubemap/gradient fog are off in SceneSystem, and bloom is off. Most of
the "invisible" lines the community passes around just re-disable things that are already off, so they gain about 0.

The options that are actually zero-visual and worth doing, all unmeasured:
1. Return the texture-budget lines to Valve's defaults: hitch insurance, never lowers quality.
2. Optionally raise `r_texture_pool_size`: VRAM for fewer streaming downgrades.
3. Set DLSS preset K instead of J: same cost, cleaner image.
4. `csm_max_visible_dist 0`: belt-and-braces, probably 0 gain.

The commonly cited "free" levers aren't free here:
- **`r_distancefield_enable 0`:** **not proven invisible**. The area-light path in the distance-field shader is tied to it,
  and alz has area lights on.
- **`r_citadel_disable_particle_lights` and `lb_precomputed_shadowmap_enable 0`:** both have a visible cost.

### Ranked candidates (zero visual cost, or a cost only in what's already off)

| # | Exact line | What it does | Evidence (measured vs claimed) | Why it's invisible | Online valid | Mod risk | alz has it? |
|---|---|---|---|---|---|---|---|
| 1 | **Delete** `r_texture_budget_threshold "0.7"` (alz gameinfo line 604) → default 0.9 | "Reduce texture memory pool size when this percentage of the budget is full." | Valve help text. ghempy53 owner report (2026-10-07) of camera-turn stutter + lower FPS with these lines, later invalidated by the owner. **Not measured.** | 0.7 makes the pool shrink *earlier*, which means lower mips and more streaming churn. The default keeps at least as much texture detail. | Yes. ConVars block, not blocked, `developmentonly defensive` | None (ConVars aren't on Valve's guard list) | Has the non-default 0.7. This is a removal. |
| 2 | **Delete** `r_texture_budget_update_period "0.5"` (line 605) → default 0.1 | Seconds between texture-budget updates | As #1 (same reverted bundle). Not measured. | Slower budget updates can only delay how the pool reacts. No image change at a steady state. | Yes | None | Has 0.5. Removal. |
| 3 | Add `r_texture_pool_size "3072"` (test; default 1600) | "Total size of the texture pool in MB". DMM: "Smaller pools stream lower-resolution textures sooner." | Valve help + DMM description. ghempy53 runs 6400 on the same RTX 5070, explicitly "not measured". **No FPS data.** | Larger pool = equal or higher texture resolution. `r_texture_budget_dynamic true` still trims it under VRAM pressure. | Yes (`developmentonly defensive`) | None | No |
| 4 | `video.txt`: `"setting.r_dlss_preset" "11"` (preset K) instead of `"10"` (alz only) | DLSS model preset | NVIDIA guide 310.6.0: J and K have identical cost on RTX 5070 (1.02 ms at 2560x1440 output). "Preset K is generally recommended over preset J", and J "might exhibit slightly less ghosting at the cost of extra flickering". The Valve value → NGX enum mapping is an inference (Q5). **Not tested in-game.** | Same cost. Image is equal or better (less flicker). | Yes (`video.txt` layer) | None; not a gameinfo line. The menu offers only 6/10, so touching the DLSS row rewrites it. | Has 10 (J) |
| 5 | `csm_max_visible_dist "0"` + `csm_cascade0..3_override_dist "0"` | Sun-shadow draw distance | Pack consensus (Sqooky, boot, OptiLock 6.1, adamescj Light). Boot's "notable performance improvement" has no number. Not measured. | The sun is already off: `r_rendersun 0`, SceneSystem `CSMCascadeResolution 0`, `video.txt` `csm_max_num_cascades_override 0`. | Yes (`cheat`, applies at startup) | None | No. It was in experimental r4 only. |

Expected gain from #1-#5 together: **≈0 average FPS in fights.** The only realistic effect is fewer texture-streaming hitches
(#1-#3) and a cleaner DLSS image (#4). This is an inference from what the lines do; nothing here is measured.

### Not zero-visual, or not proven: rejected or "test with screenshots"

| Line | Why rejected | Evidence |
|---|---|---|
| `r_distancefield_enable "0"` | **Not proven invisible.** In the current distance-field compute shader, the area-light combo exists only in distance-field mode 5 (`DynamicComboRule( Requires( D_AREA_LIGHTS, D_DISTANCE_FIELD_MODE==5 ) )`), and that pass reads `g_BarnLights` and light cookies. `deferred_lighting` samples `g_tDistanceFieldAmbientOcclusion`. alz's `video.txt` has `r_arealights true`, so turning the DF master switch off may change area lights and beams. DF AO quality 0 and DF shadows false are already set, so the remaining saving is the DF upkeep only. OptiLock 6.1 sets it false; adamescj Light keeps 1. Only test with before/after screenshots of beam and area-light effects. | [GT6821 distancefield_cs.slang](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/shaders_vulkan_dir/shaders/vfx/distancefield_cs.slang); [deferred_lighting.slang](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/shaders_vulkan_dir/shaders/vfx/deferred_lighting.slang) |
| `r_citadel_disable_particle_lights "true"` | Visible: dynamic light emitted by particles (ability glow on walls and floors) goes away, "except when explicitly overriden in particle renderer ops". It's `release`, so A/B it live in the console. OptiLock 6.1 (2026-10-23) now ships it. No measurement. | [GT6821 convars.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/DumpSource2/convars.txt); [OptiLock 2691647](https://github.com/dacooderr/OptiLock/commit/26916477030f024102af5e8dcde07d832befcde8) |
| `lb_precomputed_shadowmap_enable "false"` | Visible risk: "Uses precomputed shadow maps for static lights" (DMM). Since 6801 these maps also feed fog shadows. ghempy53: "map becomes unreadably bright or dark". OptiLock 6.1 still sets false. No measurement. | [DMM catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog); [ghempy53 UPSTREAM-DIFF](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/UPSTREAM-DIFF-2026-10-10.md) |
| `r_particle_max_detail_level "2"` (newly settable, see Q3) | Visible: it stops creating particle children tagged Ultra. It's a CPU lever, but it removes effect detail. | [GT 6812 commit](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/0abfe676c64c7d24bd5340a46778e65a84be70ed) |
| `r_dlss_preset "6"` (CNN) | About 0.59 ms GPU per frame cheaper than J/K on the 5070, but softer and less stable (Q5). It's a trade-off, not free. | NVIDIA guide 310.6.0 |
| `r_low_latency "2"` (Reflex + Boost) | Valve tooltip: "may draw more power to the GPU and slightly impact FPS". Keep 1, which alz already has. | [GT6821 citadel_main_english.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/resource/localization/citadel_main/citadel_main_english.txt) |
| `engine_low_latency_sleep_after_client_tick "true"` | Frame pacing/latency, not FPS. A keyboard-lag owner report exists (later invalidated). alz has the default `false` written out (a no-op line). | convars.txt help; [ghempy53 TESTED-CHANGES](https://github.com/ghempy53/deadlock-config/blob/main/docs/TESTED-CHANGES.md) |
| `vis_sunlight_enable "false"` (new in OptiLock 6.1) | It changes the visibility set for sunlight views. With the sun off, there's nothing to gain and the PVS semantics are unclear. No evidence. | convars.txt help |
| Shader cache / async compile | Nothing to set: `mat_async_shader_load` no longer exists in 6821; `mat_shader_cache` (default true) and `r_dx11_software_cmd_lists` (default true) are already on. The real lever is the NVIDIA driver shader-cache size (outside the cfg). | GT6821 convars.txt |
| Swapchain/present ConVars | None useful: `r_wait_on_present` (no description), `r_legacy_vsync` (hidden, "for testing for a couple user machines"), `r_force_no_present` (cheat). | GT6821 convars.txt |

### Cited Findings
- `r_texture_budget_threshold` default **0.9** ("Reduce texture memory pool size when this percentage of the budget is full."), `r_texture_budget_update_period` default **0.1**, `r_texture_pool_size` default **1600** ("Total size of the texture pool in MB"), `r_texture_budget_dynamic true` ("Dynamically adjust texture streaming budget based on GPU memory usage."), all `developmentonly defensive` and not `gameinfo_cannot_override` in build 6821 — [GT6821 convars.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/DumpSource2/convars.txt)
- ghempy53 (owner report 2026-10-07): "Batching thresholds 256, `r_particle_max_size_cull 900`, `r_limit_particle_job_duration true`, `r_texture_budget_update_period 0.5`: Stutter when turning the camera and clearly lower FPS". The owner later declared the 2026-10-06/07 results invalid ("not measured performance evidence") — [ghempy53 TESTED-CHANGES.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/TESTED-CHANGES.md)
- ghempy53 rendering audit (build 6814, 2026-10-22): the 6400 MB pool and the 0.7 threshold "interact with memory pressure… The effective budget, residency, hitches, and frame times require measurement"; "No game was launched… no FPS, latency, memory or visual measurement was made" — [ghempy53 AUDIT-RENDERING-2026-10-22.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/AUDIT-RENDERING-2026-10-22.md)
- DMM: `r_texture_pool_size` "Smaller pools stream lower-resolution textures sooner"; `lb_precomputed_shadowmap_enable` "Uses precomputed shadow maps for static lights"; `sc_instanced_mesh_motion_vectors` "used by temporal effects such as TAA upscaling and motion blur" (catalog 2026.10.26-1, convar build 6812) — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- `r_citadel_disable_particle_lights false (clientdll release)`: "Disable particle lights except when explicitly overriden in particle renderer ops." `csm_max_visible_dist 7500 (cheat)`. `r_rendersun true (cheat)`: "Render sun lighting" — [GT6821 convars.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/DumpSource2/convars.txt)
- The distance-field compute shader declares `DynamicCombo( D_DISTANCE_FIELD_MODE, 0..9 )`, `DynamicCombo( D_AREA_LIGHTS, 0..1 )`, `DynamicComboRule( Requires( D_AREA_LIGHTS, D_DISTANCE_FIELD_MODE==5 ) )`, and binds `g_BarnLights`, `g_tLightCookieTexture` and `g_farFieldInstances`. `deferred_lighting` binds `g_tDistanceFieldAmbientOcclusion` — [GT6821 distancefield_cs.slang](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/shaders_vulkan_dir/shaders/vfx/distancefield_cs.slang); [GT6821 deferred_lighting.slang](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/shaders_vulkan_dir/shaders/vfx/deferred_lighting.slang)
- OptiLock FPS Config 6.1b (2026-10-23/26) sets `r_citadel_disable_particle_lights "true"`, `r_distancefield_enable "false"`, `lb_precomputed_shadowmap_enable "false"`, `csm_max_visible_dist "0"`, `vis_sunlight_enable "false"`, with no measurements published. The 2026-10-26 "timescale fix" changed `r_particle_timescale` 0.7 → 1.2 in all presets — [OptiLock 2691647](https://github.com/dacooderr/OptiLock/commit/26916477030f024102af5e8dcde07d832befcde8); [OptiLock 8b78c0f](https://github.com/dacooderr/OptiLock/commit/8b78c0f9e09b767b60f7c90be473a9d3320b398e)
- Valve's Reflex tooltip: Boost "may draw more power to the GPU and slightly impact FPS to reduce latency as much as possible" — [GT6821 citadel_main_english.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/resource/localization/citadel_main/citadel_main_english.txt)
- `mat_shader_cache true (developmentonly)`, `r_dx11_software_cmd_lists true` ("Enable Software Command lists for DX11 (Avoid using deferred contexts)"), `r_texture_nonstreaming_load true`. `mat_async_shader_load` isn't in the 6821 dump — [GT6821 convars.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/DumpSource2/convars.txt)
- Web searches for Deadlock measurements of `r_citadel_disable_particle_lights` / `r_distancefield_enable` found only generic guides with no per-convar numbers — [esports.gg guide](https://esports.gg/news/deadlock/best-settings-to-maximize-fps-and-performance-in-deadlock); [evetech guide](https://evezone.evetech.co.za/game-desk/best-deadlock-pc-settings-for-maximum-fps-in-2026)

### Inferences
- **The old experimental "-40 FPS" result is confounded, so rounds 2-4 were never measured.** The experimental `video.txt`
  set `r_citadel_upscaling 4` + `r_citadel_dlss_settings_mode 4` (DLAA: native 1440p render plus a DLSS pass costing
  ≈1 ms on a 5070). Stable ran Stretch at scale 1 with FXAA. In GPU-bound moments that switch alone can plausibly cost
  tens of FPS at 200+ FPS. That means the 29 consensus lines, the 6 stutter resets and r4 have no measurement of their own. If alz
  retests, hold `video.txt` constant and change only `gameinfo.gi`.
- **The `r_rendersun 0` / CSM question is now mostly settled by the engine sections.** SceneSystem `CSMCascadeResolution 0`
  and `DefaultShadowTextureWidth/Height 0`, plus `video.txt` `csm_max_num_cascades_override 0`, mean the CSM pass has no
  cascades and no atlas. Any `csm_*` / `lb_csm_*` ConVar line therefore gains about 0. This is why #5 ranks last.
- `r_particle_max_size_cull "600"` (default 1200; "Particle systems larger than this in every dimension skip culling to save
  CPU. They will be drawn anyway."): lowering it means *more* systems skip culling and get drawn. That trades CPU culling
  for GPU draw work. It is zero-visual either way, but its direction is unknown. It is one of the ghempy53 stutter-bundle
  lines, so resetting it with #1/#2 as one "texture/particle reset" A/B is reasonable.

### Gaps
- No frame-time measurement exists for any line in the table. The validation alz should do: CapFrameX or PresentMon, a
  fixed Sandbox route plus one real match, `video.txt` held constant.
- Whether texture streaming actually hitches on this PC at mip bias 0 with the 1600 MB pool is unknown. Check
  `r_texture_pool_size`, VRAM use and pop-in in a long match.
- What distance-field "mode 5" represents in-game (area-light occlusion or something else) is unknown. The shader
  combo only shows the coupling exists.

---

## Q2. Which video.txt keys and config lines are dead after build 6801 and later? (audit of alz/ and stable/)

### Takeaway
- **Valve's video layer hasn't changed since 6801.** `video_defaults_0..3.txt`, `video_version.txt` (still 20) and
  `popup_settings.xml` are byte-identical from 6801 to 6821.
- **Dead `video.txt` key:** only `setting.r_particle_depth_feathering`. Valve's presets, the settings UI and every 6821
  string dump checked have no reference to it.
- **gameinfo ConVars block (identical in alz and stable):** 19 lines name convars that don't exist, 5 are blocked, 12
  duplicate `video.txt` (`video.txt` wins), 22 are `replicated` (the server wins online), 11 are server-only, 3 are below
  the engine minimum, 7 names are duplicated, and 45 restate the default.
- **New since the earlier audits:**
  - `sc_instanced_mesh_motion_vectors 0` now matters for alz, because alz runs DLSS.
  - Four RenderSystem keys appear in no engine string dump, and several more are Vulkan-only, so they do nothing on DX11.
  - **Correction:** the commented `FogCachedShadowAtlas*` runtime keys are *not* proven dead. The runtime key strings still
    exist in `scenesystem.dll`.

### B1. ConVars-block audit vs the 6821 dump (line numbers are `alz/gameinfo.gi`; `stable/` is the same file)

| Class | Count | Lines |
|---|---|---|
| Don't exist in 6821 | 19 | `r_citadel_enable_pano_world_blur` 558, `citadel_damage_text_batching_window_ability` 572, `citadel_distance_mouse_move_for_minimap_drawing` 573, `citadel_unit_status_old_update_rate` 578, `citadel_unit_status_single_bar_mode` 579, `citadel_camera_height_ceiling_distance` 595, `mat_async_shader_load` 625, `r_citadel_ssao_thin_occluder_compensation` 628, `r_lightmap_bicubic_filtering` 631, `r_multiscattering` 634, `r_citadel_screenspace_particles_full_res` 664, `cl_enable_eye_occlusion` 701, `csm_viewmodel_farz` 705, `r_async_compute_fog` 712, `r_citadel_depth_prepass_dynamic_objects` 713, and 4 stock-tail lines Valve itself still ships (`cl_async_usercmd_send_disabled_recvmargin_min`, `panorama_classes_perf_warning_threshold_ms`, `snd_event_browser_default_stack`, `snd_event_browser_focus_events`; keep those, they are stock) |
| `gameinfo_cannot_override` (ignored) | 5 | `lb_enable_dynamic_lights` 557, `lb_enable_baked_shadows` 582, `lb_enable_stationary_lights` 583, `sc_fade_distance_scale_override` 680, `r_citadel_gpu_culling` 686 |
| Owned by `video.txt` (`video.txt` value wins) | 12 | `r_texture_stream_mip_bias` 606 (gi 3, vt 0), `lb_csm_override_staticgeo_cascades` 613, `lb_csm_override_staticgeo_cascades_value` 614 (gi "true", vt -1), `lb_enable_shadow_casting` 616, `r_citadel_shadow_quality` 620, `r_citadel_ssao_quality` 627, `r_depth_of_field` 649, `r_effects_bloom` 650, `r_post_bloom` 651, `cl_particle_fallback_multiplier` 660, `cl_particle_fallback_base` 661, `fps_max` 844 (gi 400, vt 0) |
| `replicated` (server wins online) | 22 | incl. `citadel_camera_see_distance_max` 598, `ik_final_fixup_enable` 644, `props_break_max_pieces_perframe` 645, `phys_cull_internal_mesh_contacts` 677, `debug_draw_enable` 709, `snd_occlusion_*` 738-739, the spatial-partition stock-tail lines |
| Server-only (`gamedll` without `clientdll`) | 11 | `citadel_hideout_ball_*` 574-575, `citadel_melee_shake_duration` 585, `citadel_melee_shake_amplitude` 589, `nav_edit_use_camera` 602, `sv_maxunlag*`, `sv_lagcomp_filterbyviewangle`, `nav_gen_connect_dist_a`, `disable_source_soundscape_trace`, `sv_parallel_checktransmit` (the last six are Valve stock) |
| Below engine minimum (clamped up) | 3 | `lb_dynamic_shadow_resolution_base 16` 615 (min 128), `lb_ssss_samples 0` 617 (min 3), `r_character_decal_resolution 4` 648 (min 256) |
| Duplicate names (last line wins) | 7 | `sc_layer_batch_threshold_fullsort` 684 = "120" vs stock tail 835 = "20" (**the 120 is dead**); `snd_ui_positional` 742 "false" vs stock 850 "1" (**the false is dead**); `cl_aggregate_particles`, `r_particle_batch_collections`, `sc_allow_dithered_lod` (679/692), `cl_interp_parallel`, `snd_steamaudio_enable_pathing` (same values) |
| Equal to the 6821 default | 45 | incl. `r_distancefield_enable 1` 630, `engine_low_latency_sleep_after_client_tick false` 584, `r_citadel_shadow_caching true`, `mat_colorcorrection 1`, `r_max_portal_render_targets 2`, `r_farz -1`, `r_mapextents 16384`, `citadel_trooper_glow_disabled 0` |

These counts match RESEARCH.md §2 (build 6779) exactly. Nothing changed class between 6801 and 6821 for any line in these
files.

### B2. Lines newly affected, or worth a second look

| Line | Status | Why |
|---|---|---|
| `sc_instanced_mesh_motion_vectors "0"` (line 681) | **Newly relevant for alz (DLSS).** stable: harmless (no temporal AA). | DMM: motion vectors "used by temporal effects such as TAA upscaling". Static geometry gets motion vectors reconstructed from the G-buffer (`reconstruct_static_motion_vectors`: "Reconstruct motion vectors from gbuffer"), and wind is off (`r_world_wind_strength 0`), so visible ghosting is unlikely (inference). Any moving instanced mesh would ghost under DLSS. Its FPS saving is unmeasured. For alz, deleting the line (default true) is the safe zero-cost choice for image stability. |
| `"setting.r_citadel_antialiasing" "1"` (alz video.txt line 28) | Possibly redundant under DLSS | Valve tooltip: FXAA is used "when FSR2 is disabled". Whether FXAA also runs on top of DLSS in Deadlock is unknown. If it does, it wastes a small pass and softens the DLSS output. **Gap:** compare FXAA on and off in the menu with DLSS on. |
| `"setting.mat_viewportscale" "0.58"` with `r_citadel_dlss_settings_mode 2` (1.7x) | Fine | 1/1.7 = 0.588. The menu snaps it. No action. |
| `"setting.r_particle_depth_feathering" "true"` (line 36) | **Dead** since 6801 | Absent from all four 6821 presets, from `popup_settings.xml`, and from client, materialsystem2 and rendersystem strings. |
| `"setting.shaderquality"`, `recommendedheight`, `knowndevice` | Alive (not convars, but engine video keys) | `shaderquality` is referenced in client, materialsystem2 and rendersystemdx11 strings and in all 4 presets. `knowndevice` is in rendersystemdx11 strings. |
| `"setting.r_citadel_fsr_*"`, `r_citadel_fsr3_min_reactiveness` | Inert for alz (DLSS) and for stable (Stretch) | They only apply with FSR. Harmless. |
| `lb_csm_override_staticgeo_cascades_value "true"` (gi 614) | Dead twice | `video.txt` sets -1 (it wins), and "true" isn't a valid value for the numeric convar (default -1) |
| `//[6801 renamed to ...Tools, tools-only] FogCachedShadowAtlasWidth/Height/TileSize "0"` (gi 456-458, commented) | **Correction:** not proven dead | The 6801 `scenesystem` string diff only *added* the `...Tools` keys. `SceneSystem/FogCachedShadowAtlasWidth`, `…Height` and `…TileSize` are still present in the 6821 `scenesystem` strings. Valve stopped *setting* them in stock, so the engine now uses its built-in defaults. Keep them commented out. Re-adding liv's 0s would be an untested guarded-section edit, and the dynamic-light fog-shadow cost they controlled is moot here anyway (SceneSystem `VolumetricFog 0`, `lb_enable_shadow_casting false`). |

### B3. `video.txt` keys vs Valve (6821)
- **Menu-owned keys alz and stable set, and their 6821 status:**
  - Upscaling, DLSS mode, DLSS model and AA are live menu rows.
  - `r_dlss_preset` has only CNN=6 and Transformer=10 in the menu. Every preset now writes 6, with the comment "CNN - was 10 for transformer model".
  - `r_low_latency` (Reflex dropdown) and fog/shadow/SSAO quality are live.
  - `r_texture_stream_mip_bias` 0 = the High preset value.
- **Advanced keys alz sets that have no menu row** (`volume_fog_*` at the minimum 64/64/48, `csm_max_num_cascades_override`,
  `lb_*` shadow keys, `r_citadel_distancefield_*`): all are real 6821 convars, none below its minimum, none blocked. Whether the
  `video.txt` loader applies them at all is still the open in-game check from RESEARCH.md §4. Several are also
  redundant with SceneSystem keys (`VolumetricFog 0`, `DefaultShadowTexture* 0`).

### Cited Findings
- Valve's `gameinfo.gi` has the same MD5 at 6801 (`37f9aeb`) and 6821 (`d251cf9`). Between them, the only `DumpSource2/convars.txt` change is one line (build 6812). The `cfg/` folder and `popup_settings.xml` aren't touched by any commit after 6801 — [GameTracking-Deadlock history](https://github.com/SteamDatabase/GameTracking-Deadlock/commits/master); [GT6821 gameinfo.gi](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/gameinfo.gi)
- 6821 `video_defaults_3.txt` (Ultra): `"setting.r_dlss_preset" "6" // CNN - was 10 for transformer model`, `"setting.r_citadel_upscaling" "4"`, `"setting.r_citadel_dlss_settings_mode" "0"`, `shaderquality 1`, no `r_particle_depth_feathering` — [GT6821 video_defaults_3.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/pak01_dir/cfg/video_defaults_3.txt)
- The settings UI's DLSS Model enum: `convar="r_dlss_preset"` with `value="6"` (CNN) and `value="10"` (Transformer). The AA row tooltip: "Post-process anti-aliasing effect to use when FSR2 is disabled" — [GT6821 popup_settings.xml](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/pak01_dir/panorama/layout/popups/popup_settings.xml); [GT6821 citadel_main_english.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/resource/localization/citadel_main/citadel_main_english.txt)
- The 6801 diff of `scenesystem_strings.txt` added `SceneSystem/FogCachedShadowAtlasHeightTools`, `…WidthTools` and `…TileSizeTools`, and removed nothing. The 6821 file still lists `SceneSystem/FogCachedShadowAtlasHeight`, `…Width` and `…TileSize` — [GT6821 scenesystem_strings.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/bin/win64/scenesystem_strings.txt); [GT 6801 commit](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/37f9aebdc62766aa13748f73309b9b8120549833)
- `sc_instanced_mesh_motion_vectors true`: "Toggles motion vector support for instanced meshes" (6821). The `reconstruct_static_motion_vectors` shader is described as "Reconstruct motion vectors from gbuffer" — [GT6821 convars.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/DumpSource2/convars.txt); [GT6821 reconstruct_static_motion_vectors.slang](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/shaders_vulkan_dir/shaders/vfx/reconstruct_static_motion_vectors.slang)
- Clamp minimums: `lb_dynamic_shadow_resolution_base` min 128, `lb_ssss_samples` min 3, `r_character_decal_resolution 1024 (min: 256)`, `volume_fog_width/height/depth` min 64/64/48 — [GT6821 convars.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/DumpSource2/convars.txt)
- ghempy53 independently flags `lb_csm_override_staticgeo_cascades_value "true"` (numeric default -1; "how this boolean-looking text is parsed were not verified") and documents the stock-tail `sc_layer_batch_threshold_fullsort "20"` override — [ghempy53 AUDIT-RENDERING-2026-10-22.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/AUDIT-RENDERING-2026-10-22.md)
- alz's and stable's `gameinfo.gi` differ only in line 1. Their `video.txt` files differ only in upscaling (4 vs 0), `mat_viewportscale` (0.58 vs 1) and comments — local `diff alz/ stable/` (repo HEAD `1b37f16`)

### Inferences
- All dead or duplicate lines are harmless. Removing them gains no FPS. It only makes the file honest. The two that
  silently *don't do what they say* are `sc_layer_batch_threshold_fullsort "120"` (the stock tail's 20 wins) and
  `snd_ui_positional "false"` (the stock tail's 1 wins).
- Because nothing render-relevant changed in Valve's files after 6801, the 6801 fix (`cb1bb5b`) is still the current
  structure: `PGIVersion 48C04ECA…` and `BakedLighting Version 5` match 6821 stock. SearchPaths keeps the explicit Mod/Write
  lines and the DMM markers.

### Gaps
- Whether `video.txt` applies its non-menu keys (and blocked convars) still needs a console check in-game. Nothing in
  Valve's files answers it.
- Whether FXAA runs on top of DLSS is unknown (see B2).

---

## Q3. Did builds after 6801 (6802-6821) change gameinfo.gi, convar defaults or render code relevant to performance?

### Takeaway
Only one render-relevant change. **Build 6812 (2026-10-21) removed `gameinfo_cannot_override` from
`r_particle_max_detail_level`** and gave it `min 0, max 3`, so `gameinfo.gi` can set it again. There were no changes to
`gameinfo.gi`, the video presets, the settings UI, shaders or maps. Everything else was hero content and gameplay.

### Cited Findings
- 6812 (`0abfe67`, 2026-10-21 22:03 UTC): `r_particle_max_detail_level 3 (developmentonly defensive gameinfo_cannot_override)` → `r_particle_max_detail_level 3 (min: 0, max: 3, developmentonly defensive)`: "The maximum detail level of particle to create". This is the only line changed in `convars.txt` between 6801 and 6821 — [GT 6812 commit](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/0abfe676c64c7d24bd5340a46778e65a84be70ed)
- DMM's catalog (2026.10.26-1, convar build 6812) now lists `r_particle_max_detail_level` with min 0 / max 3 and no block: "Highest particle detail level spawned; 0 spawns only the cheapest variants" — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- What changed in `pak01` after 6801 (`pak01_dir.txt` diff 6801→6821): 53 animgraph files (6810 added `hero_leans` graphs for every hero), 29 hero models/clips (Nurse, Artist, Doorman), 22 ability particles (Nurse leech, Artist pull brush), 12 diner portrait models, 8 particle materials, VO and sounds. No `shaders_*` and no `maps/` entries — [GT 6810 commit](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/c90ff498d244fc9a3e6722faf70e455c0b7a07f8); [GT 6821 commit](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/d251cf9d9a796061c90f58724230b7e17b97121b)
- 6810 also removed `is_high_skill_range_party` from the party protobuf (matchmaking, not render) — [GT 6810 commit](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/c90ff498d244fc9a3e6722faf70e455c0b7a07f8)
- OptiLock 6.1 (2026-10-23) and ghempy53's upstream check (2026-10-23, build 6819) made no Valve-driven structural changes — [OptiLock commits](https://github.com/dacooderr/OptiLock/commits/main); [ghempy53 7231a9e](https://github.com/ghempy53/deadlock-config/commit/7231a9e781584298b49560f01801cbfd4b52924f)
- Web search found no official October 2026 patch notes about performance — [deadlock.wiki Patch notes](https://deadlock.wiki/Patch_notes); [Liquipedia patches](https://liquipedia.net/deadlock/Portal:Patches)

### Inferences
- The unblocked `r_particle_max_detail_level` is a CPU lever that suits a CPU-bound 5700X. But any value below 3 removes
  particle children Valve tagged above that level (Low 0 / Medium 1 / High 2 / Ultra 3), which is a visual cost. Valve may
  have unblocked it deliberately or by accident; it can't be told from the files. It belongs to a separate "small visible
  cost" test (2 = drop only Ultra children), not to this zero-loss list.
- The 6810 lean animations are on every hero. They add a little animation CPU work per visible hero, which no cfg line
  controls. This is an inference with no measurement.

### Gaps
- GameTracking stopped tracking executables (2026-10-07). Binary-only render changes would show only through string
  dumps. None of the post-6801 commits changed `game/bin/win64/*_strings.txt` (scenesystem, rendersystem, particles).

---

## Q4. Engine-section keys: which are safe and measured?

### Takeaway
**None is measured as an FPS gain on any PC.** The only measurements that exist are negative, and both were on this PC:
liv's engine edits put back (round 1) gave slightly *less* FPS, and OptiLock's engine sections gave 30-40 FPS less. So:
- Propose **no new engine keys**.
- Keep alz's current guarded edits, since the baseline look depends on several of them.
- The only zero-cost engine work is cleanup:
  - Four RenderSystem keys alz sets appear in **no** engine string dump.
  - Several more are Vulkan-only, which does nothing on DX11.
  - Dropping them lowers matchmaking-guard exposure with no visual change.

### Guarded-section edits in alz/stable vs Valve 6821 stock

| Section / key (alz value; stock value) | Status on DX11 | Verdict |
|---|---|---|
| RenderSystem `GraphicsPipelineLibrary 1` (not in stock), `SwapChainSampleableDepth 1` (not in stock), `VulkanOnly_Linux 1` (not in stock), `VulkanSteamShaderCache 1` (not in stock) | **No string for these keys** in the 6821 rendersystemdx11, rendersystemvulkan, engine2, scenesystem, materialsystem2, worldrenderer or particles dumps. The near-matches that exist are `SwapChainSampleableStencil`, `VulkanOnly` and `VulkanSteamAppShaderCache`. | Probably unread (copied from CS2-style configs). Zero-cost to delete. |
| RenderSystem `VulkanAdditionalShaderCache`, `VulkanSteamAppShaderCache 1`, `VulkanSteamDownloadedShaderCache 1`, `VulkanStagingPMBSizeLimitMB 768` (stock 384), `VulkanDefrag`, `VulkanMutableSwapchain`, `VulkanRequire*` | Strings exist only in `rendersystemvulkan` | No effect on DX11. Keep stock values or delete the non-stock ones. |
| RenderSystem `IndexBufferPoolSizeMB 128` (stock 32), `MinStreamingPoolSizeMB 2048` (stock 1024), `AllowPartialMipChainImmediateTexLoads 1` (not in stock; key exists in dx11) | Real keys | Unmeasured. Larger pools are a VRAM cost, not an image cost. Keep, or revert to stock if Valve enforces the guard. |
| SceneSystem `VolumetricFog 0`, `CubemapFog 0`, `NonTexturedGradientFog 0` (stock 1/1/1) | Real keys | **They are part of alz's current look** (fog systems off). They make `video.txt` `volume_fog_*` / `r_citadel_fog_quality` and the 6801 baked fog-shadow sampling moot, which is an inference. Not "free": reverting adds fog back. |
| SceneSystem `CSMCascadeResolution 0` (2048), `DefaultShadowTextureWidth/Height 0` (6144), `SunLightMaxCascadeSize 2` (4) | Real keys | Shadow atlases already at zero. They make every `csm_*` / `lb_csm_*` ConVar redundant. |
| WorldRenderer `GrassCastsShadows 0` (1), `EnvironmentMapCacheSizeTools 2` (300, tools-only) | Real / tools-only | Grass shadows: already invisible with shadows off. `...Tools`: no runtime effect. |
| Engine2 / Particles / MaterialSystem2 | Identical to stock | Don't touch. `Engine2/RenderingPipeline/DistanceField 0` crashes (DMM deny list). |

Engine keys that exist but are **not proposed**:
- **Visual or unknown:** `Engine2/RenderingPipeline/AmbientOcclusionProxies` (a visual change), and the RenderSystem keys
  `ReserveMemoryForNonTextureUseMB`, `SetInitialStreamingPoolSizeFromBudget`, `VertexBufferPoolSizeMB` and
  `MaxPreloadTextureResolution` (semantics unknown, no evidence).
- **Already tested negative on this PC:** SceneSystem `HDRFrameBuffer` and `Particles/EnableMixedResolution` (round 1).

### Cited Findings
- Valve's matchmaking error lists "Engine2, MaterialSystem2, NetworkSystem, Particles, RenderSystem, SceneSystem, WorldRenderer". DMM's `guardedSections` repeats that list, and its deny list has `Engine2/RenderingPipeline/DistanceField` ("Setting it to 0 crashes the current game build after the hideout loads") — [DMM perf catalog rules](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog); RESEARCH.md §1
- 6821 stock RenderSystem: `IndexBufferPoolSizeMB 32`, `VulkanStagingPMBSizeLimitMB 384`, `MinStreamingPoolSizeMB 1024`, `MinStreamingPoolSizeMBTools 2048`, `LowLatency 1`, `VulkanDefrag 1`, `VulkanMutableSwapchain 1`, and no `GraphicsPipelineLibrary`, `SwapChainSampleableDepth`, `VulkanOnly_Linux`, `VulkanSteam*` or `AllowPartialMipChainImmediateTexLoads`. Stock SceneSystem: `CSMCascadeResolution 2048`, `DefaultShadowTextureWidth/Height 6144`, `SunLightMaxCascadeSize 4`, `NonTexturedGradientFog 1`, `CubemapFog 1`, `VolumetricFog 1`. Stock WorldRenderer: `GrassCastsShadows 1`, `EnvironmentMapCacheSizeTools 300` — [GT6821 gameinfo.gi](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/gameinfo.gi)
- Engine key strings present in 6821: `RenderSystem/AllowPartialMipChainImmediateTexLoads`, `IndexBufferPoolSizeMB`, `MinStreamingPoolSizeMB`, `MaxPreloadTextureResolution`, `ReserveMemoryForNonTextureUseMB`, `SetInitialStreamingPoolSizeFromBudget`, `VertexBufferPoolSizeMB` (dx11 and vulkan); `RenderSystem/VulkanAdditionalShaderCache`, `VulkanSteamAppShaderCache`, `VulkanSteamDownloadedShaderCache`, `VulkanOnly`, `SwapChainSampleableStencil` (vulkan only); `Engine2/RenderingPipeline/AmbientOcclusionProxies`, `…/DistanceField`, `…/OpaqueFade` — [GT6821 rendersystemdx11_strings.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/bin/win64/rendersystemdx11_strings.txt); [GT6821 rendersystemvulkan_strings.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/bin/win64/rendersystemvulkan_strings.txt); [GT6821 engine2_strings.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/bin/win64/engine2_strings.txt)
- ghempy53's 2026-10-22 audit lists `GraphicsPipelineLibrary`, `SwapChainSampleableDepth`, `VulkanOnly_Linux` and the `VulkanSteam*` keys among "52 engine paths absent from stock". It notes that "A binary string containing a key path supports the existence of that string, not a claim that the path is read", and that "Vulkan-named keys … are not evidence of a DX11 performance benefit" — [ghempy53 AUDIT-RENDERING-2026-10-22.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/AUDIT-RENDERING-2026-10-22.md)
- This PC's own engine-section tests (from repo history): round 1 (7 engine lines back on) gave "slightly less FPS"; OptiLock engine sections plus this cfg's ConVars gave "30-40 FPS less" — local `research/RESEARCH.md` §3

### Inferences
- The absence of a key string is strong but not conclusive evidence that a key is unread. GameTracking dedupes strings
  across modules, and not every DLL was checked. Deleting the four unmatched RenderSystem keys is still zero-risk: if a key
  is unread, nothing changes, and if it is read, Valve stock doesn't set it either.
- The negative engine-section results on this PC fit the general pattern: changing pool and buffer sizes or render paths
  away from Valve's tuned stock can cost FPS. Without a measurement, the evidence-based default is stock or the current
  values.

### Gaps
- No A/B exists for `MinStreamingPoolSizeMB 2048` vs stock 1024, or `IndexBufferPoolSizeMB 128` vs 32, on any PC.
- The semantics of `SetInitialStreamingPoolSizeFromBudget` and `ReserveMemoryForNonTextureUseMB` are unknown.

---

## Q5. DLSS: is the transformer preset measurably more expensive than CNN at 1.7x on an RTX 5070? Is there a no-loss option?

### Takeaway
**Yes.** NVIDIA's own table puts the transformer presets J/K at **1.02 ms** versus CNN E/F at **0.43 ms** on an RTX 5070 at
2560x1440 output. That's ≈0.6 ms per frame, a big share of a 4-5 ms frame at 200-250 FPS, but only when GPU-bound.

alz's `r_dlss_preset 10` is, by inference, NGX preset **J**. The no-loss move is **preset K (`11`)**: NVIDIA lists the same
cost and recommends it over J. Switching to CNN (`6`) does give FPS when GPU-bound, but it's a visible-quality trade
(softer, less stable), so it is rejected for a zero-loss list. Valve itself moved every preset back to CNN.

### Cited Findings
- NVIDIA DLSS SR guide 310.6.0 (March 2026), "DLSS Execution Times": RTX 5070 at 1920x1080 / **2560x1440** / 3840x2160 output →
  - presets E, F: 0.27 / **0.43** / 0.93 ms
  - presets J, K: 0.64 / **1.02** / 2.11 ms
  - preset L: 1.17 / **1.87** / 3.87 ms
  - preset M: 0.75 / **1.33** / 2.98 ms

  For comparison, RTX 5080 J/K at 1440p is 0.68 ms. The test conditions: "NVIDIA ran the DLSS library using a command line
  utility (i.e. without a 3D renderer)", in "Performance Mode" (1440p output from a 1280x720 input). VRAM at 1440p:
  E/F 95.22 MB, J/K 143.54 MB — [NVIDIA DLSS Programming Guide](https://github.com/NVIDIA/DLSS/blob/main/doc/DLSS_Programming_Guide_Release.pdf)
- Same guide, preset descriptions:
  - "Preset J: Similar to preset K. Preset J might exhibit slightly less ghosting at the cost of extra flickering. Preset K is generally recommended over preset J".
  - "Preset K: Default preset for DLAA/Balanced/Quality modes".
  - Preset L and M "Delivers a sharper, more stable image … more expensive".
  - "Preset F … Will be deprecated".

  The enum order is Default, (A-D removed), E, F, G, H, I, J, K, L(, M); the revision history has 310.2.0 "Added preset K"
  and 310.5.0 "Add Presets L, M" — [NVIDIA DLSS Programming Guide](https://github.com/NVIDIA/DLSS/blob/main/doc/DLSS_Programming_Guide_Release.pdf)
- Deadlock ships `game\bin\win64\nvngx_dlss.dll` (54,778,992 bytes). Its 6821 strings show the NGX source branch `rel_310_5` (DLSS 310.5.x). They also contain "App hint Preset %s is not available, using title default Preset %s" — [GT6821 nvngx_dlss_strings.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/bin/win64/nvngx_dlss_strings.txt); GT6821 `manifests/manifest_1422456.txt`
- Valve's tooltip: Transformer is "the newer beta model released with DLSS4, sharper and more accurate especially at higher scaling ratios, but also more expensive". All 6821 presets write `r_dlss_preset 6` ("CNN - was 10 for transformer model"). The convar default is 5 with no min/max — [GT6821 citadel_main_english.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/resource/localization/citadel_main/citadel_main_english.txt); [GT6821 video_defaults_3.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/game/citadel/pak01_dir/cfg/video_defaults_3.txt); [GT6821 convars.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/d251cf9d9a796061c90f58724230b7e17b97121b/DumpSource2/convars.txt)
- Deadlock player report (forum, via search snippet only, page not fetchable):
  - Setup: RTX 4070 Super + Ryzen 7 5700X3D.
  - 1080p at 2x DLSS: about 400 FPS, with Transformer and CNN "nearly identical".
  - 4K at 2x DLSS: about 175 FPS, with the Transformer dropping more.
  - The same behaviour on Vulkan and DX11. One anecdotal test — [forums.playdeadlock.com thread 98349](https://forums.playdeadlock.com/threads/dlss-with-cnn-model-run-really-poorly-since-the-new-update.98349)
- General reviews (search snippets): KitGuru measured about a 4% cost for the Transformer on an RTX 5090. PCGH reports the DLSS 4.5 Transformer costs less on newer architectures (FP8) — [KitGuru RTX 5090 review](https://www.kitguru.net/components/graphic-cards/dominic-moass/nvidia-rtx-5090-review/27/); [PCGH DLSS 4.5 test](https://www.pcgameshardware.de/Deep-Learning-Super-Sampling-Software-277618/Specials/DLSS-45-aktivieren-Test-Performance-Spiele-1490771/4/)

### Inferences
- **Mapping.** Valve's menu values 6 (CNN) and 10 (Transformer) line up exactly with the NGX enum ordinals F=6 (CNN) and
  J=10 (the first transformer preset, Jan 2025, from before K existed). So `11` = K, `12` = L, `13` = M. This is consistent
  but not confirmed. Verify in-game: set `"setting.r_dlss_preset" "11"` and check the console value. If the NGX log is
  available, the DLL string "Using App hint Preset %s" would show it.
- **Size of the CNN trade at 1.7x on the 5070.** DLSS cost scales mainly with output resolution (2560x1440), so expect
  ≈0.6 ms saved per frame with CNN. Worked numbers, GPU-bound only:
  - 5.0 ms → 4.4 ms (200 → ~227 FPS, +13%).
  - 4.0 ms → 3.4 ms (250 → ~293 FPS, +17%).

  In CPU-bound fights the GPU has idle time, so the gain shrinks toward 0. This matches the forum report: nearly identical
  at high-FPS 1080p, a gap at GPU-bound 4K. Because CNN is visibly softer, it's an alz-taste decision, not a free gain.
- **No-loss DLSS option:** preset K (`11`) costs the same as J and reduces flicker. Avoid L (`12`, +0.85 ms vs J/K) and
  M (`13`, +0.31 ms) on a frame-rate-focused setup.
- **The scaling ratio matters far more than the preset.** 1.7x (`r_citadel_dlss_settings_mode 2`) is already a good
  balance. The bigger move, 2x (`1`), is a visual trade.

### Gaps
- There's no Deadlock-specific frame-time A/B of preset 6 vs 10 vs 11 on an RTX 5070. NVIDIA's figures come from a
  standalone utility, not from Deadlock.
- The Valve → NGX preset mapping is unverified (see above). The Deadlock forum thread could only be read as a search
  snippet: its date, build and exact numbers are unverified.
- Whether a value outside the menu (11) survives a menu save, and how the menu shows it, is untested.
