# Deadlock FPS config repos: what changed from 2026-10-14 to 2026-10-19

Method: on 2026-10-19 (about 22:00 UTC) I fetched all scratch clones. They are Sqooky/OptimizationLock, dacooderr/OptiLock,
7liv/compylock, deadlock-mod-manager, ghempy53/deadlock-config, simulieren/deadtune, and the adamescj, Erik-Backdahl,
KubilayUlucay and TheGreatGat5by OptimizationLock forks. I ran `git log --since=2026-10-13` against `origin/HEAD` and
compared configs with a key-value parser (`scratchpad/kvdiff.py`) as well as `diff -w`.

- **Issues:** I read the GitHub issue pages through WebFetch.
- **Convar flags:** these come from the DMM perf catalog (`catalog.json`, convar build 6790).
- **GameBanana:** unreachable. WebFetch failed DNS and curl got a proxy 403. GameBanana data below comes only from DMM's
  synced catalog.
- **Baseline:** `latest_community_findings.md`, written 10-16, already covers Sqooky 3.5.2, Kaizu 10-14, OptiLock
  5.7 up to e3c48af and ghempy up to 10-15. Those items are repeated here only as background.
- **Measured vs claimed:** I found **no measured FPS or frame-time numbers** in the window. Every reason below is an
  author's claim or a subjective in-game impression.

## Q1. What each project changed from 2026-10-14 to today, and why

### Takeaway
Sqooky shipped OptimizationLock 3.5.3 (10-16) and 3.6 / Max-FPS 1.5 (10-17). Both are mostly HUD and minimap tweaks plus
dead-line cleanup. 3.6 also reverts `citadel_camera_use_vmdl_flatten_vertical` to the default `true`.

OptiLock did two things:
- It rebased onto the current stock 6779 file (10-14), and its 10-15/16 v5.7 work is already in the baseline.
- It changed its `FileSystem` block for the "Grimoire" mod manager, and that change drops `UserSettingsPathID`.

ghempy53 ran the only real experiment of the window, an in-game bisect. It found that Sqooky's
`r_particle_min_timestep "0.00241"` makes fast particles look jagged above about 415 FPS. compylock, deadtune, adamescj
and the other forks had **no commits** in the window.

### Cited Findings

