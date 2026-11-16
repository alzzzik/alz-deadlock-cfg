# Convar review r2: every apex line re-read against the community's descriptions (2026-11-16)

The first apex pass classified lines by flags (exists, blocked, replicated, default, range). This pass asks a
different question of each line: **what does it do?** It uses three written sources and changes apex-testing where
the answer contradicts the line.

## Sources

| Source | What it gives |
|---|---|
| [CompLock CVAR Index](https://deadlockconfig.com/docs/cvars/) (build 6861) | A plain-language description for 4,193 of 4,886 cvars, how each can be set (console, `gameinfo.gi`, video settings, saved value), whether it is locked online, and a category. 526 cvars are filed under "Unused" and 118 under "Tools". The page does not say how "Unused" was decided. |
| [Deadlock Mod Manager catalog](https://github.com/deadlock-mod-manager/deadlock-mod-manager/tree/main/packages/perf-catalog) (2026.11.13-1) | 474 hand-written descriptions and the side effects pack authors have documented. |
| Sqooky's comments in [OptimizationLock](https://github.com/Sqooky/OptimizationLock) | The author's own reason for each line, including the honest "not sure what it does" ones. |

## Three corrections to the first pass

**1. Replicated lines were removed too quickly.** The first pass dropped 11 lines because they are `replicated`, on
the rule "the server's value wins online". The CVAR Index splits them: `cheat` + `replicated` cvars are marked locked
online, but `developmentonly` + `replicated` ones are marked "gameinfo.gi only" and **not** locked. That fits
what players see: `props_break_max_pieces_perframe` and `citadel_camera_see_distance_max` have visible, documented
effects in real matches. Nobody has published a console read from a matchmade game, so this is still unproven
either way. apex-testing now restores the five that do something useful and stays without the rest:

| Line | Decision | Why |
|---|---|---|
| `ik_final_fixup_enable 0` | restored | Skips the last IK pass. In all four packs and in alz. |
| `props_break_max_pieces_perframe 1` | restored | Crates break into 1 piece per frame, not 16. |
| `phys_cull_internal_mesh_contacts true` | restored | Skips physics contacts inside meshes. |
| `citadel_camera_see_distance_max 7000` | restored | Far units lose their overhead health bar, so fewer world panels update. |
| `debug_draw_enable false` | restored | No debug drawing. |
| `citadel_shoot_forward_offset 0` | **stays out, and should leave stable and alz too** | Index: "The server uses its own value, so changing it only makes your shots mispredict." If the line applies, it hurts; if it doesn't, it is dead. |
| `citadel_stuck_camera_trace_extra_length`, `snd_occlusion_rays`, `snd_occlusion_bounces`, `rpg_camera_yaw` | stay out | Unused, or a debug camera. |
| `citadel_melee_shake_*`, `nav_edit_use_camera`, hideout ball | stay out | Filed under "Server". |

**2. "Valve already turns every threading switch on" was wrong.** The index lists seven that ship off:
`phys_threaded_cloth_bone_update`, `phys_threaded_kinematic_bone_update`, `phys_threaded_transform_update`,
`ragdoll_parallel_pose_control`, `run_voicecontainer_async`, `r_ui_update_parallel_with_server`,
`sv_tick_parallel_with_client`. OptiLock turns the first four on. Valve leaving them off suggests they are unfinished
or unsafe, so they went into the `[test]` group, not the active file.

**3. `engine_low_latency_sleep_after_client_tick` is filed under "Unused".** This is the line with split reports
("more FPS" on the forum, "keyboard lag" from ghempy53) and it is in DMM Clean. If the index is right, both reports
were noise. The `[test]` line was removed. The same goes for other popular lines the index calls unused:
`panorama_disable_blur`, `cl_smoothtime`, `mat_tonemap_bloom_scale`.

## Lines removed because of what they do

| Line | What the description says | Why it goes |
|---|---|---|
| `snd_enable_subgraph_corenull_passthrough false` | "Pass-through optimisation in the sound graph: subgraphs set to the empty sound are passed through instead of processed." | `false` turns an optimisation **off**. Sqooky's comment ("disabling these should help with performance") has it backwards, like `snd_boxverb_simd`. |
| `audio_enable_spawn_mask_mix_layer false` | "The mix layer that mutes certain sounds at map load boundaries." | Not a cost; turning it off only un-mutes load noise. |
| `r_particle_model_new8 false` | "Switches model particles to the newer renderer path. Works together with `r_particle_model_new`." | `r_particle_model_new` is `false` by default, so the pair is already off. |
| `r_ssao_strength 0` | "Ambient occlusion strength in the asset preview tool. The game ignores it." | Tool-only. |
| `r_drawviewmodel false`, `csm_viewmodel_*` (3), `sparseshadowtree_*_viewmodel` (2) | "...the first-person view model, which Deadlock doesn't draw." | Nothing to turn off. |
| `citadel_camera_height 0` | "Changing it doesn't move the hero camera." | No effect. |
| `r_citadel_gpu_preview_denoise_passes 0`, `r_renderdoc_auto_shader_pdbs false` | Lightmap previews; RenderDoc captures. | Developer tools. |

Seven more are filed under "Unused" with no explanation: `cloth_sim_on_tick`, `r_particle_skip_postsim`,
`r_size_cull_threshold_shadow`, `r_drawtracers_firstperson`, `citadel_tightcamera_alternative`,
`citadel_bullet_shot_offset_fade_time`, `snd_steamaudio_reverb_order_rendering`. Because the method isn't published,
they stay in the file in their own labelled group. They cost nothing if unused and match alz if not.

## Lines understood better, kept

- **Every shadow line is belt and braces.** Index, on `lb_enable_shadow_casting`: "Shadows only draw with shadow
  quality above Off." alz's `video.txt` has shadow quality 0, so the nine `lb_csm_*`, `sparseshadowtree_*` and shadow
  cull lines change nothing today. They matter only if you raise shadow quality in the menu.
- **`r_particle_max_size_cull 600`** makes *more* particle systems skip culling ("always drawn"). It trades GPU work
  for CPU work, which suits a CPU-bound PC. Sqooky says the same: lower it "if you have GPU overhead to spare".
- **`cl_fasttempentcollision 1000`**: the index calls it a per-frame limit on fast collision checks for tracers and
  sparks; Sqooky reads it as "higher usually = more work". In the Source 1 code this cvar is a frame interval between
  checks, so 1000 means far fewer checks. The sources disagree and nobody measured it. Kept.
- **`r_particle_model_per_thread_count 64`**: "Lower values split the work into more jobs." 64 means fewer, larger
  jobs than Valve's 32. Direction of the effect on a 16-thread CPU is unknown. Kept as alz has it.
- **`sc_aggregate_bvh_threshold 256`**: "Only aggregate meshes with more than this many pieces get a culling
  hierarchy." Raising it gives fewer meshes a hierarchy. Sqooky: "Not fully sure what these do." Kept, unproven.
- **`panorama_min_comp_layer_cache_cost 0`** costs about 300 MB of VRAM (Sqooky). Fine on a 12 GB card.
- **`audio_enable_vmix_mastering false`** changes how the final mix sounds (DMM). It is a taste call, not FPS.
- **`mm_idle_enabled false`** turns off the queue's idle warning and removal. **`citadel_show_survey true`** forces
  the survey screen on. Neither is performance; they are liv's preferences.

## New lines

| Line | State | What it does | Who uses it |
|---|---|---|---|
| `skeleton_instance_lod_optimization true` | **on**, `[zv]` | Computes bones only for the model's current LOD instead of every LOD. | CompLock, Sqooky, ghempy53 |
| `r_late_particle_job_sync 1` | `[test]` | Waits for particle work later in the frame. | Sqooky, OptiLock, ghempy53 |
| `citadel_npc_ticks_per_anim_update 3` | `[test]` | Troopers animate every 3rd tick instead of every 2nd. | nobody |
| `panorama_worldpanel_update_culling true` | `[test]` | Stops updating far or tiny health bars. | nobody; values can be stale |
| `phys_threaded_*` (3), `ragdoll_parallel_pose_control` | `[test]` | Moves bone and physics transform work off one thread. | OptiLock |
| `r_particle_max_detail_level 2` | `[test]` | "Parts that need a higher level are skipped." | (0 in OptiLock; never use 0) |

## Result

apex-testing went from 108 active lines to 95, plus 8 `[test]` lines. `tools/lint.py` no longer counts replicated
lines as dead weight, and a bug in it was fixed (it treated `"1"` and `"true"` as different values). With the fix,
stable and alz each show 114 active and 57 dead-weight lines; the first report's "122 and 61" came from the old rule.

## One thing to do in stable and alz

Delete `citadel_shoot_forward_offset "0"`. It can only be dead or harmful.
