#ifndef _NOISE_
#define _NOISE_
#include "./hash.cginc"

float ValueNoise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);

    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));

    float2 u = f * f * (3.0 - 2.0 * f);

    return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
}

float ParlignNoise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    
    float2 u = f * f * (3.0 - 2.0 * f);

    float a = dot(ToM11(hash22(i)), f);
    float b = dot(ToM11(hash22(i + float2(1.0, 0.0))), f - float2(1.0, 0.0));
    float c = dot(ToM11(hash22(i + float2(0.0, 1.0))), f - float2(0.0, 1.0));
    float d = dot(ToM11(hash22(i + float2(1.0, 1.0))), f - float2(1.0, 1.0));

    return 0.5f * lerp(
        lerp(a, b, u.x),
        lerp(c, d, u.x), u.y
    ) + 0.5f;
}

//https://thebookofshaders.com/edit.php#11/2d-snoise-clear.frag
inline float3 mod289(float3 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
inline float2 mod289(float2 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
inline float3 permute(float3 x)
{
    return mod289(((x * 34.0) + 1.0) * x);
}

float SimplexNoise(float2 v)
{

    const float4 C = float4(0.211324865405187,
    0.366025403784439,
    - 0.577350269189626,
    0.024390243902439);

    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);

    float2 i1 = 0.0;
    i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
    float2 x1 = x0.xy + C.xx - i1;
    float2 x2 = x0.xy + C.zz;

    i = mod289(i);
    float3 p = permute(
        permute(i.y + float3(0.0, i1.y, 1.0))
    + i.x + float3(0.0, i1.x, 1.0));

    float3 m = max(0.5 - float3(
        dot(x0, x0),
        dot(x1, x1),
        dot(x2, x2)
    ), 0.0);

    m = m * m ;
    m = m * m ;

    float3 x = 2.0 * frac(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;

    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

    float3 g = 0.0;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * float2(x1.x, x2.x) + h.yz * float2(x1.y, x2.y);
    return (130.0 * dot(m, g)) * 0.5 + 0.5;
}


//https://www.shadertoy.com/view/3tcyD7
float3x3 getOrthogonalBasis(float3 direction)
{
    direction = normalize(direction);
    float3 right = normalize(cross(float3(0, 1, 0), direction));
    float3 up = normalize(cross(direction, right));
    return float3x3(right, up, direction);
}

float CyclicNoise(float3 p)
{
    float noise = 0.;
    
    float amp = 1.;
    const float gain = 0.6;
    const float lacunarity = 1.5;
    const int octaves = 8;
    
    const float warp = 0.3;
    float warpTrk = 1.2 ;
    const float warpTrkGain = 1.5;
    
    float3 seed = float3(-1, -2., 0.5);
    float3x3 rotMatrix = getOrthogonalBasis(seed);
    
    for (int i = 0; i < octaves; i++)
    {
        
        p += sin(p.zxy * warpTrk - 2. * warpTrk) * warp;
        
        noise += sin(dot(cos(p), sin(p.zxy))) * amp;
        
        p = mul(rotMatrix, p);
        p *= lacunarity;
        
        warpTrk *= warpTrkGain;
        amp *= gain;
    }
    
    return 1. - abs(noise) * 0.5;
}

float FBMParlign(float2 p)
{
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 2.0;

    int octaves = 5;
    float2x2 rot = float2x2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
    for (int i = 0; i < octaves; i++)
    {
        value += ValueNoise(p) * amplitude;
        p = mul(rot, p) * frequency + 100.0;
        amplitude *= 0.5;
    }

    return value;
}
#endif