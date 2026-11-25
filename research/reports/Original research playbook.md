# Original research playbook: how to find Deadlock FPS wins nobody has shipped yet

Researched 2026-11-25 against Deadlock build 6868 (SteamDatabase GameTracking dump). Research only: no cfg file was
changed. Goal: learn how CompLock (HoppCX, jcStani) and others find new optimizations, and turn that into a plan alz
can run on their own PC (Ryzen 7 5700X, RTX 5070, 1440p, DLSS 1.7x, DX11). The metric that matters most is the
**fight-time 1% low**.

## Headline

- **CompLock's wins come from a method, not from secret knowledge.** Every one of their big zero-visual wins uses the
  same trick: find work the game redoes **every frame** that only needs to happen at **tick rate** (~60 Hz), and cap
  it. The sound stack cap (sound positions at 15-17 ms instead of every frame, +11.1% 1% low), HUD++'s 30 Hz cached
  repaint (+8.1%), and Particle Pruning's `m_flMinimumTimeStep` at 30 Hz on decoration all follow it. At 200-400 FPS
  the game does the same per-frame work 3-6 times per server update, so anything that can be decoupled from frame
  rate is a candidate.
- **They find candidates by profiling and by reading game files, then prove them with a strict A/B harness.**
  The harness is public ([Deadlock Performance Lab](https://github.com/itchyfeetleech/Deadlock-Performance-Lab), Linux
  only). The method is published on [deadlockconfig.com/docs/benchmarks](https://deadlockconfig.com/docs/benchmarks/).
  The mod build tool ("deadlock-fpsmaxing") is private.
- **alz can do the same on Windows** with free tools: replays plus PresentMon for measuring, Windows Performance
  Recorder / AMD uProf / Superluminal for finding where CPU time goes, Source 2 Viewer CLI for reading and diffing
  game files, and the community CSDK 12 `resourcecompiler` for building paks.
- **The best untried leads for alz** (section 5): a CPU profile of a team fight replay (to rank subsystems),
  extending the update-cap idea to the other sound stacks, a "timestep only" particle pak that keeps every effect,
  Valve's own stock `sc_layer_batch_threshold_fullsort 20` vs the code default 80, and a screen of Valve's
  off-by-default optimization switches.
- **Biggest risk is measuring wrong, not getting banned.** A 3-match live comparison cannot detect a 3% change. Build
  the replay harness first; use live matches only to confirm.

## 1. How CompLock actually finds and proves things

| Step | What they do | Evidence |
| --- | --- | --- |
| Pick a hard scene | A public match replay, its 5 busiest 6v6 fights, chase camera on one hero | Benchmarks page |
| Make it CPU-bound | Low settings (render scale 40% earlier), GPU 58-65% busy | Benchmarks page |
| Isolate each change | "Test each setting separately": one config per convar/mod. `dpl profile sweep tests.csv` makes one config per `id,cvar,value` row | DPL README |
| Remove run order bias | Fresh game launch per run, ABBA order, a quadratic drift curve fitted over the 5.9-hour session | Benchmarks page |
| Do the maths right | Mean of log FPS per launch, 1% low = 1000 / mean of the slowest 1% of frame times, 95% interval from a t-distribution; a result is "real" only if its interval excludes 0 | Benchmarks page |
| Report time, not % | "Time saved per frame" column (soundcap: 225 µs) | Benchmarks page |
| Find new targets | A 100-convar screen in September (later deleted from DPL's repo, still in git history); then asset-level edits once the convar space was exhausted | Earlier report ([CompLock report](CompLock%20deadlockconfig%20com.md)) |
| Ship as small paks | Each idea is one replacement file where possible: soundcap is **one** file, `soundstacks/soundstacks_citadel_base_3d.vsndstck_c`, with new `update_rate_rand` and `update_rate_cap` operators | Earlier pak listing |

Their noise floor on a 9800X3D under Linux: baseline SD 0.7% for average FPS and about 1.1% for 1% lows. A 1% low
change smaller than about 2% is not measurable even for them.

What their changelog shows about where they looked next (all Nov 2026): HUD repaint rate (18 Nov), the stat panel
only existing while it's visible (18 Nov), 1,708 particle layers hand-emptied (18 Nov), camera soft collision traces
off (18 Nov: `citadel_camera_soft_collision 0`, `..._multi_thread 0`, the camera fires 128 traces per frame for it),
`sc_layer_batch_threshold_fullsort` 20 to 80 (18 Nov). In other words: **per-frame CPU work in HUD, sound, particles,
camera and scene sorting.** That list is a map of where the CPU time goes.

## 2. Tooling

### 2a. Measuring (Windows)

| Tool | Use | Notes |
| --- | --- | --- |
| **PresentMon** (Intel, free, CLI) | Logs every frame of `deadlock.exe` to CSV | Use the present-to-present frame time column. Same role as MangoHud in CompLock's setup |
| **CapFrameX** (free) | Wraps PresentMon, shows 1% low two ways | "1% low average" (CompLock's definition) and "1% low integral". Pick one and never mix |
| `timedemo`, `timedemoquit`, `timedemo_start`, `timedemo_end` | All `release` convars in build 6868: "Play a demo and report performance info", start/end on given ticks | **Untested on Deadlock replays.** First thing to try; if it prints nothing useful, use `playdemo` + PresentMon |
| `playdemo`, `demo_gototick`, `demo_pause`, `demo_resume`, `demo_timescale`, `demo_quitafterplayback` | All `release` | What CompLock uses. Replays live in `citadel/replays/<match>.dem` |
| `cl_showfps 4` | `release`: "Show FPS and Log to file" | Rough cross-check only |
| `-condebug -vconsole -insecure -novid` | Launch options CompLock uses for bench runs | `-insecure` = VAC off for that launch; it can't queue, so it's for replay runs only |

### 2b. Finding where the time goes (the part nobody in the Deadlock scene publishes)

CompLock never says how they picked sound stacks as a target. A sampling profiler answers that directly:

| Tool | Why |
| --- | --- |
| **Windows Performance Recorder + Analyzer** (built into Windows) | Records CPU samples per thread and per DLL. Even without Valve's symbols you see **which module** eats the main thread: `client.dll`, `soundsystem.dll`, `panorama.dll`, `particles.dll`, `scenesystem.dll`, `animationsystem.dll`, `rendersystemdx11.dll`. That ranks the subsystems |
| **AMD uProf** (free, fits the 5700X) | Same, with hardware counters (cache misses), useful for the "main thread waits on memory" question |
| **Superluminal** (paid, trial) | The friendliest view of per-thread hot paths and waits |
| **NVIDIA Nsight Systems** (free) | CPU threads and DX11 submission on one timeline: shows if a frame was CPU- or GPU-bound and where the main thread blocked |

Game-side profilers exist but are locked: `vprof_on`, `vprof_generate_report`, `vprof_generate_report_budget`,
`engine_frametime_print_report` ("vprof 'lite' profiler"), `particle_profile`, `particle_profile_spike`,
`panorama_show_fps` are all `developmentonly defensive`. In CS2, `defensive` commands open up when
`DefensiveConCommands` is 0; Deadlock's stock `gameinfo.gi` sets `DefensiveConCommands 1` in the **Engine2** section,
which is on Valve's matchmaking-check list. So: **use a separate research-only `gameinfo.gi`** with
`DefensiveConCommands 0`, for replay runs only, and swap the real one back before playing. Whether the retail
binaries still print VProf data is **unverified** (`engine2.dll` does contain `CVProfService` and a
`CMsgSource2VProfLiteReport` message, which is a good sign). If `particle_profile` works, it names the most
expensive particle systems directly, which beats guessing.

### 2c. Reading and building game files

| Tool | Use |
| --- | --- |
| [Source 2 Viewer](https://s2v.app/ValveResourceFormat/guides/vpk-management.html) (VRF) GUI + CLI | Browse `pak01_dir.vpk`, decompile (`Source2Viewer-CLI -i pak01_dir.vpk -d -o out -f <paths>`), build VPKs (`--vpk_create`) |
| [Source 2 Schema Explorer](https://s2v.app/SchemaExplorer/deadlock/particles) | Every particle operator and field, e.g. `m_flMinimumTimeStep`, `m_flMaximumTimeStep`, `m_bShouldSort`, `m_flMaxDrawDistance`, `m_flCullRadius`, `m_nMaxParticles` |
| CSDK 12 `resourcecompiler.exe` | The community "Reduced_CSDK_12" toolset; recompiles edited `.vsndstck`, `.vpcf`, `.vcss`, `.vxml` |
| [deadlock-modbox](https://github.com/rszyma/deadlock-modbox) / DiffMod spec | Mods as `.patch` files over decompiled game files, rebuilt per game build. Best way to keep a perf pak alive across Valve patches |
| [GameTracking-Deadlock](https://github.com/SteamDatabase/GameTracking-Deadlock) | Every build's convar dump, schemas, strings and decompiled scripts. `git log -p` on a file shows what Valve changed |
| VRF on someone else's pak | Decompile a published mod and diff it against stock to learn the technique (how soundcap was done is readable this way). Learn from it; don't redistribute their files |

## 3. Methodology for alz's PC

1. **Scene.** Download 1-2 recent high-elo replays. Pick 3-5 of the busiest fights (lots of heroes, ults, troopers).
   Note the start ticks. Same replay for every test until the game build changes (a patch can break old replays).
2. **One launch per run.** Close the game between runs. Shader caches and memory state persist inside a session and
   bias the second run.
3. **Warm up 15 s, measure 30 s** per fight, like CompLock. Lock `fps_max 0`, same `video.txt` for all setups.
4. **ABBA order** across rounds; at least 3 baseline runs spread through the session to catch drift (thermals,
   background tasks).
5. **Statistics.** Per run: mean of log(FPS) over fights; 1% low = 1000 / mean of slowest 1% frame times. Compare
   setups with a t-interval. Rough run count: `n ≈ 16 × (SD / effect)²` per setup for 95% confidence and 80% power.
   With a 2% run-to-run SD, finding a 2% effect needs ~16 runs per setup; a 4% effect needs ~4.
6. **Measure the noise floor first.** Run the baseline 8 times. If 1% low SD is above 3%, fix the environment
   (background apps, power plan, Discord overlay, browser) before testing anything.
7. **Screen in replays, confirm live.** Replays don't do prediction, input or live networking, and the server
   owns `replicated` convars online. A replay win on a `replicated` line proves nothing for real matches.
8. **Log everything** in the README experiment log: build, driver, setups, n, mean change, interval.

A small Python script can do steps 2-5: swap files, start Steam with `-insecure -novid -condebug +exec bench`,
start PresentMon for N seconds, kill the game, restore files, repeat in ABBA order, then compute the table. That is
DPL rebuilt for Windows, and it would also fit naturally as a "Benchmark" tab in deadlock-config-manager later.

## 4. Where new wins are likely (the search space)

Deadlock is CPU-bound in fights on alz's PC, so the targets are main-thread work that scales with **entities on
screen** or with **frame rate**:

| Area | Why it costs | Who has worked it | Untouched angle |
| --- | --- | --- | --- |
| Sound | ~80 sounds re-spatialised every frame in fights | CompLock capped the 3D base stack only | The other `soundstacks/*.vsndstck_c` files (2D/UI, VO, ambient, music, any per-hero stacks) |
| Particles | Simulated and sorted every frame | Particle Pruning deletes layers (visual cost) | Keep every layer, only cap sim rate (`m_flMinimumTimeStep`) on decoration; turn off sorting (`m_bShouldSort`) on purely additive systems, where draw order cannot change the result |
| Panorama world panels | Health bars over every trooper and hero | jcStani's HP bars (perf-neutral), HUD++ | Measure stock health-bar cost per unit first; `panorama_worldpanel_update_culling` is out (hides info) |
| Camera | 128 traces per frame for soft wall collision | CompLock turned it off (feel change, `replicated`) | `citadel_camera_soft_collision_multi_thread` (non-replicated, default 8 jobs): test values, keep the feature |
| Scene sorting | Translucent layer batching | Valve's stock block sets `sc_layer_batch_threshold_fullsort 20`; the code default is 80; CompLock moved to 80 on 18 Nov as part of a "performance update" | apex keeps Valve's 20 (alz's old 120 was silently overridden by it). Clean A/B: 20 vs 80 |
| Valve's off-by-default switches | Valve leaves some optimizations off | Partly screened (QoLLock report) | `net_skip_redundant_change_callbacks` (default false), `citadel_visibility_queue_rate` (2), plus the ~197 client convars not in apex whose names contain update/rate/interval/budget/lod/thread/cache/batch/skip/throttle |
| Shader and streaming hitches | Hurt 0.1% lows more than 1% lows | Little measured | Compare first fight after launch vs later fights; driver shader cache size; `r_texture_stream_throttle_*` |
| OS scheduling | HoppCX pins the main thread to one core on Linux | Not measured on Windows | Process priority, affinity / CPU sets, timer resolution, Game Mode. On a single-CCD 5700X the gain is probably small, but it is cheap to test with the harness |
| Unsearched `gameinfo.gi` sections | Only 7 sections are on the matchmaking list | — | `SoundSystem` (`WaveDataCacheSizeMB 256`, `SteamAudioEnabled`) and `Sounds` are not on the list. A bigger wave cache could cut load hitches; Steam Audio off changes positional audio (info), so out |

## 5. Prioritized roadmap

Ranked by expected 1% low value × effort × fit with alz's rule ("same or better visuals, nothing hidden").
Don't touch active apex lines until the apex vs alz baseline (started 2026-11-21) is finished.

| # | Experiment | Effort | What it gives | Fits the rule? |
| --- | --- | --- | --- | --- |
| **1** | **Build the Windows replay harness** (section 3) and measure the noise floor: 8 baseline runs | 1-2 evenings | Everything below depends on it. Turns 3-match guesses into ±1-2% answers | n/a |
| **2** | **Profile a team fight replay** with WPR or uProf, main thread, by module. Repeat with soundcap on/off to validate that the profiler sees a known 225 µs win | 1 evening | A ranked list of subsystems. This is how the next soundcap gets found instead of guessed | n/a |
| **3** | **`sc_layer_batch_threshold_fullsort` 20 vs 80** (Valve's stock line vs the code default) | 1 hour with the harness | One clean answer on a line CompLock changed in a perf update | Yes: no visual change expected |
| **4** | **Soundstack audit.** Decompile every `soundstacks/*.vsndstck_c` with VRF; find the ones running per-frame spatial/volume operators; decompile CompLock's soundcap to see their exact operator chain; apply the same cap to the next-busiest stack | 2-3 evenings | Possibly another few % on 1% lows, stacking with soundcap. Original work | Yes if sounds still start instantly and positions stay right. Footsteps/enemy cues: listen-test so nothing gets later or quieter |
| **5** | **"Timestep only" particle pak**: keep every layer, set `m_flMinimumTimeStep` 1/30 s on map decoration (steam, smoke, lamp glow, dust) and `m_bShouldSort false` on purely additive systems | 3-4 evenings | Part of Particle Pruning's gain without deleting anything. Useful for alz/stable users who won't run Pruning | Mostly: 30 Hz decoration can look slightly choppy on close inspection; ship as `[test]` |
| **6** | **Off-by-default switch screen**: `net_skip_redundant_change_callbacks true`, `citadel_visibility_queue_rate`, `citadel_camera_soft_collision_multi_thread` values, then the keyword shortlist, one config per line | Harness time, mostly unattended | Each line gets a measured answer; most will be 0 | Only non-`replicated`, non-visual lines. Anything that "caches values" (like `cl_modifier_value_cache_enabled`) also needs a correctness check |
| **7** | **Game-side profilers**: research-only `gameinfo.gi` with `DefensiveConCommands 0`; try `vprof_on` / `vprof_generate_report_budget`, `particle_profile`, `panorama_show_fps` in a replay | 1 evening | If they work: per-system and per-particle costs straight from the engine | Research file only, never for matches |
| **8** | **Hitch hunting for 0.1% lows**: first fight vs later fights; shader cache size; texture stream throttle | 1-2 evenings | Fewer big spikes | Yes |
| **9** | **Windows scheduling**: priority, affinity, CPU sets, Game Mode, timer resolution | 1 evening | Probably small on a 5700X | Yes |
| **10** | **Health bar cost**: replay with many troopers, stock vs jcStani bars vs HUD++, profiler on `panorama.dll` | 1 evening | Tells whether a perf-only health bar pak is worth making | Must keep every number and bar the stock game shows |

How to ship what works: one small pak per idea (`pakNN_dir.vpk`, built from a DiffMod patch), installed through DMM so
it coexists with HUD++, Particle Pruning and soundcap. The `SearchPaths` block stays as it is. Add each measured
result to the README experiment log and the per-variant NOTES.

## 6. Risks and rules

| Risk | What is known | What to do |
| --- | --- | --- |
| **VAC / account** | Valve has published no mod policy. The Steam store shows no VAC label; Valve's patch notes mention "improved anti-cheat". No confirmed ban for cosmetic or perf VPKs. Valve can close accounts for unfair advantage (Steam Subscriber Agreement), and 2024 reports say playtest bans also hit invited friends | VPKs that only replace game assets are the community's accepted space. Never inject code, hook the process, or read memory while the game is live. Profilers in section 2b attach to replay runs only, with `-insecure` |
| **Matchmaking block** | Since build 6417 the queue refuses Tools mode and changes to Engine2, MaterialSystem2, NetworkSystem, Particles, RenderSystem, SceneSystem, WorldRenderer. Not enforced today | Research-only `gameinfo.gi` (`DefensiveConCommands 0`, `-tools`) for offline runs; restore the normal file before queueing |
| **Information hiding** | Community guides (Divine Skins, GameBanana norms) treat removed smoke/fog/effects, brighter lighting, timers and louder cues as advantage mods. alz's own rule already excludes them | Every new pak gets a "does it show or hide anything the stock game doesn't" check. Particle work keeps shapes, areas and warnings; sound work keeps start time and loudness |
| **Server-owned convars** | `replicated` lines can work in replays and do nothing online | Never ship a `replicated` line on replay evidence alone |
| **Patch breakage** | Valve patches often; full-file replacements silently hide Valve's fixes (e.g. a new ability's sound in a replaced stack) | DiffMod patches, rebuild every build, diff the stock file in GameTracking before rebuilding |
| **Credit and licence** | CompLock's paks and tool are private; DPL is GPL-3.0 | Learn techniques from their published files, write your own; credit HoppCX/jcStani for the method. Reusing DPL code means GPL-3.0 for that code |
| **Fooling yourself** | 3 live matches can't detect a 3% change. 1% low definitions differ between tools | Section 3 rules; one 1% low definition everywhere |

## Sources

- CompLock: [benchmarks and methodology](https://deadlockconfig.com/docs/benchmarks/) (build 6861, 2026-11-16),
  [changelog](https://deadlockconfig.com/docs/changelog/), [install guide](https://deadlockconfig.com/docs/guide/),
  [CVAR Index](https://deadlockconfig.com/docs/cvars/)
- [Deadlock Performance Lab](https://github.com/itchyfeetleech/Deadlock-Performance-Lab) (HoppCX, GPL-3.0),
  [deadlock-linux-optimizations](https://github.com/HoppCX/deadlock-linux-optimizations)
- [GameTracking-Deadlock](https://github.com/SteamDatabase/GameTracking-Deadlock), build 6868: `DumpSource2/convars.txt`,
  `commands.txt`, `schemas/particles`, stock `game/citadel/gameinfo.gi`, `engine2_strings.txt`
- Source 2 Viewer: [VPK guide](https://s2v.app/ValveResourceFormat/guides/vpk-management.html),
  [Deadlock files](https://s2v.app/ValveResourceFormat/games/deadlock.html),
  [particle schema](https://s2v.app/SchemaExplorer/deadlock/particles)
- [deadlock-modbox](https://github.com/rszyma/deadlock-modbox) (DiffMod builds with CSDK 12 resourcecompiler)
- [Divine Skins wiki: what's allowed](https://wiki.divineskins.gg/en/docs/deadlock/getting-started/stay-safe),
  [update-after-a-patch](https://wiki.divineskins.gg/en/docs/deadlock/publishing/update-after-a-patch)
- [Steam Dashboard: is modding allowed](https://steamdb.com/en/deadlock/how-to-install-skins) (2026-11-16),
  [howtovideogame: ban risk](https://howtovideogame.com/deadlock-mods-ban/) (2026-11-11)
- [CapFrameX: performance metrics explained](https://www.capframex.com/blog/post/Explanation%20of%20different%20performance%20metrics),
  [PresentMon percentile discussion](https://github.com/GameTechDev/PresentMon/issues/219)
- Earlier reports in this repo: [CompLock](CompLock%20deadlockconfig%20com.md),
  [QoLLock test branch and free FPS](QoLLock%20test%20branch%20and%20free%20FPS.md),
  [Convar review r2](Convar%20review%20r2.md)
