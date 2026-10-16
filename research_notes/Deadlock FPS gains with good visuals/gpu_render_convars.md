# GPU/render-side ConVars for Deadlock: near-free FPS that keeps the compylock look (build ~6769-6779, Oct 2026)

Scope: `ConVars` block of `gameinfo.gi` only. Convars flagged `gameinfo_cannot_override` and the 7 guarded engine sections
are excluded. Baseline is `/home/user/alz-deadlock-cfg/experimental/gameinfo.gi` (compylock + 29 consensus lines + 6
stutter resets). This extends `/home/user/alz-deadlock-cfg/RESEARCH.md` and does not repeat it.

How sources were used. Flags, defaults, min/max and Valve help text come from the Deadlock Mod Manager perf catalog
(`catalog.json`, convar build 6769, generated 2026-10-09). Pack values come from local copies of each repo. Web fetches
to forums, guide sites and GitHub were blocked in this session (DNS/proxy denial), so web evidence is limited to search
snippets and is marked that way.

**Evidence caveat that applies to everything below:** I found **no per-convar FPS measurement** for any render convar in
Deadlock, apart from the reverted stutter lines already covered in RESEARCH.md. Every FPS statement below is either a
config author's comment or an inference from what the convar does. Treat each "adopt" as "safe to try, low risk", not
"measured gain".

## 1. Which render convars not in the experimental config give FPS with little or no visible change?

### Takeaway
Very little is left that's both free and real. Compylock plus round 2 already pulls every major non-hiding render lever
that isn't blocked (`lb_*` light/shadow switches, `r_citadel_distancefield_*`, `lb_enable_envmaps`, fog switches and
`lb_max_visible_*` are all `gameinfo_cannot_override` now). What remains:
- **Adopt:** `csm_max_visible_dist 0`. Every other pack sets it, including adamescj's visuals-first Light config. It has
  no visible cost while the sun is already off (`r_rendersun 0`), and it may save a shadow pass on both CPU and GPU.
- **Adopt as a safety net:** `volume_fog_width/height/depth` at the engine minimum (64/64/48). Liv's own `video.txt` already
  asks for this.
- **Test:** AO-proxy cuts and `fog_enable false`. These change the look.
- **Skip:** the rest of what other packs set. It's either moot under this config, server-overridden, likely to *cost*
  CPU (it disables caches or precomputed visibility), or visibly ugly.

### Ranked candidate table (not currently in experimental)

Columns: G = can gameinfo set it (not `gameinfo_cannot_override`). Flags are from the build-6769 dump (via the DMM catalog).

| # | ConVar | Default | Proposed | Flags | G | FPS evidence | Visual cost | CPU too? | Verdict |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `csm_max_visible_dist` | 7500 | 0 | cheat (applies from gameinfo at startup) | yes | No measurement. Set by Sqooky default, Sqooky test/max-fps, Eskay, boot, OptiLock Potato and adamescj **Light** (0). OptiLock FPS uses 1, Kaizu 1000. Boot "provided the csm cvars which had a notable performance improvement" (OptimizationLock README credits, no number). | None beyond today's look: compylock already runs `r_rendersun 0`, and round 2 sets `csm_max_num_cascades_override 0`. | Yes: fewer shadow-caster draw calls if a sun-shadow pass is still rendered. | **Adopt** (belt and braces) |
| 2 | `csm_cascade0..3_override_dist` | -1 | 0 | cheat | yes | Same packs as #1 (Light config included). No measurement. | None while the sun is off. | Same as #1 | **Adopt with #1** or skip as redundant |
| 3 | `volume_fog_width` / `volume_fog_height` / `volume_fog_depth` | 240 / 160 / 128 | 64 / 64 / 48 (engine minimum) | defensive, developmentonly | yes | No Deadlock measurement. The froxel grid shrinks from 4.9 M to 0.2 M cells (arithmetic). Generic engine docs say a smaller fog buffer means better performance and less detail. | Coarser volumetric fog and light shafts, more light bleed. **Compylock's `video.txt` already requests 16/16/16, which clamps to 64/64/48**, so this matches compylock's intended look. | No (GPU) | **Adopt as a safety net.** Redundant if `video.txt` already applies; check with `volume_fog_width` in the console. |
| 4 | `fog_enable` | true | false | cheat | yes | No measurement. Set by **every** compared pack, including adamescj Light and Sqooky default. Not set by compylock. DeadTune's preset comment (Sqooky): "Disable fog entirely (cheat)". | Removes distance haze and atmosphere. The map looks harsher and flatter. DMM's curated list calls this hiding ("changes how far players can see"), though removing haze arguably shows *more*. | Negligible | **Test only if you like the look.** It isn't "free": it changes compylock's look. |
| 5 | `r_aoproxy_cull_dist` / `r_aoproxy_min_dist` / `r_aoproxy_min_dist_box` | 12 / 3 / 1 | 0.01 / 9999 / 9999 | defensive, developmentonly | yes | No measurement. Boot max-fps and OptiLock FPS/Potato only. DeadTune notes: "might be able to do 0, idk". | Removes the soft AO "blobs" that ground heroes and props. SSAO is already off in compylock, so these proxies are the only AO left. Expect a "floaty" look. | Slight (fewer proxies) | **Test (low priority)** |
| 6 | `lb_shadow_texture_width_override` / `lb_shadow_texture_height_override` | -1 | leave, or 512 | defensive, developmentonly | yes | No measurement. Kaizu 16, OptiLock 1, Ultra Potato 0. | Valve/DMM: "small values make shadows blocky". With light shadow casting and the sun off there should be little left to see, but 0/1/16 are risky values. | No | **Skip** (the saving is likely VRAM only) |
| 7 | `sc_force_single_display_list_per_layer` | false | 1 | defensive, developmentonly | yes | OptiLock only. Undocumented. | Unknown | Batching change; could go either way | **Skip until measured** (the same class as the batching lines reverted in round 3) |
| 8 | `sc_aggregate_indirect_draw_compaction_threshold` | 8 | 1 | release | yes | adamescj left it commented out as "Need to test". | None expected | GPU-driven draw compaction | **Skip / test later** |

