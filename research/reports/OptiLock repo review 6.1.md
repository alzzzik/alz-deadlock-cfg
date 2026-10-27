# OptiLock repo review: v6.1 (2026-10-27)

Whole-repo review of [dacooderr/OptiLock](https://github.com/dacooderr/OptiLock) at commit `8b78c0f`
(2026-10-26, "timescale fix"). It covers everything since our 5.8 review (`4c4f156`, 2026-10-21). Every line was checked
against Valve's build-6821 convar dump (SteamDatabase GameTracking `d251cf9`). The Community preset has its own report:
[OptiLock Community Config review](OptiLock%20Community%20Config%20review.md). Nothing in alz's cfg files was changed.

## What's in the repo

| Part | What it is |
|---|---|
| `OptiLock FPS Config (Recommended)` | The main preset (v6.1). Its own goal: "lowering the graphics settings as much as possible while keeping competitive integrity" |
| `OptiLock Potato Config`, `OptiLock Ultra Potato Config` | **Almost the same `gameinfo.gi` as the FPS preset.** Only 8–9 lines differ: shorter draw distance (`r_farz` 8500/7000), more aggressive LOD (`sc_screen_size_lod_scale_override`), decals and color correction off, your own hero allowed to use lower LOD. Ultra Potato's `video.txt` also uses mip bias 8 (FPS uses 4) |
| `OptiLock Community Config` | Community "Ultra Low" preset, still on v5.9. See the separate report |
| `Localization/` | Translated copies (Arabic, Portuguese, Russian, Turkish, Ukrainian), made by community translators. They may lag behind the English presets |
| `Essential Fixes/` | 4 asset-replacement VPK mods (below) |
| `cvarlist.md` | A 2,049-line reference list of convars with defaults and flags. Not a config |
| `README.md` | Install guide, FAQ, mod list. Claims "~30% improvement in 1% lows and ~40% average FPS gain on most low to mid range systems". No benchmark data is published (a benchmarker is credited, but no numbers are given) |

Note from the README: **QoL Lite is dacooderr's own mod**, the OptiLock author's. That's the mod liv said doesn't work with
their cfg.

## The Essential Fixes VPKs

Read from the VPK file lists:

| VPK | Files | What it replaces | Notes for alz |
|---|---|---|---|
| `SinnersLightFix.vpk` | 8 | Textures for the light bulbs in the Sinner's Sacrifice vault | OptiLock says it's **required if `r_texture_stream_mip_bias` is above 4**. This is the "sinners fix" alz already runs. With alz's mip bias 0 it isn't strictly needed, but it's harmless |
| `SoulContainer.vpk` | 9 | Soul container model and materials | The "Optimized Soul Container" from our earlier research. A lighter model; looks slightly different |
| `OptimizedMcGinnisWall.vpk` | 23 | McGinnis's wall ability materials | A cheaper-looking ability effect, so it changes how the wall looks |
| `ScopeDownscale.vpk` | 2 | Vindicta's scope overlay texture | A lower-res scope image |

None of these were updated after 6801 (last change: 2026-07-01). They replace art files, not config, so the 6801
lighting change doesn't affect them.

## What changed from 5.8 to 6.1 (FPS preset)

137 keys changed between 5.8 (10-21) and 6.1 (10-26):

| Class | Lines |
|---|---|
| Real client-side changes | 73 |
| Reset to Valve's default | 17 |
| `replicated` (server value wins online) | 27 |
| Blocked from `gameinfo.gi` | 11 |
| Don't exist | 5 |
| Server-only | 2 |
| Engine section (`RenderSystem/MinDXLevel 80`) | 1 |

The real changes, grouped by what they mean for alz:

**Visual cuts (not for alz):**
- `r_citadel_disable_particle_lights true`: ability effects stop lighting their surroundings.
- `mat_max_lighting_complexity 0`, `mat_shading_complexity_max_instruction_count 0` / `_register_count 0`: `cheat`
  convars (they apply at startup from `gameinfo.gi`) that cap material and lighting complexity.
- `r_morphing_enabled false`: no facial and shape morphs.
- `sc_instanced_mesh_enable false`, `r_pixelvisibility_partial false`: instanced props drawn differently; known to make
  boxes vanish.
- `r_texture_stream_max_resolution 64` (the engine clamps it to 512) + `r_texture_pool_size 256`: blurry textures.
- `r_draw_particle_children_with_parents false`, `r_particle_max_draw_distance 300000`, decal resolution 0.01.
- `r_particle_timescale 1.2` (the 10-26 "timescale fix"): effects now play **20% faster**, up from 0.7 (slower) in 5.8.
  Either way it changes how abilities look and time out on screen.

**Moot for alz (the feature is already off):**
- The whole sun-shadow block came back (`csm_max_visible_dist 0`, `csm_cascade0-3_override_dist 0`, `csm_res_override_*`,
  `csm_sst_*`, `csm_viewmodel_*`). alz already has the sun and its shadows off three ways, so this gains nothing.
- `vis_sunlight_enable false`, the `lb_*` shadow-bias and resolution values: shadows are already off.

**Things our earlier research flagged as risky, now in OptiLock:**
- `r_skip_precache_validation_check true`: we turned it off in liv's cfg for mod risk.
- `r_update_particles_on_render_only_frames true`: our "community consensus" claim for it was later retracted.
- `cl_predictioncopy_runs 0`: undocumented and touches client prediction. Avoid.

**Fixed:**
- `cl_ragdoll_limit -1`: OptiLock now keeps Doorman's ultimate indicator working (5.8 had 1).

**Ray-tracing proxy lines (new, possibly zero-visual):**
- `rtx_dynamic_blas false`, `rtx_force_default_hitgroup true`, `sc_aggregate_rtproxy_instanced_geo false`,
  `sc_aggregate_rtproxy_unique_geo false`, `sc_aggregate_render_mesh_shader false`.
- These control the geometry the engine builds for ray tracing, and the mesh-shader draw path. If the DX11 renderer
  never uses that ray-tracing geometry, turning it off saves work with no visible change. That's an inference: nothing
  shows whether Deadlock builds it on DX11. Two of them are `cheat` convars (startup-only from `gameinfo.gi`). Turning
  off mesh shaders could cost FPS on an RTX 5070, which supports them, so that one isn't a free win.

**Removed "Experimental" preset (10-22 → 10-23):** an "Ultra Potato (Experimental)" folder existed for one day and was
then deleted. Its extra lines (12 real ones: `cl_particle_max_count 1000`, `citadel_unit_status_max_distance_scale 0.4`,
`r_farz 7000`, decals 0.001, `r_particle_timescale 0.7`, and others) are visual or readability cuts. Most of them ended
up in the Community preset.

## Ideas from the whole repo for alz

Beyond the 5 zero-visual tests in the [Community review](OptiLock%20Community%20Config%20review.md), the full repo adds one
more candidate worth a single test:

| # | Lines (ConVars) | Why it might be free | Risk |
|---|---|---|---|
| 6 | `rtx_dynamic_blas "false"`, `sc_aggregate_rtproxy_instanced_geo "false"`, `sc_aggregate_rtproxy_unique_geo "false"` | They skip building ray-tracing geometry, which DX11 may never use | Unverified that DX11 builds it at all, so the gain may be 0. Leave `sc_aggregate_render_mesh_shader` alone |

Everything else new in 6.1 either costs looks, does nothing online, or is already covered by alz's settings.

## Bottom line

- OptiLock 6.1 is a "lowest settings that stay competitive" config: lower textures, simpler materials, no morphs, faster
  effects. That goes against alz's "looks decent" rule.
- Its three main presets share nearly the same `gameinfo.gi`. The Potato tiers mainly shorten draw distance and blur
  textures more.
- Still no published measurements behind the README's "~40% FPS" claim.
- For alz: keep the Sinner's light fix you already use. The other Essential Fixes VPKs are optional small visual trades.
  There's one possible zero-visual test (#6, the ray-tracing proxy lines) on top of the five from the Community review.
