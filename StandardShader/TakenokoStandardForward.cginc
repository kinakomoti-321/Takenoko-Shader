#ifndef TK_STANDARD_FORWARD_BASE
    #define TK_STANDARD_FORWARD_BASE
    #pragma target 3.0
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile_fwdbase
    #include "UnityShaderVariables.cginc"
    #include "UnityShaderUtilities.cginc"

    #include "AutoLight.cginc"
    #include "Lighting.cginc"

    #include "Lightmap.cginc"
    #include "TakenokoStandardBSDF.cginc"
    #include "../common/noise.cginc"
    #include "../common/matrix.cginc"
    #include "CommonStruct.cginc"

    struct TKStandardVertexInput
    {
        float4 vertex : POSITION;
        float2 texcoord0 : TEXCOORD0;
        float2 texcoord1 : TEXCOORD1;
        float2 texcoord2 : TEXCOORD2;
        float4 normal : NORMAL;
        float4 tangent : TANGENT;
    };

    struct TKStandardVertexOutput
    {
        UNITY_POSITION(pos);

        float2 uv : TEXCOORD0;
        float3 worldNormal : TEXCOORD1;
        float3 worldPos : TEXCOORD2;
        float4 lightmapUV : TEXCOORD3;
        UNITY_SHADOW_COORDS(4)
        UNITY_FOG_COORDS(5)

        #ifndef LIGHTMAP_ON
            #if UNITY_SHOULD_SAMPLE_SH
                half3 sh : TEXCOORD6;
            #endif
        #endif

        float3 worldTangent : TEXCOORD7;
        float3 worldBinormal : TEXCOORD8;

        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
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

    TKStandardVertexOutput VertTKStandardForwardBase (TKStandardVertexInput v)
    {
        TKStandardVertexOutput o;

        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord0;
        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        float3 worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldPos = worldPos;
        o.worldNormal = worldNormal;
        o.worldTangent = UnityObjectToWorldNormal(v.tangent);
        o.worldBinormal = cross(o.worldNormal,o.worldTangent) * v.tangent.w;

        #ifdef DYNAMICLIGHTMAP_ON
            o.lightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
        #endif

        #ifdef LIGHTMAP_ON
            o.lightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        #endif
        
        UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy);
        UNITY_TRANSFER_FOG(o,o.pos);
        return o;
    }

    float3 getNormalMap(float2 uv){
        float3 normal = UnpackNormal(tex2D(_BumpMap,uv));
        normal = normalize(normal);
        return normal;
    }


    fixed4 FragTKStandardForwardBase(TKStandardVertexOutput i) : SV_Target
    {
        float3 shade_color = 0;

        float3 worldPos = i.worldPos;
        float3 normalWorld = i.worldNormal;

        float3 viewDirection = normalize(_WorldSpaceCameraPos - i.worldPos);
        float3 normal = UnpackNormal(tex2D(_BumpMap,i.uv));
        normal = normalize(normal);
        normalWorld = localToWorld(i.worldTangent,i.worldNormal,i.worldBinormal,float3(normal.x,normal.z,-normal.y));
        
        normalWorld = normalize(normalWorld);

        MaterialParameter matParam;
        matParam.basecolor = _BaseColor.rgb * tex2D(_BaseColorMap,i.uv).rgb;
        matParam.roughness = _Roughness * tex2D(_RoughnessMap,i.uv).r;
        matParam.metallic = _Metallic * tex2D(_MetallicMap,i.uv).r;
        

        //Lighting Infomation
        //Directional Light
        float3 lightDir = _WorldSpaceLightPos0.xyz;
        UNITY_LIGHT_ATTENUATION(atten,i,worldPos)

        UnityGI gi;
        UNITY_INITIALIZE_OUTPUT(UnityGI,gi);
        gi.indirect.diffuse = 0;
        gi.indirect.diffuse = 0;
        gi.light.color = _LightColor0.rgb;
        gi.light.dir = lightDir;

        UnityGIInput giInput;
        UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
        giInput.light = gi.light;
        giInput.worldPos = worldPos;
        giInput.worldViewDir = viewDirection;
        giInput.atten = atten;

        #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
            giInput.lightmapUV = i.lightmapUV;
        #else
            giInput.lightmapUV = 0.0;
        #endif

        #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
            giInput.ambient = 0.0; //Vertex SH
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

        //Directional Light Shading
        float3 main_diffuse;
        float3 main_specular;
        EvaluateLighting_TK(main_diffuse,main_specular,normalWorld,giInput,matParam);

        //SH Light
        float3 sh = ShadeSH9(float4(normalWorld,1.0)) * matParam.basecolor ;

        //Lightmap
        float3 lightmap_shade_col = 0;
        #ifdef LIGHTMAP_ON
            float3 lightmapDiffuse = 0;
            float3 lightmapSpecular = 0;
            sample_lightmap(lightmapDiffuse,lightmapSpecular,normalWorld,i.lightmapUV);
            lightmap_shade_col = lightmapDiffuse * matParam.basecolor + _EmissionColor.rgb;
        #else
            shade_color += (main_diffuse + sh) * (1.0f - matParam.metallic) + main_specular;
        #endif

        shade_color += lightmap_shade_col;
        //shade_color += max(dot(giInput.light.dir,normalWorld),0.0) * _LightColor0 * atten;
        //shade_color = atten;
        //UNITY_APPLY_FOG(IN.fogCoord, c);

        return fixed4(shade_color,1.0);
    }
#endif