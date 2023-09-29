#ifndef TK_STANDARD_ADD
    #define TK_STANDRD_ADD
    #pragma target 3.0
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile_add
    #include "UnityShaderVariables.cginc"
    #include "UnityShaderUtilities.cginc"

    #include "AutoLight.cginc"
    #include "Lighting.cginc"

    #include "Lightmap.cginc"
    #include "TakenokoStandardBSDF.cginc"
    #include "../common/noise.cginc"
    #include "../common/matrix.cginc"
    #include "../common/color.cginc"
    #include "CommonStruct.cginc"


    float4 _Color;
    sampler2D _MainTex;
    SamplerState sampler_MainTex;
    float4 _MainTex_ST;

    float _Roughness;
    sampler2D _RoughnessMap;
    float4 _RoughnessMap_ST;

    float _Metallic;
    sampler2D _MetallicGlossMap;
    float4 _MetallicMap_ST;

    sampler2D _BumpMap;
    float4 _BumpMap_ST;

    float4 _EmissionColor;
    sampler2D _EmissionMap;
    float4 _EmissionMap_ST;

    #if defined(_TK_THINFILM_ON) 
        float _ThinFilmMiddleIOR;
        float _ThinFilmMiddleThickness;
        float _ThinFilmMiddleThicknessMin;
        float _ThinFilmMiddleThicknessMax;
        Texture2D _ThinFilmMiddleThicknessMap;
    #endif

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

    TKStandardVertexOutput VertTKStandardAdd (TKStandardVertexInput v)
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

    void SetMaterialParameterTK(inout MaterialParameter matParam,float2 uv){
        matParam.basecolor = _Color * tex2D(_MainTex, uv).rgb;
        matParam.metallic = _Metallic * tex2D(_MetallicGlossMap, uv).r;
        matParam.roughness = _Roughness * tex2D(_RoughnessMap, uv).r;
        matParam.emission = _EmissionColor * tex2D(_EmissionMap, uv).rgb;

        //ThinFilm Parametor
        #if defined(_TK_THINFILM_ON)
            float thickness_value = _ThinFilmMiddleThicknessMap.Sample(sampler_MainTex,uv).r * _ThinFilmMiddleThickness;
            float thickness = lerp(_ThinFilmMiddleThicknessMin,_ThinFilmMiddleThicknessMax,thickness_value); //nm

            matParam.middle_thickness = thickness;
            matParam.middle_ior = _ThinFilmMiddleIOR;
            matParam.top_ior = 1.0;

            float3 dietric_ior = 1.5;
            float3 dietric_kappa = 0.0;

            float3 metal_color = clamp(matParam.basecolor.rgb,0.001,0.999); //avoid NaN
            float3 edge_tint = ShlickFresnelF0(metal_color,0.75); //Magic Number TODO:Find better value
            float3 metallic_ior = rToIOR(metal_color,edge_tint);
            float3 metallic_kappa =rToKappa(metal_color,metallic_ior);

            float3 metallic_color = getR(metallic_ior,metallic_kappa);
            float3 metallic_tint = getG(metallic_ior,metallic_kappa);
            
            metallic_ior = rToIOR(metallic_color,metallic_tint);
            metallic_kappa = rToKappa(metallic_color,metallic_ior);

            matParam.bottom_ior = lerp(dietric_ior,metallic_ior,matParam.metallic); 
            matParam.bottom_kappa = lerp(dietric_kappa,metallic_kappa,matParam.metallic);

            // matParam.bottom_ior = metallic_ior;
            // matParam.bottom_kappa = metallic_kappa;
        #endif 
    }

    fixed4 FragTKStandardAdd(TKStandardVertexOutput i) : SV_Target
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
        SetMaterialParameterTK(matParam,i.uv);

        float3 lightDir;
        if(_WorldSpaceLightPos0.w > 0.0){
            lightDir = _WorldSpaceLightPos0.xyz - i.worldPos.xyz;
        } 
        else {
            lightDir = _WorldSpaceLightPos0.xyz;
        }

        lightDir = normalize(lightDir);

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

        float3 diffuse;
        float3 specular;
        EvaluateBSDF_TK(diffuse,specular,normalWorld,giInput,matParam);

        shade_color = diffuse * (1.0 - matParam.metallic) + specular;

        return fixed4(shade_color,1.0);
    }
#endif