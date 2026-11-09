# Raw notes: CompLock (deadlockconfig.com), collected 2026-11-09

These are working notes. The readable write-up is `research/reports/CompLock deadlockconfig com.md`.
Downloads went into new folders under the session scratchpad (`cl_web`, `cl_dl`, `cl_gh`, `cl_ref`, `cl_compy`,
`cl_render`). Python only ran with `-I` on downloaded files. Nothing in the repo was modified except these two new files.

## 1. Site map (fetched 2026-11-09, page footer says "Updated 2026-11-09")

`sitemap.xml` lists 5 pages. There is no separate FAQ, install, changelog or downloads page.

| URL | What it is |
| --- | --- |
| `/` | Landing page, headline chart, the JS **Pack Builder** (`#pack-app`), data in `<script id="pack-data">` (JSON) |
| `/docs/benchmarks/` | Benchmarks plus methodology (the only "docs" with content) |
| `/docs/cvars/` | "Cvar Library": a plain dump of Valve's convars (build 6844, 4,884 cvars) in `<script id="cvar-data">`, with categories. No CompLock-specific notes. |
| `/docs/hitsound/` | Browser hitsound builder by jcStani (makes a VPK with your sounds at stock hit-indicator paths) |
| `/docs/privacy/` | No accounts, no own cookies, served through Cloudflare, **Google AdSense ads** (updated 2026-11-08) |

Other assets: `/docs/pack/pack.js` (49.7 KB, the builder), `/docs/js/site.js` (sliders/videos), `/dl/pack/*.z`
(each pak stored as one raw-deflate stream; No Cloth split in 2 parts). Comments in pack.js name private build
scripts (`site/build.py`, `site/pack.toml`, `render.py`); none are public.

Domain: RDAP says `deadlockconfig.com` was registered **2026-11-01 04:42 UTC**.
Discord invite `3XtAKEGwvm`: server "CompLock", description "quality of life mods we made for deadlock",
~1,439 members, ~833 online (2026-11-09).
Promotion: "Deadlock Intel" X account, 2026-11-07: "nearly double your FPS", ~136k views.
Name collision: a 2024 r/complock subreddit and "COMPLOCK" competitive Discord are unrelated (2024 posts by other people).

### Pack Builder (rendered with Playwright/Chromium 2026-11-09)

Always in the pack: HUD++ (`hud.vpk`, damage-number choice Vanilla / **Cumulative (default)** / Hidden) and
CompLock's `gameinfo.gi` ("By HoppCX", +24.1% / +18.0%). Default-on options: Sound stack update cap, Particle Pruning
(stock tracers). Builder estimate for the default pack: **+48.5% avg / +38.5% 1% low** "over the game without mods".

| Option (group) | Pak (number) | Size | gameinfo lines it adds | Site number (CPU-bound) |
| --- | --- | --- | --- | --- |
| HUD++ (base) | hud.vpk / hud_nodamage / hud_vanilla (pak01) | 5.4 MB | Cumulative/Hidden: `citadel_damage_text_batching_window_individual "2"` | +3.8% / +5.2% |
| gameinfo.gi (base) | - | - | always: `citadel_unit_status_healthbar_highlight_speed "100"` | +24.1% / +18.0% |
| Cloth simulation off (physics toggle) | nocloth_dir.vpk (pak07) | 118 MB | `cloth_update "false"` | +4.0% / +3.7% |
| Client physics off (physics toggle) | - | - | `cl_phys_enabled "false"`, `cl_disable_ragdolls "true"` | +2.6% / +0.8% |
| Sound stack update cap (engine, on) | soundcap.vpk (pak03) | 25 KB | - | +6.7% / +6.3% |
| Particle Pruning (effects, on) | particlepruning_stocktracers.vpk / particlepruning.vpk (pak02) | 9.8 / 12.5 MB | - | +8.4% / +4.6% (reduced: +10.1 / +5.5) |
| Low detail map (effects) | lowdetailmap.vpk (pak06) | 35 MB | - | +2.6% / +2.1% |
| Brighter lighting (effects, by BreadRollius) | brighterlighting.vpk (pak04) | 108 KB | - | +2.4% / +0.3% |
| jcStani's HP Bars (visibility) | hpbars.vpk (pak05) | 60 KB | - | not measured on 11-09 (0.0% on 11-05) |

Install paths: zip (`game/citadel/gameinfo.gi`, `game/citadel/addons/pakNN_dir.vpk`, `addons/mods.txt`) or
"Install to game folder" (File System Access API, Chrome/Edge). The installer **overwrites gameinfo.gi**, writes fixed
pak numbers pak01-pak07, deletes paks that an earlier CompLock `mods.txt` listed, deletes a folder
`optional-addons` if its mods.txt starts with "CompLock optional mods", and only *names* other paks it finds.
mods.txt says "pak01 loads first, and a lower number wins when two paks change the same file".

