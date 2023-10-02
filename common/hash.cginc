#ifndef _HASH_
#define _HASH_
#define ToM11(x) 2.0f * x - 1.0f

inline float hash11(float s)
{
    return frac(sin(s) * 43758.5453123);
}

inline float hash21(float2 s)
{
    return frac(sin(dot(s, float2(12.9898, 78.233))) * 43758.5453123);
}

inline float hash31(float3 s)
{
    return frac(sin(dot(s, float3(12.9898, 78.233, 45.164))) * 43758.5453123);
}

inline float2 hash12(float s)
{
    return frac(sin(float2(s * 194.2, s * 293.2)) * 43758.5453123);
}

inline float2 hash22(float2 s)
{
    return frac(sin(float2(dot(s, float2(12.9898, 78.233)), dot(s, float2(45.164, 39.645)))) * 43758.5453123);
}

inline float2 hash32(float3 s)
{
    return frac(sin(float2(dot(s, float3(12.9898, 78.233, 45.164)), dot(s, float3(39.645, 45.164, 12.9898)))) * 43758.5453123);
}

inline float3 hash13(float s)
{
    return frac(sin(float3(s * 194.2, s * 293.2, s * 394.2)) * 43758.5453123);
}

inline float3 hash23(float2 s)
{
    return frac(sin(float3(dot(s, float2(12.9898, 78.233)), dot(s, float2(45.164, 39.645)), dot(s, float2(39.645, 45.164)))) * 43758.5453123);
}

inline float3 hash33(float3 s)
{
    return frac(sin(float3(dot(s, float3(12.9898, 78.233, 45.164)), dot(s, float3(39.645, 45.164, 12.9898)), dot(s, float3(45.164, 12.9898, 78.233)))) * 43758.5453123);
}

#endif