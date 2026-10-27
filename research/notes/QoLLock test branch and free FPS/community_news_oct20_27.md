# Deadlock FPS config and performance-mod community news, 2026-10-20 to 2026-10-27 (excluding QoLLock)

Scope: what changed in Valve's builds after 6801, in the config repos (OptiLock, compylock, OptimizationLock,
ghempy53, deadtune), in Deadlock Mod Manager (DMM), and on forums and GameBanana, judged for alz's PC (5700X, RTX 5070,
1440p, DX11, DLSS preset 10 at 1.7x, CPU-bound in team fights, mods through DMM).

Method and access limits (important for the writer):
- Valve builds, config repos and DMM were read directly from git (blobless clones in the scratchpad). Every
  convar claim was checked against Valve's convar dump at build 6821 (`DumpSource2/convars.txt`, Oct 26).
- **Reddit, Steam (store, community, news API), forums.playdeadlock.com, GameBanana, YouTube, liquipedia and
  deadlock.wiki were all unreachable from this session** (proxy refused or DNS failed). Forum, GameBanana and news
  items below come only from search-engine snippets and summaries, so their dates and wording are approximate. The
  GitHub REST API (`gh api`) was also blocked, so "recently updated gameinfo.gi repos" could not be listed.
- Nothing here was measured in game by us. "Measured" means a third party says they measured it.

---

## 1. Valve builds after 6801 (6802-6821): performance-relevant changes

### Takeaway
Thirteen small builds shipped between Oct 20 and Oct 26 (6802, 6803, 6805, 6806, 6807, 6810, 6812, 6813, 6814, 6815,
6817, 6819, 6821). None touches `gameinfo.gi`, the engine DLLs or the video presets. They are hero content and fixes
(Nurse Harrow, Violet, Doorman). **One change matters for configs:** in **build 6812 (2026-10-21)** Valve removed the
`gameinfo_cannot_override` flag from **`r_particle_max_detail_level`**, so `gameinfo.gi` can set it again. That is
a real particle CPU lever, and it means configs that already set it to `0` (all OptiLock presets) now **really drop
particle detail**.

