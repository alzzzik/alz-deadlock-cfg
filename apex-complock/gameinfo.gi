// alz deadlock cfg - apex-complock (2026-11-25): apex-testing's gameinfo.gi + the CPU-side lines from CompLock's gameinfo.gi, for use WITH CompLock's mod paks. github.com/alzzzik/alz-deadlock-cfg - GPL-3.0


GameInfo
{
    game        "citadel"
    title       "Citadel"
    type        "multiplayer_only"
    nomodels    "1"
    nohimodel   "1"
    nocrosshair "0"
    hidden_maps
    {
        test_speakers "1"
        test_hardware "1"
    }
    nodegraph   "0"
    perfwizard  "0"
    tonemapping "0"
    GameData    "citadel.fgd"

    PGIVersion "48C04ECAFC6448F8D3F41F0AA3A15D065501751CF45FBE32DF6CB951BC4F7F6E" // build 6801

    Localize
    {
        DuplicateTokensAssert "1"
    }

    SupportedLanguages
    {
        brazilian  "3"
        czech      "3"
        english    "3"
        french     "3"
        german     "3"
        italian    "3"
        indonesian "3"
        japanese   "3"
        koreana    "3"
        latam      "3"
        polish     "3"
        russian    "3"
        schinese   "3"
        spanish    "3"
        thai       "3"
        turkish    "3"
        ukrainian  "3"
    }

    FileSystem
    {
// Deadlock Mod Manager - Start
        SearchPaths
        {
            Game_UILanguage  "citadel_*LANGUAGE*"
            Game_LowViolence "citadel_lv"

            // Mod/Write must be explicit: without them the engine makes the FIRST Game path (citadel/addons)
            // the MOD path and fails with "Unable to read default keybinding configuration (user_keys_default)".
            Game  "citadel/addons"
            Mod   "citadel"
            Write "citadel"
            Game  "citadel"
            Mod   "core"
            Write "core"
            Game  "core"
        }
// Deadlock Mod Manager - End

        UserSettingsPathID       "USRLOCAL"
        LegacyUserSettingsPathID "MOD"
    }

    MaterialSystem2
    {
        RenderModes
        {
            game "Default"
            game "Forward"
            game "Deferred"
            game "Outline"
            game "Depth"
            game "FrontDepth"
            game "ShadowSilhouette"

            dev "ToolsVis"       // Visualization modes for all shaders (lighting only, normal maps only, etc.)
            dev "ToolsWireframe" // This should use the ToolsVis mode above instead of being its own mode\

            tools "ToolsUtil" // Meant to be used to render tools sceneobjects that are mod-independent, like the origin grid
        }
    }

    MaterialEditor
    {
        DefaultShader "environment_texture_set"
    }

    NetworkSystem
    {
        BetaUniverse
        {
            FakeLag  "40"
            FakeLoss ".1"
            FakeReorderPct   "0"
            FakeReorderDelay "0"
            FakeJitter       "off"
        }

        SkipRedundantChangeCallbacks "1"
    }

    RenderSystem
    {
        IndexBufferPoolSizeMB              "128"  
        LowLatency                         "1"    
        MinStreamingPoolSizeMB             "2048" 
        MinStreamingPoolSizeMBTools        "2048" 
        Use32BitDepthBuffer                "0"    
        Use32BitDepthBufferWithoutStencil  "0"    
        UseReverseDepth                    "1"    
        VulkanAdditionalShaderCache        "vulkan_shader_cache.foz"
        VulkanDefrag                       "1"   
        VulkanMutableSwapchain             "1"   
        VulkanOnlyTestProbability          "0"   
        VulkanRequireDescriptorIndexing    "1"  
        VulkanRequireSubgroupWaveOpSupport "1"   
        VulkanStagingPMBSizeLimitMB        "768" 
        VulkanSteamAppShaderCache          "1"   
        VulkanSteamDownloadedShaderCache   "1"   



//[mods] MaxPreloadTextureResolution           "0" // this stems from the dll so you can assume that there is no default value.
        AllowPartialMipChainImmediateTexLoads "1"


    }

    NVNGX
    {
        AppID        "103371621"
        SupportsDLSS "1"
//[test] ReflexLateWarp "1"   // Reflex 2 Frame Warp switch found in the renderer binaries. Needs nvngx_latewarp.dll, which Valve does not ship. Read research/reports/Reflex 2 Frame Warp key.md first.
    }

    Engine2
    {
        HasModAppSystems "1"
        Capable64Bit     "1"
        URLName          "citadel"
        RenderingPipeline
        {
            SupportsMSAA  "0"
            DistanceField "1"
        }
        PauseSinglePlayerOnGameOverlay "1"
        PauseOnCtrlConsole             "0" // Src2 issues a 'setpause' on holding down CTRL + toggleconsole key, disable this for Deadlock.
        DefensiveConCommands           "1"
        DisableLoadingPlaque           "1"
        LocalServerClientAccess        "1"

        MapMaxCoord "32768"
    }

    ContentBuilder
    {
        ResourceCompilerDirectXUsesWARP "0"
    }

    SoundSystem
    {
        SteamAudioEnabled   "1"
        WaveDataCacheSizeMB "256"
        UsePlatTime         "1"
    }
    Sounds
    {
        HierarchicalEncodingFiles "1"
    }

    ToolsEnvironment
    {
        Engine   "Source 2"
        ToolsDir "../sdktools" // NOTE: Default Tools path. This is relative to the mod path.
    }

    pulse
    {
        pulse_enabled "1"
    }

    Hammer
    {
        fgd                           "citadel.fgd" // NOTE: This is relative to the 'game' path.
        GameFeatureSet                "Citadel"
        DefaultSolidEntity            "trigger_multiple"
        DefaultPointEntity            "info_player_start"
        NavMarkupEntity               "func_nav_markup"
        OverlayBoxSize                "8"
        TileMeshesEnabled             "1"
        RenderMode                    "ToolsVis"
        CreateRenderClusters          "1"
        DefaultMinDrawVolumeSize      "2048"
        DefaultMinTrianglesPerCluster "16384"
        TileGridSupportsBlendHeight   "1"
        TileGridBlendDefaultColor     "0 255 0"
        LoadScriptEntities            "0"
        UsesBakedLighting             "1"
        UseAnalyticGrid               "0"
        SupportsDisplacementMapping   "0"
        SteamAudioEnabled             "1"
        LatticeDeformerEnabled        "1"
        ShadowAtlasWidth              "16384"
        ShadowAtlasHeight             "16384"
        TimeSlicedShadowMapRendering  "1"
    }

    SoundTool
    {
        DefaultSoundEventType "src1_3d"

        SoundEventBaseOptions
        {
            Base.Announcer.VO.2d     ""
            Base.World.VO.Emitter.3d ""
            Base.Hero.VO.Ping.2d     ""
            Base.Hero.VO.2d          ""
            Base.Hero.VO.3d          ""
            Base.Hero.VO.Ability.3d  ""
            Base.Hero.VO.Ultimate.3d ""
            Base.Hero.VO.Dash.3d     ""
            Base.Hero.VO.Effort.3d   ""
            Base.Hero.VO.Pain.3d     ""
            Base.Hero.VO.Melee.3d    ""
            Base.Hero.VO.Death.3d    ""
        }
    }

    RenderPipelineAliases
    {
    }

    ResourceCompiler
    {
        // Overrides of the default builders as specified in code, this controls which map builder steps
        // will be run when resource compiler is run for a map without specifiying any specific map builder
        // steps. Additionally this controls which builders are displayed in the hammer build dialog.
        DefaultMapBuilders
        {
            bakedlighting "1" // Enable lightmapping during compile time
            envmap        "0" // turned off since it currently causes an assert and doesn't work due to some build issue
            nav           "1" // Generate nav mesh data
            sareverb      "0" // Bake Steam Audio reverb
            sapaths       "0" // Bake Steam Audio pathing
            sacustomdata  "1" // Bake Steam Audio custom data
        }

        // Game specific steps run after the map has been built, in the order they are listed here
        GameSpecificPostMapBuildSteps
        {
            pve_nav_cache "1" // Bake the spots the PVE directors spawn things on
        }

        MeshCompiler
        {
            OptimizeForMeshlets       "1"
            TrianglesPerMeshlet       "64" // Maximum valid value currently is 126
            UseMikkTSpace             "1"
            EncodeVertexBuffer        "1"
            EncodeVertexBufferVersion "1"
            EncodeVertexBufferLevel   "3"
            EncodeIndexBuffer         "1"
            SplitDepthStream          "1"
        }

        WorldRendererBuilder
        {
            VisibilityGuidedMeshClustering     "1"
            MinimumTrianglesPerClusteredMesh   "8192"
            MinimumVerticesPerClusteredMesh    "8192"
            MinimumVolumePerClusteredMesh      "8192" // ~20x20x20 cube
            MaxPrecomputedVisClusterMembership "96"
            MaxCullingBoundsGroups             "128"
            UseAggregateInstances              "1"
            AggregateInstancingMeshlets        "1"
            BakePropsWithExtraVertexStreams    "1"
            MergeTranslucents                  "1"

            // 6801: precomputed static shadowmaps for fog (Valve stock)
            BakePrecomputedShadows                     "1"
            BakePrecomputedShadowsForDirectionalLights "0"
            BakePrecomputedDepthPyramids               "0"
            PrecomputedShadowmapAtlas                  "1" // so precomputed shadows work without bindless (dx11)
            PrecomputedShadowmapAtlasBorder            "1"
            PrecomputedShadowmapResolutionDefault      "128" // should match SceneSystem/FogCachedShadowTileSizeTools
        }

        BakedLighting
        {
            Version                          "5" // 6801: maps now ship v5 lightmaps
            ImportanceVolumeTransitionRegion "512" // distance we transition from high to low resolution charts
            LightmapChannels
            {
                direct_light_shadows          "1"
                debug_chart_color             "1"
                directional_irradiance_sh2_dc "1"

                // 6801: the r/g/b channels were replaced by one luminance channel
                directional_irradiance_sh2_lum
                {
                    CompressedFormat "DXT1"
                }
            }
            LightmapGutterSize   "2" // For bicubic filtering
            UseStaticLightProbes "0"
            LPVAtlas             "1"
        }

        SteamAudio
        {
            ReverbDefaults
            {
                GridGenerationType          "0" // 0: Automatic, Everywhere, 1: Automatic, Use Probe Generation Volume, 2: Manual
                FilterUsingVolumes          "1" // Filter Using Probe Exclusion Volumes ( boolean )
                FilterUsingNavMesh          "0" // Filter Using NavMesh
                GridSpacing                 "3.0"
                HeightAboveFloor            "1.5"
                RebakeOption                "0" // 0: cleanup, 1: manual, 2: auto
                NumRays                     "32768"
                NumBounces                  "64"
                IRDuration                  "1.0"
                AmbisonicsOrder             "1"
                ClusteringEnabled           "0"
                ClusteringCubemapResolution "16.0"
                ClusteringDepthThreshold    "10.0"
            }
            PathingDefaults
            {
                GridGenerationType "0" // 0: Automatic, Everywhere, 1: Automatic, Use Probe Generation Volume, 2: Manual
                FilterUsingVolumes "1" // Filter Using Probe Exclusion Volumes ( boolean )
                FilterUsingNavMesh "0" // Filter Using NavMesh
                GridSpacing        "3.0"
                HeightAboveFloor   "1.5"
                RebakeOption       "0" // 0: cleanup, 1: manual, 2: auto
                NumVisSamples      "1"
                ProbeVisRadius     "0"
                ProbeVisThreshold  "0.1"
                ProbeVisPathRange  "1000.0"
            }
            CustomDataDefaults
            {
                GridGenerationType         "0" // 0: Automatic, Everywhere, 1: Automatic, Use Probe Generation Volume, 2: Manual
                FilterUsingVolumes         "1" // Filter Using Probe Exclusion Volumes ( boolean )
                FilterUsingNavMesh         "1" // Filter Using NavMesh
                GridSpacing                "6"
                HeightAboveFloor           "1.5"
                RebakeOption               "0" // 0: cleanup, 1: manual, 2: auto
                BakeOcclusion              "0" // 0: Disabled, 1: Enabled
                BakeDimensions             "1" // 0: Disabled, 1: Enabled
                BakeMaterials              "0" // 0: Disabled, 1: Enabled
                OcclusionPathing           "1"
                OcclusionReflection        "0"
                OcclusionReflectionRays    "16384"
                OcclusionReflectionBounces "16"
                DimensionsOutsideThreshold "0.02"

            }
            ProbeGenerationVolumeDefaults
            {
                Spacing            "3.0"
                Height             "1.5"
                HeightSpacing      "12"
                UseForReverb       "0"
                UseForPathing      "0"
                UseForCustomData   "1"
                FilterUsingVolumes "1"
                FilterUsingNavMesh "1"
            }
        }
        SoundEventScripts
        {
            OmitMetadataAndLineText "1"
        }
        SoundStackScripts
        {
            CompileStacksStrict "1"
        }
        VisBuilder
        {
            MaxVisClusters                     "4096"
            PreMergeOpenSpaceDistanceThreshold "128.0"
            PreMergeOpenSpaceMaxDimension      "2048.0"
            PreMergeOpenSpaceMaxRatio          "8.0"
            PreMergeSmallRegionsSizeThreshold  "20.0"
        }

        VDataLocalization
        {
            GameOutputPath "resource/localization/citadel_vdata"
            TokenPrefix    "Citadel_VData_"
        }

        TextureCompiler
        {
            // CompressMinRatio        "95"
            // CompressMipsOnDisk      "1"
            // Compressor              "lz4"
            // PublicToolsDefaultMaxRes "2048"
            AllowNP2Textures           "1"
            AllowPanoramaMipGeneration "1"
        }
    }

    Source1Import
    {
        forcevtxfileupconvert "1"
    }

    WorldRenderer
    {

        BindlessSceneObjectDesc      "CitadelBindlessDesc"
        EnvironmentMapCacheSizeTools "2"              
        EnvironmentMapColorSpace     "linear"         
        EnvironmentMapFaceSize       "256"            
        EnvironmentMapFormat         "BC6H"           
        EnvironmentMapMipProcessor   "GGXCubeMapBlur" 
        EnvironmentMapPreviewFormat  "BC6H"           
        EnvironmentMapRenderSize     "1024"           
        EnvironmentMapUseCubeArray   "1"              
        EnvironmentMaps              "1"              
        GrassCastsShadows            "0"              



//[mods] AggregateInstanceStream    "1"    
//[mods] AggregateRTProxyDesc       "1"    
//[mods] AggregateSceneObjectDesc   "1"    
//[mods] AggregateVertexColorStream "1"    
//[mods] EnvironmentMapCacheSize    "1024" 
//[mods] LPVEdgeBlending            "0"    

    }

    SceneSystem
    {
        CSMCascadeResolution                        "0"          
        CubemapFog                                  "0"          
        DefaultShadowTextureHeight                  "0"          
        DefaultShadowTextureWidth                   "0"          
//[mods] DisableLateAllocatedTransformBuffer         "1"          
        DynamicShadowResolution                     "1"          
//[6801 renamed to ...Tools, tools-only] FogCachedShadowAtlasHeight                  "0"
//[6801 renamed to ...Tools, tools-only] FogCachedShadowAtlasWidth                   "0"
//[6801 renamed to ...Tools, tools-only] FogCachedShadowTileSize                     "0"
        FogCachedShadowAtlasWidthTools              "2048" // 6801 Valve stock
        FogCachedShadowAtlasHeightTools             "2048" // 6801 Valve stock
        FogCachedShadowTileSizeTools                "128"  // 6801 Valve stock, matches PrecomputedShadowmapResolutionDefault
        FrameBufferCopyFormat                       "R11G11B10F" 
        GpuLightBinner                              "1"          
        GpuLightBinnerSunLightFastPath              "1"          
//[mods] HDRFrameBuffer                              "0"          
//[mods] LayerBatchThresholdFullsort                 "200"        
//[mods] MinimumLateAllocatedVertexCacheBufferSizeMB "64"         
        NonTexturedGradientFog                      "0"          
        SunLightManagerCount                        "0"          
        SunLightManagerCountTools                   "0"         
        SunLightMaxCascadeSize                      "2"          
        SunLightShadowRenderMode                    "Depth"      
        Tonemapping                                 "0"         
        TransformTextureRowCount                    "1024"       
        TransformTextureRowCountToolsMode           "6144"       
        VolumetricFog                               "0"          




        WellKnownLightCookies
        {
            blank      "materials/effects/lightcookies/blank.vtex"
            flashlight "materials/effects/lightcookies/flashlight.vtex"
        }

        ComputeShaderSkinning "1"
    }

    NavSystem
    {
        NavTileSize   "128.0"
        NavCellSize   "1.5"
        NavCellHeight "2.0"

        // Hull definitions live in scripts/nav_hulls.vdata
        // Preset definitions live in scripts/nav_hulls_presets.vdata
        NavHullsPreset "default"

        NavRegionMinSize              "8"
        NavRegionMergeSize            "20"
        NavEdgeMaxLen                 "1200"
        NavEdgeMaxError               "51.0"
        NavVertsPerPoly               "4"
        NavDetailSampleDistance       "120.0"
        NavDetailSampleMaxError       "2.0"
        NavSmallAreaOnEdgeRemovalSize "81.0"
    }

    AnimationSystem
    {
        DisableServerInterpCompensation "1"
        DisableAnimationScript          "1"
        ServerPoseRecipeHistorySize     "60"
        ClientPoseRecipeHistorySize     "60"

    }

    ModelDoc
    {
        models_gamedata "models_gamedata.fgd"
        features        "modelconfig;gamepreview;wireframe_backfaces;distancefield"
    }


    Particles
    {
        BindlessParticleShader               "1"
        EnableParticleShaderFeatureBranching "1"
        Features                             "non_homogenous_forward_layer_only"
        Float16HDRBackBuffer                 "1"
        PET_SupportFadingOpaqueModels        "1"

//[mods] EnableMixedResolution         "1" 
//[mods] MPropertyFlattenIntoParentRow "1"
//[mods] ParticleTraceOffsetOnlyHit    "1"
//[mods] ParticlesFoggedByDefault      "0"
//[mods] PerVertexLighting             "0"
//[mods] PostSimulate                  "0"
    }

    Physics
    {
        EnableWorldCompounds "1"
    }

    ConVars
    {
        // =====================================================================================
        // apex block. Every line below was checked against Valve's convar dump (build 6861):
        // it exists, is not gameinfo_cannot_override, is inside its min/max, differs from Valve's
        // default and is not owned by video.txt. Re-checked against build 6868 on 2026-11-25: no apex line changed flags or was removed. Replicated lines are kept only in their own group.
        // Full reasoning for every line: apex-testing/NOTES.md
        // Tags:  [arch]  archive convar: this is only a DEFAULT. A value saved in
        //                machine_convars.vcfg wins. Use the launch options in README to force it.
        //        [cheat] cheat-flagged: applies at startup from this file; can't be changed live.
        //        [zv]    new vs alz, zero visual change.   [fight] new vs alz, small visual cost.
        //        [test]  off by default; remove the leading // to A/B one at a time.
        // r2 (2026-11-16): every line re-read against CompLock's CVAR Index (plain-language description of
        // 4,886 cvars, build 6861), DMM's notes and Sqooky's comments. See research/reports/Convar review r2.md.
        // =====================================================================================

        // --- View and feel (alz's own look; not FPS) ---
        r_aspectratio                                "2.4"
        citadel_camera_use_vmdl_flatten_horizontal   "false"
        citadel_camera_wobble_disable                "true"
        citadel_camera_listening_offset              "-1"
        citadel_camera_pitch_default                 "0"
        r_citadel_clip_sphere_min_opacity            "0"      //[cheat]
        cam_idealdelta                               "0"      //[arch]
        cam_ideallag                                 "0"      //[arch]
        cc_captiontrace                              "0"
        mm_idle_enabled                              "false"
        mm_prefer_solo_only                          "true"   //[arch]
        citadel_show_survey                          "true"
        steam_inputhandler_enabled                   "false"

        // --- Input and frame pacing ---
        engine_accurate_input_processing_delta_time  "true"
        engine_max_ticks_to_simulate                 "2"

        // --- Things not drawn (deliberate, same as alz) ---
        r_drawropes                                  "false"  //[cheat]
        r_render_hair                                "false"  //[cheat]
        r_hair_ao                                    "0"
        r_rendersun                                  "0"      //[cheat]
        r_pixelvisibility_partial                    "false"  //[cheat]
        cl_show_splashes                             "0"
        sc_clutter_enable                            "false"
        r_grass_quality                              "0"
        r_grass_start_fade                           "0"
        r_grass_end_fade                             "0"
        violence_ablood                              "0"      //[arch]
        violence_agibs                               "0"      //[arch]
        violence_hblood                              "0"      //[arch]
        violence_hgibs                               "0"      //[arch]

        // --- Culling and LOD ---
        r_size_cull_threshold                        "0.9"    // 0.8 is Valve's. Higher hides crates / trooper bars at range.
        sc_screen_size_lod_scale_override            "0.55"   // known cost: holes in Victor/Paige at some angles. Delete the line if it bothers you.
        sc_allow_dithered_lod                        "false"
        sc_instanced_mesh_opaque_fade                "false"
        sc_instanced_mesh_size_cull_bias_shadow      "10"
        r_strip_invisible_during_sceneobject_update  "1"

        // --- Shadows (sun and cascades are already off in SceneSystem + video.txt) ---
        lb_enable_shadow_casting                     "0"
        lb_barnlight_shadowmap_scale                 "0"
        lb_csm_cascade_size_override                 "1"
        lb_csm_draw_alpha_tested                     "0"
        lb_csm_draw_translucent                      "0"
        lb_dynamic_shadow_resolution_base            "128"    // engine minimum (alz had 16, which is raised to 128 anyway)
        lb_sun_csm_size_cull_threshold_texels        "60"
        r_citadel_sun_shadow_slope_scale_depth_bias  "0"
        sparseshadowtree_enable_rendering            "0"

        // --- Lighting and post ---
        cl_retire_low_priority_lights                "1"
        mat_max_lighting_complexity                  "0"      //[cheat]
        r_ssao                                       "0"
        lb_ssss_samples                              "3"      // engine minimum (alz had 0, which is raised to 3 anyway)
        r_lightmap_size                              "2048"
        r_lightmap_size_directional_irradiance       "0"
        volume_fog_intermediate_textures_hdr         "false"
        r_character_decal_resolution                 "256"    // engine minimum (alz had 4)
        r_citadel_disable_particle_lights            "true"   //[fight] Valve dev tip. Ability effects still draw; they stop lighting floor and heroes. Light count grows with fight size. Flip 0/1 live to compare.

        // --- Textures ---
        r_texturefilteringquality                    "5"      // 16x aniso (alz's choice; 0 = bilinear is the FPS option)
        r_texture_budget_threshold                   "0.7"
        r_texture_budget_update_period               "0.5"

        // --- Particles (the fight-time CPU cost) ---
        cl_particle_sim_fallback_threshold_ms        "1"
        cl_particle_sim_fallback_base_multiplier     "100"
        cl_particle_fallback_base                    "5"      // also in video.txt, which wins
        cl_particle_fallback_multiplier              "10"     // also in video.txt, which wins
        r_limit_particle_job_duration                "true"
        r_particle_max_size_cull                     "600"    // Valve: bigger systems "skip culling to save CPU. They will be drawn anyway"
        r_particle_max_texture_layers                "4"      // never below 4 (Infernus/Paige/Drifter effects go blocky)
        r_particle_model_per_thread_count            "64"
        r_physics_particle_op_spawn_scale            "0"

        // --- Scene batching / CPU ---
        sc_aggregate_bvh_threshold                   "256"
        sc_layer_batch_threshold                     "256"
        cl_batch_entity_list_ops_during_latch        "true"   // Valve: "to avoid mutex contention"
        cl_simulate_dormant_entities                 "false"
        cl_fasttempentcollision                      "1000"   // temp effects (tracers, sparks) do their cheap collision check far less often
        r_vma_defrag_algorithm                       "0"
        rtx_dynamic_blas                             "false"
        rtx_force_default_hitgroup                   "true"
        rtx_texture_resolution                       "64"
        v8_maximum_heap_size_mb                      "1024"   // more headroom for script HUD mods
        cl_generate_postdataupdatepreserved          "false"  //[zv] skip update callbacks for entities that did not change. Watch: idle things that stop updating.
        panorama_min_comp_layer_cache_cost           "0"      //[zv] let the UI cache every composition layer. Sqooky: about 300 MB more VRAM.
        panorama_comp_layer_lru_lifetime             "4"      //[zv] keep cached UI layers 4 s (Valve 1). Watch HUD mods / VRAM in long sessions.

        // --- Wind and ropes (already invisible: wind strength 0, ropes hidden) ---
        r_world_wind_strength                        "0"
        r_world_wind_frequency_grass                 "0"      //[zv]
        r_world_wind_frequency_trees                 "0"      //[zv]
        wind_system_default_resolution_xy            "0"      //[zv]
        wind_system_temporal_smoothing               "false"  //[zv]
        rope_collide                                 "0"      //[zv]
        rope_wind_dist                               "0"      //[zv]

        // --- Sound ---
        audio_enable_vmix_mastering                  "false"  //[cheat]
        snd_steamaudio_max_occlusion_samples         "32"     //[cheat]
        snd_steamaudio_num_diffuse_samples           "512"    //[cheat]

        // --- Animation, physics and far health bars (developmentonly + replicated; see README "Replicated lines") ---
        ik_final_fixup_enable                        "0"      // skips the last IK correction pass. Every pack sets it.
        skeleton_instance_lod_optimization           "true"   //[zv] computes bones only for the model's current LOD instead of every LOD. Watch for odd poses at a distance.
        phys_cull_internal_mesh_contacts             "true"   // skips physics contacts inside meshes
        citadel_camera_see_distance_max              "7000"   // units farther than this lose their overhead health bar (Valve 20000)
        debug_draw_enable                            "false"

        // --- [cl2] From CompLock's gameinfo.gi (build 6866 pack, 2026-11-24). Kept so that CompLock's mods run with the same ---
        // --- engine settings they were measured with. CPU-side; some small visual costs, noted per line. See apex-complock/NOTES.md. ---
        // HUD++ support (the Pack Builder writes these for HUD++ with cumulative damage numbers)
        citadel_damage_text_batching_window_individual   "2"
        citadel_unit_status_healthbar_highlight_speed    "100"
        citadel_damage_text_cumulative_mode              "1"      //[arch] HUD++ cumulative damage. Saved value wins; set it in HUD++ if it doesn't stick.
        citadel_action_refresh_interval                  "0.11"   // Valve 0.1
        panorama_panel_occlusion                         "0"      // Valve true. CompLock ships it; no description from Valve.
        // Animation: no inverse kinematics, no foot locking, no facial morphs. Feet don't adapt to slopes/steps; faces don't animate.
        // CompLock per-line numbers (their CPU-bound rig): r_morphing_enabled +2.1%, animgraph_footlock_enabled +2.0%, ik_enable +1.4%.
        ik_enable                                        "false"
        ik_constraints_enabled                           "false"
        ik_fabrik_backwards_enabled                      "false"
        ik_fabrik_forwards_enabled                       "false"
        ik_planetilt_enable                              "false"
        animgraph_footlock_enabled                       "false"
        animgraph_footlock_calculate_tilt                "false"
        animgraph_footlock_ground_roll                   "false"
        animgraph_footlock_hip_offset_enable             "false"
        animgraph_footlock_ik_enable                     "false"
        animgraph_footlock_trace_ground_enabled          "false"
        animgraph_footlock_use_hip_shift                 "false"
        animgraph_slowdownonslopes_enabled               "false"
        r_morphing_enabled                               "false"  //[cheat]
        r_smooth_morph_normals                           "0"
        // Camera, cloth, props
        citadel_camera_soft_collision                    "0"      // no 128 camera traces per frame; camera snaps in at walls
        citadel_camera_soft_collision_multi_thread       "0"
        cloth_update                                     "false"  // capes and coats hang frozen (CompLock's file had this on during your CompLock sessions)
        props_break_max_pieces_perframe                  "0"      // apex had 1; crates break with no pieces
        // Small render-side extras
        r_haircull_percent                               "100"
        r_hair_indirect_transmittance                    "false"
        r_ropetranslucent                                "false"
        r_monitor_3dskybox                               "0"
        r_character_decal_monitor_render_res             "64"
        r_impacts_alt_orientation                        "false"
        sc_clutter_density_full_size                     "0.5"
        sc_clutter_density_none_size                     "1"

        // --- [test] One at a time. Each has a stated mechanism and no measurement. ---
//[test] r_particle_max_detail_level                 "2"      // skips effect parts that need detail level 3. Console must print 2. NEVER 0 (ability visuals go missing).
//[test] r_late_particle_job_sync                    "1"      // waits for particle jobs later in the frame. In Sqooky, OptiLock and ghempy53. Revert on any crash.
//[test] citadel_npc_ticks_per_anim_update           "3"      // troopers and other NPCs animate every 3rd tick instead of every 2nd. Nobody ships this.
//[test] panorama_worldpanel_update_culling          "true"   // stops updating far or tiny health bars. Their numbers can be stale until you get close.
//[test] phys_threaded_cloth_bone_update             "true"   // the next four move bone/physics work off one thread. Valve ships them off; OptiLock turns them on. Crash risk.
//[test] phys_threaded_kinematic_bone_update         "true"
//[test] phys_threaded_transform_update              "true"
//[test] ragdoll_parallel_pose_control               "true"
        // --- [test] added 2026-11-25 (build 6868), from CompLock's 18-20 Nov updates. Same rule: one at a time. ---
        // [test] sc_layer_batch_threshold_fullsort 80 (Valve's code default; CompLock moved 20 -> 80): Valve's stock block below sets 20 and a later line wins,
        //        so to try it, change the "20" on the sc_layer_batch_threshold_fullsort line in Valve's block instead of adding a line here.

        // --- Listed as "Unused" in CompLock's CVAR Index (the game registers them but reads them nowhere, by that index). ---
        // --- Kept only because alz has them and they cost nothing either way. Not a reason to expect anything from them. ---
        citadel_tightcamera_alternative              "1"
        citadel_bullet_shot_offset_fade_time         "0"
        r_drawtracers_firstperson                    "false"
        r_size_cull_threshold_shadow                 "2.4"
        r_particle_skip_postsim                      "true"
        cloth_sim_on_tick                            "0"
        snd_steamaudio_reverb_order_rendering        "0"

        // ===== end of apex block. Everything from here down is Valve's stock ConVars block, untouched. =====

        rate
        {
            min     "133120"
            default "786432"
            max     "1000000"
        }

        // Networking - General
        sv_minrate                   "133120"
        sv_maxunlag                  "0.500"
        sv_maxunlag_player           "0.200"
        sv_lagcomp_filterbyviewangle "false"
        cl_usesocketsforloopback     "1"
        cl_poll_network_early        "0"
        cq_buffer_bloat_msecs_max    "120" // 7.68 ticks @64hz max cq bloat

        // Networking - Induced latency (pred offset)
        cl_tickpacket_recvmargin_desired              "5" // 5 ms base, min. floor for protecting against thrashing the queue
        cl_tickpacket_desired_queuelength             "1"
        cl_async_usercmd_send_disabled_recvmargin_min "0.5" // Additional frame since we do not use the async usercmd send (potentially unneccessary)
        cl_clock_buffer_ticks                         "1"   // Buffer added to the simulation clock margin ( affects pred offset and cadence of client world ticks )
        cl_interp_ratio                               "0"
        cl_async_usercmd_send                         "false" // We don't support early prediction at the moment, which async send requires

        // Nav gen
        nav_gen_connect_dist_a "2.0"

        // Spew warning when adding/removing classes to/from the top of the hierarchy
        panorama_classes_perf_warning_threshold_ms "0.75"

        // Panorama - enable minidumps on JS exceptions
        panorama_js_minidumps "1"
        // Enable the render target cache optimization.
        panorama_disable_render_target_cache "0"

        // Enable the composition layer optimization
        panorama_skip_composition_layer_content_paint "1"

        // Steam audio loading data
        snd_steamaudio_load_reverb_data     "0"
        snd_steamaudio_load_pathing_data    "0"
        snd_steamaudio_load_occlusion_data  "0"
        snd_steamaudio_load_dimensions_data "1"
        snd_steamaudio_load_materials_data  "0"

        // Steam Audio project specific convars
        snd_steamaudio_enable_custom_hrtf                                "0"
        snd_steamaudio_active_hrtf                                       "0"
        snd_steamaudio_pathing_order                                     "3"
        snd_steamaudio_pathing_order_rendering                           "3"
        snd_steamaudio_enable_pathing                                    "0"
        snd_steamaudio_enable_reverb                                     "0"
        snd_steamaudio_reverb_level_db                                   "-6"
        snd_steamaudio_enable_pathing                                    "0"
        snd_steamaudio_invalid_path_length                               "0.0"
        snd_steamaudio_max_probes_customdata_dimensions                  "100000"
        snd_steamaudio_dimensions_grid_height_max                        "100"
        snd_steamaudio_baked_dimensions_probelookup_usealternate         "1"
        snd_steamaudio_custombake_dimensions_size_and_inout_bake_enabled "1"
        snd_steamaudio_custombake_dimensions_outsidefield_bake_enabled   "0"
        snd_steamaudio_custombake_dimensions_smallsizefield_bake_enabled "0"
        snd_steamaudio_dimensions_max_ray_length                         "2500"
        cl_disconnect_soundevent                                         "citadel.convar.stop_all_game_layer_soundevents"
        snd_event_browser_default_stack                                  "citadel_default_3d"

        // voip
        voice_in_process "1"

        // Sound debugging
        snd_report_audio_nan "1"

        // Audio system settings
        snd_sos_max_event_base_depth "10"
        sos_use_guid_filter          "1"

        voice_always_sample_mic
        {
            version "2"
            default "0"
        }

        reset_voice_on_input_stallout "0"
        voice_input_stallout          "0.5"

        audio_enclosure_calc_enabled "0"

        sc_layer_batch_threshold_fullsort "80"   // [cl2] Valve stock 20; CompLock and Valve's code default 80

        // Perf/Parallelism
        iv_parallel_restore "1"

        // For perf reasons, since we don't use source-based DSP:
        disable_source_soundscape_trace "1"


        fps_max    "400"
        fps_max_ui "120"

        in_button_double_press_window "0.3"

        // Convars that control spatialization of UI audio.
        snd_ui_positional            "1"
        snd_ui_spatialization_spread "2.4"

        // sound volume rate change limiting
        snd_envelope_rate                        "100.0"
        snd_soundmixer_update_maximum_frame_rate "0"

        //don't let people mess with speaker config settings.
        speaker_config
        {
            min     "0"
            default "0"
            max     "2"
        }


        snd_soundmixer                   "Default_Mix"
        cloth_filter_transform_stateless "0"

        cl_joystick_enabled       "0"
        panorama_joystick_enabled "0"

        snd_event_browser_focus_events "true"

        cl_max_particle_pvs_aabb_edge_length "100"

        // Particles
        cl_aggregate_particles       "true"
        r_particle_batch_collections "1"

        citadel_enable_vdata_sound_preload "true"

        r_add_views_in_pre_output "1"

        // Disable Cubemap Brightening
        lb_cubemap_normalization_max "1"

        update_all_keyframed_in_spatial_partition_update               "0"
        parallel_update_surrounding_bounds_in_spatial_partition_update "1"
        always_perform_full_spatial_partition_update                   "1"
        cl_interp_parallel                                             "1"
        parallel_perform_invalidate_physics                            "1"
        phys_agg_world_compounds                                       "0"

        cl_updaterate                "128"
        sv_parallel_checktransmit    "2"
        net_gather_child_fields_only "1"
    }

    Memory
    {
        EstimatedMaxCPUMemUsageMB "1"
        EstimatedMinGPUMemUsageMB "1"

        ShowInsufficientPageFileMessageBox      "1"
        ShowLowAvailableVirtualMemoryMessageBox "1"
    }
}
