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

    //Fragment and Vertex : [Frag or Vert]TKTestName

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

        [HDR]_EmissionColor("Emission", Color) = (0,0,0,0)
        _EmissionMap("Emission Texture", 2D) = "white" {}

        [KeywordEnum(NONE,SH,MONOSH)]_LightmapMode("LightmapMode", Int) = 0  
        [KeywordEnum(LINER,NONLINER)]_SHMode("SHMode", Int) = 0  
    }

    CustomEditor "TakenokoStandardGUI"
    
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
            #pragma multi_compile_local _SHMODE_LINER _SHMODE_NONLINER
            //#pragma multi_compile_prepassfinal

            #pragma shader_feature _NORMALMAP_ON

            #include "UnityCG.cginc"
            #include "TakenokoStandardForward.cginc"

            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode"="ShadowCaster"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
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
            #pragma fragment FragTKStandardMeta // changed to customized fragment shader name

            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION

            float3 _BaseColor;
            sampler2D _BaseColorMap;
            //float3 _EmissionColor;
            float4 FragTKStandardMeta(v2f_meta i) : SV_Target
            {
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

                o.Albedo = _BaseColor * tex2D(_BaseColorMap, i.uv).rgb;
                o.SpecularColor = 0.0;
                o.Emission = _EmissionColor.rgb;

                return UnityMetaFragment(o);
            }

            ENDCG
        }
    }
}