### Cited Findings
- Build list with UTC times: 6802 (10-20 22:18), 6803 (22:28), 6805 (23:24), 6806 (10-21 03:52), 6807 (05:01),
  6810 (19:44), 6812 (22:03), 6813 (10-22 04:14), 6814 (18:54), 6815 (20:00), 6817 (20:38), 6819 (23:53),
  6821 (10-26 20:03, `VersionDate=Oct 26 2026`, SourceRevision 11170534). There are no 6804, 6808, 6809, 6811, 6816,
  6818 or 6820 commits. — [GameTracking-Deadlock history](https://github.com/SteamDatabase/GameTracking-Deadlock/commits/master)
- **6812 (2026-10-21):** `r_particle_max_detail_level 3 (developmentonly defensive gameinfo_cannot_override)` became
  `r_particle_max_detail_level 3 (min: 0, max: 3, developmentonly defensive)`. Description: "The maximum detail level
  of particle to create". This was the only convar line that changed between 6801 and 6821. The number of
  `gameinfo_cannot_override` convars went from 125 to 124. — [commit 0abfe67](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/0abfe676c64c7d24bd5340a46778e65a84be70ed); [SteamDB patch 26118388](https://steamdb.info/patchnotes/26118388/)
  - "defensive" isn't a special lock. 1,674 convars carry it, including ordinary client settings. — Valve
    `convars.txt` at [6821](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/d251cf9d9a796061c90f58724230b7e17b97121b)
  - 6812 also changed Doorman's Doorway placement code (new debug strings such as "NO LOS camera->door", "OTHER DOOR TOO
    FAR"). That's gameplay, no FPS effect. — [commit 0abfe67](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/0abfe676c64c7d24bd5340a46778e65a84be70ed)
- **6802 (10-20):** Nurse Harrow voice lines, a new diner portrait model and signage materials. — [commit be9aeb5](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/be9aeb5c21f89d947158da54d1e38ea21ef2b75d)
- **6805 (10-20):** item tooltip text only ("enemy hero" became "hero" for Overflow and Reinforcing Casings). — [commit 88c2fe5](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/88c2fe5caca830c9cb32493df85cd113a2c22584)
- **6806, 6807, 6815, 6817:** manifest or steam.inf only, plus a few Harrow model files. No config-relevant content. — [6806](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/67a51eaef8b9148ec02887d7b1c35657a476841e), [6807](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/3207c1601bf83515155a1108b4b8def7338b1b29), [6815](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/7fd2af7964e1fd3fd612434f0957a5fb779beb1b), [6817](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/04d261bfd6fddf07647416ab0382f9468c102830)
- **6810 (10-21):** 11 new Harrow ultimate particles (`particles/abilities/nurse/nurse_ult_terror_*`, ring and rocks
  AoE) plus projected ground materials, and 52 animgraphs rebuilt. The matchmaking protobuf dropped
  `is_high_skill_range_party`. — [commit c90ff49](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/c90ff498d244fc9a3e6722faf70e455c0b7a07f8); [SteamDB 26115603](https://steamdb.info/patchnotes/26115603/)
- **6813 (10-22):** fear immunity renamed (`MODIFIER_STATE_NECRO_FEARIMMUNE` became `MODIFIER_STATE_FEAR_IMMUNE`).
  Warden's Last Stand now grants fear immunity. — [commit a94d8b4](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/a94d8b455203f12b176de75a5598dd8e6e8a94d4)
- **6814 (10-22):** Harrow leech pickup particles (beam, glow, indicator) and a new server-side `CNavIdolWalkbackPathCost`.
  — [commit e95b323](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/e95b323b88d48c3fc4d80066ee603fb75060b248)
- **6819 (10-22):** Violet's Draw (`CCitadel_Ability_Artist_PullBrush`) gained `m_flMinStrokeDistance` (schema
  default 40). `abilities.vdata` sets it to **15.0**, and the three Draw stroke/trail particles were rebuilt. — [commit 17462b2](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/17462b250a0ca80e7f80102f2c83cc3eecff5f12)
- **6821 (10-26):** Violet's Draw trail particles rebuilt again, with new `artist_pullbrush_trail_facing_fast` and
  `..._horizontal_fast` variants. Also new Violet animation clips, a Harrow fear sound for NPCs, and the hero-release
  vote enum emptied (all six City Never Sleeps heroes are out). — [commit d251cf9](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/d251cf9d9a796061c90f58724230b7e17b97121b); [unDeadlock patch index](https://undeadlock.com/patches) (lists 6821 as a "technical build")
- No `game/bin/win64/*_strings.txt` (engine2, rendersystem, scenesystem) file changed after 6801, and `gameinfo.gi`
  and `video_defaults_*.txt` are unchanged since 6801. — [GameTracking-Deadlock history](https://github.com/SteamDatabase/GameTracking-Deadlock/commits/master)
- Official notes: the Oct 20 patch ("Shh... This Won't Hurt a Bit.") released Nurse Harrow and changed Midtown crates
  and lighting. — [Steam announcement](https://steamcommunity.com/games/1422450/announcements/detail/669505296465396779) (search summary only; page unreachable); [unDeadlock 6801](https://undeadlock.com/patches/2026-10-20-6801)
  The deadlock.wiki index lists Oct 21 and Oct 22 as "(Undocumented) Bug fixes / Hero changes". — [deadlock.wiki Updates](https://deadlock.wiki/Updates) (search snippet)
- Correction to [our 6801 report](../../reports/Deadlock%20build%206801%20changes.md) and the [OptiLock 5.8 report](../../reports/OptiLock%205.8%20update%202026-10-21.md):
  the 5.8 report said `ResourceCompiler/WorldRendererBuilder/BakePrecomputedShadows*` are map-compile-only keys that
  "at runtime do nothing". **`scenesystem.dll` (a runtime DLL) does read
  `ResourceCompiler/WorldRendererBuilder/BakePrecomputedShadows` and `...BakePrecomputedShadowsForDirectionalLights`**
  (plus `ResourceCompiler/BakedLighting/DisableCullingForShadows`, `LPVAtlas`, `Version`). — `game/bin/win64/scenesystem_strings.txt` at [6801](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/37f9aebdc62766aa13748f73309b9b8120549833); DMM found the same and changed its catalog for it on 10-22: [DMM 591300a](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/591300a52b35d2e1622de767a11ab81eb46154af)
  alz keeps Valve's stock values (`BakePrecomputedShadows 1`, `...ForDirectionalLights 0`), so alz is unaffected.
  OptiLock's `0` may have a runtime effect, but which way is unknown.

### Inferences
- **`r_particle_max_detail_level` is the one new lever.** Before 6812 our research rated it "blocked from `gameinfo.gi`"
  ([RESEARCH.md](../../RESEARCH.md) section 3) and suggested testing it through `video.txt`. Since 6812 it can go
  straight into `gameinfo.gi` ConVars. Particle work is a big share of fight-time CPU cost, so this is the most
  plausible new CPU-side gain for alz. **It is not free visually:** it stops the most detailed particle sub-effects
  from being created. `2` is the cautious value. `0` (OptiLock) risks missing ability visuals, as noted in RESEARCH.md.
  Unknown: whether Valve re-adds the flag. A flag removed one build after a big patch can be deliberate or an accident.
- **The 6812 change made existing OptiLock installs behave differently without an OptiLock update.** OptiLock sets
  `r_particle_max_detail_level "0"` in the gameinfo.gi of all four presets, and also in `video.txt` (see section 2).
  From 6812 on that line applies, so OptiLock users get the lowest particle detail. This is a possible cause of
  "missing effect" reports from OptiLock users after Oct 21.
- **Violet's Draw**: 6819 lowered the minimum stroke distance to 15 (schema default 40), which means about 2.7× more
  stroke points per stroke length, and so more particles and ink segments. It is the likeliest file-level match for the
  forum report "Violet's Drawing changes tanked the FPS" (section 4). In 6821 Valve rebuilt the same particles and added
  `_fast` variants, possibly a fix. This is inference only; nobody has verified it.
- Harrow's new content (ult AoE rings and rocks, leech pickup beams) is ordinary ability particles. No config lever
  specific to her exists, apart from the general particle convars.

### Gaps
- Official Valve changelog text for Oct 21-26 could not be read (Steam and the forums are unreachable). Whether Valve
  said anything about performance is unknown.
- Whether `r_particle_max_detail_level 2` measurably raises fight FPS on a 5700X is untested. Which effects disappear at
  2 is also unknown.

---

## 2. Config repos and DMM since 2026-10-20

### Takeaway
OptiLock went from 5.8 to **6.1c** (10-21 to 10-26) and OptimizationLock went to **3.7** (10-26). Neither published
measurements. Both add many lines that cost visual quality, or that do nothing online. **compylock (liv) and deadtune have
not changed** since early October. **ghempy53 withdrew its own October 6-7 A/B results (10-22)**, and those results
were the basis for our "round 3" reset. **DMM 2.1-2.2** now turns performance configs on by default, writes engine
sections, and fixed a bug that rewrote `gameinfo.gi` on every launch.

### Cited Findings
**OptiLock (dacooderr)**
- Tags and dates: v5.9 `d9c131d` (10-21 01:19 EDT), v6.0 `81a1339` (10-22 03:50, "new optimizations"), v6.1 `ee1127d`
  (10-22, "Updated some ConVar to their true lowest Value"), v6.1a `2817564` (10-22, testing config added, then removed on 10-23),
  `91b71c9` (10-23, "Added back a lot of the ConVars I removed due to DMM having an issue reading certain ones"),
  v6.1b `2691647` (10-23, "added new optimizations to all presets, made recommended look brighter"), `3822b53` (10-23,
  `cl_particle_max_count 800` commented out), v6.1c `8b78c0f` (10-26 "timescale fix"). There is also a new **OptiLock Community
  Config** ("Ultra Low", 10-21, `174fc95`), whose readme says it "will make your game look horrendous in the hideout". Turkish
  localization was added. — [dacooderr/OptiLock commits](https://github.com/dacooderr/OptiLock/commits/main)
- "timescale fix" (10-26): `r_particle_timescale` 0.7 → **1.2** (effects now animate 20% faster than Valve's speed,
  having been 30% slower). — [commit 8b78c0f](https://github.com/dacooderr/OptiLock/commit/8b78c0f)
- FPS Config (Recommended), net changes from 5.8 (`4c4f156`) to 6.1c, 142 keys. Checked against the 6821 dump, the notable
  lines are:
  - Only cost visual quality: `r_citadel_disable_particle_lights true` (release; "Disable particle lights"),
    `r_morphing_enabled false` (cheat), `ik_enable false` / `animgraph_footlock_*` false (replicated, so they do nothing online),
    `r_texture_pool_size 256` (stock 1600 MB), `r_texture_stream_max_resolution 64` (clamped to the 512 minimum),
    `sc_screen_size_lod_scale_override 0.10`, `r_character_decal_resolution 0.01` (clamped to 256),
    `r_particle_max_draw_distance 300000` (cheat), `sc_instanced_mesh_enable false`, `r_nearz 10`
    (`gameinfo_cannot_override`, so it does nothing).
  - Back to stock or brighter: `r_size_cull_threshold 0.8` (= Valve default), `r_postprocess_enable true`,
    `mat_colorcorrection true`, `r_decals 1`, `cl_ragdoll_limit -1`.
  - Blocked (`gameinfo_cannot_override`) and so dead: `lb_mixed_shadows`, `lb_enable_fog_mixed_shadows`,
    `lb_shadow_map_cull_empty_mixed`, `lb_shadow_map_culling`, `r_citadel_gpu_culling_shadows`,
    `sc_disable_spotlight_shadows`, `r_environment_map_roughness_range`, `r_fallback_texture_lod_scale`,
    `csm_max_shadow_dist_override`, `r_postprocess_enable`.
  - Not in the game at all: `mat_async_shader_load`, `r_texture_budget`, `r_texture_load_async`,
    `lb_allow_time_sliced_shadow_map_rendering`, `vprof_on`.
  - Server-only or replicated (do nothing online): `sv_maxupdaterate 40`, `sv_minupdaterate`, `sv_maxspeed`,
    `sv_pvs_max_distance 3000`, `sv_hide_ent_in_pvs`, `snd_occlusion_*`, `cl_modifier_parallel_gather_status_effect_updates true`
    (flagged `replicated`).
  - Same as the default: `r_particle_enable_fastpath true`, `r_threaded_scene_object_update 1`, `vis_enable 1`,
    `citadel_player_model_force_highest_lod true`.
  - Engine sections: `RenderSystem/MinDXLevel 80` (RenderSystem is one of the guarded sections).
  - Already in the gameinfo.gi of all OptiLock presets (unchanged by these commits): `r_particle_max_detail_level "0"`,
    `r_draw_particle_children_with_parents false`. `video.txt` also has `"setting.r_particle_max_detail_level" "0"` (twice).
    — files at [8b78c0f](https://github.com/dacooderr/OptiLock/tree/8b78c0f) checked against the Valve dump at [6821](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/d251cf9d9a796061c90f58724230b7e17b97121b)
- OptiLock's only performance claim is still the old README line: "~30% improvement in 1% lows and ~40% average FPS
  gain on most low to mid range systems". No numbers were published with 5.9-6.1c. — [OptiLock README](https://github.com/dacooderr/OptiLock)
- The `Essential Fixes` VPK folder hasn't changed since 2026-07-01 (`e62324a`). — [dacooderr/OptiLock](https://github.com/dacooderr/OptiLock/tree/main/Essential%20Fixes)

**OptimizationLock (Sqooky)**
- 10-20 `e1a873f`/`23c8338`: clean and main configs updated to the 6801 stock engine sections. 10-21 `347a669`:
  Kaizuchaneru's config updated. 10-26 `9a44475`: **v3.7** of the main config, testing config 1.6, and a Windows
  PowerShell/BAT **gameinfo auto-updater** by Kaizuchaneru, Neb and Bonclide. — [Sqooky/OptimizationLock commits](https://github.com/Sqooky/OptimizationLock/commits/main)
- What 3.7 changed: it dropped 16 obsolete SceneSystem keys that 6801 stock no longer has (`ShadowAtlas`,
  `ShadowDepthBuffer`, `EnableSunlight`, `PointLightShadowsEnabled`, ...), so those were already dead. It added the Particles
  section keys `Budget_ActualTraces/RenderUS/SimulationUS/InterectionTests 1`, `GPUParticles 1`,
  `MixedResolution/Slices 16`, `GameSupportsLegacyShaders 1`. It changed `RenderSystem/MinStreamingPoolSizeMB 2048 → 500`
  (comment: "In CS2 this is 500, not sure why"), `ExecuteQueuedCommandBuffers 0`, `SceneSystem/ParticleBufferSize 512 → 2048`.
  New ConVars: `citadel_unit_status_hide_names true` (hides player names on health bars; a readability cost),
  `citadel_action_refresh_interval 0.11`, `audio_viewing_damage_*` 0, plus a few server-only `ai_*`/`citadel_ai_*` lines.
  The config still has `r_texture_budget_threshold 0.7` and `r_texture_budget_update_period 0.5`. — [commit 9a44475](https://github.com/Sqooky/OptimizationLock/commit/9a44475)
- **Clutter be Gone (Laund) re-split, 10-20 `2b8f7bb`** (19:28 UTC, before 6801 went live): "1. Screenspace Particle
  Remover" is now its own VPK (212 KB). New variants are "6. Movement" ("Removes movement particles (dash, double jump,
  etc)") and "7. Pickups" ("Removes pickup particles/beams (souls, buffs)"). Graves and Walker were updated, and the
  "All of these" bundle grew from 549 KB to 655 KB. — [commit 2b8f7bb](https://github.com/Sqooky/OptimizationLock/commit/2b8f7bb); [Clutter be Gone README](https://github.com/Sqooky/OptimizationLock/tree/main/Various%20Addons%20Relating%20to%20Performance/Clutter%20be%20Gone)
- The GameBanana listing "Optimizationlock/Sqooky's fps config [harrowfix]" (mod 656341) exists. — [GameBanana 656341](https://gamebanana.com/mods/656341) (search result title only)

**ghempy53/deadlock-config**
- 10-22 documentation audit (`AUDIT-2026-10-22.md` plus rendering, runtime and tooling audits): "**October 6–7 results below
  were invalidated by the owner, including the rows labelled 'kept'; they are not measured performance evidence.**" The
  invalidated row includes "Batching thresholds 256, `r_particle_max_size_cull 900`, `r_limit_particle_job_duration true`,
  `r_texture_budget_update_period 0.5` | Stutter when turning the camera and clearly lower FPS (2026-10-07)". Their current
  stable has "all four lines from that revert active". — [TESTED-CHANGES.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/TESTED-CHANGES.md); [AUDIT-RENDERING-2026-10-22.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/AUDIT-RENDERING-2026-10-22.md)
- The audit also says: "No game was launched, no matchmaking test was run, and no FPS, latency, memory or visual
  measurement was made during this audit." It reclassifies claims such as "`r_update_particles_on_render_only_frames true` saves
  work as FPS falls" as unsupported ("permitting extra updates is not inherently less work"), and lists
  `r_particle_fixedrandomseeds` as a debugging convar with no measured benefit. — [AUDIT-RENDERING-2026-10-22.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/research/AUDIT-RENDERING-2026-10-22.md)
- Other ghempy53 changes: stable frozen as v1.4 (10-20). The stable config pulled in OptimizationLock 3.6.1's stock engine sections (10-21).
  The experimental config applied "Valve's build 6810 engine-section patch (new PGIVersion)" (10-21, `c588ece`). `r_aspectratio` is commented out
  for an FOV mod (10-20/22). The 10-23 upstream check found OptimizationLock 347a669 unchanged on Valve build 6819. — [ghempy53 commits](https://github.com/ghempy53/deadlock-config/commits/main)

**compylock (liv), deadtune**
- compylock's last commit is still `e69ac8a` (2026-10-10, "Rename pak26_dir (1).vpk to sinners LOD fix.vpk"). It has no
  6801 update, so liv's upstream `gameinfo.gi` still has the pre-6801 lighting block, which breaks lighting. — [7liv/compylock commits](https://github.com/7liv/compylock/commits/main)
- deadtune's last release is v0.28.0 (2026-10-08). — [simulieren/deadtune](https://github.com/simulieren/deadtune/commits/main)

**Deadlock Mod Manager**
- v2.0.0 (10-20), v2.1.0 and v2.1.1 (10-21), v2.2.0 (10-25). — [DMM tags](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tags)
- v2.1.0: "**turn performance configs on by default** … A store migration turns the toggle on for existing users". — [6f4891a](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/6f4891a9602e2c2270e976ec73fa0a50cff3311a)
- v2.1.0: "**flag gameinfo.gi changes no config made**": status now diffs the file against its closest stock build, counts
  hand edits, and offers to save them through a "My gameinfo.gi" import. — [8a10da1](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/8a10da1c6f6501d4b10a0f43f1e36efc17ca889d)
- v2.2.0: fixed "adding blank lines to gameinfo.gi on every launch". Before the fix, `update_mod_paths` added a blank line on
  every launch, so the file was rewritten each time, and vanilla/modded switching left a stray tab line. — [709ecbb](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/709ecbb5f073ef35dfaa4f91d7cb141bc5bf61d8)
- v2.2.0: dropped the `-exec autoexec` launch option ("Deadlock runs autoexec.cfg at every launch without -exec … the
  option only ran the file a second time"). — [4912c80](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/4912c80fce4d7feba86d7a50732d0d468adac02a)
- perf-catalog 0.0.2/0.0.3: "Apply performance configs as written, **including engine sections** and dev tools". Engine
  sections are now written "unless the user turns engine sections off". Editor and compiler sections are kept because
  `scenesystem.dll` reads some of them. OptiLock Ultra Potato was added. The catalog refreshes twice a day (CI) and hourly in
  the app. The catalog now tracks OptiLock v6.1c, OptimizationLock 23c8338 and 347a669, and Valve builds 6801/6812. — [perf-catalog CHANGELOG](https://github.com/deadlock-mod-manager/deadlock-mod-manager/blob/main/packages/perf-catalog/CHANGELOG.md); [rules.ts](https://github.com/deadlock-mod-manager/deadlock-mod-manager/blob/main/packages/perf-catalog/curated/rules.ts); [sources.json](https://github.com/deadlock-mod-manager/deadlock-mod-manager/blob/main/packages/perf-catalog/sources.json)
- Open issue #875: custom gameinfo.gi configs "are wiped or fail to parse when launching modded". — [DMM issue #875](https://github.com/deadlock-mod-manager/deadlock-mod-manager/issues/875) (search result; its status this week wasn't checked)

### Inferences
- **Correction to RESEARCH.md section 3 (round 3):** we justified the round-3 reset of six lines
  (`r_limit_particle_job_duration`, `r_particle_max_size_cull`, `r_texture_budget_threshold`, `r_texture_budget_update_period`,
  `sc_aggregate_bvh_threshold`, `sc_layer_batch_threshold`) with "another author measured camera-turn stutter and lower FPS".
  That author (ghempy53) now calls the Oct 6-7 results invalid and runs those lines again. **Round 3 has no external
  measured evidence for or against it.** It should be treated as an untested hypothesis like round 2, not as the best-supported half of
  `experimental`. Since experimental as a whole tested at about −40 FPS, this weakens the earlier plan to "split it: round 3
  alone first".
- **No config line from this week is a free FPS win for alz.** Every new OptiLock or OptimizationLock line either costs looks
  (particle lights, morphs, IK, textures, LOD, decals), does nothing online (replicated, `sv_*`, blocked, removed), or is
  already the default. `cl_modifier_parallel_gather_status_effect_updates` sounds like a CPU win, but it is `replicated`, so the
  server value applies online. alz's own `"false"` line is the default and harmless.
- **DMM risk for alz:** after updating to 2.1+, the performance feature is on, and the app writes engine sections when it applies a
  config. alz uses a hand-made `gameinfo.gi`. alz should check that DMM shows it as "My gameinfo.gi" (imported) and doesn't apply
  a catalog preset over it. Updating to 2.2.0 also stops the rewrite-on-every-launch bug, which made "did my cfg change?" checks
  noisy. (This is an inference from commit messages; we didn't test the app.)
- liv has not ported 6801, so the user's base cfg upstream is still broken on lighting. The `alz/` cfg already has the fix
  (local repo commit `cb1bb5b`). Nothing to pull from liv.
- OptimizationLock 3.7's `MinStreamingPoolSizeMB 500` goes the opposite way from alz (2048). It's a guarded RenderSystem edit with
  no measurement. Not worth copying.

### Gaps
- No author measured anything this week (OptiLock, OptimizationLock, ghempy53 all say so or publish none).
- The GameBanana changelog for Sqooky's "[harrowfix]" upload couldn't be read.
- We couldn't search GitHub for other recently updated `gameinfo.gi` repos (API blocked). Only the Dreyyyyy/OptimizationLock fork
  turned up in search, with no date.

---

## 3. Performance mods (GameBanana and VPKs)

### Takeaway
The only new item from a known performance-mod author is **Clutter be Gone's re-split (10-20)**: Screenspace Particle Remover
is now a separate VPK. That is the variant RESEARCH.md recommends, and it is now easier to install alone. A new GameBanana
tool, **Deadlock Blackout** (about 10-21, release 2.0.6 on 10-24), turns off map lights, fog and shadows, which is a visual
change, and it **rewrites `gameinfo.gi`**, so it conflicts with alz's cfg. We found no news on Optimized Soul Container, Vindicta
Scope Downscale or liv's sinners LOD fix.

### Cited Findings
- Clutter be Gone variants (10-20): 1. Screenspace (the old README text says "I was dropping 30fps while standing on vents,
  found the screenspace smoke particles are the reason"), 2. Graves, 3. City Ambient, 4. Walker ("A bit experimental"),
  5. Clean Doorway, **6. Movement** (new: dash and double-jump particles), **7. Pickups** (new: soul and buff pickup beams). — [Clutter be Gone README @2b8f7bb](https://github.com/Sqooky/OptimizationLock/commit/2b8f7bb)
- Deadlock Blackout (resrct): GameBanana mod 727681, "No glare, no clutter, more FPS", posted about 6 days before 10-27. GitHub release
  2.0.6 is dated 24 Oct. It's an exe that "changes only two things: the game config (`gameinfo.gi`) … mod files in the game's
  `addons` folder". The FPS config has "no shadows, fog or post-processing". On maps "lamps and street lights are switched off". It
  rebuilds itself after every game update and "works with Mod Manager". Its README notes "the October 2026 Deadlock update started
  using two KV3 value types that the released [ValveResourceFormat] 20.0 can't read yet", so mod tools built on the released
  VRF 20.0 may fail on 6801+ files. — [GameBanana 727681](https://gamebanana.com/mods/727681); [resrct/deadlock-blackout README](https://github.com/resrct/deadlock-blackout); [release 2.0.6](https://github.com/resrct/deadlock-blackout/releases/tag/2.0.6)
  - The public git tag `2.0.6` points to a 10-14 commit, so the 10-24 binary's source isn't in the repo. — local clone of [resrct/deadlock-blackout](https://github.com/resrct/deadlock-blackout)
- Search found no new versions or post-6801 breakage reports for Optimized Soul Container, Vindicta Scope Downscale or the sinners LOD
  fix. compylock's sinners LOD fix was last touched 10-10. — [7liv/compylock](https://github.com/7liv/compylock/commits/main); search found nothing on GameBanana ([GameBanana Deadlock](https://gamebanana.com/games/20948))

### Inferences
- For alz (no visual loss wanted): **Screenspace Particle Remover alone** stays the best mod candidate. It removes screen-edge
  overlays (low-health glow, vent smoke, Shiv bleed). Those are effects, not world detail, but they do give gameplay feedback (low HP).
  Movement and Pickups remove readability cues (dash trails, soul beams), so skip them under a no-visual-loss rule.
- Blackout is not for alz. It replaces the cfg and darkens maps, which is a visual change.
- Any VPK mod that ships compiled particles or materials from before 6801 can break on the newer resource formats. Clutter be
  Gone's update was built before 6801 went live (19:28 UTC vs 21:02 UTC). If DMM flags it red or effects look wrong, wait for a newer
  build. (Inference from timing; no breakage report found.)

### Gaps
- We couldn't read GameBanana pages or comments, so mod update dates there and any "broken after Harrow" comments are unknown.

---

## 4. Player reports: FPS, stutter, crashes, Vulkan/DX11, DLSS, drivers (Oct 20-27)

### Takeaway
No measured benchmark was published this week. The forum reports (from search snippets) are: a severe FPS drop when looking at
**Violet's drawings** after a recent emitter change, crashes that get more frequent after about 20 minutes "since the Harrow update"
(the reported workaround is resetting `video.txt`), and the usual CPU-limited low-FPS threads. The Vulkan vs DX11 evidence is unchanged.
The GeForce 621.01 driver (Oct 21) adds Microsoft Advanced Shader Delivery, which Deadlock doesn't use.

### Cited Findings
- "Violet's Drawing changes tanked the FPS" (forum bug report, thread 179686): "drop FPS by 50-70% when looking at the drawing".
  Users say the drop stops when they look away. A related report: "Violet Ability 1 (Draw) causing staggering FPS drop (300+>>>15) ever
  since the update to its emitter two days ago". Another thread title mentions "Invisible spots" in Violet's Draw "since FPS Rework".
  No Valve reply was found. — [forum thread 179686](https://forums.playdeadlock.com/threads/violets-drawing-changes-tanked-the-fps.179686/) (search snippets)
- Crashes "become more often after the 20 min mark since the Harrow update". The workaround users report is renaming `video.txt`
  (which resets graphics settings), and one poster blamed `"setting.volume_fog_depth" "1"` "(DonH confirmed)". We couldn't verify this. — forum
  results summarized via search ([Nurse Harrow Day](https://forums.playdeadlock.com/threads/nurse-harrow-day.178358/), [Bug Reports](https://forums.playdeadlock.com/forums/bug-reports.6/))
- Harrow's ultimate is reported to freeze or crash lobbies and replays ("Nurse Harrow ulting ending the game"). — [forum thread 178648](https://forums.playdeadlock.com/threads/nurse-harrow-ulting-ending-the-game.178648/) (search snippet)
- "performance issues that make no sense" (about 10-24): RTX 3060 + i7-11700F at 70-100 FPS. The poster concludes "the biggest contributor
  to this low fps is my cpu". — [forum thread 179819](https://forums.playdeadlock.com/threads/performance-issues-that-make-no-sense.179819/) (search snippet)
- Vulkan vs DX11: no new benchmark. A guide updated about 5 days ago cites one Radeon user at "117 FPS on DX11 versus 99 on Vulkan" as a
  single data point. A "Massive Performance Issues - Vulkan and DX11" thread (undated in the snippet) describes FPS getting worse over a
  session on Vulkan and hard crashes on DX11. — [WebSearch summary of guide](https://hyperpc.ae/company/blog/deadlock-fps); [forum thread 109063](https://forums.playdeadlock.com/threads/massive-performance-issues-vulkan-and-dx11.109063/)
- GeForce Game Ready 621.01 (Oct 21) adds Advanced Shader Delivery (precompiled shaders for supported games; needs Windows 11 24H2+).
  Launch titles are Gears of War: E-Day and CoD MW4 (secondary report). No Deadlock-specific or RTX 50 stutter fix was confirmed. — [TechRepublic](https://www.techrepublic.com/article/news-nvidia-driver-shader-stutter-fix/); [TechSpot driver page](https://www.techspot.com/downloads/drivers/essentials/nvidia-geforce/)
- DLSS: Valve's `video_defaults_3.txt` still says `"setting.r_dlss_preset" "6" // CNN - was 10 for transformer model`. That comment dates
  from build 6723 (09-30), so it isn't new. alz's `video.txt` uses `r_dlss_preset 10` (transformer). — [GameTracking-Deadlock video_defaults_3.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/master/game/citadel/pak01_dir/cfg/video_defaults_3.txt)

### Inferences
- The Violet report lines up with Valve's 6819 Draw change (min stroke distance 15, rebuilt stroke particles) and possibly the 6821
  rebuild. If alz sees fight drops when a Violet paints, that is a game-side cost with no config fix. A Clutter-be-Gone-style particle
  mod for Violet's ink would be the only lever, and it would remove gameplay-relevant visuals.
- The `volume_fog_depth "1"` crash claim doesn't apply to alz: alz's `video.txt` uses the engine minimums 64/64/48, which the 6821 dump
  shows as `min: 48`/`min: 64`. OptiLock's `video.txt` sets `volume_fog_* "0"`, which the engine clamps, so whether it's relevant there is
  unknown.
- 621.01 is not a Deadlock FPS item. Deadlock's DX11 shader cache is unaffected (inference: ASD needs per-game support).

### Gaps
- No Reddit r/DeadlockTheGame or Steam-forum posts could be read. Search didn't index any Reddit threads from this week.
- No YouTube or blog benchmark from Oct 20-27 was found.
- Exact post dates for the forum threads are approximate (taken from search "days ago" text).

---

## 5. Assessment for alz's setup: what could give FPS with no visual-quality loss

### Takeaway
**Nothing new this week is a confirmed free FPS gain.** The best new candidate is a **one-line A/B test of `r_particle_max_detail_level "2"`**
in `gameinfo.gi` ConVars, which can be set again since build 6812. It targets fight-time particle CPU cost, but it is a small visual cut,
not zero. The other actionable items are hygiene: DMM 2.2.0, and checking that DMM keeps alz's cfg. Also a research-record correction:
round 3's evidence was withdrawn.

### Cited Findings
- `r_particle_max_detail_level` can be set from gameinfo since 6812 (range 0-3, default 3). — [GameTracking 0abfe67](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/0abfe676c64c7d24bd5340a46778e65a84be70ed)
- alz's cfg has no `r_particle_max_detail_level` line, and keeps stock `BakePrecomputedShadows 1` and volume fog at the minimums. — `/home/user/alz-deadlock-cfg/alz/gameinfo.gi` lines 293-298, `/home/user/alz-deadlock-cfg/alz/video.txt` lines 41-44 (local files)
- DMM 2.1+ performance configs are on by default, and 2.2.0 fixes the rewrite on every launch. — [6f4891a](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/6f4891a9602e2c2270e976ec73fa0a50cff3311a), [709ecbb](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/709ecbb5f073ef35dfaa4f91d7cb141bc5bf61d8)
- The ghempy53 Oct 6-7 stutter result has been withdrawn. — [TESTED-CHANGES.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/TESTED-CHANGES.md)

### Inferences
Ranked for alz (5700X CPU-bound in fights, wants to keep visuals):
1. **Try (small visual cost, likely CPU gain):** `r_particle_max_detail_level "2"` in ConVars. Test it alone, in real fights. Check with
   `r_particle_max_detail_level` in the console that it reads 2. Watch Harrow's ult and Violet's paint for missing parts. Don't use 0.
2. **Free, no FPS change but avoids trouble:** update DMM to 2.2.0. In DMM's Performance page, make sure alz's file is kept or imported
   ("My gameinfo.gi") and no catalog preset or engine-section overlay is applied over it.
3. **Mod (unchanged advice, now easier):** use only the new standalone "1. Screenspace Particle Remover" VPK. Skip Movement and Pickups (readability).
4. **Don't copy:** anything from OptiLock 6.x or OptimizationLock 3.7 this week (`r_particle_timescale`, particle lights off, morphing off,
   texture pool 256, `MinStreamingPoolSizeMB 500`, `citadel_unit_status_hide_names`, Particles-section budget keys). These cost visuals, do
   nothing online, or are unmeasured guarded-section edits.
5. **Record fixes:** (a) RESEARCH.md section 3 round 3: its "measured" basis has been withdrawn by its author. (b) The OptiLock 5.8 report's line
   saying the `WorldRendererBuilder/BakePrecomputedShadows*` keys have no runtime effect is wrong for `BakePrecomputedShadows` and
   `...ForDirectionalLights`, which scenesystem.dll reads. alz's stock values are fine. (c) RESEARCH.md's "Not worth it" list names
   `r_particle_max_detail_level` among the gameinfo-blocked convars. That has been outdated since 6812.
6. **Watch next run:** whether Valve re-blocks `r_particle_max_detail_level`, the Violet Draw FPS fix (6821 `_fast` particles), any official
   changelog text for 6810-6821, and whether liv ports 6801.

### Gaps
- None of the candidates has been measured on alz's hardware or by anyone else this week.
