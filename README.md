# alz deadlock cfg

A Deadlock `gameinfo.gi` FPS config that keeps mods working (skins, HUD and particle mods through Deadlock Mod Manager).

## Configs

| Folder | Use it if |
|---|---|
| [`stable/`](stable) | You want a safe start. Any GPU, any mods. |
| [`apex-complock/`](apex-complock) | You run CompLock's mod paks (Particle Pruning, Sound stack cap, HUD++) on an NVIDIA RTX card. This is alz's daily config: about 106 1% lows vs 82 for the old alz config over 18 sessions. |

Each folder has a `gameinfo.gi` and a `video.txt`, so you can drop them straight in.

## Install

1. Back up `steamapps/common/Deadlock/game/citadel/gameinfo.gi` and
   `Steam/userdata/<your id>/1422450/local/cfg/video.txt`.
2. In the new `video.txt`, copy over your own `VendorID`, `DeviceID`, `setting.defaultres` and
   `setting.defaultresheight` (marked with comments).
3. Copy both files over the originals.
4. Launch options: `-novid +fps_max 0 +fps_max_ui 0`.
5. Game updates can overwrite `gameinfo.gi`. Copy it in again after a patch.

Want more FPS? Turn on an upscaler in Settings → Video: DLSS 1.5x to 1.7x on NVIDIA RTX, FSR on anything else.

## More

- [apex-complock/NOTES.md](apex-complock/NOTES.md): results and test plan for the main config.
- [research/RESEARCH.md](research/RESEARCH.md): what still gives FPS (mods, `video.txt`, Windows), and what doesn't.
- [research/HISTORY.md](research/HISTORY.md): how the cfg became mod compatible, and old experiments.
- `tools/lint.py`: after a game update, run
  `python3 tools/lint.py apex-complock/gameinfo.gi --video apex-complock/video.txt` to find lines that no longer work.
- Retired configs live on branches: [`archive/alz`](https://github.com/alzzzik/alz-deadlock-cfg/tree/archive/alz),
  [`archive/alz-experimental`](https://github.com/alzzzik/alz-deadlock-cfg/tree/archive/alz-experimental),
  [`experimental`](https://github.com/alzzzik/alz-deadlock-cfg/tree/experimental).

## Credits

Started from liv's [compylock](https://github.com/7liv/compylock), part of the
[OptimizationLock](https://github.com/Sqooky/OptimizationLock) family, with
[OptiLock](https://github.com/dacooderr/OptiLock) as the mod-compatible reference. Research help from the
[Deadlock Mod Manager](https://github.com/deadlock-mod-manager/deadlock-mod-manager) perf catalog,
[ghempy53/deadlock-config](https://github.com/ghempy53/deadlock-config) and
[simulieren/deadtune](https://github.com/simulieren/deadtune). GPL-3.0, like the upstream projects.
