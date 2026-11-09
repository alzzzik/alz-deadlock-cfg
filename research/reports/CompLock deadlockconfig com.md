# CompLock (deadlockconfig.com): what it is, whether the +64.5% is real, and what alz can take from it

Researched 2026-11-09 against Deadlock build 6860. Raw notes: [notes/CompLock deadlockconfig com/notes.md](../notes/CompLock%20deadlockconfig%20com/notes.md).

## Headline

- **The benchmark is the most careful one any Deadlock config has published.** Every setup ran in fresh launches, with
  the same video settings, in mixed order, with 95% error bars. The scare that "vanilla ran on high settings" is
  **not true** today. But the **+64.5% compares the game with nothing removed against CompLock with every
  visual-cutting mod turned on.** It was measured on one Linux PC (Ryzen 7 9800X3D, Proton with the author's own Wine
  patches) during **replay playback**, not in live matches. Its gameinfo-only result was +3.4% on 2026-10-28, +19.6%
  on 11-05 and +24.1% on 11-09.
- **Most of CompLock's gameinfo is already in alz.** 31 of its 80 convar lines are in alz, and so are its 3 fog
  switches. Of the 49 that are new to alz, 17 are server-controlled, so they very likely do nothing in a live match.
  Most of the rest hide something.
- **Worth testing in alz-experimental:** the **Sound stack update cap** mod. CompLock says it is +6.7% average and
  +6.3% 1% lows, with nothing looking or sounding different. Also worth testing: a small group of zero-visual
  convars (entity callbacks, UI layer caching, rope/wind work that alz already hides).
- **Not for alz:** Particle Pruning, Low detail map, No Cloth, client physics off, Brighter lighting, far clip 7000,
  bilinear filtering. They are real FPS, but they change how the game looks. HUD++ changes the HUD, so it is your call.
- **CompLock does not work alongside your mods.** Its installer overwrites `gameinfo.gi` and takes pak01-pak07. It
  replaces 4,550 particle files and 206 HUD files. It also moves where the game reads `video.txt`. Do not install the
  pack. Take single pieces from it.

## 1. What CompLock is

A mod set plus a `gameinfo.gi`, sold as "Deadlock mods and config for smoother, clearer fights". Everything is
delivered through the site's **Pack Builder**: you tick options and it zips the paks plus a patched `gameinfo.gi`, or
installs them straight into the game folder in Chrome or Edge.

| Page | Content |
| --- | --- |
| `/` | Headline chart + Pack Builder (all data is JSON inside the page) |
| `/docs/benchmarks/` | Results and methodology |
| `/docs/cvars/` | A searchable dump of Valve's convar list (build 6844). No CompLock notes |
| `/docs/hitsound/` | Make your own hitsound VPK in the browser (by jcStani) |
| `/docs/privacy/` | No accounts, Cloudflare, **Google AdSense ads** |

There is no FAQ, changelog or downloads page. The domain was **registered 2026-11-01**, so the whole project is
about a week old. The Discord ("CompLock", about 1,440 members) is the only support channel.

What the Pack Builder offers (default picks in **bold**):

| Piece | What it does | Changes the look? | Site's number (CPU-limited) |
| --- | --- | --- | --- |
| **HUD++** (always) | Replacement HUD: cooldowns in seconds, team souls, boss timers, clean minimap, own crosshair. Damage numbers: vanilla / **cumulative** / hidden | Yes (different HUD) | +3.8% avg / +5.2% low |
| **gameinfo.gi** (always) | CompLock's engine settings, by HoppCX | Yes (see section 4) | +24.1% / +18.0% |
| **Sound stack update cap** | Playing sounds update ~60x per second (random 15-17 ms) instead of every frame | Claimed no | +6.7% / +6.3% |
| **Particle Pruning**, stock tracers | 4,550 effect files without glow, smoke, sparks; map loses fog, steam, street-light glow | Yes, a lot | +8.4% / +4.6% |
| Particle Pruning, reduced tracers | Same plus fainter tracers, no impacts, blood or headshot effects | Yes, more | +10.1% / +5.5% |
| Low detail map | 414 textures and 676 materials swapped for low-detail ones | Yes | +2.6% / +2.1% |
| Brighter lighting (by BreadRollius) | New post-process: no vignette or base bloom, no lamp/storm glow | Yes | +2.4% / +0.3% |
| Cloth simulation off | Removes coats, capes and skirts from 17 heroes, plus `cloth_update false` | Yes | +4.0% / +3.7% |
| Client physics off | `cl_phys_enabled false`, `cl_disable_ragdolls true`: no ragdolls, props frozen | Yes (Doorman ult issue, per the site) | +2.6% / +0.8% |
| jcStani's HP Bars | Flat health bars, stamina dots | Yes (HUD) | about 0 |

