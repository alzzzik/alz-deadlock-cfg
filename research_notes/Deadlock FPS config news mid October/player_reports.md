# Deadlock player/community reports on FPS, configs and stability, 2026-10-14 to 2026-10-19

Scope note: research run 2026-10-19. Baseline is `/home/user/alz-deadlock-cfg/RESEARCH.md` (consolidated 2026-10-15, build ~6779) and `reports/Deadlock FPS gains with good visuals.md` (2026-10-16, build 6785). Only new items are listed. Anything dated before 2026-10-14 is marked **[BACKGROUND]**.

Access limits in this environment, which shape what could be verified:
- `forums.playdeadlock.com`, `techspot.com`, `techpowerup.com` and `isthisgamedown.com` failed DNS resolution through WebFetch. Forum, driver-site and status-site items below come from **search-engine snippets only**, so their wording and dates are not first-hand verified.
- The `gh` API was blocked for these repos, but public GitHub issue pages were fetchable, so the Sqooky/OptimizationLock items **are** read first-hand.
- Reddit returned **no results** for any `site:reddit.com` query. That is a search miss, not evidence that nothing was posted.
- YouTube, X/Twitter (Sqooky, dacooderr) and GameBanana turned up nothing dated in the window.

Evidence labels: **MEASURED** = numbers from a capture or benchmark. **ANECDOTAL** = a player's impression. **GUIDE/CLAIM** = an author's or guide's assertion. **OFFICIAL** = vendor or Valve data.

## Q1. What are players reporting about FPS and stability in the last ~5 days, and are there credible new tips for a Ryzen 7 5700X + RTX 5070 (CPU-bound in fights)?

### Takeaway
The window has no new measured FPS data from any source I could reach. Player traffic is about breakage, not gains: configs half-working after the Solomon update, a new-hero crash, a driver crash on one community config, and visual bugs from aggressive `gameinfo.gi` packs. Nothing new and credible changes the baseline plan for a 5700X + 5070. The baseline's CPU-side levers (particle lights, SMT-off test, DX11, Reflex on) still stand unchallenged.