**Sqooky/OptimizationLock**
- **10-14, `clean gameinfo.gi` rewritten** (55+/916−, "updated the clean gameinfo.gi properly"). My key-value diff of
  that file against my stock build-6779 `gameinfo.gi` (scratchpad/vanilla) shows **no differences**. In effect it is now
  a stock reference copy. — [commit 1691141](https://github.com/Sqooky/OptimizationLock/commit/1691141)
- **10-14, Kaizuchaneru update** (background, in the baseline): adds `citadel_player_model_force_highest_lod false`,
  `r_citadel_disable_particle_lights 1`, `gameinfo-EXTREME-LOW.gi` and `EnvironmentMapFaceSize 2048`. — [commit 0298945](https://github.com/Sqooky/OptimizationLock/commit/0298945)
- **10-16, 3.5.3** (main config; Max-FPS only lost one line):
  - Turned on `citadel_per_weapon_per_surface_impact_effects "false"`. The author's comment: "Reduces the visuals for
    bullet tracers. This will disable the radius of yamato right click" [def true].
  - Deleted `phys_dynamic_scaling "false"` from main and Max-FPS. 3.6 later re-adds it as a comment: "Makes it so that
    you can't shoot holiday barrels".
  - Deleted `citadel_unit_status_use_new`, `_use_v2` and `_use_v2_for_nonplayers`, and two commented ping lines.
  - Added `citadel_unit_status_healthbar_highlight_speed "100"` (def 2).
  - Reflowed the UI block and expanded the particle-lights comment to "Disables all lighting effects from particles".

  — [commit 65a7462](https://github.com/Sqooky/OptimizationLock/commit/65a7462)
- **10-17, 3.6 and Max-FPS 1.5** (title "3.6 and maxfps 1.5 release"; the commit message gives no reasons). Key-value
  diff 3.5.3 → 3.6:
  - `citadel_camera_use_vmdl_flatten_vertical "false"` → `"true"`, back to the default. The comment still says false
    "should improve responsiveness of mouse input but makes Rem, Venator, AND ESPICIALLY RAT KING's cameras move
    downwards when aiming down scope".
  - `citadel_unit_status_healthbar_highlight_speed` 100 → **999**: "Removes interpolation of the health bar".
  - New: `citadel_minimap_trooper_size "2"` (def 3), `minimap_trooper_update_rate_hz "2"` (def 5),
    `citadel_show_minimap_reveal_indicators "true"` ("idk yet") and `citadel_show_old_neutral_camp_icons "false"` ("idk yet").
  - Removed: `citadel_unit_status_allies_see_thru_walls_max_distance "40"` and `citadel_unit_status_dpi "10"`.
  - `lb_enable_baked_shadows "false"` is now commented out.
  - The "Testing" block was regrouped into `ai_` / `citadel_` / `cl_` / `lb_` / `r_` / `sc_` / Misc headers, with the
    note "Not certain if these actually improve performance but they aren't replicated or unable to be overwritten".
    No values changed.
  - A new header recommends launch options: "Pleas experiemnt with -dx11 or -vulkan" and
    "-nojoy -nosteamcontroller -nohltv -particles 1 -softparticlesdefaultoff -particle_disable_diffuse".
  - Max-FPS 1.5 gets the same HUD/minimap changes and adds `ResourceCompiler { ForceVulkanForMapBuild 1 }`.
  - No change in either file to engine sections or any render or particle convar.

  — [commit aba20cd](https://github.com/Sqooky/OptimizationLock/commit/aba20cd)
- **Flags for those lines in the DMM catalog (convar build 6790):**
  - `lb_enable_baked_shadows` is `gameinfo_cannot_override`, status "blocked since 6769".
  - `citadel_per_weapon_per_surface_impact_effects` is `defensive developmentonly replicated`.
  - `phys_dynamic_scaling` is `cheat replicated`.
  - `minimap_trooper_update_rate_hz` and `citadel_unit_status_healthbar_highlight_speed` are `developmentonly`.

  ghempy53's log calls the trooper-rate line "server-only" and `lb_enable_baked_shadows` "blocked", so both have no
  effect. — [DMM catalog.json](https://github.com/deadlock-mod-manager/deadlock-mod-manager/blob/main/packages/perf-catalog/data/catalog.json); [ghempy53 CHANGES.txt](https://github.com/ghempy53/deadlock-config/blob/main/docs/CHANGES.txt)
- **10-16/17, auto-updater (PR #96):** adds a `performance` target (the Max-FPS config) and an `eskay` target, removes
  the deleted `test`, and drops "(comparatively outdated)" from Piggy. — [commit 1fd563b](https://github.com/Sqooky/OptimizationLock/commit/1fd563b)
- **10-15/17:** Portuguese README translation (PR #95). — [commit 36f0d51](https://github.com/Sqooky/OptimizationLock/commit/36f0d51)
- **10-18:** `vdf-fmt` pre-commit hook and PR workflow for `.gi` formatting ("thanks to phoriah", issue #94), plus README
  credits. The README credits now accuse Dacooder (OptiLock) of copying the config and removing attribution, which
  shows the two projects are openly feuding. ghempy53 checked 690e4fb and found `gameinfo.gi` "byte-identical", so it
  holds no config changes. — [commit 21e144c](https://github.com/Sqooky/OptimizationLock/commit/21e144c), [commit 690e4fb](https://github.com/Sqooky/OptimizationLock/commit/690e4fb), [ghempy53 de40157](https://github.com/ghempy53/deadlock-config/commit/de40157)

**dacooderr/OptiLock**
- **10-14, "Updated Recommended Preset" and "Updated gameinfo for Tracers Fix" (5.5 → 5.6):** the FPS and Potato
  files were rebased onto the current stock file:
  - `PGIVersion` changed from `6E09D3ED…` to `39A735A4…`, the current stock hash, which the alz cfg already has.
  - Removed `DisallowGameInfoConditionals`, `DuplicateTokensAssert`, `Engine2/AllowKeyChordBindings`,
    `SinglePlayerAsyncRendering`, `NetworkSystem/UseSerializedEntityPool`, several SceneSystem keys
    (`HDRFrameBuffer 0`, `ParticleBufferSize 256`, `LayerBatchThresholdFullSort 80`, and others) and Particles keys
    (`EnableMixedResolution`, `PerVertexLighting 0`, and others).
  - SceneSystem `SunLightMaxCascadeSize` 2→0 and `PointLightShadowsEnabled` 1→0.
  - The "tracers fix" removed `r_drawtracers 0`, `r_drawtracers_firstperson 0`, `r_drawmodeldecals 0`,
    `cl_removedecals 1` and the `r_decals_*` fade lines, and set `r_decals` 0→1.

  — [commit da52e74](https://github.com/dacooderr/OptiLock/commit/da52e74), [commit 95485f6](https://github.com/dacooderr/OptiLock/commit/95485f6) (local key-value diff da52e74~1..fca258f)
- **10-14, other changes:**
  - "fixed Yamato right click thanks to Ethanal" set `citadel_per_weapon_per_surface_impact_effects` **false → true**
    in FPS and Potato. Sqooky 3.5.3 went the other way two days later.
  - Removed `r_draw_particle_children_with_parents false`.
  - Potato got `mat_colorcorrection false`.
  - `r_size_cull_threshold` 1 → 0.8 in Potato and Ultra Potato.
  - Ultra Potato got a second `video(Shadows).txt`.

  — [commit b90bfa7](https://github.com/dacooderr/OptiLock/commit/b90bfa7), [980ba17](https://github.com/dacooderr/OptiLock/commit/980ba17), [d0d6503](https://github.com/dacooderr/OptiLock/commit/d0d6503), [dd7d641](https://github.com/dacooderr/OptiLock/commit/dd7d641)
- **10-15/16, v5.7 and the TEST block** (background, in the baseline):
  - `r_particle_max_draw_distance` 300000→5000 and `r_particle_max_size_cull` 126→64.
  - Trooper outline off, `citadel_player_model_force_highest_lod false`, and about 40 TEST lines.
  - `video.txt`: `r_render_portals` 1→2 and `lb_csm_override_staticgeo_cascades_value` -1→0.

  — [OptiLock commits](https://github.com/dacooderr/OptiLock/commits/main)
- **10-16, `video(Shadows).txt` for Ultra Potato:** `r_texture_stream_mip_bias` 6 → 8, with no stated reason. — [commit 0ff2287](https://github.com/dacooderr/OptiLock/commit/0ff2287)
- **10-16, "added Grimoire FileSystem Flag for mod support with the manager"** (FPS Recommended):
  - `SearchPaths` now sits inside `// Deadlock Mod Manager - Start/End` markers.
  - It adds `Game citadel/grimoire` and `Game citadel/addons` ahead of the language paths, plus explicit
    `Mod citadel / Write citadel / Game citadel / Mod core / Write core / Game core`.
  - **It deletes `"UserSettingsPathID" "USRLOCAL"` and `"LegacyUserSettingsPathID" "MOD"`.**
  - It also edits tool-only `ResourceCompiler` keys: `bakedlighting` 1→0, `TrianglesPerMeshlet` 64→32 and
    `ImportanceVolumeTransitionRegion` 512→128.

  — [commit fca258f](https://github.com/dacooderr/OptiLock/commit/fca258f)

**ghempy53/deadlock-config** (the owner tests in game; Claude writes the commits)
- **10-16:** pulled Sqooky 3.5.3 into stable. Its log says 3.5.3 "turns on citadel_per_weapon_per_surface_impact_effects
  false and drops phys_dynamic_scaling false (both replicated)". It also added a rule that stable keeps
  `r_aspectratio 2.11`. — [CHANGES.txt](https://github.com/ghempy53/deadlock-config/blob/main/docs/CHANGES.txt), [commit bc18d55](https://github.com/ghempy53/deadlock-config/commit/bc18d55)
- **10-17, jagged-fire bisect** (commits 5800512 → edcae9e). The owner saw "jagged" fire on Deadman Danny's jetpack and
  on heal particles. The bisect went:
  1. Full-res textures (mip bias 3→0, anisotropic 8x, no pool or cap) did not fix it.
  2. Removing the `r_particle_max_texture_layers 4` cap "looked worse".
  3. Particles section back to stock, then HDR plus 19 particle lines back to Valve values: fixed.
  4. HDR alone back to Valve values: not fixed.
  5. The 9 simulation and timing lines back to Valve values: fixed.
  6. Only `r_particle_min_timestep` back to Valve's value: fixed.

  Conclusion: `r_particle_min_timestep "0.00241"` → engine default 0 is "the confirmed fix". The reasoning, quoting
  Valve's help text: "particle simulation happening more frequently than this will lerp". 0.00241 s ≈ 415 Hz, and
  "at uncapped FPS above about 415 the particles are interpolated between simulation steps". The evidence is the
  owner's visual check, not a measurement. — [commit edcae9e](https://github.com/ghempy53/deadlock-config/commit/edcae9e), [dd0b9df](https://github.com/ghempy53/deadlock-config/commit/dd0b9df), [TESTED-CHANGES.md §0b](https://github.com/ghempy53/deadlock-config/blob/main/docs/TESTED-CHANGES.md)
- **10-17, other changes (owner preferences, no measurements):**
  - Textures: experimental pool 3200 MB, then 6400 MB, and mip bias 3 → 2. Stable then took all experimental values:
    `fps_max 0` and `fps_max_ui 0`, mip bias 2, `r_texture_pool_size 6400` (Sqooky 256, engine default 1600 per the
    log) and the 128 px `r_texture_stream_max_resolution` cap removed.
  - Damage-number lines removed.
  - Frozen as v1.3.

  — [commit cb67652](https://github.com/ghempy53/deadlock-config/commit/cb67652), [747fd60](https://github.com/ghempy53/deadlock-config/commit/747fd60), [51a1c6e](https://github.com/ghempy53/deadlock-config/commit/51a1c6e)
- **10-18:** pulled Sqooky 3.6 into stable, "untested in game; v1.3 stays the rollback". **10-19:** upstream check, no
  changes. — [commit cda130d](https://github.com/ghempy53/deadlock-config/commit/cda130d), [de40157](https://github.com/ghempy53/deadlock-config/commit/de40157)

**Repos with no activity in the window** (last commit date in parentheses):
- 7liv/compylock (10-10, "sinners LOD fix.vpk")
- simulieren/deadtune (10-08, v0.28.0)
- adamescj/OptimizationLock (10-06)
- Erik-Backdahl (10-03), KubilayUlucay (10-06) and TheGreatGat5by (10-07) forks

— local `git log origin/main` after fetch; [compylock](https://github.com/7liv/compylock/commits/main), [deadtune](https://github.com/simulieren/deadtune/commits/main), [adamescj](https://github.com/adamescj/OptimizationLock/commits/main)

### Inferences
Verdicts for the alz cfg (stable and experimental, 5700X + 5070):

- **`r_particle_min_timestep "0.00241"`.** Both alz files have this line, at stable:667 and experimental:664. **Adopt
  ghempy's change (comment it out → default 0), low priority.**
  - Alz caps `fps_max 400`. Frame time is then at least 2.5 ms, which is above 2.41 ms, so the lerp should never
    trigger today. The bug only appears if you uncap, or if `fps_max` goes above about 415.
  - Removing the line is harmless at a 400 cap. Sqooky's own comment says lower values "could negatively impact
    performance", but at 400 FPS the simulation step is already longer than 2.41 ms.
- **`citadel_camera_use_vmdl_flatten_vertical "true"`.** Alz already has it. 3.6 confirms that choice. No action.
- **`lb_enable_baked_shadows "false"`.** It is at line 578 in both alz files. It is blocked since 6769, which makes it a
  dead line. **Remove or comment it out** for hygiene. There is no FPS impact either way.
- **`citadel_per_weapon_per_surface_impact_effects`.** Alz doesn't set it. Skip. It is `replicated` and
  `developmentonly`, so the client value may not even apply. The two big configs also disagree on the side effect: it
  breaks the Yamato right-click radius.
- **3.6 HUD/minimap lines** (`healthbar_highlight_speed 999`, trooper dot size, reveal indicators). These are taste
  only and give no FPS. Optional. `minimap_trooper_update_rate_hz` has no effect.
- **3.6 launch-option header** (`-particles 1 -softparticlesdefaultoff -particle_disable_diffuse -nojoy …`). Don't
  adopt it. No author shows these flags do anything in Source 2 Deadlock, and they look like Source-1 era flags.
  "Experiment with -dx11 or -vulkan" is a suggestion, not a measured result.
- **OptiLock's 10-16 `FileSystem` rewrite.** Don't copy it. The alz cfg's `SearchPaths` already has explicit Mod/Write
  lines, which is OptiLock's new layout too. Alz also **keeps** `UserSettingsPathID "USRLOCAL"` and
  `LegacyUserSettingsPathID "MOD"`, which OptiLock dropped. Both are in Valve's stock file. Dropping them likely
  changes where per-user settings and keybinds are read from (see Q3).
- **OptiLock `TrianglesPerMeshlet` 64→32 and the ResourceCompiler edits.** These only matter when compiling maps.
  There is no runtime FPS effect. Ignore them.
- **ghempy's texture choices** (mip bias 2, 6400 MB pool). These are the owner's taste on unknown hardware. Alz's
  `video.txt` mip bias 0 with gameinfo mip bias 3 is a separate decision. There is no new evidence either way.

### Gaps
- None of the 10-14 to 10-19 changes has a measured FPS or frame-time result, from Sqooky, OptiLock or ghempy.
- The reasons for 3.6 dropping `lb_enable_baked_shadows` and for OptiLock's mip bias 6→8 and SceneSystem
  `SunLightMaxCascadeSize 0` are unstated. The commit messages are bare.
- I couldn't verify whether `citadel_per_weapon_per_surface_impact_effects` actually changes anything client-side,
  given its `replicated` flag.

## Q2. Did anyone adopt or reject particle lights, the player-model LOD convar, csm_max_visible_dist, or change particle fallback, shadow cascades, mip bias or DLSS?

### Takeaway
There were no new adoptions or rejections of the 6769/6779 convars in this window. The split from before 10-14 still
holds:
- Sqooky main, Max-FPS and Kaizu, and ghempy stable, use `r_citadel_disable_particle_lights true`.
- **No OptiLock preset** uses it.
- OptiLock and Sqooky Max-FPS, but not Sqooky main, use `citadel_player_model_force_highest_lod false`.

The one particle change in the window is ghempy reverting `r_particle_min_timestep`. Mip-bias moves went in opposite
directions: ghempy 3→2 (sharper), OptiLock Ultra Potato 6→8 (blurrier). Nobody changed DLSS or upscaling advice; OptiLock
ships upscaling and DLSS off.

### Cited Findings
- Values in Sqooky 3.6 (main / Max-FPS 1.5):
  - `r_citadel_disable_particle_lights "true"` in both.
  - `citadel_player_model_force_highest_lod "false"` **only in Max-FPS**, with the comment "allows the player model to
    render lowest LoD from your sc_screensize_lod_scale_override setting".
  - `csm_max_num_cascades_override "2"` and `csm_max_visible_dist "0"` ("All of these commands should reduce shadow
    quality").
  - `r_texture_stream_mip_bias "3"` and `r_particle_min_timestep "0.00241"`.
  - None of these changed between 3.5.3 and 3.6.

  — [Sqooky's .gi @aba20cd](https://github.com/Sqooky/OptimizationLock/blob/aba20cd/Sqooky's%20.gi/gameinfo.gi), [Max-FPS @aba20cd](https://github.com/Sqooky/OptimizationLock/tree/aba20cd/maximumfps%20or%20minimum%20spec%20config%20and%20resources%20here)
- Values in OptiLock at fca258f (FPS / Potato / Ultra Potato / Testing):
  - No `r_citadel_disable_particle_lights` in any preset.
  - `citadel_player_model_force_highest_lod "false"` in all four.
  - `csm_max_visible_dist` is set twice, `"10"` and then `"1"` in the TEST block.
  - `csm_max_num_cascades_override "0"`.
  - `r_particle_min_timestep "0.001"`.
  - gameinfo `r_texture_stream_mip_bias "8"`; `video.txt` mip bias is 4 (FPS), 6 (Potato) and 8 (Ultra Potato).
  - Every `video.txt` sets `r_citadel_upscaling "0"` and `r_citadel_dlss_settings_mode "0"`.
  - The translated presets (UA, RU, AR, PT) still carry older values: cascades 2 and `csm_max_visible_dist 0`.

  — [OptiLock tree @fca258f](https://github.com/dacooderr/OptiLock/tree/fca258f) (local grep)
- ghempy53 stable (current):
  - `r_citadel_disable_particle_lights "true"` ("Disables all lighting effects from particles").
  - `r_particle_min_timestep` commented out.
  - Mip bias 2.
  - Experimental briefly tested anisotropic 8x with full-res textures, then reverted to bilinear plus mip bias 3, then 2.

  — [stable-config/gameinfo.gi](https://github.com/ghempy53/deadlock-config/blob/main/stable-config/gameinfo.gi), [commit 8e10fa2](https://github.com/ghempy53/deadlock-config/commit/8e10fa2)
- ghempy also ruled out the `r_particle_max_texture_layers 4` cap as a cause of the jagged fire ("no cap looked
  worse"). It found no visual problem from the particle fallback, culling, lights or texture-layer lines, which were
  all kept. — [TESTED-CHANGES.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/TESTED-CHANGES.md)
- Flags: `r_citadel_disable_particle_lights` and `citadel_player_model_force_highest_lod` are `release`.
  `csm_max_visible_dist` is `cheat` (def 7500). `r_particle_min_timestep` is `defensive developmentonly`. — [DMM catalog.json](https://github.com/deadlock-mod-manager/deadlock-mod-manager/blob/main/packages/perf-catalog/data/catalog.json)

### Inferences
- Alz experimental already has `r_citadel_disable_particle_lights "true"` and `csm_max_visible_dist "0"`, and both video
  files have `csm_max_num_cascades_override 0`. Nothing in the window argues against them.
- `citadel_player_model_force_highest_lod "false"` is missing from both alz files. It is still the cheapest untried
  option: it is `release`, affects only your own hero, and is used by OptiLock, Max-FPS and Kaizu. Nobody reported a
  problem with it in the window, and nobody measured a gain either.
- OptiLock's `csm_max_visible_dist "1"` and `csm_max_num_cascades_override "0"` amount to the same "no sun shadows"
  goal as alz's 0 values. There is nothing new to adopt.

### Gaps
- No project published any A/B test of `r_citadel_disable_particle_lights` or of the player-model LOD convar. Its FPS
  value is still unmeasured.
- No project discussed DLSS 4 or transformer presets, or upscaling on RTX 50 cards, in the window.

## Q3. New reported problems: crashes, visual bugs, keybindings, matchmaking

### Takeaway
No new matchmaking block or guard kick was reported in any repo during the window. The new crash reports have either
no root cause or are blamed on outdated mods rather than configs:
- OptimizationLock #98: crash in matches with Solomon/Violet, closed the same day.
- #87: Eskay config GPU crash on an RX 9070 XT, still open.
- #89/#90: launch errors and locked heroes, which Sqooky blamed on outdated mods.

OptiLock closed its keyboard issues (#10, #12) on 10-14 without any explanation. Those include keys swapping A↔D and
S↔W, followed by crashes. ghempy found one config-caused visual bug, jagged particles from `r_particle_min_timestep`.

### Cited Findings
- **OptimizationLock #98** (10-18), "solomon to violet, cant use abilities, causes crashes": the game crashes once a
  match includes the new heroes, on the newest gameinfo. The reporter closed it as completed the same day with no
  comments. — [#98](https://github.com/Sqooky/OptimizationLock/issues/98)
- **#90** (10-14), "New heros locked": Deadman Danny and Solomon were locked. Sqooky replied "YOU HAVE AN OUTDATEDMODDDDDD
  … NOT AN ISSUE WITH THE CONFIG … I've been asked it fifty million times", and the reporter confirmed they had a
  forgotten mod. **#89** (10-14), "can't load up the game": same answer from Sqooky. — [#90](https://github.com/Sqooky/OptimizationLock/issues/90), [#89](https://github.com/Sqooky/OptimizationLock/issues/89)
- **#87** (10-13, open), "eskay config gpu crash": 5800X3D, RX 9070 XT and driver 26.8.1. The driver crashes after about
  5 minutes on the Eskay config, while the Max-FPS config "seems fine". On 10-15 Sqooky asked the reporter to try DX11 vs
  Vulkan and said he "can't replicate". — [#87](https://github.com/Sqooky/OptimizationLock/issues/87)
- **#91** (10-14, open): the Sinners light mod doesn't work together with the "Texture Downscaler" mod. **#97** (10-18): a
  user has no `video.txt` to follow the "Roblox Mode" section of Sqooky's latest video. No replies. **#94** (10-15):
  vdf-fmt request, implemented 10-18. — [OptimizationLock issues](https://github.com/Sqooky/OptimizationLock/issues)
- **#70**, "Rat King Camera Bugged When Using Config", was closed on 10-19. 3.6 had reverted `flatten_vertical` to `true`
  on 10-17. I didn't read the closing comment. — [OptimizationLock issues list](https://github.com/Sqooky/OptimizationLock/issues?q=is%3Aissue)
- **OptiLock #12**, "Keyboard controls change completely in the PC version in game" (opened 10-05): "A ->D, S-W … about
  once every 5–6 games — and the game crashes several times after restarting". dacooderr closed it on 10-14 as
  completed, with no comment. **#10** (09-18): SharpKeys remaps stop working "when using the modified gameinfo.gi". Also
  closed 10-14 with no fix stated. **#11** (restore bullet tracers) and **#14** ("mods") were closed 10-14, the same day
  as the "Tracers Fix" commit. — [#12](https://github.com/dacooderr/OptiLock/issues/12), [#10](https://github.com/dacooderr/OptiLock/issues/10), [OptiLock issues](https://github.com/dacooderr/OptiLock/issues?q=is%3Aissue)
- **ghempy53:** `r_particle_min_timestep 0.00241` made fire and heal particles look jagged at uncapped FPS. This is
  covered in Q1. It is a subjective visual result from the owner. — [TESTED-CHANGES.md](https://github.com/ghempy53/deadlock-config/blob/main/docs/TESTED-CHANGES.md)

### Inferences
- The **keyboard and SearchPaths family of bugs** is still live in other configs. Alz already guards against the
  `user_keys_default` failure with explicit Mod/Write lines, as its stable `gameinfo.gi` comment notes.
  - OptiLock's 10-16 file additionally drops `UserSettingsPathID`, so OptiLock users may see new keybind or settings
    oddities. This is unverified.
  - The alz cfg should keep both `UserSettingsPathID` lines exactly as stock.
- #98, the crash with the new heroes, has no known cause. If alz users report crashes only when Solomon or Violet are in
  a match, first rule out stale addon VPKs, which is the #89/#90 pattern. Only then suspect the config.

### Gaps
- None of the closed OptiLock keyboard issues states a root cause, and neither does #98.
- I could not check Discord, Reddit or the playdeadlock forums for matchmaking-block reports. Searches returned no
  posts dated in the window, and the forum is unreachable from here.

## Q4. Did Deadlock Mod Manager change how it rewrites gameinfo.gi, or add perf presets?

### Takeaway
DMM made two rewrite-safety fixes:
- It recovers from a read-only `gameinfo.gi` and from stale vanilla resets (10-17, #890).
- It no longer rewrites `gameinfo.gi` when the search paths are unchanged (10-18).

It refreshed the perf catalog on 10-18, pinning Sqooky 3.6, Kaizu 10-14 and OptiLock v5.7, against stock build 6779 and
convar build 6790. It added **no new presets**. An open issue (#875) says DMM still wipes or fails to parse custom FPS
`gameinfo.gi` files on modded launches.

### Cited Findings
- **#890** (10-17): "Guides tell users to make gameinfo.gi read-only, and DMM then failed with os error 5 …". DMM now
  names the read-only file and offers a "Make writable" action. A vanilla reset now refreshes the manager state and
  falls back to a validated local backup. This closes #873 and #874. — [commit 40531b3](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/40531b3)
- **7616335** (10-18): "skip rewriting gameinfo.gi when search paths are unchanged". If the newly generated content
  equals the current file, DMM returns early and doesn't write. — [commit 7616335](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/7616335)
- **041cb36 / #862** (10-14): DMM updated its bundled stock `gameinfo.gi` from the depot. — [DMM commits](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commits/main)
- **Perf catalog refresh, #927 and #934 (10-18).** The bot's #934 refresh carries the new pins:
  - Catalog `2026.10.18-1`, `latestBuild` 6711 → **6779**, `convarBuild` 6769 → **6790**.
  - New GameTracking `convars.txt` pin: build 6790, dated 10-16.
  - Sqooky main and Max-FPS → aba20cd (3.6); Kaizu → 0298945, with the new `gameinfo-EXTREME-LOW.gi` path; OptiLock FPS
    and Potato → fca258f, tag v5.7. Eskay is still at the 10-05 pin.

  #927 was needed because "the weekly refresh has been failing" on upstream renames. It also dropped curated labels for
  `cl_show_bloodspray` and `cl_ejectbrass` ("already removed by Valve") and classed
  `citadel_unit_status_healthbar_highlight_speed` as visibility. — [commit e3a8346](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/e3a8346), [commit abd59a1](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/abd59a1)
- **Catalog contents after the refresh:**
  - The preset list is unchanged: `dmm-clean, optimizationlock, eskay, sqooky-max-fps, kaizu-min-spec, optilock-fps,
    optilock-potato`.
  - `r_citadel_disable_particle_lights` (release, "lighting") is now known to the catalog.
  - The convar entries added since 6769 are otherwise HUD, deadpack, zipline and damage-text items. None of them is a
    performance setting.
  - The rules still guard the same 7 sections (`Engine2, MaterialSystem2, NetworkSystem, Particles, RenderSystem,
    SceneSystem, WorldRenderer`).
  - The rules deny `Engine2/RenderingPipeline/DistanceField` ("Setting it to 0 crashes the current game build after the
    hideout loads") and `r_render_portals` ("Turning portals off breaks Doorman's door"). These denials date from 10-08,
    which is background.

  — [catalog.json](https://github.com/deadlock-mod-manager/deadlock-mod-manager/blob/main/packages/perf-catalog/data/catalog.json)
- **Crash check** (10-18): it no longer sits behind the performance-configs experimental flag and is on by default ("Check
  for crashes after launch"). On 10-19 DMM added "find the mod that breaks the game by testing in halves", a mod bisect. — [commit 7557bad](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/7557bad), [commit d8d6e74](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/d8d6e74)
- **#875** (open, 10-15): "Custom gameinfo.gi configs (FPS/FOV) are wiped or fail to parse when launching modded". It
  cites about 20 incidents in #general around the 10-13 update. It asks DMM to leave edits outside its managed
  search-path block alone. No maintainer reply or linked PR yet. — [#875](https://github.com/deadlock-mod-manager/deadlock-mod-manager/issues/875)

### Inferences
- **DMM compatibility for alz.** Since 7616335, launching through DMM with the alz `gameinfo.gi` should leave the file
  untouched, as long as alz's `SearchPaths` already match what DMM would write. Before that fix DMM rewrote the file on
  every launch. #875 shows that wipes or parse failures still happen for some custom files. Keep a backup, and keep the
  file parseable: no duplicate or odd quoting, since DMM now also expects vdf-fmt-clean files.
- **The `DistanceField` deny rule.** It is a crash report from DMM's maintainers. Make sure alz never sets
  `Engine2/RenderingPipeline/DistanceField 0`.

### Gaps
- I could not see the exact new convars in build 6790 separately from 6779. The catalog diff spans 6769 to 6790.
  Another researcher covering Valve changes should check GameTracking directly.

## Q5. New public config repos or GameBanana configs in the window

### Takeaway
I found no new GitHub config repos. The GitHub topic `deadlock-config` is empty, and web searches turned up only
known projects. On GameBanana, as seen through DMM's synced catalog, only dyson's long-running config was updated in the
window (10-16), and that update was a large one.

### Cited Findings
- **"configuration optimization from dyson"** (GameBanana 616141, about 121k downloads): updated **2026-10-16**,
  file `dyson_build_45ccf.zip`.
  - DMM's analysis: settings count 337 → **416**, engine-section edits 37 → **67**.
  - Still `baseBuild` 6462: its engine sections derive from a pre-CNS stock file, according to DMM.
  - It ships a Doorman door-fix VPK and translations in 15 languages.

  The other tracked GameBanana configs were not updated in the window: back3p OptimizationDL (06-14), Tysen98 (05-24),
  SHR1KN (05-31), Hanturaya (02-05), Maidehnless (04-08) and SideLock (10-01). — [DMM sources.json diff](https://github.com/deadlock-mod-manager/deadlock-mod-manager/commit/e3a8346), [catalog.json community](https://github.com/deadlock-mod-manager/deadlock-mod-manager/blob/main/packages/perf-catalog/data/catalog.json)
- I could not open the GameBanana script "true FPS boost config" (scripts/12939) because of DNS failure, so its date is
  unknown. Web searches for new 2026 repos returned only older or known projects. An example is codeberg
  trapplus/deadlock-resources, last committed in August 2026. — [GameBanana 12939](https://gamebanana.com/scripts/12939), [codeberg trapplus](https://codeberg.org/trapplus/deadlock-resources), [GitHub topic deadlock-config](https://github.com/topics/deadlock-config)

### Inferences
- dyson's config is pre-CNS-based and now has 67 engine edits. DMM catalogs it as a "potato" tier config, and its
  engine-section edits likely hit the guarded sections. It is not a source to copy into a "decent visuals" config like
  alz.

### Gaps
- GameBanana pages and comments were unreachable, so dyson's changelog and any user problem reports are unknown.
- Reddit r/DeadlockTheGame returned no posts in the window through search. I did not find or read Sqooky's "Roblox
  Mode" video, which #97 references.
