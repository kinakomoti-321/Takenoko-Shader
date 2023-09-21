Shader "Kinanko/StandardShader"
{

    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _BaseColorTex("Base Color Texture", 2D) = "white" {}
        _Roughness ("Roughness", Range(0,1)) = 0.5
        _RoughnessTex("Roughness Texture", 2D) = "white" {}
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _MetallicTex("Metallic Texture", 2D) = "white" {}
        [Normal]_NormalTex("Normal Texture", 2D) = "bump" {}
        _AOTex("AO Texture", 2D) = "white" {}

        [HDR]_Emission("Emission", Color) = (0,0,0,0)

        [KeywordEnum(NONE,SH,MONOSH)]_LightmapMode("LightmapMode", Int) = 0  
        [KeywordEnum(LINER,NONLINER)]_SHMode("SHMode", Int) = 0  
        [KeywordEnum(NONE,NORMALMAP,NOISE)]_NormalMode("NormalMode", Int) = 0

    }

    SubShader
    {

        Pass
        {
            Tags { 
                "LightMode"="ForwardBase"  
                "RenderType"="Opaque" 
            }
            LOD 100
            ZWrite On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_local _LIGHTMAPMODE_NONE _LIGHTMAPMODE_SH _LIGHTMAPMODE_MONOSH
            #pragma multi_compile_local _NORMALMODE_NONE _NORMALMODE_NORMALMAP _NORMALMODE_NOISE
            #pragma multi_compile_local _SHMODE_LINER _SHMODE_NONLINER
            #pragma multi_compile_prepassfinal

            #include "UnityCG.cginc"
            #include "lightmap.cginc"
            #include "../common/noise.cginc"
            #include "../common/matrix.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
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

            sampler2D _BaseColorTex;
            float4 _BaseColorTex_ST;

            sampler2D _RoughnessTex;
            float4 _RoughnessTex_ST;

            sampler2D _MetallicTex;
            float4 _MetallicTex_ST;

            sampler2D _NormalTex;
            float4 _NormalTex_ST;

            sampler2D _AOTex;

            float4 _Emission;

            v2f vert (appdata v)
            {
                v2f o;
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

            float3 getNormal(float2 uv){
                float2 epsiron = float2(0.0001,0.000);
                float3 pos = float3(uv,_Time.x * 0.1);
                
                float3 dx = float3(2.0 * epsiron.x,CyclicNoise(pos + epsiron.xyy) - CyclicNoise(pos - epsiron.xyy),0.0);
                float3 dy = float3(0.0,CyclicNoise(pos + epsiron.yxy) - CyclicNoise(pos - epsiron.yxy),2.0 * epsiron.x);
                
                dx.y *= 0.5;
                dy.y *= 0.5;
                return normalize(cross(dy,dx));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 col = _BaseColor.rgb;


                float3 basecolor = _BaseColor.rgb * tex2D(_BaseColorTex,i.uv).rgb;
                float roughness = _Roughness * tex2D(_RoughnessTex,i.uv).r;
                float metallic = _Metallic * tex2D(_MetallicTex,i.uv).r;
                float ao = tex2D(_AOTex,i.uv).r;
                
                float3 normalWorld = i.worldNormal;

               #ifdef _NORMALMODE_NONE
                    normalWorld = i.worldNormal;
               #elif _NORMALMODE_NORMALMAP
                    float3 normal = UnpackNormal(tex2D(_NormalTex,i.uv));
                    normal = normalize(normal);
                    normalWorld = localToWorld(i.worldTangent,i.worldNormal,i.worldBinormal,float3(normal.x,normal.z,-normal.y));
                    normalWorld = normalize(normalWorld);
               #elif _NORMALMODE_NOISE
                    float3 normal = getNormal(i.uv * 0.1);
                    //normalWorld = normal.x * i.worldTangent + i.worldBinormal * normal.z + i.worldNormal * normal.y;
                    normalWorld = localToWorld(i.worldTangent,i.worldNormal,i.worldBinormal,normal);
                    normalWorld = normalize(normalWorld);
               #endif

                float3 lightmapDiffuse = basecolor;
                float3 lightmapSpecular;


                #ifdef LIGHTMAP_ON
                //Lightmapが付けられてるとき
                sample_lightmap(lightmapDiffuse,lightmapSpecular,normalWorld,i.lightmapUV);
                col = lightmapDiffuse * basecolor + _Emission.rgb;
                #else
                //Lightmapがない時
                //lightprobeをもらう
                float3 shlight = ShadeSH9(float4(normalWorld,1.0));
                col = shlight * basecolor + _Emission.rgb;
                #endif

                //col = UnpackNormal(tex2D(_NormalTex,i.uv));
                // normalWorld = UnpackNormal(tex2D(_NormalTex,i.uv));
                // normalWorld = normalize(normalWorld);
                // normalWorld = (i.worldTangent * normalWorld.x + i.worldBinormal * normalWorld.y + i.worldNormal * normalWorld.z);
                //col = normalWorld * 0.5 + 0.5;
                
                return fixed4(col * ao,1.0);
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
            #pragma fragment frag_meta_custom // changed to customized fragment shader name

            //#pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION

            float4 _BaseColor;
            sampler2D _BaseColorTex;
            float4 _BaseColorTex_ST;

            float4 _Emission;

            float4 frag_meta_custom(v2f_meta i) : SV_Target
            {
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

                o.Albedo = _BaseColor * tex2D(_BaseColorTex,i.uv);
                //o.SpecularColor = 1.0;
                o.Emission = _Emission.rgb;

                return UnityMetaFragment(o);
            }

            ENDCG
        }
    }
}
