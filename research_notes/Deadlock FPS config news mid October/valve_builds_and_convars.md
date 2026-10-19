# Valve-side Deadlock builds and convar changes, 2026-10-14 to 2026-10-19

Method: fresh `--filter=blob:none --shallow-since=2026-10-10` clone of SteamDatabase/GameTracking-Deadlock at
`/tmp/claude-0/-home-user-alz-deadlock-cfg/db6895a8-f913-52c5-ab52-f7e33997af67/scratchpad/research_tmp2/gt`
(HEAD = build 6796, commit 2e024f9, 2026-10-19 19:28 UTC). For each build I diffed `DumpSource2/convars.txt`, `game/citadel/gameinfo.gi`,
`popup_settings.xml`, the localization files, `steam.inf`, depot manifests (to see which DLLs actually changed) and the binary
string dumps. I extracted the 6779 and 6796 convar dumps and ran `research_tmp/scripts/cvcheck.py` plus a new
`research_tmp2/vcheck.py` (it checks `setting.*` keys) against the user's stable and experimental `gameinfo.gi` and `video.txt`.
Web access was limited. Steam API, steamdb.info, deadlock.wiki, undeadlock.com, deadlock.one and deadlock-tracker.com all failed
to fetch (DNS/proxy). Third-party patch summaries below therefore come from search snippets only. GitHub pages did load.
Baseline: the prior report covers everything through build 6785. Anything at 6785 or earlier is marked background.

## Q1. Which builds came after 6785, and what changed in convars.txt and gameinfo.gi in each?

### Takeaway
Valve shipped five builds after 6785: 6790, 6793, 6794, 6795 and 6796, dated 10-16 to 10-19. Only 6790 (the Violet hero update) touched `convars.txt`, and it added two `developmentonly` HUD convars plus one description change. Stock `gameinfo.gi` has not changed since 6779 (10-13), and no convar was added, removed, re-flagged or given a new default in any way that affects FPS tuning.

### Cited Findings
**Build timeline in the window (confirmed from Valve files: `steam.inf` ClientVersion and VersionDate, plus GameTracking commit time):**

