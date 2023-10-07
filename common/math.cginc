#ifndef _MATH_
#define _MATH_
inline float mod(float a, float b)
{
    return a - floor(a / b) * b;
}

inline float norm2(float3 a)
{
    return a.x * a.x + a.y * a.y + a.z * a.z;
}

static inline float square(float a)
{
    return a * a;
}
static inline float3 square(float3 a)
{
    return a * a;
}

inline float remap(float x, float a, float b, float c, float d)
{
    return c + (x - a) / (b - a) * (d - c);
}

inline int nearestInteger(float f)
{
    return int(((ceil(f) - f) < 0.5) ? ceil(f) : floor(f));
}

inline float2 rotate(float2 p, float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

#endif