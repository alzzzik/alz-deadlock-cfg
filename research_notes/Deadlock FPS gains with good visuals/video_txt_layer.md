# video.txt as an FPS lever that still looks decent (Deadlock, Oct 2026)

Scope: `Steam\userdata\<id>\1422450\local\cfg\video.txt`, for a Ryzen 7 5700X + RTX 5070 12 GB + 32 GB DDR4-3200 PC
that is CPU-bound in fights. This extends RESEARCH.md section 4. It does not repeat it, and section 5 below
**corrects** one item in it (`r_render_portals`).

Primary evidence used (all read for this note):
- Valve's own files, from SteamTracking/GameTracking-Deadlock at commit `4e0f960a` (build **6785**, 2026-10-15; this is a
  few builds past the 6769-6779 target. The video files are not version-bumped: `video_version.txt` is still 20):
  - `cfg/video_defaults_0..3.txt`: what each in-game preset writes
  - `cfg/video_version.txt`
  - `cfg/moddefaults.txt`: the autoconfig "dxsupport" table that sets cpu/gpu/mem levels
  - `panorama/layout/popups/popup_settings.xml` + `citadel_main_english.txt`: menu exposure and Valve's tooltips
  - `DumpSource2/convars.txt`: every registered convar with default, min/max and flags
  - `DumpSource2/schemas/particles/*`: particle definition fields
  - `*_strings.txt`: binary string dumps
- DMM perf-catalog (`dmm/packages/perf-catalog/data/catalog.json` v2026.10.09-1, convar build 6769, and `curated/video.ts`).
- Community files: liv/compylock, alz-pc, OptiLock (FPS/Potato/Ultra Potato), Piggy's, Sqooky test_cfg, kaizu "maximumfps or minimum spec".
- DeadTune (`crates/dt-core/src/video.rs`, PLAN.md) and ghempy53 docs (RESEARCH-2026-10-06 §5, TUNING-CANDIDATES §C/§D).
- The web: most guide sites (hone.gg, dodge.gg, prosettings, forums.playdeadlock.com, developer.valvesoftware.com) could not
  be fetched from this sandbox (DNS/proxy refusal). Only their search snippets were available, so web claims below are
  snippet-level.

GT = `https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/`

---

## Q1. Does video.txt apply `setting.<convar>` for convars flagged `gameinfo_cannot_override`?

### Takeaway
There is no direct evidence either way. No community test, Valve note or DeadTune doc settles it, so it still needs the
2-minute in-game console check. The circumstantial evidence leans towards "the loader can set any convar by name", but
even if it does, none of the five blocked convars is worth using for this PC's goal except possibly
`r_particle_max_detail_level 2`. `r_shadows` is also a `cheat` convar, and `r_particle_shadows` no longer exists.

### Cited Findings
- Current flags (build 6785 dump):
  - `r_shadows true (cheat gameinfo_cannot_override)`
  - `csm_max_shadow_dist_override -1 (developmentonly defensive gameinfo_cannot_override)`
  - `r_particle_max_detail_level 3 (developmentonly defensive gameinfo_cannot_override)`
  - `r_particle_cables_cast_shadows true (developmentonly defensive gameinfo_cannot_override)`
  - `r_particle_shadows` is **not in the dump at all**

  — [GT DumpSource2/convars.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/convars.txt)
- DMM marks the four as `status: blocked, statusSinceBuild 6701`, and `r_particle_shadows` as `removed` (no longer in Valve's
  dump). DMM's own preset excludes any convar flagged `gameinfo_cannot_override`. — local `dmm/packages/perf-catalog/data/catalog.json` and `README.md` ("DMM Clean" rules)
- The video.txt loader must use a privileged path. Menu-owned settings that video.txt sets every launch are
  `developmentonly` convars, which the release console can't set: `r_citadel_upscaling 4 (developmentonly clientdll defensive)`,
  `r_texture_stream_mip_bias 0 (developmentonly defensive)`, `r_low_latency 1 (developmentonly defensive)`.
  — [GT convars.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/convars.txt)
- client.dll contains a generic `setting.%s` format string next to a handful of hard-coded `setting.*` keys (aspectratiomode,
  cpu_level, gpu_level, gpu_mem_level, mat_viewportscale, monitor_index, recommendedheight, resettodefaults, shaderquality,
  useadvanced). It also contains `cfg/video_defaults_%d.txt`.
  — [GT game/citadel/bin/win64/client_strings.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/bin/win64/client_strings.txt)
- No binary string dump contains "cannot_override" or similar wording, so the strings don't show where the flag is enforced.
  — GT `game/bin/win64/*_strings.txt`, `client_strings.txt` (searched)
- Valve's own `video_defaults_*.txt` still contain `setting.r_citadel_motion_blur`, which is not a registered convar in the
  6785 dump. So the loader tolerates unknown keys and doesn't reject the file.
  — [GT video_defaults_1.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/pak01_dir/cfg/video_defaults_1.txt)
