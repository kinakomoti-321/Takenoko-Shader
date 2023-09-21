//https://github.com/cnlohr/shadertrixx

float4x4 inverse(float4x4 input)
{
    #define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
    //determinant(float3x3(input._22_23_23, input._32_33_34, input._42_43_44))

    float4x4 cofactors = float4x4(
        minor(_22_23_24, _32_33_34, _42_43_44),
        -minor(_21_23_24, _31_33_34, _41_43_44),
        minor(_21_22_24, _31_32_34, _41_42_44),
        -minor(_21_22_23, _31_32_33, _41_42_43),

        -minor(_12_13_14, _32_33_34, _42_43_44),
        minor(_11_13_14, _31_33_34, _41_43_44),
        -minor(_11_12_14, _31_32_34, _41_42_44),
        minor(_11_12_13, _31_32_33, _41_42_43),

        minor(_12_13_14, _22_23_24, _42_43_44),
        -minor(_11_13_14, _21_23_24, _41_43_44),
        minor(_11_12_14, _21_22_24, _41_42_44),
        -minor(_11_12_13, _21_22_23, _41_42_43),

        -minor(_12_13_14, _22_23_24, _32_33_34),
        minor(_11_13_14, _21_23_24, _31_33_34),
        -minor(_11_12_14, _21_22_24, _31_32_34),
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

float3 worldToLocal(float3 x, float3 y,float3 z,float3 v){
    return float3(dot(x,v),dot(y,v),dot(z,v));
}

float3 localToWorld(float3 x, float3 y,float3 z,float3 v){
    return x*v.x + y*v.y + z*v.z;
}
