#ifndef _TK_SAMPLER
#define _TK_SAMPLER

#include "../common/matrix.cginc"
#define SAMPLE2D_TK(tex, sampler_tex, uv) tex.Sample(sampler_tex, uv)
#define SAMPLE2D_GRAD_TK(tex, sampler_tex, uv, dx, dy) tex.SampleGrad(sampler_tex, uv, dx, dy)
#define SAMPLE2D_GRAD_TK(tex, sampler_tex, uv) tex.SampleGrad(sampler_tex, uv, ddx(uv), ddy(uv))

//Triplanar Mapping
//https://web.archive.org/web/20220105142932/https://www.willpodpechan.com/blog/2020/10/16/de-tiled-triplanar-mapping-in-unity
inline float3 TriplanarMapping_TK(Texture2D tex, SamplerState sampler_tex, float3 pos, float3 normal, float4 uv_ST)
{
    float3 blend = abs(normal);
    blend = blend / (blend.x + blend.y + blend.z);
    
    float2 uvX = pos.yz;
    float2 uvY = pos.xz;
    float2 uvZ = pos.xy;

    uvX = (normal.x < 0) ? - uvX : uvX;
    uvY = (normal.y < 0) ? - uvY + 0.5 : uvY + 0.5;
    uvZ = (normal.z < 0) ? - uvZ - 0.5 : uvZ - 0.5;

    float3 texX = SAMPLE2D_GRAD_TK(tex, sampler_tex, uvX * uv_ST.xy + uv_ST.zw);
    float3 texY = SAMPLE2D_GRAD_TK(tex, sampler_tex, uvY * uv_ST.xy + uv_ST.zw);
    float3 texZ = SAMPLE2D_GRAD_TK(tex, sampler_tex, uvZ * uv_ST.xy + uv_ST.zw);

    return blend.x * texX + blend.y * texY + blend.z * texZ;
}

float3 BlendTriplanarNormal_float(float3 tangent, float3 world)
{
    float3 n;
    n.xy = tangent.xy + world.xy;
    n.z = tangent.z * world.z;
    return n;
}

inline float3 TriplanarMappingNormal_TK(Texture2D tex, SamplerState sampler_tex, float3 pos, float3 normal, float4 uv_ST)
{
    float3 blend = abs(normal);
    blend = blend / (blend.x + blend.y + blend.z);
    
    float2 uvX = pos.yz;
    float2 uvY = pos.xz;
    float2 uvZ = pos.xy;

    uvX = (normal.x < 0) ? - uvX : uvX;
    uvY = (normal.y < 0) ? - uvY + 0.5 : uvY + 0.5;
    uvZ = (normal.z < 0) ? - uvZ - 0.5 : uvZ - 0.5;

    float3 tangentX = UnpackNormal(SAMPLE2D_GRAD_TK(tex, sampler_tex, uvX * uv_ST.xy + uv_ST.zw)).xyz;
    float3 tangentY = UnpackNormal(SAMPLE2D_GRAD_TK(tex, sampler_tex, uvY * uv_ST.xy + uv_ST.zw)).xyz;
    float3 tangentZ = UnpackNormal(SAMPLE2D_GRAD_TK(tex, sampler_tex, uvZ * uv_ST.xy + uv_ST.zw)).xyz;

    if (normal.x < 0)
    {
        tangentX.x = -tangentX.x;
    }

    if (normal.y < 0)
    {
        tangentY.x = -tangentY.x;
    }
    if (normal.z < 0)
    {
        tangentZ.x = -tangentZ.x;
    }
    
    float3 worldX = BlendTriplanarNormal_float(tangentX, normal.zyx).zyx;
    float3 worldY = BlendTriplanarNormal_float(tangentY, normal.xzy).xzy;
    float3 worldZ = BlendTriplanarNormal_float(tangentZ, normal);

    return normalize(blend.x * worldX + blend.y * worldY + blend.z * worldZ);
}


inline float3 BilpanarMapping_TK(Texture2D tex, SamplerState samplerState, float3 pos, float3 normal, float4 uv_ST)
{
    float k = 8.0;

    float3 dpdx = ddx(pos);
    float3 dpdy = ddy(pos);
    normal = abs(normal);

    int3 ma = (normal.x > normal.y && normal.x > normal.z) ? int3(0, 1, 2) :
    (normal.y > normal.z) ? int3(1, 2, 0) :
    int3(2, 0, 1) ;
    int3 mi = (normal.x < normal.y && normal.x < normal.z) ? int3(0, 1, 2) :
    (normal.y < normal.z) ? int3(1, 2, 0) :
    int3(2, 0, 1) ;
    int3 me = 3 - mi - ma;
    
    float3 x_sample = tex.SampleGrad(samplerState, float2(pos[ma.y], pos[ma.z]) * uv_ST.xy + uv_ST.zw,
    float2(dpdx[ma.y], dpdx[ma.z]),
    float2(dpdy[ma.y], dpdy[ma.z]));
    float3 y_sample = tex.SampleGrad(samplerState, float2(pos[me.y], pos[me.z]) * uv_ST.xy + uv_ST.zw,
    float2(dpdx[me.y], dpdx[me.z]),
    float2(dpdy[me.y], dpdy[me.z]));
    
    float2 weight = float2(normal[ma.x], normal[me.x]);
    weight = clamp((weight - 0.5773) / (1.0 - 0.5773), 0.0, 1.0);
    weight = pow(weight, k / 8.0);
    return (weight.x * x_sample + weight.y * y_sample) / (weight.x + weight.y);
}