| Build | steam.inf VersionDate / Time | GT commit (UTC) | SteamDB link | What changed (FPS-relevant?) |
|---|---|---|---|---|
| 6782 | Oct 14 2026 10:09:01 | a9e0c69, 10-14 17:45 | [25939744](https://steamdb.info/patchnotes/25939744/) | All engine DLLs rebuilt (engine2, rendersystemdx11/vulkan, scenesystem, particles, materialsystem2, worldrenderer…). **No convars.txt change.** Content: one tutorial CSS line, one Deadpack sound event. *Background: inside the window, but the baseline only mentions 6779/6785 and never discusses 6782.* |
| 6785 | Oct 14 2026 20:01:37 (GT 10-15) | c9e6480, 10-15 03:14 | — | client/server.dll only, Baba bench-melee schema, vdata. No convars change. *Already in baseline.* |
| (6785 re-process) | — | 4e0f960, 10-15 19:11 | — | No steam.inf change. This is the tracker re-running its new string-dedupe tooling (commits a6a918a and 037ae29, "Dedupe strings…", 10-13). The 1,523 deleted string lines are a tracker artifact, **not a game change**. |
| **6790** | Oct 16 2026 13:44:07 | 9b616d3, 10-16 21:01 | [25997478](https://steamdb.info/patchnotes/25997478/) | **Violet ("artist") hero update.** All engine and game DLLs rebuilt; 350 files. `convars.txt` +2 convars, 1 description edit (details below). gameinfo.gi unchanged. |
| 6793 | Oct 16 2026 16:05:45 | 0ba033e, 10-16 23:13 | — | client.dll, server.dll, citadel.signatures, non-English localization; animgraph/model CRCs. No convars change. |
| 6794 | Oct 17 2026 13:55:49 | df11920, 10-17 21:32 | [26015805](https://steamdb.info/patchnotes/26015805/) | Content depot only (VPKs). `generic_data.vdata` `m_vecBuyTime` 5th entry 65 → 50 (shop/gameplay). No convars change. |
| 6795 | Oct 17 2026 20:53:46 (GT 10-18) | 19650b2, 10-18 04:40 | — | Content depot only, one Familiar ability model. No convars change. |
| 6796 | Oct 19 2026 11:58:27 | 2e024f9, 10-19 19:28 | — | client.dll, server.dll, localization. One English string: Violet `ability_artist_homingbrush_t1_desc` now reads "+…m Max Drawing Distance". No convars change. |

Sources: [GameTracking-Deadlock commits](https://github.com/SteamDatabase/GameTracking-Deadlock/commits/master); [9b616d3 (6790)](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/9b616d3093a7f3e25e852ec93c9b818c5d2c94ed); [a9e0c69 (6782)](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/a9e0c695d49df9b15651b8e5b02f41847e8b428d); [df11920 (6794)](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/df1192043fd269aee7edf4dffdfb4cfc03d05f64); [0ba033e (6793)](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/0ba033e); [19650b2 (6795)](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/19650b2); [2e024f9 (6796)](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/2e024f9)

**`DumpSource2/convars.txt`: the full delta for the window (6790 only; 14,592 → 14,598 lines). Confirmed:**
- ADDED `citadel_damage_text_follow_healthbar_scale true (developmentonly clientdll)`: "Damage text follows the victim's healthbar scale".
- ADDED `citadel_hud_high_unspent_souls_threshold 7000 (developmentonly clientdll)`: "Unspent souls at or above this amount set gHighUnspentSouls on the HUD (pulsing soul count, quickbuy bounce)".
- DESCRIPTION ONLY: `citadel_damage_text_follow_healthbar_pos` loses "(only works on V2 healthbars)". Its default (`true`) and flags are unchanged.
- No convar was removed. No flag changes. No default changes. No new `gameinfo_cannot_override` (the count is 124 in both the 6779 and 6796 dumps). No new `cheat`/`replicated` flags. The `r_citadel_*` count is 73 in both dumps.
- `convars.txt` is byte-identical from 6790 through 6796 (verified with `cmp`), and was unchanged in 6782 and 6785. — [9b616d3 convars.txt diff](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/9b616d3093a7f3e25e852ec93c9b818c5d2c94ed)

**Stock `game/citadel/gameinfo.gi`. Confirmed:**
- Last changed in 6779 (0c38f9d, 10-13, +2 lines: `ResourceCompiler { ForceVulkanForMapBuild 1 }`, background, already in the baseline). The 6796 file is byte-identical to the 6779 file. No changes to SearchPaths, FileSystem, ConVars or the 7 guarded sections in the window. — [GT gameinfo.gi history](https://github.com/SteamDatabase/GameTracking-Deadlock/commits/master/game/citadel/gameinfo.gi)

**Matchmaking guard text. Confirmed unchanged:**
- In 6796, `Citadel_StartMatchmaking_UnverifiedPGI` still reads "Unable to enter matchmaking while any party member is running Tools-mode, or has unsupported changes to the following sections of their 'gameinfo.gi': Engine2, MaterialSystem2, NetworkSystem, Particles, RenderSystem, SceneSystem, WorldRenderer". `citadel_main_english.txt` changed only in 6790, and only by 3 added strings (HealingMode HUD, Quickbuy "Slots Locked", Hideout heavy crate) and 1 tutorial string edit. — [9b616d3](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/9b616d3093a7f3e25e852ec93c9b818c5d2c94ed)

**Video settings menu. Confirmed:**
- `popup_settings.xml` changed only in 6790, and only one line: ping-wheel "Slot 5" was hardcoded and is now the localization token `#citadel_settings_ping_wheel_slot5`. No video options were added, removed or renamed, and nothing indicates a video.txt version bump. — [9b616d3](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/9b616d3093a7f3e25e852ec93c9b818c5d2c94ed)
- No `cfg/` file changed except `cfg/valve_builds.kv3`, which holds default hero item builds (Violet), not graphics settings. — same commit.

### Inferences
- The engine DLLs were recompiled in 6782 and 6790 without any change to the convar surface. Any FPS change from these builds would come from code changes, which GameTracking cannot show, not from tunables. A before/after benchmark is the only way to tell.
- The 6790 string-dump growth in engine modules (for example `nvngx_dlss_strings.txt` +689 lines) mirrors the 4e0f960 dedupe deletions. `nvngx_dlss.dll` does not appear in the 6790 changed-DLL list in the depot manifests. The likeliest explanation is tracker re-processing, not a new DLSS DLL.
- The 6790 manifest also changed `citadel.signatures` and all game DLLs, which is normal for a hero-release build.

### Gaps
- Valve's own patch notes text for 10-16 could not be fetched (forums, Steam news API and SteamDB were all blocked). The build table is built from Valve's shipped files, not from the changelog.
- GameTracking cannot show code-level renderer changes. Whether 6782/6790 changed performance is unknown without benchmarks.

## Q2. Did any convar or video.txt key used by the user's configs change status?

### Takeaway
No. Checking every `ConVars` line in `stable/gameinfo.gi` (255 parsed) and `experimental/gameinfo.gi` (281 parsed) against the 6779 and 6796 dumps gives identical results. Every `setting.*` key in both `video.txt` files (57 each, `"Version" "20"`) has the same default and flags in 6796 as in 6779. Nothing the user runs became blocked, removed or re-defaulted in the window.

### Cited Findings
- cvcheck output against 6796 (identical to 6779, verified with `diff`): both files have **23 "nonexistent" names** and **5 blocked** names. Blocked: `lb_enable_dynamic_lights`, `lb_enable_baked_shadows`, `lb_enable_stationary_lights`, `sc_fade_distance_scale_override`, `r_citadel_gpu_culling`. Stable has 161 `developmentonly` lines and experimental 175. The nonexistent list includes `r_citadel_enable_pano_world_blur`, `mat_async_shader_load`, `r_multiscattering`, `r_async_compute_fog`, `r_citadel_depth_prepass_dynamic_objects`, `csm_viewmodel_farz`, `r_lightmap_bicubic_filtering`, `r_citadel_ssao_thin_occluder_compensation`, `r_citadel_screenspace_particles_full_res`, `cl_enable_eye_occlusion` and others. Five entries (`min`, `default`, `max`, `version`, `snd_event_browser_*`) are parser false positives from comment or sub-block lines. **All of these were dead before the window. They are background, not new.** — [GT convars.txt @6796](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/2e024f9/DumpSource2/convars.txt)
- `r_citadel_gpu_culling` in 6796: `true (developmentonly clientdll cheat menubar_item gameinfo_cannot_override)`, unchanged. — same source
- `video.txt` (stable and experimental): 40 keys are convars, all with unchanged default and flags from 6779 to 6796. The other 17 are engine video-config keys that are not convars (`knowndevice`, `defaultres`, `defaultresheight`, `refreshrate_*`, `fullscreen`, `coop_fullscreen`, `nowindowborder`, `mat_vsync`, `fullscreen_min_on_focus_loss`, `high_dpi`, `r_particle_depth_feathering`, `shaderquality`, `recommendedheight`, `useadvanced`, `monitor_index`, `aspectratiomode`). That status is also unchanged. — same source; script `research_tmp2/vcheck.py`
- `experimental/gameinfo.gi` line 926 already sets `r_citadel_disable_particle_lights "true"`. In 6796 the convar is still `false (clientdll release)`, with no flag change. Stable does not set it. — [GT convars.txt @6796](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/2e024f9/DumpSource2/convars.txt)

### Inferences
- No config edits are needed because of Valve changes from 10-14 to 10-19. Any edits recommended in the baseline still apply as written.

### Gaps
- None for convar status. Video.txt key semantics (as opposed to existence) can't be checked from dumps.

## Q3. Did Valve add the promised "performance cvars" (OptimizationLock #88)? Any new r_citadel_* toggles or changes to r_citadel_disable_particle_lights?

### Takeaway
Nothing new since 6779. No `r_citadel_*` convar was added, removed or changed in 6782–6796, and `r_citadel_disable_particle_lights` is unchanged (`false`, `clientdll release`). The #88 thread has had no new Valve-relayed statement since 10-13.

### Cited Findings
- `r_citadel_*` count is 73 in both the 6779 and 6796 dumps, and the only 6790 convar additions are the two `citadel_` HUD devonly convars listed in Q1. — [9b616d3](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/9b616d3093a7f3e25e852ec93c9b818c5d2c94ed)
- `r_citadel_disable_particle_lights false (clientdll release)` in 6796, same as when it was introduced in 6779 (background). — [GT convars.txt @6796](https://github.com/SteamDatabase/GameTracking-Deadlock/blob/2e024f9/DumpSource2/convars.txt)
- OptimizationLock #88 has 6 entries, the last on 2026-10-14. On 10-13 Sqooky relayed a forum reply: "some cvars that will improve performance will release soon". On 10-14 Sqooky said "A LOT of popular streamers had lighting all but removed, and it really clashed with their artistic vision". The issue author added "Hope the future cvars might be good". There are no newer comments and no mention of a new convar. This is a secondhand claim, not a direct Valve quote. — [OptimizationLock #88](https://github.com/Sqooky/OptimizationLock/issues/88)
- 6790 added 8 new Violet particle "light" effects (`particles/abilities/artist/*_light.vpcf_c`, e.g. `artist_buff_flow_state_light`, `artist_ult_primer_light`). These are the kind of particle-attached dynamic lights that `r_citadel_disable_particle_lights` targets. — [9b616d3 pak01_dir.txt](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/9b616d3093a7f3e25e852ec93c9b818c5d2c94ed)

### Inferences
- If "performance cvars" are coming, they will likely land with the next major build. The 6796 binaries contain new strings such as `nurse_leech` (client, added in 6790), which hints at another hero in development. That is speculative.
- Violet's new particle lights slightly raise the value of `r_citadel_disable_particle_lights` in fights involving her (inferred from file names, not measured).

### Gaps
- Whether Valve has said anything new about performance cvars on the official forums. Forum pages were not reachable.

## Q4. Any patch notes or Valve statements about performance, FPS, stutter, memory or the renderer in this window?

### Takeaway
I found no Valve statement or patch note about performance in 10-14 to 10-19. Third-party trackers describe the window as the 10-16 "Paint the Town" update (new hero Violet) plus small balance and tooltip follow-ups. Their snippets mention no performance items.

### Cited Findings
- 10-16 update adds the hero Violet (internal name `artist`). Trackers call it "Paint the Town". — [unDeadlock 2026-10-16 (6790)](https://undeadlock.com/patches/2026-10-16-6790); [deadlock.one](https://deadlock.one/en/news/deadlock-update-patch-october-16-2026-valve-adds-new-hero-violet); [deadlocklabs.gg/patches](https://deadlocklabs.gg/patches/); [deadlock-tracker.com/patches/60](https://deadlock-tracker.com/patches/60); [deadlock.wiki Update:October 16, 2026](https://deadlock.wiki/Update:October_16,_2026) (search snippets only, pages not fetchable). Confirmed by Valve files: `hero_artist_lore` names "Violet" in `citadel_heroes_english.txt` @6796.
- A TalkEsport snippet describes a 10-16 "minor patch" with Urn reveal timer and sprint changes and Shiv/Seven nerfs, but its page header reads "July 29, 2026". **Date conflict: treat as unreliable.** — [TalkEsport](https://www.talkesport.com/news/deadlock-october-16th-update-patch-notes/)
- 10-19 data update: only reworded Violet's Homing Brush T1 to show Max Drawing Distance as a bonus, with no values changed. That matches the single English string diff in 6796. — [unDeadlock patches](https://undeadlock.com/patches) (snippet); confirmed by [GT 2e024f9](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/2e024f9)
- unDeadlock's snippet calls a build "6795" a "technical build" that "changed code and settings". **GT contradicts this**: 6795 changed only the content depot (one Familiar model), not code. The build that changed client.dll/server.dll without data changes was 6793 or 6796. — [unDeadlock](https://undeadlock.com/patches) vs [GT 19650b2](https://github.com/SteamDatabase/GameTracking-Deadlock/commit/19650b2)
- A search snippet claimed "Nurse Harrow" is the next hero, joining "Tuesday October 20th at 2pm PDT". The source page is unidentified and a direct search found nothing. **Unverified.** — (snippet from the "10-16-2026 update" search; no confirmable URL)
- Performance searches returned only older player threads (stutter and FPS drops from Feb 2026 and earlier) and generic guides. Nothing is dated in the window. — [forums.playdeadlock.com "Crazy performance stutters"](https://forums.playdeadlock.com/threads/crazy-performance-stutters.119122); [tier1settings stutter guide](https://tier1settings.com/deadlock-stuttering-fix/)

### Inferences
- Engine DLLs were rebuilt in 6782 and 6790, and a hero release ships new shaders and particles. Players may see one-time shader-compile stutter after updating. This is general Source 2 behavior, not a Valve statement.
- If the Oct 20 hero release is real, it will likely be the next build with convar changes worth re-checking.

### Gaps
- No primary Valve patch-note text was retrievable for 10-16, 10-17 or 10-19 (Steam news, forums, SteamDB and deadlock.wiki were blocked). I could not confirm whether the official notes mention performance.
- No Valve developer statement about performance or configs was found in the window.
