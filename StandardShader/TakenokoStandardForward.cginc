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



float4 _Color;
Texture2D _MainTex;
SamplerState sampler_MainTex;
float4 _MainTex_ST;

float _Roughness;
Texture2D _RoughnessMap;
SamplerState sampler_RoughnessMap;
float4 _RoughnessMap_ST;

float _Metallic;
Texture2D _MetallicGlossMap;
SamplerState sampler_MetallicGlossMap;
float4 _MetallicMap_ST;

Texture2D _BumpMap;
SamplerState sampler_BumpMap;
float4 _BumpMap_ST;

float4 _EmissionColor;
Texture2D _EmissionMap;
SamplerState sampler_EmissionMap;
float4 _EmissionMap_ST;

float _LightmapPower;

#if defined(_TK_THINFILM_ON)
    float _ThinFilmMiddleIOR;
    float _ThinFilmMiddleThickness;
    float _ThinFilmMiddleThicknessMin;
    float _ThinFilmMiddleThicknessMax;
    Texture2D _ThinFilmMiddleThicknessMap;
#endif

#if defined(_ADDLIGHTMAP1_ON)
    Texture2D _AddLightmap1;
    float _AddLightmap1_Power;
#endif
#if defined(_ADDLIGHTMAP2_ON)
    Texture2D _AddLightmap2;
    float _AddLightmap2_Power;
#endif
#if defined(_ADDLIGHTMAP3_ON)
    Texture2D _AddLightmap3;
    float _AddLightmap3_Power;
#endif

#include "TakenokoLightmap.cginc"
#include "TakenokoStandardBSDF.cginc"
#include "../common/noise.cginc"
#include "../common/matrix.cginc"
#include "../common/color.cginc"

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
    float2 screenPos : TEXCOORD9;
    float3 objectPos : TEXCOORD10;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

TKStandardVertexOutput VertTKStandardForwardBase(TKStandardVertexInput v)
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
    o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
    float4 scpos = ComputeScreenPos(o.pos);
    o.screenPos = scpos.xy / scpos.w;
    o.objectPos = v.vertex.xyz;

    #ifdef DYNAMICLIGHTMAP_ON
        o.lightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif

    #ifdef LIGHTMAP_ON
        o.lightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    #endif
    
    UNITY_TRANSFER_SHADOW(o, v.texcoord1.xy);
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
}


fixed4 FragTKStandardForwardBase(TKStandardVertexOutput i) : SV_Target
{
    float3 shade_color = 0;

    float3 worldPos = i.worldPos;
    float3 normalWorld = i.worldNormal;

    float3 viewDirection = normalize(_WorldSpaceCameraPos - i.worldPos);
    float3 normal = UnpackNormal(_BumpMap.Sample(sampler_BumpMap, i.uv));
    normal = normalize(normal);
    normalWorld = localToWorld(i.worldTangent, i.worldNormal, i.worldBinormal, float3(normal.x, normal.z, -normal.y));
    
    normalWorld = normalize(normalWorld);

    int2 pixelId = int2(i.screenPos.xy * _ScreenParams.xy);
    MaterialParameter matParam;
    SetMaterialParameterTK(matParam, i.uv, i.worldPos, normalWorld, pixelId);

    float3 lightDir = _WorldSpaceLightPos0.xyz;
    UNITY_LIGHT_ATTENUATION(atten, i, worldPos)

    UnityGI gi;
    UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
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

    float3 main_diffuse;
    float3 main_specular;
    EvaluateLighting_TK(main_diffuse, main_specular, normalWorld, giInput, matParam);

    #ifdef LIGHTMAP_ON
        float3 lightmapDiffuse = 0;
        float3 lightmapSpecular = 0;
        sample_lightmap(lightmapDiffuse, lightmapSpecular, normalWorld, i.lightmapUV, viewDirection, matParam);
        lightmapDiffuse *= matParam.basecolor;

        lightmapDiffuse *= _LightmapPower;
        lightmapSpecular *= _LightmapPower;

        float specular_occulusion = 1.0f;

        #ifdef _SPECULAR_OCCLUSION
            specular_occulusion = saturate(colorToLuminance(lightmapDiffuse));
        #endif
        
        shade_color = (lightmapDiffuse + main_diffuse) * (1.0f - matParam.metallic) + (main_specular + lightmapSpecular) * specular_occulusion;

    #else
        float3 sh = ShadeSH9(float4(normalWorld, 1.0)) * matParam.basecolor;
        shade_color = (main_diffuse + sh) * (1.0f - matParam.metallic) + main_specular;
    #endif

    #if defined(_EMISSION)
        shade_color += matParam.emission;
    #endif

    #if defined(_ADDLIGHTMAP1_ON)
        float3 addLightMap1 = lightMapEvaluate(_AddLightmap1, i.lightmapUV.xy);
        shade_color += addLightMap1 * _AddLightmap1_Power;
    #endif
    #if defined(_ADDLIGHTMAP2_ON)
        float3 addLightMap2 = lightMapEvaluate(_AddLightmap2, i.lightmapUV.xy);
        shade_color += addLightMap2 * _AddLightmap2_Power;
    #endif
    #if defined(_ADDLIGHTMAP3_ON)
        float3 addLightMap3 = lightMapEvaluate(_AddLightmap3, i.lightmapUV.xy);
        shade_color += addLightMap3 * _AddLightmap3_Power;
    #endif

    return fixed4(shade_color, 1.0);
}

#endif