inline float3 BilpanarMappingNormal_TK(Texture2D tex, SamplerState samplerState, float3 pos, float3 normal, float4 uv_ST)
{
    float k = 8.0;

    float3 dpdx = ddx(pos);
    float3 dpdy = ddy(pos);
    normal = abs(normal);

    int3 ma = (normal.x > normal.y && normal.x > normal.z) ? int3(0, 1, 2) :
    (normal.y > normal.z) ? int3(1, 2, 0) :
    int3(2, 0, 1) ;
    int3 mi = (normal.x < normal.y && normal.x < normal.z) ? int3(0, 1, 2) :
    (normal.y < normal.z) ? int3(1, 2, 0) :
    int3(2, 0, 1) ;
    int3 me = 3 - mi - ma;
    
    float3 x_sample = UnpackNormal(tex.Sample(samplerState, float2(pos[ma.y], pos[ma.z]) * uv_ST.xy + uv_ST.zw));
    float3 y_sample = UnpackNormal(tex.Sample(samplerState, float2(pos[me.y], pos[me.z]) * uv_ST.xy + uv_ST.zw));

    float2 weight = float2(normal[ma.x], normal[me.x]);
    weight = clamp((weight - 0.5773) / (1.0 - 0.5773), 0.0, 1.0);
    weight = pow(weight, k / 8.0);
    return normalize((weight.x * x_sample + weight.y * y_sample) / (weight.x + weight.y));
}


inline float DitherGradientNoise(int frame, int2 pixel)
{
    int f = trunc(float(frame)) % 64;
    int2 iP = trunc(float2(pixel.x, pixel.y));
    pixel = float2(iP) + 5.588238f * float(f);
    return frac(52.9829189f * frac(0.06711056f * pixel.x + 0.00583715f * pixel.y));
}

inline float3 DitherTriplanarMapping_TK(Texture2D tex, SamplerState sampler_tex, float3 pos, float3 normal, int2 pixelId, float4 uv_ST)
{
    float3 blend = abs(normal);
    blend = pow(blend, 10.0);
    blend = blend / (blend.x + blend.y + blend.z);

    float dither = DitherGradientNoise(1, pixelId);
    dither -= 0.5;
    float index = 0;
    index = blend.x - dither > blend.y ? 0 : 1;
    index = blend.z - dither > max(blend.x, blend.y) ? 2 : index;

    float2 uvX = pos.yz;
    float2 uvY = pos.xz;
    float2 uvZ = pos.xy;

    float4 ddx_ddy_uvX = float4(ddx(uvX), ddy(uvX));
    float4 ddx_ddy_uvY = float4(ddx(uvY), ddy(uvY));
    float4 ddx_ddy_uvZ = float4(ddx(uvZ), ddy(uvZ));

    float2 uvs[3] = {
        uvX, uvY, uvZ
    };
    float4 ddx_ddy_uvs[3] = {
        ddx_ddy_uvX, ddx_ddy_uvY, ddx_ddy_uvZ
    };

    float2 tri_uv = uvs[index];
    float4 ddx_ddy_tri_uv = ddx_ddy_uvs[index];
    float3 col = 0;

    if (index == 0)
    {
        tri_uv = uvX;
        ddx_ddy_tri_uv = ddx_ddy_uvX;
        col = tex.SampleGrad(sampler_tex, tri_uv * uv_ST.xy + uv_ST.zw, ddx_ddy_tri_uv.xy, ddx_ddy_tri_uv.zw).rgb;
    }
    else if (index == 1)
    {
        tri_uv = uvY;
        ddx_ddy_tri_uv = ddx_ddy_uvY;
        col = tex.SampleGrad(sampler_tex, tri_uv * uv_ST.xy + uv_ST.zw, ddx_ddy_tri_uv.xy, ddx_ddy_tri_uv.zw).rgb;
    }
    else if (index == 2)
    {
        tri_uv = uvZ;
        ddx_ddy_tri_uv = ddx_ddy_uvZ;
        col = tex.SampleGrad(sampler_tex, tri_uv * uv_ST.xy + uv_ST.zw, ddx_ddy_tri_uv.xy, ddx_ddy_tri_uv.zw).rgb;
    }

    return col;
}

