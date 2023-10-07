#ifndef _MATRIX_
#define _MATRIX_
//https://github.com/cnlohr/shadertrixx
float4x4 inverse(float4x4 input)
{
    #define minor(a, b, c) determinant(float3x3(input.a, input.b, input.c))
    //determinant(float3x3(input._22_23_23, input._32_33_34, input._42_43_44))

    float4x4 cofactors = float4x4(
        minor(_22_23_24, _32_33_34, _42_43_44),
        - minor(_21_23_24, _31_33_34, _41_43_44),
        minor(_21_22_24, _31_32_34, _41_42_44),
        - minor(_21_22_23, _31_32_33, _41_42_43),

        - minor(_12_13_14, _32_33_34, _42_43_44),
        minor(_11_13_14, _31_33_34, _41_43_44),
        - minor(_11_12_14, _31_32_34, _41_42_44),
        minor(_11_12_13, _31_32_33, _41_42_43),

        minor(_12_13_14, _22_23_24, _42_43_44),
        - minor(_11_13_14, _21_23_24, _41_43_44),
        minor(_11_12_14, _21_22_24, _41_42_44),
        - minor(_11_12_13, _21_22_23, _41_42_43),

        - minor(_12_13_14, _22_23_24, _32_33_34),
        minor(_11_13_14, _21_23_24, _31_33_34),
        - minor(_11_12_14, _21_22_24, _31_32_34),
        minor(_11_12_13, _21_22_23, _31_32_33)
    );
    #undef minor
    return transpose(cofactors) / determinant(input);
}

float4x4 worldToView()
{
    return UNITY_MATRIX_V;
}

float4x4 viewToWorld()
{
    return UNITY_MATRIX_I_V;
}

float4x4 viewToClip()
{
    return UNITY_MATRIX_P;
}

float4x4 clipToView()
{
    return inverse(UNITY_MATRIX_P);
}

float4x4 worldToClip()
{
    return UNITY_MATRIX_VP;
}

float4x4 clipToWorld()
{
    return inverse(UNITY_MATRIX_VP);
}

float3 worldToLocal(float3 x, float3 y, float3 z, float3 v)
{
    return float3(dot(x, v), dot(y, v), dot(z, v));
}

float3 localToWorld(float3 x, float3 y, float3 z, float3 v)
{
    return x * v.x + y * v.y + z * v.z;
}

#define VectorToQuatunion(n, theta) float4(cos(0.5 * theta), n.x * sin(0.5 * theta), n.y * sin(0.5 * theta), n.z * sin(0.5 * theta))

float3 vector_quat_rotate(float3 v, float4 q)
{
    return v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v);
}

#define copysignf(a, b) (b < 0.0 ? - a : a)

void orthonormalBasis(float3 normal, inout float3 tangent, inout float3 binormal)
{
    // float sign = copysignf(1.0f, normal.z);
    // float a = -1.0f / (sign + normal.z);
    // float b = normal.x * normal.y * a;
    // tangent = float3(1.0f + sign * normal.x * normal.x * a, sign * b,
    // - sign * normal.x);
    // binormal = float3(b, sign + normal.y * normal.y * a, -normal.y);
    if (abs(normal[1]) < 0.999f)
    {
        tangent = cross(normal, float3(0, 1, 0));
    }
    else
    {
        tangent = cross(normal, float3(0, 0, -1));
    }
    tangent = normalize(tangent);
    binormal = cross(tangent, normal);
    binormal = normalize(binormal);
}

#endif