### Cited Findings
- **ANECDOTAL (forum, ~2026-10-14, snippet only):** a thread titled "Solomon update broke the fps config commands" reports that "half the configs stopped working" after the update, "FPS all over the place, constant crashing", and asks people to keep their custom gameinfo.gi files. The search engine dated it "about 5 days ago" on 2026-10-19. The page itself was unreachable, so the date and quotes are unverified — [forums.playdeadlock.com thread 174251](https://forums.playdeadlock.com/threads/solomon-update-broke-the-fps-config-commands.174251/)
- **ANECDOTAL (forum, snippet only, date unclear):** reports of the game "crashing during jungle, towers, level-ups and end-screen after Solomon update", including on a newer PC. The snippet couldn't tie this to one thread or date, so treat it as unverified — [site search results incl. "performance issues" thread 154188](https://forums.playdeadlock.com/threads/performance-issues.154188/)
- **ANECDOTAL (GitHub, 2026-10-18):** OptimizationLock issue #98, "solomon to violet, cant use abilities, causes crashes". The game ran fine until a match containing the new heroes loaded, then crashed ("once we head into a match and the problem characters are there I would crash"). The reporter was "using the newest gameinfo". It was closed "completed" the same day with no fix described. The likely reading is a stale or custom gameinfo against new hero content — [Sqooky/OptimizationLock #98](https://github.com/Sqooky/OptimizationLock/issues/98)
- **ANECDOTAL (GitHub, opened 2026-10-13, owner reply 2026-10-15):** issue #87, "eskay config gpu crash". On a Ryzen 7 5800X3D + RX 9070 XT with driver 26.8.1 (AMD), the game "will run fine for about 5 mins then just driver crash". The reporter says Sqooky's "max fps" config is fine on the same machine. Sqooky (10-15) couldn't replicate it and suggested swapping DX11/Vulkan. It's AMD-specific and unresolved — [Sqooky/OptimizationLock #87](https://github.com/Sqooky/OptimizationLock/issues/87)
- **GUIDE/CLAIM (GitHub, 2026-10-15):** issue #93 (Chinese) lists visual bugs caused by OptimizationLock-style `gameinfo.gi` packs: soul-orb, statue-buff and death-drop text rendering as black/white boxes; hero models in shop and post-match as black silhouettes; the hero-select font missing because of a misspelled language path; the crosshair/view shifting down on zoom for some heroes (Rem, Venator, "Rat King"); distant buildings and heroes vanishing because of a short far-clip plane; and flat visuals from fog and indirect light removal. The visible fix is adding `citadel_in_world_item_panel_dpi "2"` (above the `particle_explicit_fetch` line) for the missing text. There are no FPS numbers — [Sqooky/OptimizationLock #93](https://github.com/Sqooky/OptimizationLock/issues/93)
- **ANECDOTAL/fix (GitHub, activity 2026-10-19):** issues #70 "Rat King Camera Bugged When Using Config" and PR #71 "Fix Rat King's camera" were both closed on 2026-10-19. This confirms that a config line was breaking one hero's camera and the pack was patched. Only the issue-list titles were read, not the diff — [OptimizationLock issue list](https://github.com/Sqooky/OptimizationLock/issues?q=sort%3Aupdated-desc)
- **ANECDOTAL (GitHub, closed 2026-10-18):** issue #86, "some light effects repeating?". Lights were repeating on floors and walls with Kaizu's config "even after todays update" (opened 10-12). Sqooky replied "Kaiz is working on this" (10-13), and it was closed "completed" 10-18 with no fix text. `r_citadel_disable_particle_lights` isn't mentioned — [Sqooky/OptimizationLock #86](https://github.com/Sqooky/OptimizationLock/issues/86)
- **Repo activity (2026-10-17):** OptimizationLock merged PR #96, "Update auto updater to include latest + new configurations", so the community packs were refreshed in the window. I didn't read the contents. Issue #94 (10-15) asks for automatic `vdf-fmt` formatting of `.gi` files — [OptimizationLock issue list](https://github.com/Sqooky/OptimizationLock/issues?q=sort%3Aupdated-desc)
- **GUIDE/CLAIM (2026-10-15):** an SEO-style guide on reload-animation stutter says "no universal fix is confirmed". It offers generic checks such as the frame-time display and shader cache, with no measurements — [itechguides](https://www.itechguides.com/how-to-fix-deadlock-stuttering-or-frame-drops-during-reload-animations/); similar generic post-update advice at [deadlock.now](https://deadlock.now/blog/deadlock-fps-drops-stuttering) (date not confirmed)
- **[BACKGROUND] ANECDOTAL (forum, 2026-10-10 per snippet):** a related thread claims the game's biggest problem is that it "runs on a single core", so each command matters more. This is consistent with the baseline's CPU-bound finding but adds no data — [search snippet, forum](https://forums.playdeadlock.com/threads/solomon-update-broke-the-fps-config-commands.174251/)

### Inferences
- For a 5700X + RTX 5070, the window adds **no new tip with evidence**. The practical lesson is defensive: after each hero or content patch, the first suspect for in-match crashes is a stale or custom `gameinfo.gi` (#98). Re-diff against the new stock file before blaming hardware.
- The #93 bug list is a useful **negative checklist** for the alz cfg. If the cfg shortens the far-clip plane, removes the language path or forces low panel DPI, those choices hide information (distant enemies, orb values) and don't help a CPU-bound PC. Check that the alz cfg doesn't carry these lines.
- #87 is AMD-GPU-specific (RX 9070 XT, AMD 26.8.1), so it isn't directly relevant to an RTX 5070. It does show that "eskay" vs "max fps" configs can differ in stability.

### Gaps
- No MEASURED FPS or frame-time results dated 2026-10-14 or later were found for any setting: DLSS/DLAA vs FSR vs Stretch, mip bias, cascades, particle fallbacks, `engine_low_latency_sleep_after_client_tick`, Reflex, Vulkan vs DX11, SMT, or Process Lasso. Reddit and the official forum couldn't be read directly. The baseline's older reports remain the latest evidence.
- No new launch options were reported in the window.
- No new memory-leak reports dated in the window were found. The baseline's Vulkan VRAM-leak note remains **[BACKGROUND]**.

## Q2. Reports on the newest Valve convars (r_citadel_disable_particle_lights, citadel_player_model_force_highest_lod): does it help, and how does it look?

### Takeaway
I found **no player report, FPS number or screenshot comparison** for `r_citadel_disable_particle_lights` or `citadel_player_model_force_highest_lod` dated in the window. A direct web search for the convar name returned zero relevant hits. The only context is the background Valve and Sqooky exchange that preceded the convar.

### Cited Findings
- A web search for `r_citadel_disable_particle_lights` returned **no Deadlock results at all**, only Skyrim, Particle.io and similar pages. The convar has not yet reached indexed discussion — [search, 2026-10-19; e.g. unrelated hit](https://www.nexusmods.com/skyrimspecialedition/mods/99548)
- **[BACKGROUND] GUIDE/CLAIM (GitHub #88, 2026-10-13/14):** after the Solomon update, `lb_enable_dynamic_lights "false"` stopped working in Sqooky's maxfps config on a low-end Linux laptop (the shop and end-screen portraits stayed lit). Sqooky said about 40 lighting commands can no longer be set via `gameinfo.gi`, relayed a developer reply citing the "artistic vision" of streamers whose lighting had been removed, and said "some cvars that will improve performance will release soon". No convar was named and there were no FPS numbers — [Sqooky/OptimizationLock #88](https://github.com/Sqooky/OptimizationLock/issues/88)
- Date conflict: the fetched issue page dates the #88 comments 2026-10-13/14. The baseline report says the developer statement came "four days" before build 6779 (2026-10-13), which would put it around 2026-10-09. One of the two is off. The page-render dates came through a summarizer and may be imprecise — [#88](https://github.com/Sqooky/OptimizationLock/issues/88) vs baseline `reports/Deadlock FPS gains with good visuals.md`
- **[BACKGROUND] ANECDOTAL (forum, undated snippet):** an older "Poor performance (likely due to particle effects)" thread says teamfight drops come from particle-heavy abilities and that gameinfo lighting and particle limits "barely helped" older hardware. A Valve developer reportedly pointed to `r_drawparticles 0` / `cl_particle_simulate 0` as diagnostic options. That is pre-window and pre-convar — [forums.playdeadlock.com thread 138829](https://forums.playdeadlock.com/threads/poor-performance-likely-due-to-particle-effects.138829/)

### Inferences
- The baseline's plan to A/B test `r_citadel_disable_particle_lights` live in a fight with `cl_hud_telemetry_frametime_show 1` still stands. The alz author's own test would be the **first public measurement**, which is worth publishing.
- Issue #86 (repeating light artifacts on Kaizu's config, closed 10-18) shows that lighting-related lines in community configs can produce visible artifacts. If particle lights are disabled, watch for odd or repeating light patches on floors, though no report links #86 to this convar.

### Gaps
- No visual comparisons or FPS deltas for either convar. Reddit, the official forum, YouTube and X couldn't be searched effectively.
- No reports on `citadel_player_model_force_highest_lod` at all.

## Q3. Any NVIDIA driver release or known issue in this window relevant to Deadlock on RTX 50-series?

### Takeaway
No new NVIDIA Game Ready or hotfix driver appears to have shipped between 2026-10-14 and 2026-10-19. The current WHQL Game Ready driver is still **617.42 (2026-10-06)** **[BACKGROUND]**. No Deadlock-specific driver issue surfaced. The one relevant date: October 2026 is NVIDIA's last month of Game Ready drivers for Windows 10, so 617.42 may be the final optimized Win10 driver.

### Cited Findings
- **OFFICIAL (via snippets) [BACKGROUND]:** GeForce Game Ready 617.42 WHQL, released 2026-10-06, with highlights for Call of Duty: Modern Warfare 4. It fixes an Assassin's Creed Shadows crash after 616.56 ([6685219]) — [NVIDIA driver search page](https://www.nvidia.com/Download/processFind.aspx?psid=129&pfid=1004&osid=135&lid=1&whql=1&lang=en-us&dtcid=1); [TechSpot listing](https://www.techspot.com/downloads/drivers/essentials/nvidia-geforce/)
- A snippet says TechPowerUp's version history still showed **617.42 as latest as of 2026-10-18**. I found no 618.xx driver or October hotfix. The direct fetch failed (DNS), so this is unverified — [TechPowerUp](https://www.techpowerup.com/download/nvidia-geforce-graphics-drivers/)
- **[BACKGROUND]:** the last hotfix found was 616.86 (2026-09-04), which fixed browser flicker, virtual displays and RDP black screens after 616.56 — [NVIDIA support 5906](https://nvidia.custhelp.com/app/answers/detail/a_id/5906/~/geforce-hotfix-display-driver-version-616.86); [NVIDIA CC on X](https://x.com/nvidiacc/status/2096013414070137279)
- **[BACKGROUND] open issues (list may predate 617.42):** dithering/banding "in some games on RTX 50-series", Cyberpunk Photo Mode path-tracing crash, Ghost of Tsushima light-source flicker. None mention Deadlock — [TechSpot listing via snippet](https://www.techspot.com/downloads/drivers/essentials/nvidia-geforce/)
- **OFFICIAL schedule:** the last Windows 10-compatible Game Ready driver lands in October 2026, and from November new Game Ready/Studio drivers need Windows 11. Win10 gets quarterly security updates through October 2029. GamesGPU suggests 617.42 "apparently" is already the last optimized Win10 release, but that is unconfirmed — [TechPowerUp news](https://www.techpowerup.com/352020/final-nvidia-geforce-game-ready-driver-for-windows-10-goes-out-in-october); [VideoCardz](https://videocardz.com/newz/nvidia-ends-windows-10-game-ready-support-in-october); [GamesGPU](https://en.gamegpu.com/news/zhelezo/oktyabrskij-game-ready-drajver-nvidia-stanet-poslednim-s-optimizatsiyami-dlya-windows-10); [HotHardware](https://hothardware.com/news/nvidia-preps-final-game-ready-windows-10-driver)
- **[BACKGROUND] ANECDOTAL (forum, older):** a pre-window thread says switching from DLSS to FSR3/TAA plus Vulkan helped one user, and another blamed "a recent NVIDIA driver". There was no version, no date and no data — [forum site search snippet](https://forums.playdeadlock.com/threads/fixed-insane-performance-issues.110553/)

### Inferences
- No driver action is needed for the RTX 5070 in this window. If the PC runs Windows 10, the next Game Ready driver (November) won't install, so a Deadlock-relevant fix arriving after October would need Windows 11.
- If a late-October driver ships (the "final Win10" release), it falls outside this window and needs a separate check.

### Gaps
- I couldn't read NVIDIA's 617.42 release-notes PDF or TechPowerUp directly to confirm the open-issues list or whether a newer driver appeared on 10-19/20.

## Q4. Reports of configs causing matchmaking refusals, bans, or crashes (e.g. "Unable to read default keybinding configuration")?

### Takeaway
I found no reports of bans for `gameinfo.gi` configs in the window, and no confirmed new enforcement of the matchmaking guard. There is one unexplained "kicked to hideout on queue" report (no error text), one unverified status-site mention of a "Not all party members" matchmaker error dated 10-16, and the keybinding-crash cause is now well documented: stale mod or gameinfo search paths, with a launcher fix shipped 10-11 **[BACKGROUND]**.

### Cited Findings
- **ANECDOTAL (GitHub, opened 2026-10-07 [BACKGROUND], updated 2026-10-19):** issue #79, "Cannot join match after Baba release". Every queue attempt "kicks me to the hideout". No error text or convars are given. Sqooky replied on 10-19: "I have no idea what would cause this. Could you provide more information." It remains unresolved and unconfirmed as guard enforcement — [Sqooky/OptimizationLock #79](https://github.com/Sqooky/OptimizationLock/issues/79)
- **Unverified (status site, snippet only):** isthisgamedown lists a "Not all party members…" matchmaker error **added October 16**. I couldn't confirm the full wording, or whether it is the gameinfo/party check ("Unable to enter matchmaking while any party member has changes to ConVars in Gameinfo.gi or is running Tools-Mode", a string known from earlier builds). The page didn't resolve (DNS). Check it against the GameTracking-Deadlock localization diff for builds after 6785 — [isthisgamedown.com/deadlock](https://isthisgamedown.com/deadlock/)
- **GUIDE/CLAIM [undated, likely pre-window]:** guides say the matchmaking block "does not work properly yet" and players with swapped files were "not blocked", with no Valve announcement — [ultimatemove Ranked CFG](https://ultimatemove.eu/en/deadlock-ranked-cfg/); [DMM docs, guarded sections list](https://docs.deadlockmods.app/using-mod-manager/customization)
- **Keybinding crash [BACKGROUND, 2026-10-11]:** the error text is "FATAL ERROR: Unable to read default keybinding configuration (user_keys_default)!". Causes: (a) an outdated mod shipping its own `cfg/user_keys_default.vcfg` after a big update; (b) a stock `gameinfo.gi` losing the `Game citadel/addons` + `Mod`/`Write` search-path lines, so the game looks for the file in the wrong place. PR #8 ties (b) to the 2026-09-29 update. MCLauncher PR #7 (merged 10-11) now auto-disables config-override mods and drops stale `gameinfo.gi` backups on a new build — [camwooloo/MCLauncher PR #7](https://github.com/camwooloo/MCLauncher/pull/7); [PR #8](https://github.com/camwooloo/MCLauncher/pull/8); [Frogtech guide](https://mods.frogtech.dev/guides/deadlock-mods-not-working-after-update)
- **Crashes tied to configs in the window:** #98, a new-hero crash with "the newest gameinfo" (10-18), and #87, a driver crash on the "eskay" config (AMD, 10-13/15). See Q1 — [#98](https://github.com/Sqooky/OptimizationLock/issues/98); [#87](https://github.com/Sqooky/OptimizationLock/issues/87)
- **[BACKGROUND] GitHub research:** convars flagged `gameinfo_cannot_override`: 49 on 2026-09-24, 77 after City Never Sleeps. The baseline already has 124 since build 6769 — [ghempy53 PR #26](https://github.com/ghempy53/deadlock-config/pull/26)

### Inferences
- There's no sign Valve started rejecting queues for `gameinfo.gi` edits in the window. The unverified 10-16 "Not all party members" string is the only possible lead and is worth one diff check. If it is a new party-wide gameinfo check, playing in a party with a modded cfg could start failing even when solo queue works.
- The keybinding crash is a modding and search-path problem, not a ConVars problem. The alz cfg avoids it by keeping the stock `SearchPaths` block intact, plus addons lines if mods are used, and re-copying after each update.

### Gaps
- No new `gameinfo_cannot_override` count after build 6785 could be checked: the GameTracking-Deadlock API was blocked, and the commit history wasn't reachable through search.
- I couldn't confirm the exact text and build of the 2026-10-16 "Not all party members" error.
- No ban reports were found, but Reddit and the official forum were effectively unsearchable.
