# Deadlock's renderer has a hidden Reflex 2 Frame Warp switch (2026-11-16, build 6861)

**Status: a lead, not a result.** The code and the switch are in the game. Whether it works end to end is untested;
only someone with an NVIDIA RTX card can test it. alz's RTX 5070 qualifies.

## What was found

Valve's renderer reads a `gameinfo.gi` key, `NVNGX/ReflexLateWarp`, that the stock file never sets. Behind it sits a
complete integration of NVIDIA's "Late Warp" feature, which is the engine of Reflex 2 Frame Warp. Evidence, all from
the string dumps of the shipped binaries in
[SteamDatabase/GameTracking-Deadlock](https://github.com/SteamDatabase/GameTracking-Deadlock) (commit `82735eb`,
build 6861):

| File | Strings |
|---|---|
| `game/bin/win64/rendersystemdx11_strings.txt` | `NVNGX/ReflexLateWarp`, `NGX_D3D11_CREATE_LATEWARP_EXT failed`, `LateWarpEvaluate failed`, `Unable to initialize Late Warp : FeatureInitResult = ...`, `Unable to initialize Late Warp : Need to update the driver to %u.%u`, and 40+ NGX parameters: `Latewarp.Available`, `Latewarp.Backbuffer`, `Latewarp.HudlessColor`, `Latewarp.UIColorAlpha`, `Latewarp.NoWarpMask`, `Latewarp.MV`, `Latewarp.Depth`, `Latewarp.WorldToViewMatrix`, `Latewarp.ViewToClipMatrix`, `Latewarp.PrevRendered...Matrix` |
| `game/bin/win64/rendersystemvulkan_strings.txt` | `NVNGX/ReflexLateWarp`, `CNVReflexVulkan::LateWarpUpdateResolution`, `LateWarpEvaluate failed` |

The parameter list is what a real integration needs: the frame without HUD, the HUD's alpha, a mask of pixels that
must not move, depth, motion vectors and the camera matrices of the rendered and the newest view. This is a native
integration by Valve, in both the DX11 and the Vulkan renderer. It is present in the oldest build in the checked
history (6763, 2026-10-08); how much older it is was not checked.