gameinfo edit logic (`gameinfo()` in pack.js): replace an existing `"key" "value"` inside `ConVars`, else insert at the
top of ConVars under `// CompLock Pack Builder`.

### Pak contents (downloaded, listed with own VPK reader)

- All paks carry `modinfo.json` written by tool **"deadlock-fpsmaxing" 1.0** (writtenAt 2026-11-07), author HoppCX.
- soundcap: 1 file, `soundstacks/soundstacks_citadel_base_3d.vsndstck_c` (full replacement of a stock stack). Strings
  show new operators `update_rate_rand` (math_random_float 0.015-0.017) feeding `update_rate_cap` (input_wait_time).
- brighterlighting: `postprocessing/basepostprocess_deadlock.vpost_c`, 4 glow particles, 2 funnel-cloud models.
- hpbars: `panorama/styles/unit_status_v2.vcss_c`.
- particlepruning_stocktracers: **4,550 particle files** (2,945 abilities, 390 upgrades, 354 weapon_fx, 147 npc, 96
  environment, ...). Includes `particles/environment/sinners_sacrifice_bonus_round_flash.vpcf_c`.
- hud.vpk: 206 files: panorama styles (hud, minimap, top bar, quickbuy, 46 per-hero ability styles), scripts
  (`hudpp_*.vjs_c`, clean_minimap, hud_grid_timers), 114 hudtext layouts, crosshair textures.

## 2. People and source

- HoppCX: GitHub account (joined 2024-05-08, 16 public repos). Repos' git author name and README badges say
  `itchyfeetleech` (same person / renamed account). Relevant repos:
  - `Deadlock-Performance-Lab` (DPL): Linux replay benchmark tool for gameinfo/video.txt. 26 commits 2026-09-05..09-29;
    the later ones authored by "Claude" (AI agent) via PRs. Commit 6e1433e (09-29) removed the published community
    results; recovered from history: a **100-convar one-at-a-time screen** (2026-09-06, 9800X3D/RX 9070, 1280x720 low,
    replay 102565106 tick 134987, 3 runs each, 10 s captures) and an 8-cvar value sweep. Saved to
    `scratchpad/cl_ref/dpl_screen100.csv` and `dpl_screen100_sorted.txt`.
  - `deadlock-linux-optimizations` (2026-10-28): Wine/Proton patches. Its CSV: vanilla vulkan 372.3/171.8,
    "gameinfo" 385.1/191.5 (+3.4%/+11.5%), "gameinfo + mods" 424.5/206.1. All four patches +8.3% team fight.
    Says Vulkan and DX11 same avg, Vulkan 1% lows 5-8% higher (on Linux/RADV).
- jcStani: GitHub account with 0 public repos (joined 2019). X account @jcStani. EDL.gg esports profile exists.
- No public repository for CompLock itself (no gameinfo history, no changelog).
- GameBanana: CompLock is **not** on GameBanana. The "Clutter Be Gone" page (gamebanana.com/mods/722853) says:
  "complock: not on gamebanana due to heavy AI usage. Initially bundled this mod, when i asked to please link to this
  gamebanana page instead, stopped using this mod and used AI to recreate it." (a third party's claim, unverified)
- 7liv/compylock (liv, alz's base): 14 commits, all by 7liv, 2026-10-04..10-10. No HoppCX/jcStani commits. compylock's
  README also warns against QOL Lock. **37 of CompLock's 83 gameinfo changes also appear in compylock** (30 same value:
  the whole camera block, viewmodel/hair/ropes/grass off, splashes, captiontrace, decal res, v8 heap, texture budget,
  fog x3, default_fov/viewmodel_fov 0, sc_instanced_mesh_motion_vectors 0; 7 retuned: lru_lifetime 1->4,
  props_break 1->0, r_aspectratio 2.4->2.15, r_farz -1->7000, r_mapextents 16384->7000,
  r_particle_min_timestep 0.00241->0.00833, r_texturefilteringquality 5->0). Shared lineage is likely, but nothing
  proves CompLock was forked from compylock.

## 3. Benchmarks page, as of 2026-11-09 (and the 2026-11-05 version via Exa's cache)

11-09 version: build 6860, 9800X3D + RX 9070, 32 GB, Arch Linux kernel 7.2.8, Mesa 26.3.0-rc2 RADV,
GE-Proton11-11 **with HoppCX's Wine patches**, Vulkan, 2560x1440, main thread pinned to core 2.
- Scene: a public match replay, its 5 busiest team fights (ticks 62,720 / 76,224 / 99,200 / 103,168 / 112,768), chase
  camera on one hero, 15 s warm-up, 30 s measured per fight, MangoHud per-frame log. Fresh launch per measurement
  (`-vulkan -novid -nohltv -vconsole -condebug -insecure`). 94 launches, 4,435,356 frames.
