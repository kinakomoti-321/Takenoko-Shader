Shader "Takenoko/StandardShader"
{
    //------------------------------------
    //Naming convention
    //------------------------------------
    //Properties : _TestName
    //Struct : TestName
    //Function
    //- math(static) function : testname
    //- self made function : TestName_TK()
    //- experimental function : TestName_TK_EX()
    //- other function : TestName or testName
    //Variable : testName

    //Define : TEST_NAME
    //ShaderKeyWord : _TESTNAME_ON
    //Constant : TESTNAME

    //Fragment and Vertex : [Frag or Vert]TKTestName

    Properties
    {
        //Menu FoldOut
        _RenderModeMenu ("Render Mode Menu", Float) = 0.0
        _MainTexMenu ("MainTexMenu", Float) = 0.0
        _EmissionMenu ("EmissionMenu", Float) = 0.0
        _ThinFilmMenu ("ThinFilmMenu", Float) = 0.0
        _LightmapMenu ("LightmapMenu", Float) = 0.0
        _DebugMenu ("DebugMenu", Float) = 0.0
        _ExperimentalMenu ("ExperimentalMenu", Float) = 0.0

        [Enum(UV, 0, UV2, 1, Triplanar, 2, Biplanar, 3, DitheredTriplanar, 4, XYZMask, 5)] _MappingMode ("Mapping Mode", Int) = 0
        [Enum(None, 0, Stochastic, 1, HexTiling, 2, Volonoi, 3)] _SamplerMode ("Sampler Mode", Int) = 0
        [Toggle(_MAPPING_POS_OBJ)] _MappingPosObj ("Mapping Position Object", Float) = 0.0

        [Enum(Opaque, 0, Cutout, 1, Fade, 2, Transparent, 3)] _BlendMode ("Blend Mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        [HideInInspector] _Cull ("Cull", Float) = 2.0
        
        //Main Texture
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo", 2D) = "white" { }

        _Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [Gamma] _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap ("Metallic", 2D) = "white" { }

        _Roughness ("Roughness", Range(0.0, 1.0)) = 0.0
        _RoughnessMap ("Roughness", 2D) = "white" { }

        _BumpScale ("Scale", Range(0.0, 3.0)) = 1.0
        [Bump]_BumpMap ("Normal Map", 2D) = "bump" { }

        _PallaxScale ("Scale", Range(0.0, 1.0)) = 0.02
        _PallaxMap ("Pallax Map", 2D) = "black" { }
        [Enum(None, 0 Simple, 1, Steep, 2)] _PallaxMode ("Pallax Mode", Int) = 0

        //Detail Map
        [Toggle(_TK_DETAIL_ON)] _Detail_ON ("Detail", Float) = 0.0
        [Enum(Linner, 0, Multiply, 1, Addition, 2, Subtract, 3)] _DetailBlendMode ("Detail Map Blend", Float) = 0.0
        [Enum(None, 0, Triplanar, 1, Biplanar, 2, DitheredTriplanar, 3, XYZMask, 4)] _DetailMappingMode ("Detail Mapping Mode", Int) = 0
        [Enum(None, 0, Stochastic, 1, HexTiling, 2, Volonoi, 3)] _DetailSamplerMode ("Sampler Mode", Int) = 0

        _DetailMaskFactor ("Detail Mask Factor", Range(0.0, 1.0)) = 0.5
        _DetailMaskMap ("Detail Mask Map", 2D) = "white" { }

        _DetailAlbedo ("Detail BaseColor Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _DetailAlbedoMap ("Detail BaseColor Map", 2D) = "white" { }

        _DetailRoughness ("Detail Roughness", Range(0.0, 1.0)) = 0.0
        _DetailRoughnessMap ("Detail Roughness Map", 2D) = "white" { }

        _DetailMetallic ("Detail Metallic Map", Range(0.0, 1.0)) = 0.0
        _DetailMetallicMap ("Detal Metallic Map", 2D) = "white" { }

        _DetalNormalMapScale ("Detail Normal Map Scale", Range(0.0, 3.0)) = 1.0
        [Bump] _DetailNormalMap ("Detail Normal Map", 2D) = "bump" { }

        //Emission
        [Toggle(_EMISSION)] _Emission ("Emission", Float) = 0.0
        [Enum(None, 0, RealTime, 1, Bake, 2)] _EmissionMode ("Emission Mode", Int) = 0
        [HDR] _EmissionColor ("Color", Color) = (0, 0, 0, 0)
        _EmissionMap ("Emission", 2D) = "white" { }

        //ThinFilm
        [Toggle(_TK_THINFILM_ON)] _ThinFilm_ON ("Thin Film", Float) = 0.0
        _ThinFilmMaskMap ("Thin Film Mask", 2D) = "white" { }
        _ThinFilmMiddleIOR ("Middle Layer IOR", Range(1.01, 5.0)) = 1.5
        _ThinFilmMiddleThickness ("Middle Layer Thickness", Range(0.0, 1.0)) = 0.5
        _ThinFilmMiddleThicknessMin ("Middle Layer Thickness Minimum(nm)", Float) = 0.0
        _ThinFilmMiddleThicknessMax ("Middle Layer Thickness Maximum(nm)", Float) = 1000.0
        _ThinFilmMiddleThicknessMap ("Middle Layer Thickness Map", 2D) = "white" { }
        
        //Cloth
        [Toggle(_TK_CLOTH_ON)] _Cloth_ON ("Cloth", Float) = 0.0
        _ClothAlbedo1 ("Albedo1", Color) = (0.1, 1, 0.4, 1)
        _ClothAlbedo2 ("Albedo2", Color) = (1.0, 0.0, 0.1, 1)
        _ClothIOR1 ("IOR1", Float) = 1.345
        _ClothIOR2 ("IOR2", Float) = 1.345
        _ClothKd1 ("Kd1", Float) = 0.1
        _ClothKd2 ("Kd2", Float) = 0.7
        _ClothGammaV1 ("GammaV1", Float) = 8
        _ClothGammaV2 ("GammaV2", Float) = 10
        _ClothGammaS1 ("GammaS1", Float) = 4
        _ClothGammaS2 ("GammaS2", Float) = 5
        _ClothAlpha1 ("Alpha1", Float) = 0.86
        _ClothAlpha2 ("Alpha2", Float) = 0.14
        _ClothTangentOffset1 ("Tangent Offset1", Vector) = (-25, -25, 25, 25)
        _ClothTangentOffset2 ("Tangent Offset2", Vector) = (0.0, 0.0, 0.0, 0.0)


        //Lightmap
        [Enum(Defalut, 0, SH, 1, MonoSH, 2)] _LightmapMode ("Lightmap Mode", Int) = 0
        _LightmapPower ("Add Lightmap Power", Range(0.0, 1.0)) = 1.0
        [Toggle(_SHMODE_NONLINER)] _SHModeNonLiner ("NonLiner SH", Float) = 1.0
        [Toggle(_SPECULAR_OCCLUSION)] _SpecularOcclusion ("Specular Occlusion", Float) = 0.0
        [Toggle(_SH_SPECULAR)] _SHSpecular ("SH Specular", Float) = 0.0

        //Addtional Lightmap
        [Toggle(_ADDLIGHTMAP1_ON)] _AddLightmap1_ON ("Add Lightmap1", Float) = 0.0
        _AddLightmap1_Power ("Add Lightmap1 Power", Range(0.0, 1.0)) = 1.0
        _AddLightmap1 ("Add Lightmap1", 2D) = "black" { }

        [Toggle(_ADDLIGHTMAP2_ON)] _AddLightmap2_ON ("Add Lightmap2", Float) = 0.0
        _AddLightmap2_Power ("Add Lightmap2 Power", Range(0.0, 1.0)) = 1.0
        _AddLightmap2 ("Add Lightmap2", 2D) = "black" { }

        [Toggle(_ADDLIGHTMAP3_ON)] _AddLightmap3_ON ("Add Lightmap3", Float) = 0.0
        _AddLightmap3_Power ("Add Lightmap3 Power", Range(0.0, 1.0)) = 1.0
        _AddLightmap3 ("Add Lightmap3", 2D) = "black" { }

        _LightProbeSH_Power ("Light Probe SH Power", Range(0.0, 1.0)) = 1.0
        _IBLReflection_Power ("IBL Reflection Power", Range(0.0, 1.0)) = 1.0
        _RealTimeLight_Power ("Real Time Light Power", Range(0.0, 1.0)) = 1.0
        _Specular_Power ("Specular Power", Range(0.0, 2.0)) = 1.0
        _Diffuse_Power ("Diffuse Power", Range(0.0, 2.0)) = 1.0

        [Enum(None, 0, BaseColor, 1, Normal, 2, UV1, 3, UV2, 4)] _DebugMode ("Debug Mode", Int) = 0
    }


    CGINCLUDE
    #define UNITY_SETUP_BRDF_INPUT MetallicSetup
    ENDCG
    
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" "RenderType" = "Opaque" }
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma vertex VertTKStandardForwardBase
            #pragma fragment FragTKStandardForwardBase
            #pragma multi_compile_local _LIGHTMAPMODE_NONE _LIGHTMAPMODE_SH _LIGHTMAPMODE_MONOSH
            #pragma multi_compile_local _MAPPINGMODE_NONE _MAPPINGMODE_UV2 _MAPPINGMODE_TRIPLANAR _MAPPINGMODE_BIPLANAR _MAPPINGMODE_DITHER_TRIPLANAR _MAPPINGMODE_XYZMASK
            #pragma multi_compile_local _SAMPLERMODE_NONE _SAMPLERMODE_STOCHASTIC _SAMPLERMODE_HEX _SAMPLERMODE_VOLONOI
            #pragma multi_compile_local _PARALLAXMODE_NONE _PARALLAXMODE_SIMPLE _PARALLAXMODE_STEEP
            
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

            #pragma multi_compile _DEBUGMODE_NONE _DEBUGMODE_BASECOLOR _DEBUGMODE_NORMAL _DEBUGMODE_UV1 _DEBUGMODE_UV2

            #pragma shader_feature_local _MAPPING_POS_OBJ

            #pragma shader_feature_local _TK_DETAIL_ON
            #pragma multi_compile_local _ _TK_DETAIL_BLEND_LINNER _TK_DETAIL_BLEND_MULTIPLY _TK_DETAIL_BLEND_ADD _TK_DETAIL_BLEND_SUBTRACT
            #pragma multi_compile_local _TK_DETAIL_MAPPINGMODE_NONE _TK_DETAIL_MAPPINGMODE_UV2 _TK_DETAIL_MAPPINGMODE_TRIPLANAR _TK_DETAIL_MAPPINGMODE_BIPLANAR _TK_DETAIL_MAPPINGMODE_DITHER_TRIPLANAR _TK_DETAIL_MAPPINGMODE_XYZMASK
            #pragma multi_compile_local _TK_DETAIL_SAMPLERMODE_NONE _TK_DETAIL_SAMPLERMODE_STOCHASTIC _TK_DETAIL_SAMPLERMODE_HEX _TK_DETAIL_SAMPLERMODE_VOLONOI

            #pragma shader_feature_local _TK_THINFILM_ON
            #pragma shader_feature_local _TK_THINFILM_USE_MAP

            #pragma shader_feature_local _TK_CLOTH_ON

            #pragma shader_feature_local _SHMODE_NONLINER
            #pragma shader_feature_local _SPECULAR_OCCLUSION
            #pragma shader_feature_local _SH_SPECULAR

            #pragma shader_feature_local _VERTEX_SH_ON

            #pragma shader_feature _NORMALMAP_ON
            #pragma shader_feature _EMISSION

            #pragma shader_feature _ADDLIGHTMAP1_ON
            #pragma shader_feature _ADDLIGHTMAP2_ON
            #pragma shader_feature _ADDLIGHTMAP3_ON

            #include "UnityCG.cginc"
            #include "TakenokoStandardForward.cginc"

            ENDCG
        }

        Pass
        {
            Name "ForwardAdd"
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One
            ZWrite Off
            CGPROGRAM

            #pragma enable_d3d11_debug_symbols

            #pragma vertex VertTKStandardAdd
            #pragma fragment FragTKStandardAdd

            #pragma multi_compile_local _MAPPINGMODE_NONE _MAPPINGMODE_TRIPLANAR _MAPPINGMODE_BIPLANAR _MAPPINGMODE_DITHER_TRIPLANAR _MAPPINGMODE_XYZMASK
            #pragma multi_compile_local _SAMPLERMODE_NONE _SAMPLERMODE_STOCHASTIC _SAMPLERMODE_HEX _SAMPLERMODE_VOLONOI
            #pragma multi_compile_local _PARALLAXMODE_NONE _PARALLAXMODE_SIMPLE _PARALLAXMODE_STEEP

            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

            #pragma shader_feature_local _MAPPING_POS_OBJ

            #pragma shader_feature_local _TK_THINFILM_ON
            #pragma shader_feature_local _TK_THINFILM_USE_MAP

            #include "UnityCG.cginc"
            #include "TakenokoStandardAdd.cginc"
            
            ENDCG
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 3.0

            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _PARALLAXMAP
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }

        Pass
        {
            Name "META"
            Tags { "LightMode" = "Meta" }

            Cull Off

            CGPROGRAM
            #pragma vertex vert_meta
            #pragma fragment frag_meta

            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION

            #include "UnityStandardMeta.cginc"
            ENDCG
        }
    }

    CustomEditor "TakenokoStandardGUI"
}
