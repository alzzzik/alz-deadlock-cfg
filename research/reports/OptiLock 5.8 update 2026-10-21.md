# OptiLock 5.8 (2026-10-20/21): what changed and what's useful for alz

Source: [dacooderr/OptiLock](https://github.com/dacooderr/OptiLock), commits `32227da` "fixes for Harrow Update"
(2026-10-20 17:24 EDT), `ec8cdf4`, `ebf931a` "Removed autoexec.cfgs & Updated other Presets" (2026-10-21 00:50 EDT),
`d9c131d`, `4c4f156` (README, 04:12 EDT). We compared the FPS Config (Recommended) `gameinfo.gi` before (`fca258f`)
and after, key by key, and checked every changed convar against Valve's 6801 convar dump. OptiLock published no
measurements with this update, so everything below is the author's choices, not A/B results.

## 1. Build 6801 fix: the same as ours
OptiLock made the same structural fix as our `cb1bb5b`: `BakedLighting Version 5`, the `directional_irradiance_sh2_lum`
channel, new `PGIVersion`, `FogCachedShadow*` renamed to `...Tools`.
Differences: OptiLock sets the new `WorldRendererBuilder/BakePrecomputedShadows*` and `PrecomputedShadowmap*` keys and
the `...Tools` keys to `0`. These are **map-compile settings** (Valve's strings list them under
`ResourceCompiler/WorldRendererBuilder/`), so at runtime they do nothing either way. Our Valve-stock values are fine.
`ImportanceVolumeTransitionRegion` (128 → 100) is also a bake setting, with no runtime effect.

## 2. `cloth_update "0"` → `"1"` (the "Harrow fix")
OptiLock had cloth physics off. The new hero Harrow apparently needs it, so they turned it back on. **Our cfg never
set `cloth_update`, so nothing to do.**

## 3. Big cleanup: 207 lines removed, 12 added
Of the 207 removed ConVars lines:

| Class (checked against the 6801 dump) | Lines |
|---|---|
| Don't exist in the game anymore | 57 |
| Blocked from `gameinfo.gi` (`gameinfo_cannot_override`) | 32 |
| Server-only or `replicated` (do nothing online) | 18 |
| Real client convars, now back to Valve's default | 97 |

So about half the removals were dead lines, which confirms our own October findings. The other 97 include several
lines our research had already flagged as harmful or pointless and that **OptiLock now also dropped**:
`r_particle_min_timestep` (jagged particles), `snd_mixahead 0.05` (later audio), `snd_steamaudio_num_threads`,
`r_texture_stream_mip_bias` (`video.txt` wins), `mat_viewportscale` (menu-owned), `cpu_level`/`gpu_level`, and all
the sun/CSM distance lines (`csm_*`, sun shadows are off anyway). The `autoexec.cfg` files are gone too, matching what
the OptiLock dev told alz earlier ("autoexec is redundant").

## 4. Value changes, and whether they suit alz (CPU-bound in fights, wants a decent look)

| Line (new OptiLock value) | What it does | alz now | Verdict |
|---|---|---|---|
| `r_distancefield_enable false` | Master switch for distance-field rendering (DF AO/shadows are already off in `video.txt`) | `1` | **Only candidate worth a one-line A/B.** Small possible gain, little visual risk. It was also in the old experimental, which was never split. |
| `r_size_cull_threshold 0.3` + `r_size_cull_threshold_fade 100` | Culls only objects under 0.3% of the screen (stock 0.8), with fade-out | `0.9` | **Keep alz's.** OptiLock now draws *more* small objects and adds fading, which means more CPU work. |
| `cl_particle_fallback_base 4`, `_multiplier 2`, `cl_particle_sim_fallback_base_multiplier 2` | How aggressively effects swap to cheaper versions under load | `5` / `10` / `100` | **Keep alz's** (more aggressive = better for a CPU-bound PC). OptiLock went softer, probably for looks. |
| `r_texture_stream_max_resolution 1` | Texture size cap; engine minimum is 512, so this becomes 512 px | stock | **Reject.** Big texture-quality cut. |
| `r_lightmap_size 0` | Lightmap resolution cap | `2048` | **Reject.** Flat or blotchy world lighting, and risky right after 6801's lighting change. |
| `r_character_decal_resolution 0.030`, `r_decals 0`, decal fade lines | Hero decals / bullet decals (`r_decals*` are `replicated`, so they do nothing online) | partly | Reject. Tiny gain, readability cost. |
| `r_particle_timescale 0.7` | Effects animate at 70% speed | stock | **Reject.** Changes how abilities look and time out on screen. |
| `sc_instanced_mesh_lod_bias 0.001` (+ `_shadow`) | LOD choice for instanced meshes (stock 1.25) | stock | Unclear direction, no evidence. Skip. |
| `engine_low_latency_sleep_after_client_tick true` | With Reflex on, moves the Reflex sleep after client simulation on tick frames | `false` | Latency/frame-pacing, not FPS. Optional, untested. |
| `r_citadel_drop_shadow_update_frequency 0` | Undocumented (no description in Valve's dump) | stock | Skip until someone measures it. |
| `SceneSystem/SparseShadowTrees 0` | Section key for sparse shadow trees | `sparseshadowtree_enable_rendering 0` already | No change needed. |
| Many `1` → `true` / `0` → `false` | Same value, new spelling | — | No effect. |

## 5. OptiLock `video.txt`
`mem_level` 0 → 1, `gpu_mem_level` 0 → 1, `gpu_level` 0 → 2. OptiLock moved away from the "0" values. alz's
`video.txt` already uses the autodetect values for the PC (2 / 3 / 3). No change.

## Bottom line
- Nothing in OptiLock 5.8 is a clear FPS win for alz's setup, and nothing in it means our cfg is broken.
- The update mostly agrees with our earlier research: same 6801 fix, the same dead lines removed, and the same
  harmful lines dropped.
- One line is worth a one-line A/B test if alz wants: `r_distancefield_enable "false"`.