- **Same video.txt for every setup** ("written where its gameinfo.gi reads them: the game's own reads Steam's userdata
  folder, CompLock's the game folder"). CPU-bound batch: render scale 40%, most options low, GPU 60-66% busy.
  GPU-bound batch: 100% render scale, default quality, GPU 96-99% (vanilla 93%); vanilla run with fog at lowest.
- ABBA order, batches interleaved; baseline = HUD++ + CompLock gameinfo + default pack; each option added alone.
  4 baseline runs over 5.4 h: 379.1-383.6 avg (sd 2.1 FPS, 0.5%); 1% lows 182.3-185.2.
- Stats: per fight avg FPS and 1% low (mean of slowest 1% frame times); per launch mean of log FPS; least-squares fit
  with one effect per setup plus a quadratic time-drift curve; 95% t-intervals.
- Headline: Vanilla 297.1 avg / 148.2 1% low vs "CompLock" 485.7 / 231.8 (+64.5% / +56.6%). The CompLock bar is
  **every option on** (gameinfo +24.1% x HUD++ +3.8% x every option +27.8% = 1.646). So the headline includes
  Particle Pruning (reduced), Low detail map, No Cloth, client physics off and Brighter lighting.
- Gameinfo alone: 297.1 -> 367.1 avg (+24.1% +-1.2), 148.2 -> 174.8 1% low (+18.0% +-1.5). GPU-bound: +15.6% / +14.8%.
- One run, fight 1: vanilla 371.4 avg / 180.1 low vs every option 568.2 / 273.0.
- "Time saved per frame": particle pruning 234 us, soundcap 161 us, no cloth 96 us, HUD++ 102 us, physics off 62 us.

11-05 version (Exa cache): builds 6848-6851, one team fight (tick 100,950), 15 s windows, `-dev` launch flag,
video.txt "low settings at render scale 0.75" for CompLock setups but vanilla on the menu's **lowest** preset
(Low, 75%, Stretch). Headline then +43.8% / +37.5% (vanilla 185/397 vs CompLock 254/572); gameinfo +19.6%/+16.2%;
HUD++ +6.4%, Particle Pruning +5.7%, "CompLock Map" +2.4%, soundcap +2.4%; low-poly troopers, thicker outlines,
KovaaK hitsounds, HP bars, no music: no measurable effect. 20 baseline runs sd 0.5%.

So: in 4 days the headline moved +43.8% -> +64.5% as options were added and render scale dropped 75% -> 40%.
Soundcap moved +2.4% -> +6.7% (different scene, 5 fights, 40% scale).

## 4. gameinfo.gi analysis (CompLock vs Valve stock 6860)

Header: "Gameinfo cvars tested & crafted by HoppCX for build 6844". 729 lines.
Valve stock `game/citadel/gameinfo.gi` at GameTracking FETCH_HEAD 3cfcaf9 (6860, 2026-11-06); last change to the stock
file in the fetched window 2026-10-22. Convar dump: `DumpSource2/convars.txt` at 6860 (last touched 6857).
Since build 6821 (cv_latest): 16 convars added (halloween, ranked, minimap cursor, gold), 8 defaults changed (gold,
air drag), **none removed, nothing render-related**. No alz line affected.

Structure checks:
- PGIVersion `48C04ECA...F7F6E` = stock 6860 = alz. BakedLighting `Version 5` + `directional_irradiance_sh2_lum`
  (DXT1) = stock. Current structure: yes.
- Engine sections: identical to stock except **SceneSystem `NonTexturedGradientFog`, `CubemapFog`, `VolumetricFog` = 0**
  (alz has the same three). No RenderSystem/WorldRenderer/Engine2/Particles edits (alz has ~20 such edits).
- SearchPaths: `Game_UILanguage`, `Game_LowViolence`, `Mod citadel`, `Write citadel`, `Game citadel/addons`,
  `Game citadel`, `Game core`. Explicit Mod/Write: yes. No `Mod/Write core`. **No Deadlock Mod Manager markers.**
- `"UserSettingsPathID" "USRLOCAL"` is **commented out**; `LegacyUserSettingsPathID "MOD"` kept. Effect (confirmed by
  their own methodology text): settings incl. video.txt are read from the game folder, not Steam userdata.
- Header/comments stripped; otherwise ConVars block = stock + 80 changed/added lines (+ the Pack Builder lines).

Classification of the 80 ConVars lines (flags from the 6860 dump; `classified.tsv` in scratchpad/cl_ref):
- nonexistent: 0. `gameinfo_cannot_override`: 0.
- replicated (server value wins online): 21: ik_constraints_enabled, ik_debug_dogleg3bone_enabled,
  ik_debug_fabrik_backwards_enabled, ik_debug_fabrik_forwards_enabled, ik_enable, ik_fabrik_backwards_enabled,
  ik_fabrik_forwards_enabled, ik_planetilt_enable, ik_final_fixup_enable, animgraph_footlock_calculate_tilt,
  animgraph_footlock_enabled, animgraph_footlock_ground_roll, animgraph_footlock_hip_offset_enable,
  animgraph_footlock_ik_enable, animgraph_footlock_trace_ground_enabled, animgraph_footlock_use_hip_shift,
  animgraph_slowdownonslopes_enabled, skeleton_instance_lod_optimization, props_break_max_pieces_perframe,
  citadel_camera_see_distance_max, rpg_camera_yaw.
- cheat (applies from gameinfo at startup per repo's earlier research): r_farz, r_mapextents, r_drawropes,
  r_morphing_enabled, citadel_camera_height, default_fov, viewmodel_fov, r_drawviewmodel (+ r_render_hair,
  r_haircull_percent, r_citadel_clip_sphere_min_opacity, which are also devonly).
- menu/user-owned: citadel_damage_text_cumulative_mode (archive, userinfo: the in-game setting wins once saved).
- restates default: cloth_update true, citadel_damage_offscreen_indicator_disabled true, citadel_trooper_glow_disabled 0.
- clamped: r_character_decal_resolution 4 -> min 256.
- client, real change: the rest (devonly client-side and 4 release client lines).
- 31 of the 80 are already in alz (most same value; differences: r_particle_min_timestep 0.00241 vs 0.00833, r_farz
  -1 vs 7000, r_mapextents 16384 vs 7000, r_aspectratio 2.4 vs 2.15, r_texturefilteringquality 5 vs 0,
  props_break 1 vs 0). 49 are new to alz.

Pack Builder extra lines (dump 6860): citadel_unit_status_healthbar_highlight_speed default 2 (devonly client);
citadel_damage_text_batching_window_individual default 0 (devonly client, "individual damage events within this
time are added together into a single entry"); cl_phys_enabled default true (cheat); cl_disable_ragdolls default false
(cheat); cloth_update default true (devonly).

## 5. DPL 100-convar screen (2026-09-06, replay, 3 runs, descriptive means only)

Baseline 274.1 avg. The median variant was about +0.9%, so anything under ~+2% is not distinguishable from the
baseline being slow. Relevant rows: r_morphing_enabled 0 +2.10%; animgraph_footlock_enabled 0 +1.98%;
ik_enable 0 +1.41%; ik_constraints_enabled 0 +0.02%; r_smooth_morph_normals 0 +0.37%; sc_clutter_density_full_size
0.5 +1.87%; cl_show_splashes 0 +1.25%; r_particle_min_timestep 0.001 +0.83% (inactive at that FPS anyway);
r_texturefilteringquality 0 +0.42%; r_texture_budget_update_period 0.5 +0.29%; cl_interp_parallel 1 +1.74%;
cl_disable_ragdolls 1 +2.08%; r_size_cull_threshold 1.6 +6.66% (top). Not tested there:
cl_generate_postdataupdatepreserved, panorama_min_comp_layer_cache_cost, panorama_comp_layer_lru_lifetime,
wind_system_*, rope_*.

## 6. Mod compatibility facts

- Site: "Not compatible with QOL Lock or other types of mods." Cloth option: "Not compatible with other mods that
  replace hero models."
- Why (from the files): HUD++ replaces 206 HUD files (QOL Lock and any HUD/minimap/crosshair mod touch the same
  ones); Particle Pruning replaces 4,550 particle files (any particle, ability-effect or skin mod collides, and a lower
  pak number wins); No Cloth replaces hero models; the installer uses fixed pak01-07 and rewrites gameinfo.gi; the
  gameinfo has no DMM markers and moves the settings folder; default_fov/viewmodel_fov 0 clash with FOV mods (alz
  already disabled these for that reason).
- Soundcap replaces one stock sound-stack file; stale after any Valve change to that stack.

## 7. alz context checked

- alz/gameinfo.gi: 194 differences from stock 6860, incl. ~20 engine-section edits; fog x3 same as CompLock.
- alz keeps `UserSettingsPathID USRLOCAL` + `LegacyUserSettingsPathID MOD`, explicit Mod/Write for citadel and core.
- alz already: hair, ropes, viewmodel, grass, clutter, wind strength 0, splashes off, camera block, v8 heap 1024.
- alz-experimental [ax1] removed `r_particle_min_timestep 0.00241` ("jagged particles above ~415 FPS"), [ax2] restored
  motion vectors for DLSS (`sc_instanced_mesh_motion_vectors` back on). CompLock keeps motion vectors off (it doesn't
  assume DLSS).
- alz/video.txt: bloom off already (`r_effects_bloom false`, `r_post_bloom false`), DLSS via r_citadel_upscaling 4,
  mat_viewportscale 0.58.