### Skipped because moot, server-owned, menu-owned or counterproductive

| ConVar (packs that set it) | Why skip |
|---|---|
| `thumper_use_plane_reflection false` (boot, OptiLock) | Flag `replicated`: the server's value wins online. Bot matches only. |
| `r_decals*` (boot, OptiLock) | `replicated` (server wins). DMM also notes that decals act as ability indicators (Lash slam, Warden ult). |
| `r_light_flickering_enabled` (**already in experimental**) | `replicated`, so it's a no-op online. See §4. |
| `wind_system_default_resolution_xy 64`, `wind_system_temporal_smoothing false` | Moot: compylock already sets `r_world_wind_strength 0`. |
| `r_haircull_percent`, `r_hair_*` | Moot: `r_render_hair false` already. |
| `sc_dithered_lod_transition_amt 0` | Moot: `sc_allow_dithered_lod false` already. |
| `lb_dynamic_shadow_resolution_base_cmp_shadowmapsize`, `r_citadel_shadowdb 256` | Light shadow casting is already off. `r_citadel_shadowdb` is undocumented. |
| `r_citadel_gpu_preview_baked_shadows false` (and experimental's `r_citadel_gpu_preview_denoise_passes 0`) | The name points to a lightmap *preview* (tools) path. Likely a no-op in matches (inference). |
| `sc_cache_envmap_lpv_lookup false` (boot, OptiLock) | It's a cache ("Caches which environment map and light probe each object samples"). Turning it off most likely **adds** CPU work. |
| `lb_barnlight_shadow_use_precomputed_vis 0` (boot, OptiLock) | Turns off precomputed visibility, which is an optimization. Likely adds culling work. |
| `lb_enable_binning false` (Kaizu, OptiLock), `lb_bin_slices 0` (Sqooky test/max-fps) | Light-binner internals. ghempy53 notes that "0 slices may break lighting". No evidence of a gain. |
| `r_particle_mixed_resolution_viewstart 800` (OptiLock) | It raises the distance where particles drop to reduced resolution, so more particles render at full resolution. That's more GPU work, not less. |
| `r_arealights`, `r_citadel_fog_quality`, `r_citadel_antialiasing`, `r_citadel_ssao_quality`, `r_citadel_shadow_quality`, `r_texture_stream_mip_bias` | Menu-owned: `video.txt` wins. Liv's `video.txt` already has these at minimum (arealights false, fog 0, AA 0, SSAO 0, shadows 0, mip bias 4). |
| Envmap/cubemap levers (`lb_enable_envmaps`, `lb_max_visible_envmaps_override`, `r_environment_map_roughness_range`) | All `gameinfo_cannot_override`. **No envmap lever is left in ConVars.** |
| Distance-field sub-features (`r_citadel_distancefield_*` except `_shadows`/`_ao_quality`) | All `gameinfo_cannot_override`. Only the `r_distancefield_enable` master switch remains (already in experimental). |

### Cited Findings
- `csm_max_visible_dist` (default 7500, flag `cheat`, "Distance beyond which sun shadows are not drawn") is not blocked from gameinfo — [DMM perf catalog, build 6769 dump](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- Every compared pack except Kaizu and OptiLock FPS sets `csm_max_visible_dist 0` and `csm_cascade0..3_override_dist 0`, including adamescj's visuals-first Light config — [ghempy53 convar-matrix.csv](https://github.com/ghempy53/deadlock-config/tree/main/docs/research/data); [adamescj Light gameinfo.gi](https://github.com/adamescj/OptimizationLock/tree/main/adamescj's%20light%20config)
- OptimizationLock credits: "Boot: Provided the csm cvars which had a notable performance improvement" (no number) — [Sqooky/OptimizationLock README](https://github.com/Sqooky/OptimizationLock)
- Compylock already sets `r_rendersun "0"`, and adamescj's Light config keeps `r_rendersun "0"` ("Disables sun lighting") — [7liv/compylock](https://github.com/7liv/compylock); [adamescj Light](https://github.com/adamescj/OptimizationLock/tree/main/adamescj's%20light%20config)
- `volume_fog_width/height/depth` defaults are 240/160/128 with minimums 64/64/48. They're `defensive, developmentonly` and settable from gameinfo — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog); ghempy53 confirms that `volume_fog_*`, `fog_enable`, `lb_csm_*` and `r_texturefilteringquality` "still work" from gameinfo — [ghempy53 BLOCKED-CONVARS.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/BLOCKED-CONVARS.md)
- Compylock's `video.txt` sets `volume_fog_width/height/depth "16"`, which clamps to the minimum — [7liv/compylock video.txt](https://github.com/7liv/compylock); [ghempy53 RESEARCH-2026-10-06.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/RESEARCH-2026-10-06.md)
- Generic engine documentation says a larger volumetric fog buffer gives more detail at a performance cost (Godot docs, via search snippet, not Deadlock-specific) — [Godot volumetric fog docs](https://docs.godotengine.org/it/4.5/tutorials/3d/volumetric_fog.html)
- `fog_enable` is `cheat` and not blocked. DMM's curated list treats `fog_enable` as "Removes fog, which changes how far players can see" — [DMM curated consensus.ts](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog/curated)
- `fog_enable false` appears in Sqooky default, test and max-fps, Eskay, Piggy, Kaizu, boot, OptiLock FPS/Potato/Ultra and adamescj Light — [ghempy53 convar-matrix.csv](https://github.com/ghempy53/deadlock-config/tree/main/docs/research/data)
- DeadTune's preset notes for the AO proxy: `r_aoproxy_cull_dist` "default: 12, might be able to do 0, idk"; `r_aoproxy_min_dist` "0 is always tricky so consider changing this to 1". Only boot and OptiLock use 0.01/9999 — [simulieren/deadtune convar_catalog.csv](https://github.com/simulieren/deadtune)
- `thumper_use_plane_reflection`, `r_decals*` and `r_light_flickering_enabled` carry the `replicated` flag (server value wins online) — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog); replicated behaviour is described in [RESEARCH.md §1](../../RESEARCH.md)
- `sc_cache_envmap_lpv_lookup`: "Caches which environment map and light probe each object samples" — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- `lb_bin_slices 0`: "Light binner internals; 0 slices may break lighting" — [ghempy53 UPSTREAM-DIFF-2026-10-10.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/UPSTREAM-DIFF-2026-10-10.md)
- These are `gameinfo_cannot_override` in build 6769: `lb_enable_envmaps`, `lb_max_visible_envmaps_override`, `lb_max_visible_barn_lights_override`, `r_environment_map_roughness_range`, the whole `r_citadel_distancefield_*` family (blur, farfield, max_distance and others; `_shadows` and `_ao_quality` excepted), `r_citadel_npr_outlines`, `r_citadel_mboit_quality`, `r_particle_cables_cast_shadows`, `sc_fog_cull`, `r_enable_volume_fog/cubemap_fog/gradient_fog` and `lb_shadow_map_culling` — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- adamescj left `sc_aggregate_indirect_draw_compaction_threshold "1"` commented out with "Need to test" — [adamescj Light gameinfo.gi](https://github.com/adamescj/OptimizationLock/tree/main/adamescj's%20light%20config)

### Inferences
- With `r_rendersun 0` already active, the 14 shadow lines in round 2 (`csm_*`, `lb_csm_*`) and #1/#2 above probably change nothing visible. Whether they save GPU time depends on whether the engine still renders the CSM depth pass with sun lighting off. Nobody has tested that. If it does, `csm_max_visible_dist 0` is the cleanest kill switch for that pass, and it also cuts CPU draw-call submission for shadow casters.
- A realistic total for every "adopt" in this section on an RTX 5070 at 1440p is low single-digit FPS at most, and 0 in CPU-bound fights. GPU savings show up in averages and quiet moments, not fight 1% lows.
- The CPU-side render levers already in the config (`cl_retire_low_priority_lights 1`, `r_morphing_enabled false`, `lb_enable_shadow_casting 0`, `sc_allow_dithered_lod false`, and CSM off) are the ones that also trim draw calls or skinning work. There's no further CPU-relevant render convar left that doesn't hide something.

### Gaps
- No Deadlock-specific FPS measurement exists for any single convar in the table above. Guide sites (TroubleChute "every setting tested", PC Optimized Settings) were indexed but couldn't be fetched, and their snippets had no per-setting numbers — [TroubleChute](https://hub.tcno.co/videos/deadlock-every-setting-tested-graphics-breakdown-performance/), [PC Optimized Settings](https://pcoptimizedsettings.com/deadlock-pc-optimization-guide-best-graphics-settings-for-valves-early-access-game/)
- Whether `r_rendersun 0` skips the CSM render pass is unknown (no Valve help text).
- Whether `video.txt` actually applies non-menu keys such as `volume_fog_*` is still untested (RESEARCH.md §4 open question).

## 2. r_texturefilteringquality and r_texture_stream_mip_bias on a 12 GB RTX 5070: is there any measurable FPS difference?

### Takeaway
**Keep `r_texturefilteringquality 5` (16x anisotropic).** It isn't menu-owned and it isn't blocked, so the gameinfo value
is what you get. The FPS cost of AF on modern GPUs is reported at about 1-2% when GPU-bound and roughly 0 when CPU-bound.
Bilinear (0), which every other pack uses, visibly blurs ground textures at an angle and shows mip transition lines.

**Mip bias is decided by `video.txt`** (liv's sets 4, so the gameinfo `3` is dead). On 12 GB, dropping it to 1-2 costs VRAM,
not FPS. That's the single cheapest visual gain available, and compylock's own file says to lower it if you have VRAM.

### Cited Findings
- `r_texturefilteringquality`: default 1 (trilinear). Values 0 Bilinear, 1 Trilinear, 2-5 Aniso 2x-16x. Flags
  `defensive, developmentonly` (restart required; no live A/B). Not `gameinfo_cannot_override` — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- It isn't an in-game menu option. DMM's list of menu-owned video keys (upscaling, render quality, AA, SSAO, shadows,
  fog, texture quality = mip bias, bloom, area lights, DoF, fps_max, Reflex, reduce flashing) has no texture filtering —
  [DMM curated video.ts](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog/curated)
- ghempy53 lists `r_texturefilteringquality` among the frame-time levers that still work from gameinfo after build 6769 — [ghempy53 BLOCKED-CONVARS.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/BLOCKED-CONVARS.md)
- Sqooky's config comment: "Texture filtering, has very low fps impact." Even so, every OptimizationLock/OptiLock pack and adamescj Light use 0 — [adamescj Light gameinfo.gi](https://github.com/adamescj/OptimizationLock/tree/main/adamescj's%20light%20config); [DeadTune catalog](https://github.com/simulieren/deadtune)
- ghempy53, on the same RTX 5070, deliberately ran `r_texturefilteringquality 4` ("Anisotropic 8x (owner choice); upstream bilinear") with mip bias 0, before forking to OptimizationLock 3.5.2 values. No FPS figure was recorded — [ghempy53 UPSTREAM-DIFF-2026-10-10.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/UPSTREAM-DIFF-2026-10-10.md)
- Generic modern-GPU reports put 4x→16x AF at about a 1-2% cost, with RDR2 the largest dip at about 2% (informal forum data, seen in a search snippet only; the page fetch failed) — [Guru3D forum](https://forums.guru3d.com/threads/question-about-4x-16x-anisotropic-texture-filtering-and-performance.427505/page-2)
- `r_texture_stream_mip_bias` maps to the menu "Texture quality" (0 High, 1 Med, 2 Low), and `video.txt` wins over gameinfo — [DMM curated video.ts / catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- Liv's `video.txt`: `"setting.r_texture_stream_mip_bias" "4" // CHANGE THIS IF YOU HAVE A LOT OF VRAM, LOWER NUM = HIGHER QUALITY TEXTURES` — [7liv/compylock video.txt](https://github.com/7liv/compylock)
- Above 4, Sinner's Sacrifice lights turn into small triangles unless the Sinner light fix addon is installed — [dacooderr/OptiLock README](https://github.com/dacooderr/OptiLock); [DMM catalog sideEffects](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- `r_texture_budget_dynamic` (default true) "Adjusts the texture streaming budget to the GPU's memory use", and `r_texture_pool_size` defaults to 1600 MB — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- One guide says high texture settings raise VRAM use and can cause micro-stutter only when VRAM is insufficient (search snippet, low-quality source) — [evetech guide](https://evezone.evetech.co.za/game-desk/best-deadlock-pc-settings-for-maximum-fps-in-2026)

### Inferences
- On a 5070 that's CPU-bound in fights, 16x AF vs bilinear should be within run-to-run noise in fights and perhaps 1-2%
  in GPU-bound quiet moments. Bilinear removes trilinear blending between mips, so floors and walls at an angle show
  visible mip "bands" as well as blur. It's the most visible of the "cheap" texture cuts. Verdict: **keep 5** (or 4 if you want
  a token saving). **Skip 0.**
- Mip bias costs VRAM and streaming bandwidth, not shader time. With 12 GB and a 1.6 GB default texture pool that scales
  dynamically, `video.txt` mip bias 1 (Med) or 2 (Low) should cost ~0 FPS and look much sharper than 4. Lower mip bias also
  removes the need for the Sinner LOD fix addon (only needed above 4). Delete the dead `r_texture_stream_mip_bias "3"` gameinfo
  line, or leave it; it's harmless either way.
- Pack values like `r_texture_pool_size 256` and `r_texture_stream_max_resolution 128` (boot, OptiLock) are VRAM-starvation
  settings for 2-4 GB cards. On 12 GB they only blur textures. The catalog notes that the engine minimum for max
  resolution is 512 anyway.

### Gaps
- No Deadlock A/B of AF level or mip bias with frame times was found. No published Deadlock VRAM-usage figure per texture setting was found.

## 3. What makes compylock "look decent", and which cuts in other packs are ugly vs invisible? (with visual-quality guardrails)

### Takeaway
Compylock is a **sunless, shadowless, AO-less** look. It keeps hero glows and outlines, map colour grading, full-detail
LODs (except its own `sc_screen_size_lod_scale_override 0.55`), HDR, decals, tracers of others, envmaps and fog. Its
`video.txt` is minimal on everything else. The other packs' "ugly" cuts fall into three groups:
1. **Colour and tonality:** HDR off, colour-correction entities off, `postprocess` off.
2. **Geometry and readability:** draw distance, LOD/size culling, props, decals, tracers, clutter culling that hides things.
3. **Texture starvation:** tiny pools, a capped max resolution, mip bias above 4.

The "invisible" cuts are mostly CSM and shadow internals, once shadows are already gone.

### Cited Findings
- adamescj's Light config is "Sqooky's default with the ugliest cuts reverted: normal lighting, no pop-in, proper LODs, vents visible at range". It restores `sc_fade_distance_scale_override`, `sc_screen_size_lod_scale_override`, `r_size_cull_threshold`, `r_farz`/`r_mapextents`, `lb_enable_baked_shadows` ("Map isn't flat and washed out") and `lb_enable_stationary_lights` ("Proper lighting"). It rates itself ★★★★☆ vs Sqooky ★★★☆☆, Sqooky max-fps ★★☆☆☆, boot ★★☆☆☆ and Kaizu minimum spec ★☆☆☆☆ for "Look" — [adamescj/OptimizationLock README and Light README](https://github.com/adamescj/OptimizationLock)
- The Light config still keeps `r_rendersun 0`, `r_ssao 0`, `r_lightmap_size 2048`, `fog_enable false`, all CSM cuts and `r_texturefilteringquality 0`, but keeps **`r_distancefield_enable "1"`** — [adamescj Light gameinfo.gi](https://github.com/adamescj/OptimizationLock/tree/main/adamescj's%20light%20config)
- Since build 6769, `lb_enable_baked_shadows`, `lb_enable_stationary_lights` and `lb_enable_dynamic_lights` are ignored from gameinfo, so the "flat/washed-out" lighting cut no longer applies from any pack's gameinfo — [ghempy53 BLOCKED-CONVARS.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/BLOCKED-CONVARS.md)
- Sqooky's comment on `mat_colcorrection_disableentities`: "uncomment if you want grey lookin game" (set by Kaizu extreme low, OptiLock FPS/Potato/Ultra) — [DeadTune catalog (preset comments)](https://github.com/simulieren/deadtune)
- `mat_colorcorrection` off: "the game looks less saturated"; `r_postprocess_enable` off: "Upstream notes the game looks grey without it" (blocked anyway) — [DMM curated convars.ts](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog/curated)
- `sc_hdr_enabled_override 0` "changes how bright areas and colors look" (Sqooky test/max-fps, boot, OptiLock) — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog). The related engine-section `HDRFrameBuffer 0` was tested in round 1 and gave slightly *less* FPS — [RESEARCH.md §3](../../RESEARCH.md)
- OptimizationLock FAQ fixes, each one an "ugly/broken" cut: buildings popping (`r_farz`, `r_mapextents`); boxes and trooper health bars vanish (`r_size_cull_threshold`, `sc_fade_distance_scale_override`); holes in Victor/Paige and Sinner lights as triangles (`sc_screen_size_lod_scale_override`); Lash ground slam invisible (`r_drawdecals`); in-world text unreadable (`citadel_in_world_item_panel_dpi`); rainbow puddles, statues and urn (`r_citadel_npr_force_solid_outline`, Kaizu); McGinnis wall as a tombstone (SceneEffects `CMTAtlas*`); "map is weird and dark" (lower in-game shadows) — [Sqooky/OptimizationLock README](https://github.com/Sqooky/OptimizationLock)
- `lb_enable_envmaps false`: characters render black. `r_directlighting` off: characters black in the shop (both blocked now) — [DMM curated convars.ts](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog/curated)
- `r_particle_max_texture_layers` below 4: blocky Infernus afterburn, Paige fire, Drifter passive. `r_particle_cables_render` off breaks Lash's ultimate. `r_particle_explicit_fetch`: soul orbs harder to see — [DMM curated convars.ts](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog/curated)
- `r_pixelvisibility_partial false` "Stops drawing instanced meshes / visibility system changes (boxes vanish)" (listed by ghempy53 as a readability cut; compylock and experimental set it) — [ghempy53 UPSTREAM-DIFF-2026-10-10.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/UPSTREAM-DIFF-2026-10-10.md)
- `sc_max_framebuffer_copies_per_layer`: "Maximum framebuffer copies per render layer, used by effects that sample the screen" (boot and OptiLock set 0). DeadTune's preset comment: "no idea what this does ngl" — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog); [DeadTune](https://github.com/simulieren/deadtune)
- OptiLock describes its FPS config as lowering graphics "as much as possible while keeping the competitive integrity", and claims "~30% improvement in 1% lows and ~40% average FPS gain on most low to mid range systems" (vendor claim, no method) — [dacooderr/OptiLock README](https://github.com/dacooderr/OptiLock)
- A forum thread reports "-200 fps" plus flickering shadows after build-6769 blocking hit an AI-generated config that relied on `r_shadows` and the fog switches (title and excerpt via ghempy53's digest) — [ghempy53 FORUM-RESEARCH-2026-10-06.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/FORUM-RESEARCH-2026-10-06.md)

### Visual-quality guardrails: the avoid list

Avoid all of these even though other packs use them. **H** = hides gameplay info, **B** = broken or blocky, **U** = ugly look.

| ConVar / value | Used by | Effect | Source |
|---|---|---|---|
| `r_farz`, `r_mapextents` (7000) | Sqooky, boot, Kaizu, OptiLock (compylock sets the defaults -1/16384, which is fine) | H: buildings and players pop in | OptimizationLock FAQ |
| `r_size_cull_threshold` > 0.8, `sc_fade_distance_scale_override`, `sc_instanced_mesh_size_cull_bias`, `r_propsmaxdist` | most packs | H: boxes, trooper health bars and vent wind vanish at range | OptimizationLock FAQ; DMM HIDES_THINGS |
| `sc_screen_size_lod_scale_override` < 1, `sc_instanced_mesh_lod_bias` 3-15 | Sqooky, boot, OptiLock, compylock (0.55) | B: holes in Victor/Paige, Sinner lights as triangles | OptimizationLock FAQ |
| `r_drawdecals 0`, `r_decals 0/1`, `r_decals_default_*fade 0.001` | boot, OptiLock | H: Lash slam and Warden ult indicators | DMM convars.ts; OptimizationLock FAQ |
| `r_drawtracers 0`, `cl_impacteffects 0` | boot, OptiLock, Kaizu | H: enemy tracers and hit feedback (catalog: tracers/impacts) | DMM catalog (inference on readability) |
| `cl_ragdoll_limit 0` (**in experimental**) | compylock, Sqooky | H: Doorman ult indicator | RESEARCH.md; OptimizationLock FAQ |
| `r_particle_max_texture_layers` < 4, `r_particle_max_detail_level 0`, `cpu_level`/`gpu_level` below stock | Kaizu, boot, OptiLock | B/H: blocky fire effects; particle systems skipped | DMM convars.ts; RESEARCH.md |
| `r_particle_max_size_cull` 0-256, `r_particle_max_draw_distance` 5000 | OptiLock Ultra, Kaizu | H: big or distant effects culled | DMM HIDES_THINGS |
| `sc_hdr_enabled_override 0` | Sqooky test, boot, OptiLock | U: clipped highlights, different colours; the HDR-off engine test lost FPS | DMM catalog; RESEARCH.md |
| `mat_colcorrection_disableentities 1`, `mat_colorcorrection 0` | Kaizu xlow, OptiLock | U: "grey lookin game" | Sqooky comment via DeadTune; DMM |
| `sc_max_framebuffer_copies_per_layer 0` | boot, OptiLock | B (likely): screen-sampling effects (refraction/distortion, cloak shimmer) lose their source | DMM help text (inference on what breaks) |
| `r_texture_pool_size 256`, `r_texture_stream_max_resolution 128`, mip bias > 4 | boot, OptiLock, Kaizu | U: smeared textures. Above 4, Sinner light triangles. | OptiLock README; DMM |
| `r_citadel_npr_force_solid_outline` | Kaizu (old) | B: rainbow puddles and statues (removed from the engine now) | OptimizationLock FAQ |
| `citadel_in_world_item_panel_dpi` low | max-fps, boot, Kaizu | H: soul-pickup and buff text unreadable | OptimizationLock FAQ |
| `r_render_portals 0` (**in liv's `video.txt`**) | compylock video.txt | B: Doorman's door | DMM rules.ts deny list |
| `lb_enable_binning false`, `lb_bin_slices 0` | Kaizu, OptiLock, Sqooky test | B (possible): light binner off or empty; "may break lighting" | ghempy53 UPSTREAM-DIFF |
| `vis_sunlight_enable 0`, `lb_enable_sunlight`, `r_directlighting 0`, `lb_enable_envmaps false` | various | U/B: flat or black characters. Mostly blocked now; `vis_sunlight_enable` is still settable | ghempy53 TUNING-CANDIDATES §D; DMM |

### Inferences
- In the experimental config, the parts that define compylock's "decent" look and should **not** be cut further are:
  - hero, trooper and boss glows (`citadel_trooper_glow_disabled 0`)
  - `mat_colorcorrection 1`
  - stock HDR
  - envmaps (blocked anyway)
  - decals
  - `r_farz -1` / `r_mapextents 16384`
  - the existing particle quality (`r_particle_max_texture_layers 4`)
  - **`r_texturefilteringquality 5`**: compylock's one deliberate quality choice versus every other pack
- "Invisible" cuts in other packs are the shadow internals once shadows are already off: `csm_*` distances and resolutions,
  `lb_csm_*`, `lb_dynamic_shadow_*` and `sparseshadowtree_*`. They're invisible here because there is nothing left to see,
  not because they're cheap tricks.

### Gaps
- `Screenshots.md` in the local OptimizationLock copy is empty, and per-pack screenshots couldn't be viewed or fetched, so
  "ugly vs invisible" for packs relies on maintainers' FAQ text and self-ratings, not image comparison.
- Reddit, YouTube and forum visual comparisons couldn't be fetched (network policy). Search snippets gave no pack-specific visual verdicts.

## 4. Do any convars in the current experimental config look bad or have known artifacts?

### Takeaway
None of the round-2 lines hide gameplay. Several are **dead** (no effect online, overridden or parse errors), and four
lighting lines cost visible quality for little or no measured FPS. Because the sun and SSAO are off, Deadlock's look now
rests almost entirely on **baked lightmaps**, and compylock's lightmap cuts degrade exactly that.

### Per-line verdicts

| Line in experimental | Flags | Visual cost | FPS value | Verdict |
|---|---|---|---|---|
| `r_lightmap_size "2048"` (compylock; default 65536) | defensive, developmentonly | Blurrier, flatter baked lighting, which is now the main lighting | VRAM and bandwidth only, ~0 FPS on 12 GB (inference) | **Test reverting** (delete the line) as a free visual gain |
| `r_lightmap_size_directional_irradiance "0"` (default -1) | defensive, developmentonly | Strips directional detail from the lightmap. Flatter normal-mapped surfaces. | Same as above | **Test reverting** |
| `r_directional_lightmaps "false"` (round 2) | defensive, developmentonly | Valve/DMM: "Off, baked lighting looks flatter" | One fewer lightmap sample per pixel; small | **Test reverting.** It overlaps with the line above. |
| `lb_precomputed_shadowmap_enable "false"` (round 2) | developmentonly | ghempy53 grouped it with `r_rendersun 0`: "Sun and baked sun shadows: map becomes unreadably bright or dark" | No measurement | **Test, and revert if areas look washed out or light leaks through walls** |
| `volume_fog_enable_jitter "false"` (round 2) | cheat | Jitter hides banding. Off, the minimum-resolution fog shows banding and stepping. | ~0 (jitter is a sample offset; inference) | **Revert** (remove the line) |
| `lb_cubemap_normalization_roughness_begin "0.01"` (round 2; default 0.1) | defensive, developmentonly | Changes how reflections on rough surfaces are normalised against lightmaps (subtle brightness shift) | None expected (a shader constant) | **Remove** (no FPS rationale) |
| `r_light_flickering_enabled "false"` (round 2) | **replicated** | none online | none online (the server value wins) | **Dead online.** Harmless. |
| `mat_tonemap_bloom_scale "0"` (round 2) | cheat | None: bloom already off via `video.txt` (`r_post_bloom`/`r_effects_bloom` false) | ~0 | Harmless, redundant |
| `r_ssao_blur "false"`, `r_hair_shadowtile "false"`, `r_hair_indirect_transmittance "false"`, `r_smooth_morph_normals "false"` | various | None (SSAO, hair and morphing already off) | ~0 | Harmless, redundant (ghempy53: "SSAO already off", "Hair rendering already off", "Morphing already off") |
| `r_morphing_enabled "false"` (round 2) | cheat (applies at startup) | Vertex morph targets such as facial expressions freeze. Barely visible from a third-person camera. | Reduces skinning work in fights (CPU and GPU) | **Keep.** It's one of the few render lines that help CPU-bound fights. Watch for odd hero deformations (none reported). |
| `r_distancefield_enable "0"` (round 2) | defensive, developmentonly | The DF consumers (DF AO and DF shadows) are already off in `video.txt`. adamescj Light and Sqooky keep 1; only Kaizu, boot and OptiLock use 0. | Unmeasured; saves DF upkeep | **Keep and test.** If any lighting looks wrong, it's the first to revert. Not the same as the `Engine2/RenderingPipeline/DistanceField 0` crash. |
| `csm_max_num_cascades_override "0"`, `csm_res_override_* "1"`, `lb_csm_*` | defensive/cheat | None while `r_rendersun 0` | Unknown whether the pass is still rendered | Keep |
| `lb_csm_override_staticgeo_cascades_value "true"` (compylock) | defensive, developmentonly | none | none | **Parse error** ("true is not a number") per ghempy53. Dead line. |
| `sc_layer_batch_threshold_fullsort "120"` (compylock) | defensive, developmentonly | none | none | **Dead:** the stock tail later sets `"20"`, and the last line wins |
| `sc_allow_dithered_lod "false"`, `sc_instanced_mesh_opaque_fade "false"` (compylock) | defensive, developmentonly | Hard LOD pops and fade pops instead of dithered blends | Small (no double-draw during transitions); trims draws | Part of compylock's look. Keep. |
| `lb_dynamic_shadow_resolution_base "16"`, `lb_ssss_samples "0"`, `r_character_decal_resolution "4"` | defensive, developmentonly | Clamped to 128/3/256. Slightly noisier skin SSS, softer character decals. | as clamped | Known (RESEARCH.md); fine |
| `r_citadel_gpu_preview_denoise_passes "0"` | defensive, developmentonly | none | likely none (a lightmap preview path; inference) | Harmless |

### Corrections to earlier research (RESEARCH.md §4)
- RESEARCH.md §4 recommends adding `r_particle_shadows 0`, `r_env_map_uses_height_map 0` and `r_reduce_flash 1` to `video.txt`. In the build-6769 dump,
  `r_particle_shadows` is marked **removed**, and `r_env_map_uses_height_map` and `r_reduce_flash` **aren't convars at all**.
  These keys are dead.
- Several keys in liv's `video.txt` are also removed or absent as convars: `r_citadel_half_res_noisy_effects`,
  `r_particle_depth_feathering`, `r_displacement_mapping` and `r_citadel_motion_blur` are marked removed. `r_screen_space_shadows`,
  `r_citadel_mboit`, `r_citadel_distancefield_reflections` and `shaderquality` don't appear in the dump. Some may be menu-only
  keys rather than convars.

### Cited Findings
- `r_lightmap_size`: "Maximum lightmap resolution. Lower values make baked lighting blurrier." `r_directional_lightmaps`: "Off, baked lighting looks flatter." `volume_fog_enable_jitter`: "Jitters volumetric fog samples between frames to hide banding." `r_light_flickering_enabled` flags include `replicated`. `r_morphing_enabled` is `cheat` ("Vertex morph targets such as facial expressions") — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- ghempy53 on upstream values: `r_lightmap_size 1` / `_directional_irradiance 0` give "Flatter, blurrier map lighting; VRAM and bandwidth". `lb_precomputed_shadowmap_enable false`: "map becomes unreadably bright or dark". `lb_csm_override_staticgeo_cascades_value`: "_value true is not a number (parse error, seen 2026-10-06)". `r_smooth_morph_normals`: "Morphing already off". `r_ssao_blur`: "SSAO already off". `mat_tonemap_bloom_scale`: "Bloom already off" — [ghempy53 UPSTREAM-DIFF-2026-10-10.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/UPSTREAM-DIFF-2026-10-10.md)
- ghempy53 lists bone flex, morphing, foot lock and cloth as "already tested or already set here and not worth revisiting", and prioritises "fight-time CPU cuts (particle fallbacks, bone flex, morphing, foot lock, cloth) over further GPU cuts" — [ghempy53 TUNING-CANDIDATES.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/TUNING-CANDIDATES.md); [RESEARCH-2026-10-06.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/RESEARCH-2026-10-06.md)
- `r_distancefield_enable`: Sqooky default and test = 1, Kaizu = 0, boot and OptiLock = 0 (DeadTune matrix). adamescj Light = "1" — [DeadTune](https://github.com/simulieren/deadtune); [adamescj Light](https://github.com/adamescj/OptimizationLock/tree/main/adamescj's%20light%20config)
- Stock `gameinfo.gi` sets `sc_layer_batch_threshold_fullsort "20"` after the custom block. adamescj notes that "in Sqooky's default, `sc_layer_batch_threshold_fullsort` is documented as `120`, but the stock block later sets `20`" and "only the *last* line counts" — [adamescj/OptimizationLock README](https://github.com/adamescj/OptimizationLock); [SteamDatabase stock gameinfo](https://github.com/SteamDatabase/GameTracking-Deadlock)
- `r_particle_shadows` status removed; `r_citadel_half_res_noisy_effects`, `r_particle_depth_feathering`, `r_displacement_mapping` and `r_citadel_motion_blur` status removed; `r_env_map_uses_height_map`, `r_reduce_flash`, `r_screen_space_shadows`, `r_citadel_mboit` and `r_citadel_distancefield_reflections` are absent from the 5,136-entry catalog — [DMM perf catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog)
- Compylock's `video.txt` sets `r_post_bloom false`, `r_effects_bloom false`, `r_citadel_ssao_quality 0`, `r_citadel_distancefield_ao_quality 0`, `r_citadel_distancefield_shadows false`, `r_arealights false` and `r_citadel_fog_quality 0` — [7liv/compylock video.txt](https://github.com/7liv/compylock)

### Inferences
- With sun lighting, SSAO and all dynamic shadows off, baked lightmaps carry most of the scene's shading. Reverting the three
  lightmap lines (`r_lightmap_size`, `r_lightmap_size_directional_irradiance`, `r_directional_lightmaps`) is likely the
  biggest "looks better for ~free" change available on a 12 GB card. The cost is VRAM and texture bandwidth, not shading
  work. It needs a quick visual and FPS A/B in Sandbox, since nobody has measured it.
- `lb_precomputed_shadowmap_enable false` combined with blocked (therefore active) stationary lights and `lb_enable_shadow_casting 0`
  may make stationary lights shine through geometry. Check corridors and indoor areas after the change.
- Cleanup with no FPS cost: remove `volume_fog_enable_jitter`, `lb_cubemap_normalization_roughness_begin`, the dead
  `sc_layer_batch_threshold_fullsort 120`, the parse-error `lb_csm_override_staticgeo_cascades_value "true"` (use `-1` or
  delete) and the dead gameinfo mip bias `3`.

### Gaps
- No source documents whether `r_morphing_enabled false` breaks any hero ability visual. The convar's description
  (facial expressions) suggests not, but no one has checked hero by hero.
- I found no Valve description of what `r_distancefield_enable 0` disables beyond "Distance-field rendering, which several
  lighting, shadow and occlusion effects build on", and no report of artifacts from it.
- The real FPS value of the lightmap lines on a 12 GB card is unmeasured.
