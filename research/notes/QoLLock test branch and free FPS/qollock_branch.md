# QoLLock (QOLLOCK) and its test branch: what they are cooking up (checked 2026-10-27)

Method: `git ls-remote` and a blobless clone of github.com/civo7/QOLLOCK (all 30 branches plus PR refs 1-68), its forks
Kholk3r/QOLLOCK and Specter10117/QOLLOCK, web search, and Valve's convar dump from SteamDatabase GameTracking-Deadlock
build **6821** (commit `d251cf9`, 2026-10-26 20:03 UTC; `steam.inf` ClientVersion=6821). The 6801 dump was used for
comparison. In this session GitHub search/API calls were blocked (403, "sessions are bound to their configured
repositories"). GameBanana was unreachable (DNS failure and proxy 403), and the Discord is not public. Branch and commit
data come from git, so they are exact. Release-page and Discord content is a gap.

## Which project is "QoLLock", who maintains it, what main ships, and where the test branch is

### Takeaway
"QoLLock" is **QOLLOCK / "QOL Lock"**, a Panorama **HUD and quality-of-life mod** (a VPK with XML, CSS and JS). It is
**not** a `gameinfo.gi`/`video.txt` FPS config, and it is not part of Sqooky's OptimizationLock family or liv's compylock.
No branch has "test" or "community" in its name. The live test branch is **`codex/customize-main`**: 222 commits not on
main, of which about 78 are a burst by Predi-i between 2026-10-21 and 2026-10-25. A big part of that burst is HUD-script
CPU optimization (only offline operation counts, nothing measured in FPS) plus fixes for the build 6790/6801 ammo HUD.

### Cited Findings
- Repo `civo7/QOLLOCK`, README: "A customizable HUD and quality-of-life mod for Deadlock." Downloads are on GitHub
  Releases and GameBanana mod 650634, as `QOL-Lock-405.zip` with a compiled VPK. The licence is Apache-2.0. There is a
  Discord, `discord.gg/JgVHfYGzmn`. — [civo7/QOLLOCK README](https://github.com/civo7/QOLLOCK)
- Maintainers credited in the README are civo, BreadRollius, bytenode and Predi_i, with about 20 more feature
  contributors (Hanturaya's "Always Show Passive Items", bonclide's Top Bar Plus, and others). The Predi-i GitHub account
  runs the update-marker repo [Predi-i/qollock-updates](https://github.com/Predi-i/qollock-updates), according to
  `docs/RELEASING.md`. — [README](https://github.com/civo7/QOLLOCK), [RELEASING.md](https://github.com/civo7/QOLLOCK/blob/codex/customize-main/docs/RELEASING.md)
- Forks: Specter10117/QOLLOCK mirrors the upstream branches and adds `Stylized_Ammo_&_Better_Silenced_Cursed_Abilites`
  and `agent/add-saiah-preset`. Kholk3r/QOLLOCK has `custom-hit-marker` (PR #65, 2026-10-15). — [Specter10117/QOLLOCK](https://github.com/Specter10117/QOLLOCK), [Kholk3r/QOLLOCK](https://github.com/Kholk3r/QOLLOCK)
- A separate ModsPortal listing, "QOL Lock", calls itself a full UI/HUD overhaul (v1.0, June 2026, "100+ features, 300
  settings") and tells users to remove other HUD mods. It is very likely a mirror of the GameBanana entry, but this is
  unconfirmed. — [ModsPortal](https://www.modsportal.com/deadlock/mods/qol-lock/)
- **Main** (`3d0cc34`, 2026-10-17, BreadRollius, "fix(topbar): preserve spectator target hit routing"):
  `package.json` version **4.0.5**, `QOL_UPDATE_MARKER = 8`. Since 2026-10-06 its commits are HUD repairs for builds
  6757 and 6779 (`930b71a` "refresh HUD overrides for build 6757", 10-06), the healing-mode indicator (`22e9789`, 10-16),
  showrank, storage and CI fixes, and RizoBoy's hero-testing tools ("inf souls and buy anywhere", "neutral bots and
  dummy", 10-15, which only touch `hud_hero_testing.xml`). — [main commits](https://github.com/civo7/QOLLOCK/commits/main)
- `upstream.json` on main pins Valve's native HUD resources to GameTracking commit `0c38f9d`, which is **build 6779
  (2026-10-13)**. The branch pins `2d87734`, which is **build 6774 (2026-10-09)**. — [upstream.json (main)](https://github.com/civo7/QOLLOCK/blob/main/upstream.json), [GameTracking 0c38f9d](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/0c38f9d31c4905e0fe1a292afe91aa3d01044baf)
- All branches by last commit (as of 2026-10-27). **`codex/customize-main` 2026-10-25** is the only branch active after
  10-17. `codex/native-resource-update` (10-14) is fully merged. `perf/hardcore-optimization` (2026-08-20) is fully merged
  (0 ahead, 421 behind). The older `optimization_testing` (2026-06-02), `optimization_testing_showranks` and `css-perf`
  (2026-06-25) branches show the team has run perf test branches before. Open PRs from the last 3 weeks: #62 and #66
  (native-resource reviews), #63 (showrank), #64 (Russian strings), #65 (custom hit marker), #67 (Specty, "update fix",
  10-23), #68 (wbottle, "keep Damage Fountain styles off subtitles", 10-19). — [branches](https://github.com/civo7/QOLLOCK/branches), [pulls](https://github.com/civo7/QOLLOCK/pulls)
- `codex/customize-main` vs main: merge base `1096750` (2026-09-26), **222 ahead / 144 behind**. Git reports several
  merge bases, so some commits are re-applied copies of main's commits. The branch's own work is Predi-i's 2026-10-21 to
  10-25 run: 7 + 5 + 17 + 19 + 30 commits per day. Version and marker are unchanged (4.0.5 / 8), so the branch is
  **unreleased**. — [codex/customize-main](https://github.com/civo7/QOLLOCK/commits/codex/customize-main)

### Inferences
- The request's premise (a gameinfo/video.txt FPS config with a test branch) doesn't match this project. The
  "QoLLock test branch" in the request most likely means `codex/customize-main`. Its "free FPS" angle is **less CPU spent by
  the HUD mod's own JavaScript**, not engine settings.
- The `codex/` prefix and the many `.claude/skills/*-qollock` files suggest the branch is largely AI-agent-assisted
  development, which explains the volume of commits.

### Gaps
- GameBanana changelog, GitHub Releases list, and whether a pre-release "test build" VPK from this branch circulates on
  Discord: not accessible (GameBanana blocked, GitHub releases API 403, private Discord).

## What the test branch changes (since about 2026-10-06), and how each convar classifies against Valve's dump

### Takeaway
The branch changes **no `gameinfo.gi` ConVars, no engine sections, no `video.txt` keys and no FPS VPKs**. No branch of
the repo contains a `gameinfo`, `video.txt` or `autoexec` file. The changes are HUD feature work, a refactor of the HUD
scripts' polling and panel lookups, and one new runtime console command, `citadel_crosshair_enable_clip_status`. That
convar is a real client-side `release` convar and works online. It changes the HUD (native magazine ring), not FPS.

### Cited Findings
- Search of all 30 branches for files matching `gameinfo|video.txt|autoexec`: **none**. The repo tree is `panorama/`
  (styles, scripts, images, layout, fonts), `sounds/`, `translations/`, `docs/`, `tests/` and `tools/`. — [civo7/QOLLOCK tree](https://github.com/civo7/QOLLOCK)
- **Perf commits on the branch (Predi-i, 2026-10-21 to 10-25)**. All have empty commit bodies and no numbers:
  - `168321a` (10-21) "Avoid recurring broad panel searches in healthbar and topbar owners"
  - `a7a8c1e` (10-24) "perf: avoid redundant HUD color work"
  - `8353bd9` "perf: narrow recurring HUD class and owner discovery"
  - `285a611` "perf: scope and bound recurring HUD source discovery"
  - `3d24ac5` "perf: resolve unsecured gold through its native owner"
  - `9758791` "perf: reconcile compass ticks as a sibling batch"
  - `903613e` "perf: resolve urn minimap through the native owner path"
  - `a7e94eb` "perf: reuse minimap crate descriptors and panel arrays"
  - `66f6796` "perf: derive alternate keyboard geometry on binding and settings changes"
  - `10a5fd8` "perf: reuse parsed game clock text between native changes"
  - `f6cc4e1` "perf: derive native ammo digit plans in the settings hook"
  - `8107581` (10-25 23:30 +1000) "Reduce recurring HUD discovery and overlay reconciliation work"

  — [codex/customize-main commits](https://github.com/civo7/QOLLOCK/commits/codex/customize-main)
- **Other branch work** in the same window:
  - `054eeb3` (10-21) "feat: consolidate QOLLOCK customization and runtime updates" (531 files, +74,976/−43,076)
  - Scoped keyboard themes (`6cbd02c`), Damage Fountain size slider (`f8d163b`), Minimalist and Minecraft healthbar updates (`194c63c`)
  - Ammo rework: `cfdebc6` "render ammo with native arcs and per-round masks", `3ae11c2` "use native magazine renderer and
    restore its default gate", `f75ad49`, `47909cb`
  - Healing reticle restore (`cdf6e56`)
  - Benchmark-harness fixes (`25de30b`, `12fec85`, `ca96e59`, `fee46cc`)
  - Removal of the old XML profiling model and legacy lookup scanners (`90d00da`)
  - New HUD fixture from an October 3 debugger capture (`6f04e05`)

  — [codex/customize-main commits](https://github.com/civo7/QOLLOCK/commits/codex/customize-main)
- **Static code metric (my count, `git grep`)**. Main has 695 `FindChildTraverse(` call sites, 44 `createPollLoop(`
  sites, 178 `$.Schedule(` sites and 134 JS files. The branch has **245**, 50, 139 and 160. `$.Msg(` logging call sites
  drop from 308 to 183. These are call sites in the source, not runtime call frequency. — [main](https://github.com/civo7/QOLLOCK/tree/main/panorama/scripts) vs [branch](https://github.com/civo7/QOLLOCK/tree/codex/customize-main/panorama/scripts)
- The branch's guardrail doc says "Cache stable references rather than repeating `FindChildTraverse` every tick. A miss
  can walk the entire subtree" and "A disabled feature should do zero or near-zero work". It also says these are
  "implementation constraints, not claims that every existing feature already satisfies them." — [PERF_GUARDRAILS.md](https://github.com/civo7/QOLLOCK/blob/codex/customize-main/docs/PERF_GUARDRAILS.md)
- **New convar on the branch**: `ql_ammo/manifest.js` dispatches `CitadelConCommand "citadel_crosshair_enable_clip_status 1"`
  or `0` when the Ammo feature toggles. `docs/VALIDATION.md` (added 2026-10-24) says this convar came from GameTracking's
  `convars.txt` ("a client release convar with a false default") and that the maintainer confirmed in the client "that
  enabling this convar starts the native magazine renderer". — [VALIDATION.md](https://github.com/civo7/QOLLOCK/blob/codex/customize-main/docs/VALIDATION.md), [ql_ammo manifest](https://github.com/civo7/QOLLOCK/blob/codex/customize-main/panorama/scripts/manifests/ql_ammo/manifest.js)
- Classification against Valve's **6821** dump, all set at runtime through Panorama `CitadelConCommand`, not gameinfo:

  | Convar | 6821 flags | Class | Status |
  |---|---|---|---|
  | `citadel_crosshair_enable_clip_status` | `false (clientdll release)` | Real client-side, works online. Visual only: native magazine/clip ring at the crosshair. | New on branch |
  | `citadel_crosshair_hit_marker_duration` | `0.1 (clientdll archive)` | Real client-side, saved per user | Already on main |
  | `cl_showfps`, `cl_showmem`, `cl_showtick`, `cl_showframenumber` | `clientdll release` | Real client-side | Debug-overlay toggles in QOLLOCK's dev/console tab |
  | `cl_showpos` | `clientdll cheat release` | `cheat` | Dev tab |

  The hero-testing tools (inf souls, buy anywhere, bots) only exist in the hero-testing HUD (`hud_hero_testing.xml`),
  so they don't work in online matches. — [GameTracking-Deadlock convars.txt @ 6821](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/master/DumpSource2/convars.txt), [commit 00fe46b](https://github.com/civo7/QOLLOCK/commit/00fe46b), [commit 05d539e](https://github.com/civo7/QOLLOCK/commit/05d539e)

### Inferences
- FPS effect of the branch: a likely **small CPU saving per frame**, only for people who run QOLLOCK. Fewer broad
  `FindChildTraverse` walks, fewer redundant style writes and less logging all reduce Panorama JS time on the main
  thread. That matters most in CPU-bound fights, but the size is unknown (see the measurements section). Visual cost:
  none intended. Online: yes, it's a client-side UI mod.
- Moving ammo drawing to the native magazine renderer (`citadel_crosshair_enable_clip_status`) is probably cheaper than
  drawing per-round arcs from JS, but nobody has measured it.

### Gaps
- I didn't read the full 112k-line diff. Feature-level changes beyond the commit subjects are not itemized.
- I didn't verify the exact console strings the hero-testing tool buttons send. They are hero-testing-only either way.

## Does the branch handle build 6801 (BakedLighting v5 etc.), and mod-compatibility notes

### Takeaway
The 6801 `gameinfo.gi` changes (BakedLighting Version 5, `directional_irradiance_sh2_lum`, `FogCachedShadow*Tools`) are
**not applicable**, because QOLLOCK doesn't ship a gameinfo. The 6801 change that matters to QOLLOCK is the new Nurse
element in the ammo HUD. **The branch has it and main 4.0.5 does not.**

### Cited Findings
- Valve's builds after QOLLOCK main's pinned 6779 changed HUD files that QOLLOCK overrides:
  - 6790 (2026-10-16): `element_gun.xml/.css`, `hud_quickbuy.xml/.css`, `hud_gold_and_ap_container.xml/.css`,
    `hud_minimap.css`, `hud_ability_icon.css` and others.
  - 6801 (2026-10-20): `element_gun.xml` gains `<Panel class="nurse_heal_icon" />` and
    `<Label id="healing_mode_indicator" …>`; `element_gun.css` +134 lines; `hud_ability_icon.css`; `hud_minimap.css`.

  — [GameTracking-Deadlock 6801 commit 37f9aeb](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/37f9aebdc62766aa13748f73309b9b8120549833), [6790 commit 9b616d3](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/9b616d3)
- `git grep nurse_heal_icon`: 0 files on main, 1 on `codex/customize-main`. `healing_mode_indicator`: present on both
  (main got it in `22e9789`, 10-16). Both branches carry their own `styles/ability_hud_elements/element_gun.css`,
  `hud_minimap.css`, `hud_quickbuy.css` and so on. The branch also adds `styles/features/ql_feat_native_*` copies. — [main](https://github.com/civo7/QOLLOCK/tree/main/panorama/styles), [branch](https://github.com/civo7/QOLLOCK/tree/codex/customize-main/panorama/styles/features)
- Install/compat model: the VPK goes into `citadel/addons` (pak01 to pak99, allocated by its builder). The build tool
  restricts packed content to `panorama`, `soundevents` and `sounds`. — [RELEASING.md](https://github.com/civo7/QOLLOCK/blob/codex/customize-main/docs/RELEASING.md)
- alz's `gameinfo.gi` SearchPaths already load addons with explicit Mod/Write (`Game "citadel/addons"`, `Mod "citadel"`,
  `Write "citadel"`, …). HUD-mod-sensitive convars are commented out as `//[mods]`: `citadel_custom_ui_colors`,
  `panorama_alignment_fixes`, `panorama_content_size_fixes`, `panorama_enable_secondary_layout_pass`,
  `panorama_comp_layer_lru_lifetime`. — local `/home/user/alz-deadlock-cfg/alz/gameinfo.gi` lines 566-581 (read 2026-10-27)

### Inferences
- With QOLLOCK main 4.0.5 on build 6801+, QOLLOCK's older override of `element_gun.css` probably shadows Valve's new
  Nurse styles. A likely symptom is a mis-styled ammo panel when you play Nurse. This is a visual bug, not an FPS issue.
  The branch's next release should fix it.
- QOLLOCK is compatible with alz's cfg layout: addons search path present, HUD-related convars left at defaults.
  Nothing in alz's cfg has to change for it.

### Gaps
- Not tested in a client: whether main 4.0.5 actually renders Nurse's ammo panel wrong on 6821.

## Measured A/B results (FPS, 1% lows): measured vs claimed

### Takeaway
**No FPS or frame-time numbers are published** anywhere I could reach. The project's own docs say repeatedly that its
perf tooling counts operations offline and is **not** an FPS measurement. So everything about FPS is a claim of
direction, not a measurement.

### Cited Findings
- On their offline profiler and tracer: "do not measure native traversal time, layout, rendering, GPU work or FPS".
  `cost/s` is "historical arbitrary weights … not measured milliseconds". — [PROFILING.md](https://github.com/civo7/QOLLOCK/blob/codex/customize-main/docs/PROFILING.md)
- The in-game benchmark (`Dev -> Benchmark (Current Config) -> Run Current (10s)`, also present on main) times the mod's
  Scheduler poll callbacks with `Date.now()`. It "excludes deferred layout, rendering, GPU work" and "is diagnostic
  rather than a clean FPS or frame-time benchmark". For release evidence the docs say to "compare game frame times with
  and without the mod on the same repeatable scene". — [TESTING.md](https://github.com/civo7/QOLLOCK/blob/codex/customize-main/docs/TESTING.md)
- Profiler baselines are deliberately not committed (`perf/hardcore-optimization` "chore: do not commit profiler
  baselines", 2026-08-20). — [perf/hardcore-optimization](https://github.com/civo7/QOLLOCK/commits/perf/hardcore-optimization)
- Web search for player reports of "QOL Lock" FPS, lag or stutter: none found (2026-10-27). — [search result set incl. forums.playdeadlock.com](https://forums.playdeadlock.com/threads/severe-fps-drops-and-ping-spikes-every-5%E2%80%9310-seconds-even-in-main-menu.171343/)

### Inferences
- The 695 → 245 drop in `FindChildTraverse` call sites is the only hard number. It shows less lookup code, not how
  much runtime is saved.

### Gaps
- Any numbers posted in the QOLLOCK Discord (private) or on GameBanana (unreachable from here).

## Which ideas would give alz more FPS with NO visual loss (5700X / RTX 5070 / 1440p, CPU-bound in fights, DMM)

### Takeaway
Nothing from QOLLOCK belongs in alz's `gameinfo.gi` or `video.txt`. The no-visual-loss ideas only apply **if alz runs
QOLLOCK or another heavy JS HUD mod**: measure the mod, keep only the features you use, and update to the release built
from this branch.

### Cited Findings
- Valve 6821 flags for Panorama/V8 convars in alz's cfg:
  - `panorama_js_minidumps false (developmentonly hidden defensive)`. alz sets `"1"` (comment: "enable minidumps on JS exceptions").
  - `v8_maximum_heap_size_mb 512 (developmentonly)`. alz sets `1024`.
  - `panorama_disable_render_target_cache true (developmentonly hidden defensive)`. alz sets `"0"`.
  - `panorama_skip_composition_layer_content_paint true`. alz sets `"1"`, the same as the default.

  — [convars.txt @ 6821](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/master/DumpSource2/convars.txt); local `/home/user/alz-deadlock-cfg/alz/gameinfo.gi` lines 777-785
- QOLLOCK's design rule: "A disabled feature should do zero or near-zero work", with explicit caveats. — [PERF_GUARDRAILS.md](https://github.com/civo7/QOLLOCK/blob/codex/customize-main/docs/PERF_GUARDRAILS.md)

### Inferences (ranked by how well they fit alz)
1. **If alz uses QOLLOCK: measure it first.** In a practice match or sandbox fight, compare frame times and 1% lows with
   the QOLLOCK VPK enabled and then disabled in DMM. Then run `Dev -> Benchmark (Current Config)` to see which QOLLOCK
   features cost the most callback time. No visual cost. This is the only way to know if the HUD mod costs fight FPS on
   a 5700X.
2. **Turn off QOLLOCK features alz doesn't use.** Their registry is designed so that disabled features stop polling. No
   visual loss beyond the unused feature.
3. **Update to the release built from `codex/customize-main` once it ships (expected after 4.0.5).** Fewer broad panel
   searches and less logging means less main-thread JS in fights, plus the 6801 Nurse ammo-HUD fix. No visual cost
   intended. The gain is unmeasured.
4. **Optional, low-confidence one-line test:** `panorama_js_minidumps "0"` (the Valve default). If a HUD mod throws JS
   exceptions, writing a minidump each time is a plausible source of hitches. Nobody has measured it, and with no
   exceptions it changes nothing. No visual effect.
5. Nothing for gameinfo, `video.txt` or 6801 lighting. The branch has no engine-config ideas to copy.

### Gaps
- Whether alz actually runs QOLLOCK. The repo only mentions it in RESEARCH.md §6 ("can't clash with QOL Lock"), and the
  DMM mod list isn't in the repo.
- Real frame-time cost of QOLLOCK 4.0.5 vs the branch on any PC: no data exists.
