#ifndef _DEPTH_CGINC
#define _DEPTH_CGINC


float ComputeDepth(float4 clippos)
{
#if defined(SHADER_TARGET_GLSL) || defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
    return (clippos.z / clippos.w) * 0.5 + 0.5;
#else
    return clippos.z / clippos.w;
#endif
}

#define PM UNITY_MATRIX_P

//https://github.com/keijiro/DepthInverseProjection/blob/master/Assets/InverseProjection/Resources/InverseProjection.shader
inline float4 CalculateFrustumCorrection()
{
    float x1 = -PM._31/(PM._11*PM._34);
    float x2 = -PM._32/(PM._22*PM._34);
    return float4(x1, x2, 0, PM._33/PM._34 + x1*PM._13 + x2*PM._23);
}

inline float CorrectedLinearEyeDepth(float z, float B)
{
    return 1.0 / (z/PM._34 + B);
}

#endif