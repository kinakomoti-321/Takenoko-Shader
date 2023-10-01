#ifndef _TK_SAMPLER
#define _TK_SAMPLER

#define SAMPLE2D_TK(tex, sampler_tex, uv) tex.Sample(sampler_tex, uv)

#define SAMPLE2D_GRAD_TK(tex, sampler_tex, uv, dx, dy) tex.SampleGrad(sampler_tex, uv, dx, dy)
#define SAMPLE2D_GRAD_TK(tex, sampler_tex, uv) SAMPLE2D_GRAD_TK(tex, sampler_tex, uv, ddx(uv), ddy(uv))

inline float3 TriplanarMapping_TK(Texture2D tex, SamplerState sampler_tex, float3 pos, float3 normal)
{
    float3 blend = abs(normal);
    float3 blend = blend / (blend.x + blend.y + blend.z);
    
    float3 uvX = pos.yz;
    float3 uvY = pos.xz;
    float3 uvZ = pos.xy;

    uvX = (normal.x < 0) ? - uvX : uvX;
    uvY = (normal.y < 0) ? - uvY + 0.5 : uvY + 0.5;
    uvZ = (normal.z < 0) ? - uvZ - 0.5 : uvZ - 0.5;

    float3 texX = SAMPLE2D_GRAD_TK(tex, sampler_tex, uvX);
    float3 texY = SAMPLE2D_GRAD_TK(tex, sampler_tex, uvY);
    float3 texZ = SAMPLE2D_GRAD_TK(tex, sampler_tex, uvZ);

    return blend.x * texX + blend.y * texY + blend.z * texZ;
}

inline float3 TriplanarMappingNormal_TK(Texture2D tex, SamplerState sampler_tex, float3 pos, float3 normal)
{
    float3 blend = abs(normal);
    float3 blend = blend / (blend.x + blend.y + blend.z);
    
    float3 uvX = pos.yz;
    float3 uvY = pos.xz;
    float3 uvZ = pos.xy;

    uvX = (normal.x < 0) ? - uvX : uvX;
    uvY = (normal.y < 0) ? - uvY + 0.5 : uvY + 0.5;
    uvZ = (normal.z < 0) ? - uvZ - 0.5 : uvZ - 0.5;

    float3 texX = SAMPLE2D_GRAD_TK(tex, sampler_tex, uvX);
    float3 texY = SAMPLE2D_GRAD_TK(tex, sampler_tex, uvY);
    float3 texZ = SAMPLE2D_GRAD_TK(tex, sampler_tex, uvZ);

    return blend.x * texX + blend.y * texY + blend.z * texZ;
}

inline float3 BilpanarMapping_TK(Texture2D tex, SamplerState sampler, float3 pos, float3 normal)
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
    
    float3 x_sample = _MainTex.SampleGrad(sampler_MainTex, float2(pos[ma.y], pos[ma.z]),
    float2(dpdx[ma.y], dpdx[ma.z]),
    float2(dpdy[ma.y], dpdy[ma.z]));
    float3 y_sample = _MainTex.SampleGrad(sampler_MainTex, float2(pos[me.y], pos[me.z]),
    float2(dpdx[me.y], dpdx[me.z]),
    float2(dpdy[me.y], dpdy[me.z]));
    
    float2 weight = float2(normal[ma.x], normal[me.x]);
    weight = clamp((weight - 0.5773) / (1.0 - 0.5773), 0.0, 1.0);
    weight = pow(weight, k / 8.0);
    return (weight.x * x_sample + weight.y * y_sample) / (weight.x + weight.y);
}

inline float DitherGradientNoise(int frame, int2 pixel)
{
    int f = trunc(float(frame)) % 64;
    int2 iP = trunc(float2(pixel.x, pixel.y));
    pixel = float2(iP) + 5.588238f * float(f);
    return frac(52.9829189f * frac(0.06711056f * pixel.x + 0.00583715f * pixel.y));
}

inline float3 DitherTriplanarMapping_TK(Texture2D tex, SamplerState sampler, float3 pos, float3 normal, int2 pixelId)
{
    float3 blend = abs(normal);
    blend = pow(blend, 10.0);
    blend = blend / (blend.x + blend.y + blend.z);

    float dither = GradientNoise(1, pixelId);
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
        col = _MainTex.SampleGrad(sampler_MainTex, tri_uv, ddx_ddy_tri_uv.xy, ddx_ddy_tri_uv.zw).rgb;
    }
    else if (index == 1)
    {
        tri_uv = uvY;
        ddx_ddy_tri_uv = ddx_ddy_uvY;
        col = _MainTex.SampleGrad(sampler_MainTex, tri_uv, ddx_ddy_tri_uv.xy, ddx_ddy_tri_uv.zw).rgb;
    }
    else if (index == 2)
    {
        tri_uv = uvZ;
        ddx_ddy_tri_uv = ddx_ddy_uvZ;
        col = _MainTex.SampleGrad(sampler_MainTex, tri_uv, ddx_ddy_tri_uv.xy, ddx_ddy_tri_uv.zw).rgb;
    }

    float3 ddx_col = ddx(col);
    float3 ddy_col = ddy(col);
    
    return col;
}

inline float3 SAMPLE2D_MAINTEX_TK(Texture2D tex, SamplerState samplerState float2 uv, float3 pos, float3 normal, int2 pixelId)
{
    #if defined(_MAPPINGMODE_NONE)
        return tex.Sample(samplerState, uv);
    #else if defined(_MAPPINGMODE_TRIPLANAR)
        return TriplanarMapping_TK(tex, samplerState, pos, normal);
    #else if defined(_MAPPINGMODE_BILPLANAR)
        return BilpanarMapping_TK(tex, samplerState, pos, normal);
    #else if defined(_MAPPINGMODE_DITHER)
        return DitherTriplanarMapping_TK(tex, samplerState, pos, normal, pixelId);
    #else
        return tex.Sample(samplerState, uv);
    #endif
}

#endif