# Deadlock build 6801 (2026-10-20): what changed and what it means for FPS

Source: Valve's game files as tracked by SteamDatabase
([GameTracking-Deadlock commit 37f9aeb](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/37f9aebdc62766aa13748f73309b9b8120549833),
build 6801, 2026-10-20 21:02 UTC), compared against build 6796. No official patch notes or player FPS reports
existed yet when this was written, about an hour after release. Everything below comes from the game files themselves.

## What broke the cfg (fixed in commit cb1bb5b)

Valve rebuilt the maps' baked lighting in a new format, and `gameinfo.gi` has to describe it:

| `gameinfo.gi` change | Old (6796) | New (6801) |
|---|---|---|
| `BakedLighting/Version` | 4 | 5 |
| Directional lightmap channels | `directional_irradiance_sh2_r`, `_g`, `_b` (3 DXT1 textures) | `directional_irradiance_sh2_lum` (1 DXT1 texture) |
| `WorldRendererBuilder` | none | `BakePrecomputedShadows 1`, `PrecomputedShadowmapAtlas 1`, `PrecomputedShadowmapResolutionDefault 128`, ... |
| `SceneSystem/FogCachedShadowAtlas*` / `FogCachedShadowTileSize` | runtime keys | renamed to `...Tools` (map-compile only) |

A cfg with the old lighting description loads the new maps with broken lighting, which is what happened.
Every config made before 6801 (liv's, OptiLock, OptimizationLock, ...) has the same problem until its author
updates it.

## Performance effects

### 1. Lightmaps: 3 directional textures became 1 (automatic, small gain)
The world lighting shader (`deferred_lighting`) now reads one luminance texture instead of three color textures.
That means less VRAM for lightmaps and fewer texture reads in the lighting pass, every frame. It's a GPU/memory
saving that everyone gets automatically, probably small (a few percent of one pass at most). Colored directional
detail is now approximated from the color in the `sh2_dc` channel, so the look should barely change.

Our cfg's `r_lightmap_size_directional_irradiance "0"` (from liv) still applies, now to the new channel. alz's
in-game test after the fix showed normal lighting, so it stays.

### 2. Fog shadows from static lights are now baked (automatic, neutral to small gain; makes 3 liv lines dead)
The volumetric fog shader (`cs_volumetric_fog`) now samples a **precomputed shadow-map atlas** baked into each map
for static lights (new `PrecomputedShadowmapAtlas` keys, new per-light `m_vPrecomputedShadowmapAtlasRect0-5`).
Before 6801, the engine rendered these fog shadows at runtime into a cached atlas sized by
`SceneSystem/FogCachedShadowAtlasWidth/Height/TileSize`.

- liv's cfg set those three keys to `0` to skip that runtime atlas. Valve renamed them to tools-only `...Tools`
  keys, so **those lines now do nothing**. Our cfg keeps them commented out with a `//[6801 ...]` note.
- The baked lookup costs one texture gather per static light per fog cell. The fog volume in our `video.txt` is the
  engine minimum (64×64×48) and `r_citadel_fog_quality` is 0, so this cost is tiny.
- **Lever, not recommended yet:** `lb_precomputed_shadowmap_enable "false"` (`developmentonly`, so
  `gameinfo.gi` can set it) turns precomputed shadow maps off. It was one of the round-2 lines in the old
  experimental variant (−40 FPS overall, never split). Since 6801 it also controls the new fog shadows. Turning
  it off could let light shafts leak through walls, or push lights back onto dynamic shadows, which would cost
  *more*. Try it only as a one-line A/B test.

### 3. `r_particle_depth_feathering` is gone (dead line, harmless)
Valve removed it from all four `video_defaults_*.txt` presets and from `client.dll`. The
`setting.r_particle_depth_feathering` line in our `video.txt` is now ignored. It can stay or go; it changes nothing.
Soft particle edges are now fixed by the engine.

### 4. New hero content: Nurse (new NPC `NurseLeech`)
New hero files (abilities, a summoned NPC, about 13k lines of voice events). Summons add CPU work in fights, like
other summon heroes. No cfg lever for that. The new convar `citadel_deadpack_ult_charge_navpath` is a server-side
`cheat` gameplay flag, so it has no FPS use.

### 5. Other
- `saturation_volumes` shader rewritten (post-process color grading). There's no menu setting or convar for it, and
  its cost is unknown until people measure it.
- New convar `lb_debug_visualize_precomputed_shadow_atlas_lights` (debug only, `gameinfo_cannot_override`).

## Bottom line for alz's PC (5700X + RTX 5070, CPU-bound in fights)

- **Nothing to change.** The fixed `alz/` and `stable/` cfgs already match 6801.
- The two engine changes (1 lightmap texture instead of 3, baked fog shadows) are small GPU-side savings. They won't
  move fight FPS much, because fights are CPU-bound on this PC.
- **One optional one-line test:** `lb_precomputed_shadowmap_enable "false"`. Expect little or no gain and a real
  chance of worse-looking fog or lighting. Test it alone, in a real match, against the current cfg.
- Watch for: community cfg authors' 6801 updates, and player FPS reports once patch notes are out (the scheduled
  research run on 2026-11-01 covers this).
