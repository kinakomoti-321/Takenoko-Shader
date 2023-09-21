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
    //Variable : test_name

    //Define : TEST_NAME
    //ShaderKeyWord : _TESTNAME_ON
    //Constant : TESTNAME

    //Fragment and Vertex : FragTestName

    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _BaseColorMap("Base Color Texture", 2D) = "white" {}

        _Roughness ("Roughness", Range(0,1)) = 0.5
        _RoughnessMap("Roughness Texture", 2D) = "white" {}

        _Metallic ("Metallic", Range(0,1)) = 0.0
        _MetallicMap("Metallic Texture", 2D) = "white" {}
        
        [Normal]_BumpMap("Normal Texture", 2D) = "bump" {}

        _HeightMap("Height Texture", 2D) = "black" {}

        _AOTex("AO Texture", 2D) = "white" {}

        [HDR]_EmissionColor("Emission", Color) = (0,0,0,0)
        _EmissionMap("Emission Texture", 2D) = "white" {}

        [KeywordEnum(NONE,SH,MONOSH)]_LightmapMode("LightmapMode", Int) = 0  
        [KeywordEnum(LINER,NONLINER)]_SHMode("SHMode", Int) = 0  
    }

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
            #pragma vertex VertTakenokoStandardForwardBase
            #pragma fragment FragTakenokoStandardForwardBase
            #pragma multi_compile_local _LIGHTMAPMODE_NONE _LIGHTMAPMODE_SH _LIGHTMAPMODE_MONOSH
            #pragma multi_compile_local _SHMODE_LINER _SHMODE_NONLINER
            #pragma multi_compile_prepassfinal

            #include "UnityCG.cginc"
            #include "TakenokoStandardForward.cginc"
            ENDCG
        }

        Pass
        {
            Name "META"
            Tags { "LightMode" = "Meta" }

            Cull Off

            CGPROGRAM
            #include "UnityStandardMeta.cginc"

            #pragma vertex vert_meta // change name and implement if customizing vertex shader
            #pragma fragment frag_meta_standard // changed to customized fragment shader name

            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION

            float4 _BaseColor;
            sampler2D _BaseColorTex;
            float4 _BaseColorTex_ST;

            float4 _Emission;

            float4 frag_meta_standard(v2f_meta i) : SV_Target
            {
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

                o.Albedo = _BaseColor * tex2D(_BaseColorTex,i.uv);
                o.SpecularColor = 1.0;
                o.Emission = _Emission.rgb;

                return UnityMetaFragment(o);
            }

            ENDCG
        }
    }
}
