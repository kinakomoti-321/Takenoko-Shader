﻿Shader "Takenoko/StandardShader"
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
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap("Metallic", 2D) = "white" {}

        _Roughness("Roughness",Range(0.0,1.0)) = 0.0
        _RoughnessMap("Roughness", 2D) = "white" {}

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        [Toggle(_EMISSION)] _Emission("Emission",Float) = 0.0
        [Enum(NONE,0,REALTIME,1,BAKE,2)] _EmissionMode("Emission Mode",Int) = 0
        _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        [Toggle(_TK_THINFILM_ON)] _ThinFilm_ON("Thin Film",Float) = 0.0
        _ThinFilmMiddleIOR("Middle Layer IOR", Range(1.01, 5.0)) = 1.5
        _ThinFilmMiddleThickness("Middle Layer Thickness", Range(0.0, 1.0)) = 0.5
        _ThinFilmMiddleThicknessMin("Middle Layer Thickness Minimum(nm)",Float) = 0.0
        _ThinFilmMiddleThicknessMax("Middle Layer Thickness Maximum(nm)",Float) = 1000.0
        _ThinFilmMiddleThicknessMap("Middle Layer Thickness Map", 2D) = "white" {}

        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0

        [Enum(NONE,0,SH,1,MONOSH,2)] _LightmapMode("Lightmap Mode",Int) = 0
        [Toggle(_SHMODE_NONLINER)] _SHModeNonLiner("NonLiner SH",Float) = 1.0
        [Toggle(_SPECULAR_OCCLUSION)] _SpecularOcclusion("Specular Occlusion",Float) = 0.0
        [Toggle(_SH_SPECULAR)] _SHSpecular("SH Specular",Float) = 0.0
    }

    CGINCLUDE
    #define UNITY_SETUP_BRDF_INPUT MetallicSetup
    ENDCG
    
    SubShader
    {
        Pass
        {
            Tags { 
                "LightMode"="ForwardBase"  
                "RenderType"="Opaque" 
            }

            ZWrite On

            CGPROGRAM
            #pragma vertex VertTKStandardForwardBase
            #pragma fragment FragTKStandardForwardBase
            #pragma multi_compile_local _LIGHTMAPMODE_NONE _LIGHTMAPMODE_SH _LIGHTMAPMODE_MONOSH

            #pragma shader_feature_local _TK_THINFILM_ON
            #pragma shader_feature_local _TK_THINFILM_USE_MAP

            #pragma shader_feature_local _SHMODE_NONLINER
            #pragma shader_feature_local _SPECULAR_OCCLUSION
            #pragma shader_feature_local _SH_SPECULAR

            #pragma shader_feature _NORMALMAP_ON
            #pragma shader_feature _EMISSION

            #include "UnityCG.cginc"
            #include "TakenokoStandardForward.cginc"

            ENDCG
        }

        Pass {
            Name "ForwardAdd"
            Tags {
                "LightMode" = "ForwardAdd" 
            }
            Blend One One
            ZWrite Off
            CGPROGRAM

            #pragma vertex VertTKStandardAdd
            #pragma fragment FragTKStandardAdd
            #pragma multi_compile_local _LIGHTMAPMODE_NONE _LIGHTMAPMODE_SH _LIGHTMAPMODE_MONOSH

            #pragma shader_feature_local _TK_THINFILM_ON
            #pragma shader_feature_local _TK_THINFILM_USE_MAP

            #pragma shader_feature_local _SHMODE_NONLINER
            #pragma shader_feature_local _SPECULAR_OCCLUSION
            #pragma shader_feature_local _SH_SPECULAR

            #pragma shader_feature _NORMALMAP_ON

            #include "UnityCG.cginc"
            #include "TakenokoStandardAdd.cginc"
            
            ENDCG
        }

        Pass {
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
            Tags { "LightMode"="Meta" }

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