The default pack (HUD++, gameinfo, soundcap, Particle Pruning stock) is estimated by the builder itself at **+48.5%
average / +38.5% 1% low**. The +64.5% headline is "every option on".

## 2. Who is behind it, and where the source is

- **HoppCX** (performance work) has a GitHub account. Their repos were also published under the account name
  `itchyfeetleech`. Two of them matter here:
  - [Deadlock-Performance-Lab](https://github.com/HoppCX/Deadlock-Performance-Lab) is a Linux tool that replays the
    same match moment for each config and logs every frame with MangoHud. CompLock's benchmark is clearly built on it.
    Commits run from 2026-09-05 to 09-29. The later commits were written by an AI coding agent ("Claude") through
    pull requests. A September 100-convar screen was removed from the repo on 09-29. It is still in the git history,
    and section 3 uses it.
  - [deadlock-linux-optimizations](https://github.com/HoppCX/deadlock-linux-optimizations) (2026-10-28) is a set of
    Wine/Proton patches. Together they are worth +8.3% on their PC. **They are Linux-only and do nothing on Windows.**
- **jcStani** ("competitive features and vision") has no public repos. They has an X account and plays on EDL.gg.
- **No public repo for CompLock itself.** The gameinfo, the paks and the build scripts (`build.py`, `pack.toml`) are
  private, so there is no change history. The paks were written by an unpublished tool called "deadlock-fpsmaxing".
- **GameBanana:** CompLock is not listed there. The author of *Clutter Be Gone*
  ([GameBanana 722853](https://gamebanana.com/mods/722853)) says CompLock first bundled their mod, then stopped when asked
  to link to their page, and "used AI to recreate it", and that it isn't on GameBanana "due to heavy AI usage". That is
  one side of a dispute and has not been verified.
- **Relation to liv's compylock** (alz's base): every compylock commit is by 7liv (14 commits, 2026-10-04 to 10-10).
  None are by HoppCX or jcStani. Still, **37 of CompLock's 83 gameinfo changes also appear in compylock**. That
  includes liv's whole camera block, viewmodel/hair/ropes/grass off and the three fog switches. 30 have the same
  value, and 7 were retuned (far clip 7000, bilinear filtering, `r_particle_min_timestep 0.00833`, aspect 2.15, ...).
  compylock's README also warns against QOL Lock. The two clearly share a family tree, but nothing shows who copied whom.
- **Hype:** the "Deadlock Intel" X account posted on 2026-11-07 that CompLock would "nearly double your FPS" (about
  136k views). The site's own maximum is +64.5%, and only with every visual cut on.
- Name clash: the 2024 r/complock subreddit and "COMPLOCK" Discord are a different, unrelated competitive community.

## 3. How believable are the benchmarks?

### What they did (measured facts from the page, 2026-11-09)

| Item | Detail |
| --- | --- |
| PC | Ryzen 7 9800X3D, Radeon RX 9070, 32 GB, Arch Linux, Mesa RADV, **GE-Proton11-11 with HoppCX's Wine patches**, Vulkan, main game thread pinned to one core |
| Scene | **A replay of a public match**, its 5 busiest 6v6 fights, chase camera on one hero. 15 s warm-up, then 30 s measured per fight |
| Runs | Fresh game launch per measurement, 94 launches, 4.4 million frames. ABBA order (each round reversed) with batches interleaved, and a fitted drift curve over the 5.4-hour session |
| Noise | 4 baseline runs between 379.1 and 383.6 FPS (0.5% spread). The 1% lows spread 0.8% |
| Settings | **The same `video.txt` for every setup, vanilla included.** CPU-limited batch: render scale 40%, mostly low, GPU 60-66% busy. GPU-limited batch: 100% scale, default quality |
| Maths | Average FPS = frames / time. 1% low = mean of the slowest 1% of frames. 95% intervals shown on every number |

### What that means

- **Apples to apples on settings: yes.** The worry that vanilla ran on high settings is wrong for the current page.
  On 2026-11-05 the page even gave vanilla the menu's **lowest** preset while CompLock ran "low at 75%". That favoured
  vanilla, if anything.
- **Apples to apples on what is drawn: no.** The headline "CompLock" bar is every option at once: effects stripped,
  low-detail map, no cloth, no ragdolls, no bloom or vignette. Much of the +64.5% comes from drawing and simulating
  less, not from a smarter config.
- **Replay, not a real match.** In a replay your PC does not predict your own hero, does not send input and receives
  no live network traffic. Settings the server controls (`replicated`) may also behave differently in a replay than
  online. This matters because 21 of CompLock's lines are server-controlled. HoppCX's own September screen showed
  foot-locking off at about +2% in a replay. That does not prove it helps online.
- **One PC, one OS.** The patched Proton build changes how expensive the engine's per-frame system calls are. A 9800X3D
  at 300-500 FPS also turns tiny savings into big percentages. Use the site's "time saved per frame" column instead.
  Soundcap saves 161 µs per frame. On your PC that is roughly +4-6% at ~270 FPS and only about +1.5-2% at an 85 FPS
  1% low. That is my estimate, not a measurement.
- **The numbers move fast.** The gameinfo alone measured +3.4% in HoppCX's Proton repo (2026-10-28, an older gameinfo).
  It measured +19.6% on 11-05 and +24.1% on 11-09. The headline went from +43.8% to +64.5% in four days as options were
  added and render scale dropped from 75% to 40%. The gameinfo header says "for build 6844"; the test ran on 6860.
- **Verdict:** the per-mod numbers are trustworthy *for that PC, in replays*. They are the best evidence available that
  the sound cap, particle pruning and cloth removal do something. The headline is marketing: true, but it compares a
  stripped-down game with the full one.

## 4. The gameinfo.gi line by line

The file is Valve's stock 6860 `gameinfo.gi` with:
- **Current structure:** same `PGIVersion` as stock (and alz), BakedLighting `Version 5` with
  `directional_irradiance_sh2_lum`. Nothing outdated.
- **Engine sections:** only `SceneSystem` changes, `NonTexturedGradientFog`, `CubemapFog` and `VolumetricFog` all set
  to `0`. **alz has the same three.** CompLock makes 3 edits in Valve's guarded sections; alz makes about 20.
- **SearchPaths:** explicit `Mod citadel` / `Write citadel`, then `Game citadel/addons`, `Game citadel`, `Game core`.
  It has no `Mod`/`Write core` and **no Deadlock Mod Manager markers**.
- **`UserSettingsPathID "USRLOCAL"` is commented out.** The game then reads settings, `video.txt` included, from the
  game folder instead of Steam's userdata folder. CompLock's methodology page confirms this. Your menu settings would
  seem to "reset". alz keeps the stock line, and should.
- **80 changed or added convars.** None are missing from the game, and none are blocked by `gameinfo_cannot_override`.

| Verdict | Count | Lines |
| --- | --- | --- |
| Already in alz, same value | 25 | camera block (`citadel_camera_height 0`, `pitch_default 0`, `listening_offset -1`, `wobble_disable`, `flatten_horizontal false`, `see_distance_max 7000`, `rpg_camera_yaw 0`), `r_citadel_clip_sphere_min_opacity 0`, `r_drawviewmodel`, `r_render_hair`, `r_drawropes`, grass x3, `r_world_wind_strength 0`, `sc_clutter_enable`, `cl_show_splashes`, `cc_captiontrace`, `r_character_decal_resolution`, `v8_maximum_heap_size_mb`, texture budget x2, `sc_instanced_mesh_motion_vectors 0`, `ik_final_fixup_enable`, `citadel_trooper_glow_disabled 0` |
| In alz with another value | 6 | `r_particle_min_timestep` 0.00833 (alz 0.00241), `r_farz` 7000 (-1), `r_mapextents` 7000 (16384), `r_texturefilteringquality` 0 (5), `r_aspectratio` 2.15 (2.4), `props_break_max_pieces_perframe` 0 (1) |
| **Server-controlled (replicated): very likely no effect online** | 21 | 8 `ik_*`, 8 `animgraph_footlock_*` / `slowdownonslopes`, `skeleton_instance_lod_optimization`, `ik_final_fixup_enable`, `props_break_max_pieces_perframe`, `citadel_camera_see_distance_max`, `rpg_camera_yaw`. The animation ones would also make feet slide if they did apply |
| Restates the default / clamped / pointless with other lines | 9 | `cloth_update true`, `citadel_damage_offscreen_indicator_disabled true`, `citadel_trooper_glow_disabled 0` (defaults). `r_character_decal_resolution 4` (raised to the 256 minimum). `r_haircull_percent`, `r_hair_indirect_transmittance` (hair is off), `r_ropetranslucent` (ropes are off), `sc_clutter_density_*` x2 (clutter is off) |
| Menu/user setting | 1 | `citadel_damage_text_cumulative_mode 1`. The in-game damage-number option wins once you save it |
| HUD, camera or gameplay, not FPS | 10 | `citadel_boss_glow_disabled 1` (bosses lose their glow), `citadel_damage_indicator_*` x3 (tiny hit-direction marker), `audio_viewing_damage_*` x2, `default_fov 0`, `viewmodel_fov 0` (alz dropped these for clashing with FOV mods), `citadel_action_refresh_interval 0.11`, `r_aspectratio` |
| **Cost visuals** | 9 | `r_farz`/`r_mapextents 7000` (distant pop-in), `r_texturefilteringquality 0` (blurry floors), `r_morphing_enabled false` + `r_smooth_morph_normals 0` (no face/shape morphs), `fx_drawmetalspark false`, `r_particle_min_timestep 0.00833` (particles update at most 120x/s; alz-experimental already removed the old value for "jagged particles"), `r_monitor_3dskybox 0`, `r_impacts_alt_orientation false` (undocumented) |
| **Zero-visual client work that alz lacks** | 9 | `cl_generate_postdataupdatepreserved false`, `panorama_min_comp_layer_cache_cost 0`, `panorama_comp_layer_lru_lifetime 4`, `rope_collide 0`, `rope_wind_dist 0`, `wind_system_default_resolution_xy 0`, `wind_system_temporal_smoothing false`, `r_world_wind_frequency_grass 0`, `r_world_wind_frequency_trees 0` (the last six are only zero-visual because alz already hides ropes and has wind at 0) |
| Small extra | 1 | `r_character_decal_monitor_render_res 64` (a decal monitor texture, tiny) |

Rows overlap: for example, `rpg_camera_yaw` is both "already in alz" and "server-controlled".
The 9 zero-visual lines were never measured on their own. HoppCX's September 100-convar screen didn't include them.
In that screen anything under about +2% was within noise.

Pack Builder extras: `citadel_unit_status_healthbar_highlight_speed "100"` (default 2) goes into every pack. It most
likely makes the health-bar damage highlight finish instantly, which is a small HUD change. Undocumented.
`citadel_damage_text_batching_window_individual "2"` (default 0) merges hits within 2 s into one number. It goes with
HUD++.

**Why it says "not compatible with QOL Lock or other mods":**
1. HUD++ replaces 206 HUD files (styles, scripts, minimap, crosshair). QOL Lock and every HUD, minimap or crosshair mod
   touch the same files.
2. Particle Pruning replaces 4,550 effect files, so any effect, ability or skin mod collides with it. The pack's own
   `mods.txt` says "a lower number wins", and CompLock takes the lowest numbers (pak01-07).
3. No Cloth replaces hero models (the site warns about this itself).
4. The installer rewrites `gameinfo.gi` without DMM markers and moves the settings folder.
5. `default_fov 0` / `viewmodel_fov 0` clash with FOV mods.
6. Every replacement file is a frozen copy of Valve's file as of ~2026-11-07. After a patch that touches those files, a
   stale copy can break or roll back effects and sounds.

## 5. What this means for alz and alz-experimental

Your rule is more FPS with the same or better visuals. Your PC is a 5700X + RTX 5070 at 1440p with DLSS, CPU-limited
in fights, with mods through DMM (including the sinners light fix).

### Worth testing (zero visual change)

**A. Sound stack update cap mod** (biggest and cleanest lead)
- What: one file, `soundstacks/soundstacks_citadel_base_3d.vsndstck_c`, adds a random 15-17 ms wait to how often each
  playing 3D sound recomputes volume, position and filters. Sounds still start instantly.
- Evidence: +6.7% average / +6.3% 1% low and 161 µs per frame (11-09). +2.4% / +2.6% on 11-05 in a single fight.
  Both batches were replays on the 9800X3D.
- How: on the Pack Builder, use the Sound stack update cap row's own download. Don't download the whole pack. Add the
  file through DMM if it lets you import a local VPK. Otherwise put it in `game/citadel/addons` under a pak number DMM
  doesn't use. Check that nothing else you run replaces that same file (hit-sound mods replace sound files, not
  stacks, so they're fine).
- Risk: after every Deadlock patch, check whether Valve changed that stack. If they did, remove the mod until CompLock
  updates it. Listen once for distance/positional oddities in a fight.

**B. Zero-visual convars (tag `[cl1]`, alz-experimental `ConVars`)**
```
        cl_generate_postdataupdatepreserved   "false"  //[cl1] CompLock: skip update callbacks for entities that didn't change
        panorama_min_comp_layer_cache_cost    "0"      //[cl1] CompLock: let the UI cache every composition layer
        panorama_comp_layer_lru_lifetime      "4"      //[cl1] CompLock: keep cached UI layers 4 s (default 1)
        rope_collide                          "0"      //[cl1] ropes are already hidden (r_drawropes false)
        rope_wind_dist                        "0"      //[cl1]
        wind_system_default_resolution_xy     "0"      //[cl1] wind strength is already 0
        wind_system_temporal_smoothing        "false"  //[cl1]
        r_world_wind_frequency_grass          "0"      //[cl1]
        r_world_wind_frequency_trees          "0"      //[cl1]
```
- These are expected to be small (likely under 2% together, a guess). Test them as a bundle. If the bundle wins, keep
  it. If it loses, split it: `cl_generate_postdataupdatepreserved` alone, then the two panorama lines, then rope/wind.
- Watch for: anything that stops updating while it stands still, such as a hero's state or effects on idle entities
  (`cl_generate_postdataupdatepreserved`). Also watch for UI glitches or VRAM creep in long sessions (panorama caching).

### Your call: different HUD

**C. HUD++** (+3.8% / +5.2%, damage-number variants up to +5.4% 1% lows while shooting). It's a better-informed HUD
for many players, but it's a *different* HUD, it conflicts with any HUD mod, and it needs updating after every
HUD patch. If you want just the damage-number part without HUD++, set *cumulative damage numbers* in the game's own
settings (`citadel_damage_text_cumulative_mode`). That is the menu option, so you don't need a gameinfo line.

### Costs visuals (reject under alz's rule)

Particle Pruning (both versions), Low detail map, Brighter lighting (alz already has bloom off in `video.txt`, so less
gain anyway), Cloth simulation off, Client physics off (alz-experimental just fixed Doorman's ult indicator; this
brings back a Doorman issue), `r_morphing_enabled false` (+2.1% in the September screen, within noise),
`r_smooth_morph_normals 0`, `fx_drawmetalspark false`, `r_farz`/`r_mapextents 7000`, `r_texturefilteringquality 0`,
`r_particle_min_timestep 0.00833`, `r_monitor_3dskybox 0`, `citadel_boss_glow_disabled 1`.

### Placebo or no effect for alz (rejected)

- All 21 server-controlled lines (`ik_*`, `animgraph_*`, `skeleton_instance_lod_optimization`, ...). They likely do
  nothing online, and would make feet slide if they did.
- The 9 default, clamped or already-hidden lines in the table above.
- `default_fov 0` / `viewmodel_fov 0` (alz removed these on purpose).
- Commenting out `UserSettingsPathID`: it only moves your settings file and breaks the README's install steps.
- `sc_instanced_mesh_motion_vectors 0`: alz-experimental turned motion vectors back on for DLSS. CompLock doesn't use
  DLSS, so its choice doesn't apply to you.
- CompLock's "+24.1% gameinfo" does **not** carry over to alz. alz already has the fog switches and most of the
  shared liv-lineage lines. The remaining big pieces are either server-controlled or cost visuals.
- The Proton/Wine patches and the "Vulkan has better 1% lows" finding are Linux results. On Windows, keep the repo's
  DX11-vs-Vulkan A/B advice.

## 6. Test plan (fixes the problem with your earlier sessions)

The earlier "-40 FPS experimental" result was confounded by DLAA. The Street Brawl session (alz-experimental 232/69
vs alz 271/85) was one session in a different mode. Neither can detect a 2-5% change. Copy CompLock's method instead:

1. **Use a replay, not live games.** Download one replay of a busy match and note 2-3 big fights (tick numbers via
   `demo_info` or the replay timeline). Launch with `-novid -console` (and `-insecure` only for the replay sessions).
   Use the same `video.txt` and DLSS 1.7x for both configs.
2. In the console: `fps_max 0`, `playdemo replays/<match>.dem`, then for each fight `demo_gototick <tick - 15 s>`,
   `spec_player <n>`, `spec_chase`, `demo_resume`. The demo plays at 64 ticks per second, so 15 s = 960 ticks.
3. Capture 30 s after a 15 s warm-up with CapFrameX or PresentMon (average FPS and 1% low).
4. **Fresh launch each run, ABBA order:** alz, exp, exp, alz, alz, exp, exp, alz (8 launches minimum). Swap only
   `gameinfo.gi` and the addons being tested.
5. Decide: if the alz runs differ from each other by more than 1%, add rounds. Keep a change only if its gain beats the
   alz-vs-alz spread on both average and 1% low.
6. Order: test **A (soundcap)** on top of alz first, then **B** as a bundle, then C if you want it. Afterwards, confirm
   in two or three real matches that nothing looks or sounds off. Don't use real matches for the FPS number itself.

## 7. Rejected list (one line each)

| Item | Why rejected |
| --- | --- |
| Whole CompLock pack / installer | Overwrites gameinfo, takes pak01-07, conflicts with DMM mods, moves `video.txt` location |
| CompLock `gameinfo.gi` as a base | Same structure as alz, but alz already has the useful parts. Its additions are server-controlled or visual cuts |
| Particle Pruning | Removes glow, smoke, sparks and map ambience (visual). 4,550 files, mod conflicts, goes stale after patches |
| Low detail map | Lower-detail textures and materials (visual) |
| Brighter lighting | Different post-process look; alz already has bloom off |
| Cloth simulation off | Removes clothing from 17 heroes; conflicts with model mods |
| Client physics off | No ragdolls or debris; Doorman ult issue |
| `ik_*`, `animgraph_*` (16 lines), `skeleton_instance_lod_optimization` | Server-controlled; foot sliding if applied |
| `r_farz`/`r_mapextents 7000` | Distant buildings and players pop in |
| `r_texturefilteringquality 0` | Blurry textures at an angle; about 0.4% in the September screen |
| `r_morphing_enabled false`, `r_smooth_morph_normals 0` | Removes shape morphs; gain within noise |
| `r_particle_min_timestep 0.00833` | Particle motion steps at 120x/s; alz-experimental already moved away from this cvar |
| `fx_drawmetalspark false`, `r_monitor_3dskybox 0`, `citadel_boss_glow_disabled 1` | Visual or gameplay-visibility changes |
| `default_fov 0`, `viewmodel_fov 0` | FOV-mod conflicts (already removed in alz) |
| Commenting out `UserSettingsPathID` | Moves where settings are read from; no FPS |
| Restated defaults / clamped (`cloth_update true`, offscreen indicator, `r_character_decal_resolution 4`) | No effect |
| Proton/Wine patches | Linux only |

## Sources

- deadlockconfig.com home, Pack Builder data and `pack.js`, `/docs/benchmarks/`, `/docs/cvars/`, `/docs/hitsound/`,
  `/docs/privacy/` (fetched 2026-11-09; 11-05 benchmark version via Exa's cache). Pack Builder rendered in Chromium.
- CompLock paks from `/dl/pack/` (soundcap, brighterlighting, hpbars, particlepruning_stocktracers, hud), inspected for
  file lists and modinfo.
- Valve: [SteamDatabase/GameTracking-Deadlock](https://github.com/SteamDatabase/GameTracking-Deadlock) at build 6860
  (stock `game/citadel/gameinfo.gi`, `DumpSource2/convars.txt`); local build 6821 dump for the diff.
- [HoppCX/Deadlock-Performance-Lab](https://github.com/HoppCX/Deadlock-Performance-Lab) (incl. the removed 2026-09-06
  100-convar screen, commit 6e1433e^), [HoppCX/deadlock-linux-optimizations](https://github.com/HoppCX/deadlock-linux-optimizations).
- [7liv/compylock](https://github.com/7liv/compylock) commit history and gameinfo.
- [Clutter Be Gone on GameBanana](https://gamebanana.com/mods/722853) (author's statement about CompLock).
- Deadlock Intel post on X, 2026-11-07. Discord invite metadata. RDAP domain record.
- DMM perf catalog (local copy from 2026-10-27) for cvar descriptions.