- ghempy53's research says outright that "Nothing in Valve's files answers this; it needs an in-game check". Its proposed test
  is to add `setting.r_particle_max_detail_level 2`, launch, and read the console value. A second check: whether the key
  survives a menu save. — local `ghempy53_deadlock-config/docs/research/RESEARCH-2026-10-06.md` §5, `docs/TUNING-CANDIDATES.md` §C
- DeadTune's writer keeps unknown `setting.*` lines and treats video.txt as "normal menu settings" for ranked-safe mode.
  Its Windows test plan has no item for blocked convars. — local `simulieren_deadtune/crates/dt-core/src/video.rs`, `README.md`, `docs/testing-windows.md`
- Web searches for `"gameinfo_cannot_override"` and for Deadlock video.txt + `r_particle_max_detail_level` returned nothing
  relevant. — [search: Steam/Deadlock wiki results](https://steamcommunity.com/app/1422450/discussions/0/4696783122980510606) (no mention); [esports.ru guide](https://esports.ru/guides/deadlock-kak-povysit-fps-grafika/) (mentions video.txt location only)
- What `r_particle_max_detail_level` gates: particle *child* systems have a field "disable at detail levels below"
  (`ParticleChildrenInfo_t::m_nDetailLevel`, enum Low 0 / Medium 1 / High 2 / Ultra 3).
  — [GT schemas/particles/ParticleChildrenInfo_t.h](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/schemas/particles/ParticleChildrenInfo_t.h); [ParticleDetailLevel_t.h](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/schemas/particles/ParticleDetailLevel_t.h)
- Community values: Piggy's and kaizu/Sqooky use `r_particle_max_detail_level 0`, as do OptiLock (all presets) and
  `r_particle_cables_cast_shadows 0`. Piggy's sets `r_shadows 1`, OptiLock `r_shadows 0`. Liv/compylock sets none of them.
  liv sets `csm_max_shadow_dist_override 2048`. — local community `video.txt` files (counted: `r_particle_max_detail_level` appears in 28 files)

### Inferences
- Because the loader already sets `developmentonly` convars and uses a generic `setting.%s` mapping, it probably resolves
  any `setting.<name>` to a convar by name. `gameinfo_cannot_override` is checked in the gameinfo ConVars parser by name,
  so video.txt *may* bypass it. This is not proven. Confidence: low to medium.
- Even if it does: `r_shadows` is a `cheat` convar. Source 2 normally reverts or locks cheat convars on `sv_cheats 0`
  servers, so `setting.r_shadows 0` is unlikely to survive in a real match, and it violates the "decent looks" goal anyway.
- `r_particle_max_detail_level`: 0 removes every child effect tagged Medium or higher (looks bad, may thin ability visuals).
  2 removes only Ultra-tagged children. That is the only blocked key worth testing here, and only at 2. It is a CPU-side
  saving, since fewer particle systems are simulated, so it fits the 5700X bottleneck.
- `csm_max_shadow_dist_override`: if it applies, liv's 2048 caps sun-shadow range (cheaper), and 0 might mean "no sun
  shadows" or "engine default". This is ambiguous. Keep 0 (alz-pc) or delete the line; with `csm_max_num_cascades_override 0`
  it is moot.
- `r_particle_cables_cast_shadows 0` is cosmetic and cheap. Keep it only if the test shows the path works.
- `r_particle_shadows` is dead. Remove it from alz-pc (it was added in the last round).

### Gaps
- No in-game confirmation. Test: launch, open the console, and type `r_particle_max_detail_level` (expect 2 if the line
  applied), `csm_max_shadow_dist_override`, `r_shadows`. Then open Settings → Video, change any option and check whether the
  game deleted the community keys from video.txt on save.
- No CS2 documentation was found for the analogous `cs2_video.txt` behaviour. A search returned only generic forum threads.
  — [Steam CS2 discussion](https://steamcommunity.com/app/730/discussions/0/3823033163004695190)

---

## Q2. cpu_level / gpu_level / gpu_mem_level / mem_level

### Takeaway
These are autoconfig "hardware class" levels. The in-game menu presets never write them: `video_defaults_N.txt` has no
level keys. Autoconfig (`moddefaults.txt`) would give this PC `cpu_level 2, gpu_level 3, gpu_mem_level 3, mem_level 2`.
Particle systems do carry a "minimum CPU level" and "minimum GPU level", so lowering cpu/gpu_level can drop whole
effects. For a CPU-bound 5700X that wants to keep effects: **cpu_level 2, gpu_level 3** (liv's values), and raise
`mem_level` 0 → 2 and `gpu_mem_level` 2 → 3 to match autodetect.

### Cited Findings
- Convar defaults: `cpu_level 2`, `gpu_level 3`, `gpu_mem_level 2`, `mem_level 2`, all `developmentonly clientdll defensive`.
  Help text: "CPU Level - Default: High", "GPU Level - Default: High", "Memory Level - Default: High".
  — [GT convars.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/convars.txt); old dump in local `simulieren_deadtune/research/configs/OptimizationLock/cvarlist.txt`
- Autoconfig table:
  - `cpu_level` by processor count: 1-4 → 0, 5-7 → 1, 8-99 → 2
  - `mem_level` by RAM: <4 GB → 0, 4-8 GB → 1, ≥8 GB → 2
  - `gpu_mem_level` by VRAM ("megatexels"): <5800 → 0, 5800-7800 → 1, 7800-9800 → 2, ≥9800 → 3
  - `gpu_level` per device ID. Unlisted NVIDIA → "NVidia Unknown" → `gpu_level 3`. No RTX 50-series entry exists.
    Device-ID entries total 759×0, 94×1, 116×2, 610×3.

  — [GT moddefaults.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/pak01_dir/cfg/moddefaults.txt)
- The menu "Rendering quality" preset is the convar `citadel_video_preset` (0-3, `clientdll archive`). The panel shows it only
  when "Advanced settings" is off (`BasicVideo hidden-by="CustomGraphicsToggle"`). Selecting it calls `CitadelSetGraphicsLevel()`.
  — [GT popup_settings.xml](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/pak01_dir/panorama/layout/popups/popup_settings.xml), [convars.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/convars.txt)
- What each preset writes (Low / Med / High / Ultra):

  | Key | Low | Med | High | Ultra |
  |---|---|---|---|---|
  | `r_citadel_ssao_quality` | 0 | 0 | 3 | 4 |
  | `r_effects_bloom` | false | false | true | true |
  | `r_post_bloom` | false | true | true | true |
  | `r_citadel_antialiasing` | 0 | 1 | 1 | 1 |
  | `r_citadel_upscaling` | 0 | 4 | 4 | 4 |
  | `r_dlss_preset` | 6 | 6 | 6 | 6 |
  | `r_depth_of_field` | false | false | true | true |
  | `r_arealights` | false | false | true | true |
  | `r_texture_stream_mip_bias` | 2 | 1 | 0 | 0 |
  | `r_dashboard_render_quality` | 0 | 0 | 1 | 1 |
  | `r_particle_depth_feathering` | false | false | true | true |
  | `shaderquality` | 0 | 1 | 1 | 1 |
  | `recommendedheight` | 720 | 720 | 1080 | 0 |
  | `r_citadel_fog_quality` | 0 | 0 | 1 | 1 |
  | `r_citadel_motion_blur` | 0 | 1 | 1 | 1 |
  | `r_citadel_shadow_quality` | 0 | 1 | 2 | 3 |

  `r_dlss_preset 6` is CNN (Ultra's comment: "CNN - was 10 for transformer model"). Distance-field AO is commented out in
  every preset. **No preset touches cpu/gpu/mem levels.**
  — [GT video_defaults_0.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/pak01_dir/cfg/video_defaults_0.txt), [_1](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/pak01_dir/cfg/video_defaults_1.txt), [_2](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/pak01_dir/cfg/video_defaults_2.txt), [_3](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/pak01_dir/cfg/video_defaults_3.txt)
- Particle system definitions have a "Performance Options" group with `m_nMinCPULevel` ("minimum CPU level") and
  `m_nMinGPULevel` ("minimum GPU level"). They also have `m_hFallback` ("fallback replacement definition") and
  `m_nFallbackMaxCount`. — [GT CParticleSystemDefinition.h](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/schemas/particles/CParticleSystemDefinition.h)
- Valve Developer Community (snippet only, Source 1 since L4D): cpu_level/gpu_level "used to adjust shader & particle details"
  and decide whether entities with `mingpulevel/maxgpulevel` keyvalues are rendered.
  — [VDC Cpu level](https://developer.valvesoftware.com/wiki/Cpu_level); [VDC Gpu level](https://developer.valvesoftware.com/wiki/Gpu_level)
- Community values (cpu/mem/gpu_mem/gpu):
  - liv: 2 / 0 / 2 / 3
  - OptiLock (all presets): 1 / 0 / 0 / 0
  - kaizu "maximumfps or minimum spec" and Sqooky test_cfg: 0 / 1 / 0 / 0
  - Piggy's: not set

  — local community `video.txt` files
- ghempy53 lists cpu/gpu/mem levels under "Deliberately not candidates": "particle systems carry a minimum CPU/GPU level and
  are skipped below it." — local `ghempy53_deadlock-config/docs/TUNING-CANDIDATES.md` §D

### Inferences
- "Particle systems below a min CPU/GPU level get skipped" is consistent with the schema: the field exists per system, and the
  standard Source behaviour is not to create the system. It is not directly confirmed for Deadlock: no particle (.vpcf) data
  is in GameTracking, so we can't tell *which* hero effects set a minimum level. Treat lowering cpu/gpu_level as able to
  hide effects. That violates the "never hide abilities" rule, so OptiLock's/kaizu's 0/1 values are rejected.
- cpu_level 2 is both autodetect and liv's value. Going lower saves CPU only by removing content. Keep 2.
- gpu_level 3: the 5070 has headroom, and 3 is autodetect. Keep 3.
- mem_level 0 (liv) is the "<4 GB RAM" class. Its exact effect in Deadlock is undocumented (likely cache or pool sizes).
  With 32 GB there is no upside to 0 and possible hitch risk. Use 2 (autodetect).
- gpu_mem_level 2 vs 3: autodetect for 12 GB is 3. The effect is undocumented (likely texture or streaming budget). Use 3.
  It pairs with sharper textures (Q3).
- Autoconfig only runs when `Version` differs from `video_version.txt` (comment: "Bump the version number to force auto
  config to be re-run") or, by analogy with CS2, when the device changes. So hand-set levels persist.
  — [GT video_version.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/pak01_dir/cfg/video_version.txt)

### Gaps
- No benchmark of cpu_level 1 vs 2 in Deadlock fights, and no list of which effects are gated.
- The meaning of gpu_mem_level and mem_level inside Deadlock's renderer is undocumented.
- `knowndevice 0` (liv) vs 1 (OptiLock/kaizu): the binary only shows it is a rendersystem field. Its effect if it mismatches
  the autoconfig lookup is unknown.

---

## Q3. Per-key audit: what it is, exposure, range, FPS vs looks, recommendation for this PC

### Takeaway
Out of about 75 keys seen across community files, 22 are real menu settings, about 25 are real convars or settings with no
menu row ("advanced" layer), about 13 are display or bookkeeping keys, and about 13 are **dead** (not a convar and not a
known video key in build 6785). For a CPU-bound 5700X, almost nothing in video.txt lowers CPU cost except shadow and
particle work. Most GPU-side cuts in liv's file buy nothing on a 5070 and cost looks. The best "decent-looking" changes
from liv's file are: textures High, DLAA or FXAA instead of no AA, soft particles, area lights, autodetect memory levels,
and deleting dead keys.

### Cited Findings
Sources for this table: menu rows and labels from [GT popup_settings.xml](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/pak01_dir/panorama/layout/popups/popup_settings.xml) and [citadel_main_english.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/resource/localization/citadel_main/citadel_main_english.txt) (Valve's "Performance cost" tooltip text quoted). Convar default, range and flags are from [convars.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/convars.txt). Preset values are from `video_defaults_*` (Q2). Side effects are from the local DMM `catalog.json`.

**A. Menu-exposed (Settings → Video; most rows are shown only when "Advanced settings" = `useadvanced 1`)**

| Key | What / Valve tooltip | Range | liv | Recommend (this PC) |
|---|---|---|---|---|
| `useadvanced` | "Advanced settings" toggle. Off shows only the preset buttons | 0/1 | 1 | **1** (keeps per-row values instead of a preset) |
| `r_citadel_upscaling` | "Upscaling technology": 0 Stretch, 1 FSR, 2 FSR2 (TAA), 3 FSR3 (TAA), 4 NVIDIA DLSS. "Performance cost: moderate/consistent" | 0-4 (default 4) | 0 | **4 + DLAA**, or 0 + FXAA (Q4) |
| `mat_viewportscale` | "Render quality" slider, menu 0.40-1.00. With FSR2 it shows as 1x/1.5x/1.7x/2x (1.0/0.667/0.588/0.5) | convar 0.001563-1 | 1 | **1** (GPU-only; no CPU gain) |
| `r_citadel_dlss_settings_mode` | DLSS "Scaling mode": 4 = 1x (DLAA), 3 = 1.5x, 2 = 1.7x, 1 = 2x, 0 = Auto | 0-4 | 1 (2x, unused with upscaling 0) | **4** if DLSS |
| `r_dlss_preset` | "DLSS Model": 6 CNN, 10 Transformer ("sharper... but also more expensive") | menu 6/10; convar default 5 | 10 | **10** on RTX 50 (FP8; small cost) |
| `r_citadel_fsr_rcas_sharpness`, `r_citadel_fsr2_sharpness` | FSR sharpness sliders (FSR/FSR2 only) | 0-1 | 1/1 | irrelevant unless FSR |
| `r_citadel_antialiasing` | 0 None, 1 FXAA. "used when FSR2 is disabled". "small/consistent" | 0/1 | 0 | **1** if not using DLAA |
| `r_citadel_ssao_quality` | "Screen space AO": 0 Off … 4 Ultra. "moderate/consistent" | 0-4 | 0 | 0 (or 1-2 for depth; GPU-only) |
| `r_citadel_shadow_quality` | Shadow quality 0 Low … 3 Ultra | 0-3 | 0 | **0** (shadow passes add draw calls, which costs CPU) |
| `r_citadel_fog_quality` | 0 Low, 1 High. "reduce volumetric fog resolution" | clamp 0-1 | 0 | 0 |
| `r_texture_stream_mip_bias` | "Texture quality": menu 2 Low, 1 Med, 0 High | convar int, default 0 | **4** (off-menu) | **0** (12 GB VRAM). Above 4 breaks Sinner's lights without the fix |
| `r_post_bloom` | Post process bloom, "small/consistent" | bool | false | false or true (taste) |
| `r_effects_bloom` | Effects bloom: "draw effects directly into the bloom buffer", "small/consistent" | bool | false | false (cleaner ability read) or true |
| `mat_vsync` | VSync (non-convar video key) | 0/1 | 0 | 0 |
| `r_arealights` | Area lights: "large or irregularly shaped light sources, such as beam effects, to be rendered correctly", "small/consistent" | bool | false | **true** (beams render correctly; GPU-side) |
| `r_depth_of_field` | "negligible" cost | bool | false | false |
| `fps_max` | "In-game maximum FPS" slider 60-1000; out-of-range values (0) disable the slider | `archive release`, default 120 | 0 | see Q4 |
| `r_low_latency` | NVIDIA Reflex: 0 off, 1 on, 2 on + boost ("may draw more power... slightly impact FPS") | 0-2 | 1 | **1** |
| `r_fullscreen_gamma` | Brightness slider 1.6-2.6, inverted (1.6 = brightest); "only in fullscreen modes" | convar 1-4 | 1.6 | taste |
| `fullscreen` / `coop_fullscreen` / `nowindowborder` | Display mode: Full Screen / Co-op Full Screen / Window / Borderless | | 0/1/1 | keep liv's (Q4) |
| `fullscreen_min_on_focus_loss` | "Minimize on focus loss" (fullscreen only) | 0/1 | 0 | 0 |
| `defaultres`, `defaultresheight`, `aspectratiomode` (0 16:9, 1 16:10, 2 21:9), `monitor_index` | resolution panel | | 2560×1440 | **user's own native res** |
| `r_light_sensitivity_mode` | "Reduce flashing effects" (accessibility; `archive per_user`) | bool | true | true (less flash, no FPS change) |

`citadel_video_preset` (0-3) is a menu convar but archived in the user config, not video.txt.
`fps_max_ui` ("Dashboard maximum FPS") is also a menu setting.

**B. Real but not in the menu (only settable by video.txt or gameinfo; written by presets or kept by `useadvanced 1`)**

| Key | Status in 6785 | What | liv / alz-pc | Recommend |
|---|---|---|---|---|
| `shaderquality` | Video key (`setting.shaderquality` hard-coded in client, materialsystem2, rendersystem) | Shader detail: preset Low = 0, Med/High/Ultra = 1 | 0 | **1** for looks (GPU-side; Valve ships 1 from Medium up). FPS cost unmeasured |
| `r_particle_depth_feathering` | Video key (string present in client.dll; written by presets) | Soft-particle depth feathering: hard edges where effects meet geometry when false; High/Ultra = true | false | **true** (GPU fill only; 5070 has headroom) |
| `r_dashboard_render_quality` | convar bool, default true | Main-menu dashboard render quality | 0 | 0 (no in-match effect) |
| `r_citadel_distancefield_ao_quality` | convar, default 0 | Distance-field AO quality; Valve comments it out of every preset | 0 | 0 |
| `r_citadel_distancefield_shadows` | convar bool, default true | Soft shadows ray-marched through distance fields | false | false (or true for looks; GPU) |
| `r_distancefield_enable` | convar bool, default true | Master for distance-field features | not set | **leave unset/true**. OptiLock sets false. DMM denies the related gameinfo `RenderingPipeline DistanceField 0` (crashes after the hideout loads) |
| `cl_particle_fallback_base` / `_multiplier` | convars, default 0 / 0 (off) | "falling back to cheaper effects under load": swaps systems to their `m_hFallback` definitions. Trigger: `cl_particle_sim_fallback_threshold_ms 6`, `cl_particle_sim_fallback_base_multiplier 5` | liv 3/3, alz-pc 5/10 | 5/10 is fine (CPU relief in fights, swaps rather than hides). Exact formula unknown |
| `csm_max_num_cascades_override` | convar, default -1 | Sun-shadow cascades; 0 = no sun shadows | alz-pc 0 | 0 = big shadow cut (CPU and GPU) but a flatter look. 1-2 is a middle ground (untested) |
| `csm_viewmodel_shadows` | convar bool, default false | First-person model shadows | 0 | 0 (already the default; the line is a no-op) |
| `lb_enable_shadow_casting` | convar bool, default true | Stationary/dynamic lights cast shadows. Off: "lamps and ability lights light the scene without shadows" | false | false (CPU win) |
| `lb_dynamic_shadow_resolution` | convar, default true | Scales light shadow-map size by screen size | false | irrelevant if shadow casting is off |
| `lb_shadow_texture_width/height_override` | convar, default -1 | Shadow atlas size | 0 | 0 with casting off; else -1 |
| `lb_csm_override_staticgeo_cascades(_value)` | convars, default false / -1 | Which cascades render static geometry | true / -1 | no-op with value -1 |
| `volume_fog_width/height/depth` | convars, default 240/160/128, **min 64/64/48**, max 1024 | Volumetric fog texture size | liv 16 (clamped), alz-pc 64/64/48 | 64/64/48 (the fog-quality menu also changes fog resolution; how the two interact is unknown) |
| `r_fullscreen_gamma` | `archive` | (see A) | | |
| `cpu_level`, `gpu_level`, `gpu_mem_level`, `mem_level` | convars (Q2) | autoconfig levels | 2/3/2/0 | **2 / 3 / 3 / 2** |
| `knowndevice`, `recommendedheight`, `refreshrate_numerator/denominator`, `high_dpi`, `Version`, `VendorID`, `DeviceID` | engine/rendersystem bookkeeping | `Version` must be **20** (= video_version.txt) or autoconfig re-runs | template placeholders | real VendorID/DeviceID from the user's own file; Version 20 |

**C. Dead in build 6785 (not a registered convar and not a hard-coded video key)**

`r_citadel_half_res_noisy_effects`, `r_citadel_motion_blur`, `r_displacement_mapping`, `r_citadel_mboit` (only
`r_citadel_mboit_quality` exists, clamped min 0 max 0), `r_screen_space_shadows`, `r_citadel_distancefield_reflections`,
`r_env_map_uses_height_map`, `r_reduce_flash` (the real key is `r_light_sensitivity_mode`), `r_area_lights` (typo of
`r_arealights`), `r_particle_shadows`, `r_citadel_ssao` (the real key is `r_citadel_ssao_quality`), `r_citadel_outlines`
(outlines are now `r_citadel_npr_outlines`, a cheat convar blocked from gameinfo), and **`r_render_portals`** (DMM:
`removed, statusSinceBuild 6711`).
— absent from [GT convars.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/convars.txt); DMM catalog `status: removed`; old dump `r_render_portals | devonly, cl | Default: true` in local `OptimizationLock/cvarlist.txt`

**D. Clamped or no-op values in liv's / alz-pc file**
- `volume_fog_* "16"` (liv): below min 64/64/48, so clamped. alz-pc already fixed this.
- `r_texture_stream_mip_bias "4"`: outside the menu's 0-2. It stays (not clamped), but opening the Texture row in the menu
  will show no selection. Above 4 needs the Sinner fix (DMM sideEffects).
- `r_citadel_dlss_settings_mode 1`, `r_dlss_preset 10`, FSR sharpness/reactiveness/mip-bias keys: inert while
  `r_citadel_upscaling 0`.
- `csm_viewmodel_shadows 0`: equals the default.
- `lb_csm_override_staticgeo_cascades_value -1`: equals the default ("engine default"), so the override does nothing.
- liv's file has `r_citadel_distancefield_ao_quality` twice (harmless duplicate).
- `fps_max 0`: valid (0 = no limit) but outside the menu slider's 60-1000, so the slider is disabled ("Values out of range
  for the slider will disable the slider").
- `refreshrate_numerator/denominator 0`: probably "use default/highest". Unverified. Confirm in the menu that the
  monitor's full refresh rate is selected.

### Inferences
- "Dead" is based on the convar dump plus hard-coded `setting.*` strings. Client-registered convar *names* don't appear in
  the strings dumps at all (e.g. `r_citadel_upscaling`, `r_arealights` are missing), so string absence alone is weak
  evidence. Absence from DumpSource2's convar list is the strong signal. Valve's own `video_defaults` still ship
  `r_citadel_motion_blur`, which shows that stale keys are harmless.
- The CPU-relevant keys in video.txt are the shadow ones (shadow quality, cascades, light shadow casting) and the particle
  ones (fallback, max detail level if it applies). Everything else in liv's "low" choices (AA none, SSAO, textures 4,
  feathering off, shaderquality 0, area lights off) is GPU-side. On a 5070 that is GPU-idle in fights, those cuts give
  ~0 fight FPS and cost looks.

### Gaps
- No per-setting FPS benchmark for build 67xx was retrievable. The TroubleChute "every setting tested" page and the
  hone.gg/dodge.gg guides were unreachable (only search snippets).
  — [TroubleChute](https://hub.tcno.co/videos/deadlock-every-setting-tested-graphics-breakdown-performance/), [hone.gg](https://hone.gg/blog/deadlock-best-settings), [dodge.gg](https://www.dodge.gg/en-US/deadlock/news/deadlock-system-requirements-optimization-guide-2026)
- `shaderquality` and `r_particle_depth_feathering` exact GPU costs are unknown.
- `coop_fullscreen` semantics ("Co-op Full Screen") have no Valve tooltip.

---

## Q4. Upscaling/AA, display mode, Reflex, fps_max: best values for a CPU-bound 5700X + RTX 5070

### Takeaway
Upscaling can't raise CPU-bound fight FPS. Use the 5070's spare capacity for image quality instead:
**DLSS at 1x (DLAA) with the Transformer model** (`r_citadel_upscaling 4`, `r_citadel_dlss_settings_mode 4`,
`r_dlss_preset 10`, `mat_viewportscale 1`). If the GPU ever becomes the limit, fall back to Stretch + FXAA. Reflex On
(1, not Boost). Keep liv's borderless/co-op fullscreen. Use `fps_max 0`, or a cap a few FPS under refresh if fight
frametimes swing.

### Cited Findings
- Valve's Medium/High/Ultra presets all ship `r_citadel_upscaling 4` (DLSS) with mode 0 (Auto) and the CNN model. Only Low uses
  Stretch with no AA. — [GT video_defaults_1.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/pak01_dir/cfg/video_defaults_1.txt)
- Menu text: DLSS Transformer is "sharper and more accurate especially at higher scaling ratios, but also more expensive". The
  AA row (None/FXAA) applies "when FSR2 is disabled". — [GT citadel_main_english.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/resource/localization/citadel_main/citadel_main_english.txt)
- DLSS 4.5 on RTX 50: NVIDIA calls the cost a "minor performance tradeoff" on RTX 50/40 (FP8). On an RTX 5070 Ti in
  Cyberpunk, DLSS 4.5 is ~5% slower than 4.0 at Quality/Balanced. — [HotHardware](https://hothardware.com/news/nvidia-dlss-45-benchmarked); [TechSpot](https://www.techspot.com/article/3080-nvidia-dlss-45-vs-40/)
- Deadlock forum anecdotes: the DLSS 4.5 driver model cost FPS on older RTX cards, and switching to preset K/F recovered it.
  Another user (5600X) found the CPU was the fight bottleneck and that disabling SMT helped. — [forums.playdeadlock.com "Performance issues"](https://forums.playdeadlock.com/threads/performance-issues.98611) (snippet)
- Guides: "At 1080p with a powerful GPU, Deadlock becomes CPU-bound before GPU-bound, especially during teamfights". DLSS
  Quality recommended for RTX. — [evetech 2026 guide](https://evezone.evetech.co.za/game-desk/best-deadlock-pc-settings-for-maximum-fps-in-2026); [dodge.gg 2026](https://www.dodge.gg/en-US/deadlock/news/deadlock-system-requirements-optimization-guide-2026) (snippets)
- Display mode: prosettings says there is no performance difference between Borderless and Fullscreen. A Steam thread reports
  that fullscreen at launch can give a black screen while borderless works. — [prosettings](https://prosettings.net/guides/deadlock-options/); [Steam thread](https://steamcommunity.com/app/1422450/discussions/0/4758704514230564281) (snippets)
- Reflex: `r_low_latency` help "NVIDIA Low Latency/AMD Anti-Lag 2 (0 = off, 1 = on, 2 = NV-only, on + boost)". Boost "may draw
  more power to the GPU and slightly impact FPS". — [GT convars.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/convars.txt), [citadel_main_english.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/resource/localization/citadel_main/citadel_main_english.txt)
- `engine_low_latency_sleep_after_client_tick false (release)` exists. With Reflex on, it moves the low-latency sleep on tick
  frames to after client simulation. ghempy53 lists it as a live console test. — [GT convars.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/convars.txt); local `ghempy53_deadlock-config/docs/TUNING-CANDIDATES.md`
- `fps_max` is `archive release` (default 120), so it can be changed live in the console. The menu slider covers 60-1000, and
  `+fps_max` works as a launch option for extended values. — [GT convars.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/convars.txt), [citadel_main_english.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/game/citadel/resource/localization/citadel_main/citadel_main_english.txt)
- `mat_viewportscale` help: "Scale down the main viewport (to reduce GPU impact on CPU profiling)". Valve's own wording says
  it reduces GPU load only. — [GT convars.txt](https://github.com/SteamTracking/GameTracking-Deadlock/blob/4e0f960a9d175b18757ac607c04e70f15dabe7e3/DumpSource2/convars.txt)
- `r_citadel_half_res_noisy_effects` (liv true) is not a convar in 6785, so it does nothing (Q3-C).
- `r_render_portals` no longer exists (Q3-C).

### Inferences
- DLAA vs Stretch + no AA: DLAA renders at native resolution, so it adds GPU work and a small CPU cost to set up DLSS. On a
  5070 at 1440p in a CPU-bound fight, the GPU should absorb it. Expect ≈0-3% fight FPS change for a large clarity gain over
  liv's aliased image. Not measured: A/B with the frametime telemetry (`cl_hud_telemetry_frametime_show`).
- If the GPU becomes the limit in some scenes (lane, no fight), DLSS 1.5x (mode 3) is the next step. Don't go to 2x (mode 1,
  liv's leftover value): that is a GPU saving the PC doesn't need.
- FSR3 frame generation is not exposed for DX11 in the menu (only the FSR3 TAA upscaler). Frame generation would also add
  latency.
- Reflex 1 is correct for a CPU-bound game: it keeps the render queue empty when the CPU is the limit. Boost (2) raises GPU
  clocks and helps only when GPU-bound.
- fps_max: with G-Sync, a cap ~3-5 FPS under refresh (or uncapped with Reflex, which auto-limits when NVCP VSync is on)
  smooths fight frametimes. Uncapped is fine if the user prefers lowest latency.
- Display mode: keep `fullscreen 0, coop_fullscreen 1, nowindowborder 1` (liv). With Win11 flip-model presentation,
  borderless ≈ exclusive fullscreen in latency. Exclusive fullscreen only adds alt-tab risk.
- `mat_viewportscale` stays at 1. Lowering it is GPU-only, which matches Valve's help text.

### Gaps
- No Deadlock-specific DLAA/DLSS benchmark on CPU-bound hardware was found.
- Co-op Full Screen vs Borderless latency has not been measured for Deadlock. PresentMon would settle it.
  — [Blur Busters thread](https://forums.blurbusters.com/viewtopic.php?p=109820) (generic)

---

## Q5. Resulting change list vs the alz-pc video.txt

### Takeaway
alz-pc's file is mostly right on the CPU-side cuts. Changes: fix dead or wrong keys, raise the GPU-side quality the 5070
can absorb, and correct the memory levels. Two RESEARCH.md §4 statements need updating: `r_render_portals` (no longer a
convar since 6711, so "0 breaks Doorman's door" is moot for current builds) and `r_particle_shadows` (dead).

### Cited Findings
(Each item is supported by the findings in Q1-Q4. Sources as cited there.)
- Keep: `useadvanced 1`, `cpu_level 2`, `gpu_level 3`, shadow quality 0, `csm_max_num_cascades_override 0`,
  `lb_enable_shadow_casting false`, light shadow-atlas 0, `cl_particle_fallback 5/10`, fog quality 0, volume fog 64/64/48,
  bloom/DoF off, `r_light_sensitivity_mode true`, Reflex 1, `Version 20`.
- Change for looks (GPU-side, ~free on a 5070):
  - `r_texture_stream_mip_bias 4 → 0`
  - `r_citadel_upscaling 0 → 4` + `r_citadel_dlss_settings_mode 1 → 4` (DLAA), keep `r_dlss_preset 10`. Alternative: keep 0
    and set `r_citadel_antialiasing 0 → 1` (FXAA).
  - `shaderquality 0 → 1`
  - `r_particle_depth_feathering false → true`
  - `r_arealights false → true`
- Change for correctness: `mem_level 0 → 2`, `gpu_mem_level 2 → 3` (autodetect values).
- Delete dead keys: `r_citadel_half_res_noisy_effects`, `r_render_portals`, `r_displacement_mapping`, `r_screen_space_shadows`,
  `r_citadel_distancefield_reflections`, `r_citadel_mboit`, `r_citadel_motion_blur`, `r_env_map_uses_height_map`,
  `r_reduce_flash`, `r_particle_shadows`. Keeping them is harmless, but they mislead.
- Optional test (Q1): add `setting.r_particle_max_detail_level "2"` and verify it in the console.
- Must do: real VendorID/DeviceID and native resolution from the user's own file. Confirm the refresh rate in the menu.

### Inferences
- Expected net effect: fight FPS about unchanged vs alz-pc (the CPU-side cuts are identical), with a visibly sharper,
  anti-aliased image with softer effect edges. Only the optional `r_particle_max_detail_level 2` could add CPU headroom.
- If fight FPS drops after the GPU-side changes, revert in this order: DLAA → FXAA, `shaderquality` → 0, feathering → false.
  Use the in-game frametime telemetry in the same spot.

### Gaps
- None of the recommended GPU-side changes has a measured Deadlock FPS cost on RTX 50-series. The user's own A/B test is the
  deciding evidence.
- Whether the menu, on save, drops the non-menu keys (alz-pc's added shadow keys) from video.txt is untested. If it does,
  re-apply after any menu change.
