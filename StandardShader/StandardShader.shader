Shader "Unlit/StandardShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        [Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap("Metallic", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        _Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
        _ParallaxMap ("Height Map", 2D) = "black" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}

        _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        _DetailMask("Detail Mask", 2D) = "white" {}

        _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
        _DetailNormalMapScale("Scale", Float) = 1.0
        _DetailNormalMap("Normal Map", 2D) = "bump" {}

        [Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0

        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0


        [HideInInspector] _BAKERY_2SIDED ("__2s", Float) = 2.0
        [Toggle(BAKERY_2SIDEDON)] _BAKERY_2SIDEDON ("Double-sided", Float) = 0
        [Toggle(BAKERY_VERTEXLM)] _BAKERY_VERTEXLM ("Enable vertex LM", Float) = 0
        [Toggle(BAKERY_VERTEXLMDIR)] _BAKERY_VERTEXLMDIR ("Enable directional vertex LM", Float) = 0
        [Toggle(BAKERY_VERTEXLMSH)] _BAKERY_VERTEXLMSH ("Enable SH vertex LM", Float) = 0
        [Toggle(BAKERY_VERTEXLMMASK)] _BAKERY_VERTEXLMMASK ("Enable shadowmask vertex LM", Float) = 0
        [Toggle(BAKERY_SH)] _BAKERY_SH ("Enable SH", Float) = 0
        [Toggle(BAKERY_SHNONLINEAR)] _BAKERY_SHNONLINEAR ("SH non-linear mode", Float) = 1
        [Toggle(BAKERY_RNM)] _BAKERY_RNM ("Enable RNM", Float) = 0
        [Toggle(BAKERY_MONOSH)] _BAKERY_MONOSH ("Enable MonoSH", Float) = 0
        [Toggle(BAKERY_LMSPEC)] _BAKERY_LMSPEC ("Enable Lightmap Specular", Float) = 0
        [Toggle(BAKERY_BICUBIC)] _BAKERY_BICUBIC ("Enable Bicubic Filter", Float) = 0
        [Toggle(BAKERY_PROBESHNONLINEAR)] _BAKERY_PROBESHNONLINEAR ("Use non-linear SH for light probes", Float) = 0
        [Toggle(BAKERY_VOLUME)] _BAKERY_VOLUME ("Use volumes", Float) = 0
        [Toggle(BAKERY_VOLROTATION)] _BAKERY_VOLROTATION ("Support volume rotation", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert_surf
            #pragma fragment frag_surf
            #pragma target 3.0
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #include "HLSLSupport.cginc"
            #include "UnityShaderVariables.cginc"
            #include "UnityShaderUtilities.cginc"

            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Glossiness;
            half _Metallic;
            fixed4 _Color;

            struct Input
            {
                float2 uv_MainTex;
            };

            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
                o.Alpha = c.a;
            }

            struct v2f_surf
            {
                UNITY_POSITION(pos);
                float2 pack0 : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 lmap : TEXCOORD3;
                UNITY_SHADOW_COORDS(4)
                UNITY_FOG_COORDS(5)
                #ifndef LIGHTMAP_ON
                    #if UNITY_SHOULD_SAMPLE_SH
                        half3 sh : TEXCOORD6;
                    #endif
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f_surf vert_surf(appdata_full v)
            {
                v2f_surf o;
                UNITY_INITIALIZE_OUTPUT(v2f_surf, o);

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = worldPos;
                o.worldNormal = worldNormal;

                #ifdef DYNAMICLIGHTMAP_ON
                    o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif

                #ifdef LIGHTMAP_ON
                    o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif

                #ifndef LIGHTMAP_ON
                    #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
                        o.sh = 0;
                        #ifdef VERTEXLIGHT_ON
                            o.sh += Shade4PointLights(
                            unity_4LightPosX0, 
                            unity_4LightPosY0, 
                            unity_4LightPosZ0,
                            unity_LightColor[0].rgb, 
                            unity_LightColor[1].rgb, 
                            unity_LightColor[2].rgb, 
                            unity_LightColor[3].rgb,
                            unity_4LightAtten0, 
                            worldPos, 
                            worldNormal);
                        #endif
                        o.sh = ShadeSHPerVertex(worldNormal, o.sh);
                    #endif
                #endif

                UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy);
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            fixed4 frag_surf(v2f_surf IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                float3 worldPos = IN.worldPos;
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                #ifndef USING_DIRECTIONAL_LIGHT
                    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                #else
                    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
                #endif

                Input surfIN;
                UNITY_INITIALIZE_OUTPUT(Input, surfIN);
                surfIN.uv_MainTex.x = 1.0;
                surfIN.uv_MainTex = IN.pack0.xy;

                SurfaceOutputStandard o;
                UNITY_INITIALIZE_OUTPUT(SurfaceOutputStandard, o);
                o.Albedo = 0.0;
                o.Emission = 0.0;
                o.Alpha = 0.0;
                o.Occlusion = 1.0;
                o.Normal = IN.worldNormal;

                surf(surfIN, o);

                UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)

                fixed4 c = 0;

                UnityGI gi;
                UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
                gi.indirect.diffuse = 0;
                gi.indirect.specular = 0;
                gi.light.color = _LightColor0.rgb;
                gi.light.dir = lightDir;

                UnityGIInput giInput;
                UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
                giInput.light = gi.light;
                giInput.worldPos = worldPos;
                giInput.worldViewDir = worldViewDir;
                giInput.atten = atten;

                #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
                    giInput.lightmapUV = IN.lmap;
                #else
                    giInput.lightmapUV = 0.0;
                #endif

                #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
                    giInput.ambient = IN.sh;
                #else
                    giInput.ambient.rgb = 0.0;
                #endif

                giInput.probeHDR[0] = unity_SpecCube0_HDR;
                giInput.probeHDR[1] = unity_SpecCube1_HDR;

                #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
                    giInput.boxMin[0] = unity_SpecCube0_BoxMin;
                #endif

                #ifdef UNITY_SPECCUBE_BOX_PROJECTION
                    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
                    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
                    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
                    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
                    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
                #endif

                LightingStandard_GI(o, giInput, gi);
                c += LightingStandard(o, worldViewDir, gi);

                UNITY_APPLY_FOG(IN.fogCoord, c);
                UNITY_OPAQUE_ALPHA(c.a);

                return c;
            }

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
}