inline float3 DitherTriplanarMappingNormal_TK(Texture2D tex, SamplerState sampler_tex, float3 pos, float3 normal, int2 pixelId, float4 uv_ST)
{
    float3 blend = abs(normal);
    blend = pow(blend, 10.0);
    blend = blend / (blend.x + blend.y + blend.z);

    float dither = DitherGradientNoise(1, pixelId);
    dither -= 0.5;
    float index = 0;
    index = blend.x - dither > blend.y ? 0 : 1;
    index = blend.z - dither > max(blend.x, blend.y) ? 2 : index;

    float2 uvX = pos.yz;
    float2 uvY = pos.xz;
    float2 uvZ = pos.xy;

    float4 ddx_ddy_uvX = float4(ddx(uvX), ddy(uvX));
    float4 ddx_ddy_uvY = float4(ddx(uvY), ddy(uvY));
    float4 ddx_ddy_uvZ = float4(ddx(uvZ), ddy(uvZ));

    float2 uvs[3] = {
        uvX, uvY, uvZ
    };
    float4 ddx_ddy_uvs[3] = {
        ddx_ddy_uvX, ddx_ddy_uvY, ddx_ddy_uvZ
    };

    float2 tri_uv = uvs[index];
    float4 ddx_ddy_tri_uv = ddx_ddy_uvs[index];
    float3 col = 0;

    if (index == 0)
    {
        tri_uv = uvX;
        ddx_ddy_tri_uv = ddx_ddy_uvX;
        col = UnpackNormal(tex.Sample(sampler_tex, tri_uv * uv_ST.xy + uv_ST.zw));
    }
    else if (index == 1)
    {
        tri_uv = uvY;
        ddx_ddy_tri_uv = ddx_ddy_uvY;
        col = UnpackNormal(tex.Sample(sampler_tex, tri_uv * uv_ST.xy + uv_ST.zw));
    }
    else if (index == 2)
    {
        tri_uv = uvZ;
        ddx_ddy_tri_uv = ddx_ddy_uvZ;
        col = UnpackNormal(tex.Sample(sampler_tex, tri_uv * uv_ST.xy + uv_ST.zw));
    }

    return col;
}

inline float3 SAMPLE2D_MAINTEX_TK(Texture2D tex, SamplerState samplerState, float2 uv, float4 uv_ST,
float3 pos, float3 normal, int2 pixelId)
{
    #if defined(_MAPPINGMODE_NONE)
        return tex.Sample(samplerState, uv * uv_ST.xy + uv_ST.zw).rgb;
    #elif defined(_MAPPINGMODE_TRIPLANAR)
        return TriplanarMapping_TK(tex, samplerState, pos, normal, uv_ST);
    #elif defined(_MAPPINGMODE_BIPLANAR)
        return BilpanarMapping_TK(tex, samplerState, pos, normal, uv_ST);
    #elif defined(_MAPPINGMODE_DITHER_TRIPLANAR)
        return DitherTriplanarMapping_TK(tex, samplerState, pos, normal, pixelId, uv_ST);
    #else
        return tex.Sample(samplerState, uv * uv_ST.xy + uv_ST.zw).rgb;
    #endif
}

inline float3 SAMPLE2D_NORMALMAP_TK(Texture2D tex, SamplerState samplerState, float2 uv, float4 uv_ST,
float3 pos, float3 normal, float3 worldTangent, float3 worldBinormal, int2 pixelId)
{
    #if defined(_MAPPINGMODE_NONE)
        float3 texNormal = UnpackNormal(tex.Sample(samplerState, uv * uv_ST.xy + uv_ST.zw));
        return normalize(localToWorld(worldTangent, normal, worldBinormal, float3(texNormal.x, texNormal.z, -texNormal.y)));
    #elif defined(_MAPPINGMODE_TRIPLANAR)
        return normalize(TriplanarMappingNormal_TK(tex, samplerState, pos, normal, uv_ST));
    #elif defined(_MAPPINGMODE_BIPLANAR)
        float3 texNormal = BilpanarMappingNormal_TK(tex, samplerState, pos, normal, uv_ST);
        return localToWorld(worldTangent, normal, worldBinormal, float3(texNormal.x, texNormal.z, -texNormal.y));
    #elif defined(_MAPPINGMODE_DITHER_TRIPLANAR)
        float3 texNormal = DitherTriplanarMappingNormal_TK(tex, samplerState, pos, normal, pixelId, uv_ST);
        return normalize(localToWorld(worldTangent, normal, worldBinormal, float3(texNormal.x, texNormal.z, -texNormal.y)));
    #else
        float3 texNormal = UnpackNormal(tex.Sample(samplerState, uv * uv_ST.xy + uv_ST.zw));
        return normalize(localToWorld(worldTangent, normal, worldBinormal, float3(texNormal.x, texNormal.z, -texNormal.y)));
    #endif
}

#endif