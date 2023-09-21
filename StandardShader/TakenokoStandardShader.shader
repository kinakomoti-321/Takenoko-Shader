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
            #pragma multi_compile_local _NORMALMODE_NONE _NORMALMODE_NORMALMAP _NORMALMODE_NOISE
            #pragma multi_compile_local _SHMODE_LINER _SHMODE_NONLINER
            #pragma multi_compile_prepassfinal

            #include "UnityCG.cginc"
            #include "Lightmap.cginc"
            #include "../common/noise.cginc"
            #include "../common/matrix.cginc"

            struct TKStandardVertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct TKStandardVertexOutput
            {
                float4 vertex : SV_POSITION;

                float2 uv : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;
                
                float4 screenPos : TEXCOORD4;
                float3 objectPos : TEXCOORD5;
                float3 worldPos : TEXCOORD6;
                float3 worldNormal : TEXCOORD7;
                float3 worldTangent : TEXCOORD8;
                float3 worldBinormal : TEXCOORD12;
                float3 eyeDir : TEXCOORD9;
                float4 clipPos : TEXCOORD10;
                float depth : TEXCOORD11;
            };

            float4 _BaseColor;
            float _Roughness;
            float _Metallic;

            sampler2D _BaseColorMap;
            float4 _BaseColorMap_ST;

            sampler2D _RoughnessMap;
            float4 _RoughnessMap_ST;

            sampler2D _MetallicMap;
            float4 _MetallicMap_ST;

            sampler2D _BumpMap;
            float4 _BumpMap_ST;

            float4 _EmissionColor;
            sampler2D _EmissionMap;

            struct MaterialParameter{
                float3 basecolor;
                float roughness;
                float metallic;
                float3 normal;
                float3 emission;
            };



            TKStandardVertexOutput VertTakenokoStandardForwardBase (TKStandardVertexInput v)
            {
                TKStandardVertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.lightmapUV = v.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;

                o.objectPos = v.vertex;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = mul(unity_ObjectToWorld, v.tangent.xyz);
                o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                o.eyeDir = normalize(_WorldSpaceCameraPos - o.worldPos);
                o.clipPos = o.vertex;

                return o;
            }

            float3 getNormalMap(float2 uv){
                float3 normal = UnpackNormal(tex2D(_BumpMap,uv));
                normal = normalize(normal);
                return normal;
            }


            fixed4 FragTakenokoStandardForwardBase(TKStandardVertexOutput i) : SV_Target
            {
                float3 shade_color;

                MaterialParameter mat_param;

                float3 basecolor = _BaseColor.rgb * tex2D(_BaseColorMap,i.uv).rgb;
                float roughness = _Roughness * tex2D(_RoughnessMap,i.uv).r;
                float metallic = _Metallic * tex2D(_MetallicMap,i.uv).r;
                
                float3 normalWorld = i.worldNormal;

                float3 normal = UnpackNormal(tex2D(_BumpMap,i.uv));
                normal = normalize(normal);
                normalWorld = localToWorld(i.worldTangent,i.worldNormal,i.worldBinormal,float3(normal.x,normal.z,-normal.y));
                normalWorld = normalize(normalWorld);

                #ifdef LIGHTMAP_ON
                    float3 lightmapDiffuse = 0;
                    float3 lightmapSpecular = 0;
                    sample_lightmap(lightmapDiffuse,lightmapSpecular,normalWorld,i.lightmapUV);
                    shade_color = lightmapDiffuse * basecolor + _EmissionColor.rgb;
                #else
                    float3 shlight = ShadeSH9(float4(normalWorld,1.0));
                    shade_color = shlight * basecolor + _EmissionColor.rgb;
                #endif

                return fixed4(shade_color,1.0);
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