The same strings (48 Late Warp lines and the `NVNGX/ReflexLateWarp` key) are in the DX11 renderer of
[CS2](https://github.com/SteamDatabase/GameTracking-CS2) and [Dota 2](https://github.com/SteamDatabase/GameTracking-Dota2)
and in CS2's Vulkan renderer, so this is shared Source 2 engine code, not a Deadlock experiment. Neither game's stock
`gameinfo.gi` sets the key either.

Stock `gameinfo.gi` has only `AppID` and `SupportsDLSS` in its `NVNGX` block, so the feature is off for everyone.
`NVNGX` is **not** one of the seven sections named in Valve's matchmaking message. A second undocumented key sits
beside it: `NVNGX/DLSSDefaultPreset`.

## Why it matters

Frame Warp shifts the finished frame to the newest mouse position just before it is shown, so camera movement skips
most of the render delay. NVIDIA announced it in January 2025 (claim: up to 75% lower latency) and has still not
released it; in July 2026 [VideoCardz](https://videocardz.com/newz/nvidia-reflex-2-remains-unreleased-18-months-after-announcement-rtx-owners-still-waiting)
reported no shipping game, no public SDK and no date. The only measurement is of modder PureDark's unofficial demo:
[ComputerBase](https://www.computerbase.de/news/grafikkarten/nvidia-reflex-2-mod-ermoeglicht-test-in-frueher-version-plus-ldat-messung.94802/)
measured 24.2 ms → 5.4 ms with LDAT on an RTX 5070 Ti at 144 FPS, and noted the comparison is weak (demo, not a
game). The demo ran on RTX 20-series and newer. Artifacts at the screen edges were strong at 60 FPS and small above
100 FPS; alz runs far above that.

People have tried copying NVIDIA's file into other games and found it does nothing, because those games have no
integration ([Guru3D thread](https://forums.guru3d.com/threads/reflex-2.458180/)). Deadlock is different: the
integration is there and only the file and the switch are missing.

## What is missing

- **`nvngx_latewarp.dll`.** Valve ships `nvngx_dlss.dll` in `game/bin/win64` and nothing for Late Warp. The file is
  NVIDIA's, was bundled with THE FINALS and an ARC Raiders test build, and comes with PureDark's free demo. The
  [FrameWarp ReShade project](https://github.com/xPoiler/Reshade-Asynchronous-Reprojection) documents the version it
  tested: 310.2.0.0, file description "NVIDIA Latewarp", SHA-256
  `81e63b4a9dcfb99b2b71c3ddfd3ea4a0e9780b778bd47e9a6f7f010a7a6c0f20`.
- **Any confirmation.** One pack, boot's max-FPS config in OptimizationLock, sets `ReflexLateWarp "1"` with no comment
  and no DLL. Twenty other files carry the line commented out with the note "in the code but I don't know what
  enabling them does, and I don't have an nvidia gpu to test". No report of it working was found anywhere.

## Risks, plainly

- **VAC.** Deadlock is VAC-protected. Step 2 puts a DLL that Valve does not ship into the game's `bin` folder. It is
  NVIDIA-signed and the game loads it itself through NVIDIA's own loader, the same way it loads the DLSS file, but
  nobody can promise how VAC treats it. Do step 2 only with `-insecure` (VAC off, no matchmaking) until you have
  decided the risk is acceptable. That decision is yours.
- **It may not work.** Valve may have left the integration unfinished, the driver may refuse the feature for this
  game, or the file version may not match what Valve built against.
- **It may look wrong.** The demo showed smearing at the screen edges during fast turns. Deadlock is third-person, so
  the hero model should be in the no-warp mask; if Valve didn't finish that, the hero will wobble against the scene.
- **Matchmaking.** `NVNGX` isn't a guarded section today. That can change in any patch.

## How to test

**Step 1: is the switch alive? (no extra file, no VAC question)**

1. In `apex-testing/gameinfo.gi`, find the `NVNGX` block and remove `//[test] ` from the `ReflexLateWarp` line.
2. Add `-condebug` to the launch options. Start the game on DX11 with Reflex on, load the Hideout, quit.
3. Open `game/citadel/console.log` and search for `Late Warp` and `LATEWARP`.
   - `Unable to initialize Late Warp : ...` or `NGX_D3D11_CREATE_LATEWARP_EXT failed` means the switch works and the
     game tried to start the feature. Go to step 2.
   - Nothing means the key is ignored in this build, or the message goes elsewhere. Also type `r_low_latency` in the
     console to confirm Reflex itself is on.
   - If anything misbehaves, put the `//[test] ` back.

**Step 2: with the file (only with `-insecure`)**

1. Copy `nvngx_latewarp.dll` next to `game/bin/win64/nvngx_dlss.dll`. Check its SHA-256 and that its digital
   signature says NVIDIA Corporation (Properties → Digital Signatures).
2. Launch with `-insecure -condebug`, go to the Hideout or a bot match.
3. Flick the camera. If Frame Warp is on, the view follows the mouse noticeably more tightly and the screen edges
   smear a little on fast turns. Check `console.log` again; `Need to update the driver to X.Y` names the driver it wants.
4. To measure, use NVIDIA's overlay (PC latency) with the line on and off. Reviewers doubt that the overlay counts
   Frame Warp correctly, so trust a high-speed phone video of mouse and screen more.
5. Remove the DLL and `-insecure` afterwards unless you have decided to keep it.

If step 2 works, this is the largest latency improvement available in Deadlock, and it is worth reporting publicly:
nobody has documented it.

## Other engine keys the binaries read that stock doesn't set

Found by listing every `Section/Key` string in the binaries (346 paths) and removing the ones in stock. Most are
already in liv's and Sqooky's files. The ones no pack uses, with what is known:

| Key | Known from |
|---|---|
| `Engine2/ThreadPoolCoreTypeRequest` | CS2's file sets `"undifferentiated"`. It is the engine-section form of `thread_pool_option`; only matters on CPUs with two core types. |
| `RenderSystem/SetInitialStreamingPoolSizeFromBudget`, `RenderSystem/ReserveMemoryForNonTextureUseMB` | DX11/Vulkan renderer. Texture pool sizing. Default and effect unknown. |
| `SceneSystem/PerObjectLightingSetup` | CS2 sets `1`. |
| `Engine2/RenderingPipeline/OpaqueFade` | CS2 sets `1`. |
| `SceneSystem/DrawParticleChildrenSeparateFromParents` | Dota 2 and Underlords set `1`. |
| `SceneSystem/WindController`, `SubsurfaceProfiles`, `VirtualTextures`, `SupportNeedsDynamicShadows` | Feature switches by name. Defaults unknown. |

None of these is recommended: they are in guarded sections, their defaults are unknown, and engine-section changes
have measured worse on alz's PC twice.

## Also checked, nothing found

- All 124 `gameinfo_cannot_override` convars are also `cheat` or `developmentonly` (one is `sv_cheats`), so none can
  be set from the console, an autoexec or a `+` launch option instead.
- 1,762 client-side convars that no pack and no earlier note mentions were listed and read. No unused performance
  switch stood out; the interesting names are debug views, tools or already at their fast setting.

## The best measured, zero-visual gain is still a mod, and its number went up

[CompLock re-ran its benchmark](https://deadlockconfig.com/docs/benchmarks/) on 2026-11-16 (build 6861, 9800X3D +
RX 9070, Linux, Vulkan, 5 replayed team fights, 48 launches, 95% intervals). Per mod, against the plain game:

| Mod | Average | 1% low | Looks or sounds different? |
|---|---|---|---|
| Sound stack update cap (`soundcap.vpk`) | +9.7% ± 1.1 | +11.1% ± 1.2 | No. Each playing sound recomputes position and volume every 15-17 ms instead of every frame. |
| Particle Pruning (stock tracers) | +7.7% ± 1.1 | +5.1% ± 1.2 | Yes, fewer effect pieces |
| HUD++ | +7.9% ± 1.1 | +8.1% ± 1.2 | Yes, a different HUD |
| Cloth off | +2.8% ± 1.1 | +3.4% ± 1.2 | Yes |
| CompLock's whole `gameinfo.gi` vs stock | +16.3% | +14.3% | Yes (mostly lines alz already has) |

The sound cap is the only entry that is both the largest and invisible, and it is a single file that touches no HUD,
model or particle, so it should sit beside alz's other mods. It was +6.7% / +6.3% a week earlier. The caveats are
the same as before: one Linux PC, replays, CPU-bound at low settings. On a 5700X, which is more CPU-bound than a
9800X3D, the share of frame time spent on sound is likely similar or larger, but that is an inference.

A related convar exists and nobody tunes it: Valve's own block sets `snd_soundmixer_update_maximum_frame_rate "0"`
(no limit; the code default is 10). It caps how often the mix groups update, not the per-sound work the mod caps, so
the expected gain is much smaller. Untested.
