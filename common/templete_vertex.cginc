#ifndef _TEMPLETE_VERT_CGINC
#define _TEMPLETE_VERT_CGINC

#include "depth.cginc"

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
    float3 eyeDir : TEXCOORD9;
    float4 clipPos : TEXCOORD10;
    float depth : TEXCOORD11;
};


v2f templete_vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.screenPos = ComputeGrabScreenPos(o.vertex);
    o.uv = v.uv;

    #ifdef LIGHTMAP_ON
        o.lightmapUV = v.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;
    #else 
        o.lightmapUV = float2(0,0);
    #endif

    o.objectPos = v.vertex;
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldTangent = mul(unity_ObjectToWorld, v.tangent.xyz);
    o.eyeDir = normalize(_WorldSpaceCameraPos - o.worldPos);
    o.clipPos = o.vertex;
    o.depth = ComputeDepth(o.vertex);

    return o;
}

#endif