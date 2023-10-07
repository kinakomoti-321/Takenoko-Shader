#ifndef TK_STANDARD_BSDF
#define TK_STANDARD_BSDF

#include "UnityStandardBRDF.cginc"

#include "TakenokoMaterial.cginc"
#include "TakenokoSampler.cginc"
#include "TakenokoThinFilm.cginc"
#include "TakenokoCloth.cginc"
#include "../common/constant.cginc"
#include "../common/color.cginc"

#define HILIGHT_SPECULAR_MAX 65504f
#define saturateHilight(x) min(x, HILIGHT_SPECULAR_MAX)


// Define
// struct UnityGIInput
// {
//     UnityLight light; // pixel light, sent from the engine

//     float3 worldPos;
//     half3 worldViewDir;
//     half atten;
//     half3 ambient;

//     // interpolated lightmap UVs are passed as full float precision data to fragment shaders
//     // so lightmapUV (which is used as a tmp inside of lightmap fragment shaders) should
//     // also be full float precision to avoid data loss before sampling a texture.
//     float4 lightmapUV; // .xy = static lightmap UV, .zw = dynamic lightmap UV

//     #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION) || defined(UNITY_ENABLE_REFLECTION_BUFFERS)
//         float4 boxMin[2];
//     #endif
//     #ifdef UNITY_SPECCUBE_BOX_PROJECTION
//         float4 boxMax[2];
//         float4 probePosition[2];
//     #endif
//     // HDR cubemap properties, use to decompress HDR texture
//     float4 probeHDR[2];
// };

//struct UnityLight
// {
//     half3 color;
//     half3 dir;
//     half  ndotl; // Deprecated: Ndotl is now calculated on the fly and is no longer stored. Do not used it.
// };


static inline float3 ShlickFresnelF90(float3 F90, float wdotn)
{
    float term1 = 1.0f - wdotn;
    return 1.0f + (F90 - 1.0f) * term1 * term1 * term1 * term1 * term1;
}

//Normal Distribution GGX
static inline float GGX_D(float hdotn, float roughness)
{
    float alpha = hdotn * roughness;
    float term = roughness / (1.0f - hdotn * hdotn + alpha * alpha);
    return term * term * INVPI;
}

//Visible term
static inline float GGX_V2_Heightcorrelated(float vdotn, float ldotn, float roughness)
{
    float alpha2 = roughness * roughness;
    float VisibleV = ldotn * sqrt(vdotn * vdotn * (1.0f - alpha2) + alpha2);
    float VisibleL = vdotn * sqrt(ldotn * ldotn * (1.0f - alpha2) + alpha2);
    return 0.5 / (VisibleV + VisibleL);
}


inline float3 SpecularGGX(float ldoth, float hdotn, float vdotn, float ldotn, float roughness, float3 F0)
{
    float D = GGX_D(hdotn, roughness);
    float V = GGX_V2_Heightcorrelated(vdotn, ldotn, roughness);
    float3 F = ShlickFresnelF0(F0, ldoth);
    return D * V * F;
}

inline float3 DisneyDiffuse(float ldoth, float vdotn, float ldotn, float3 basecolor, float roughness)
{
    float Fd90 = 0.5 + 2.0 * ldoth * ldoth * roughness;
    float FdView = ShlickFresnelF90(Fd90, vdotn);
    float FdLight = ShlickFresnelF90(Fd90, ldotn);
    return basecolor * FdView * FdLight * INVPI;
}

//https://www.unrealengine.com/ja/blog/physically-based-shading-on-mobile
inline float3 EnvBRDFApprox(float3 SpecularColor, float Roughness, float3 NoV)
{
    const half4 c0 = {
        - 1, -0.0275, -0.572, 0.022
    };
    const half4 c1 = {
        1, 0.0425, 1.04, -0.04
    };

    half4 r = Roughness * c0 + c1;

    half a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;

    half2 AB = half2(-1.04, 1.04) * a004 + r.zw;

    return SpecularColor * AB.x + AB.y;
}

static inline float3 CalculateF0_TK(MaterialParameter matParam, float cosTheta)
{
    #if !defined(_TK_THINFILM_ON)
        //Disney BRDF
        return lerp(0.08f, matParam.basecolor, matParam.metallic);
    #else
        return saturate(fresnel_airy(cosTheta, matParam.bottom_ior, matParam.bottom_kappa,
        matParam.middle_thickness, matParam.top_ior, matParam.middle_ior));
    #endif
}

inline void EvaluateBSDF_TK(
    inout float3 diffuse, inout float3 specular, float3 normalWorld, UnityGIInput giInput, MaterialParameter matParam)
{
    float3 lightDirection = giInput.light.dir;
    float3 viewDirection = giInput.worldViewDir;
    float3 lightEmission = giInput.light.color * giInput.atten;

    float3 halfVector = Unity_SafeNormalize(lightDirection + viewDirection);

    float vdotn = saturate(dot(viewDirection, normalWorld));
    float ldotn = saturate(dot(lightDirection, normalWorld));
    float hdotn = saturate(dot(halfVector, normalWorld));
    float ldoth = saturate(dot(halfVector, lightDirection));

    float3 disneyDif = max(DisneyDiffuse(ldoth, vdotn, ldotn, matParam.basecolor, matParam.roughness) * ldotn * lightEmission, 0.0f);

    float3 F0 = CalculateF0_TK(matParam, ldoth);

    float3 ggx_specular = max(SpecularGGX(ldoth, hdotn, vdotn, ldotn, matParam.roughness, F0) * ldotn * lightEmission, 0.0f);


    diffuse = disneyDif;
    specular = ggx_specular;

    //Unity Correction PI
    diffuse *= PI;
    specular *= PI;
}

inline void EvaluateSpecularBSDF_TK(inout float3 specular, float3 normalWorld,
float3 viewDirection, MaterialParameter matParam, float3 lightDirection, float3 lightColor, float ligthAtten)
{

    float3 lightEmission = lightColor * ligthAtten;

    float3 halfVector = Unity_SafeNormalize(lightDirection + viewDirection);

    float vdotn = saturate(dot(viewDirection, normalWorld));
    float ldotn = saturate(dot(lightDirection, normalWorld));
    float hdotn = saturate(dot(halfVector, normalWorld));
    float ldoth = saturate(dot(halfVector, lightDirection));

    float3 F0 = CalculateF0_TK(matParam, ldoth);
    float3 ggx_specular = max(SpecularGGX(ldoth, hdotn, vdotn, ldotn, matParam.roughness, F0) * ldotn * lightEmission, 0.0f);

    specular = ggx_specular;

    //Unity Correction PI
    specular *= PI;
}

inline void EvaluateSpecularGI_TK(inout float3 specular, float3 normalWorld,
UnityGIInput giInput, MaterialParameter matParam)
{
    float3 refDir = reflect(-giInput.worldViewDir, normalWorld);
    float ndotv = saturate(dot(normalWorld, giInput.worldViewDir));

    float perceptualRoughness = matParam.roughness * (1.7 - 0.7 * matParam.roughness);
    
    float miplevel = perceptualRoughnessToMipmapLevel(perceptualRoughness);
    half4 envRefProbe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, refDir, miplevel);
    float3 envSpec0 = DecodeHDR(envRefProbe0, giInput.probeHDR[0]);
    half4 envRefProbe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, refDir, miplevel);
    float3 envSpec1 = DecodeHDR(envRefProbe1, giInput.probeHDR[1]);

    float3 envSpecCombine = lerp(envSpec1, envSpec0, giInput.boxMin[0].w);

    float3 F0 = CalculateF0_TK(matParam, ndotv);

    float3 envBRDF = envSpecCombine * EnvBRDFApprox(F0, matParam.roughness, ndotv);
    specular = envBRDF;
}

inline void EvaluateLighting_TK(inout float3 diffuse, inout float3 specular, float3 normalWorld,
UnityGIInput giInput, MaterialParameter matParam)
{
    EvaluateBSDF_TK(diffuse, specular, normalWorld, giInput, matParam);
    float3 specularGI = 0.0f;
    EvaluateSpecularGI_TK(specularGI, normalWorld, giInput, matParam);
    specular += specularGI;
}

inline void EvaluateLightingSpecular_TK(inout float3 specular, float3 normalWorld,
UnityGIInput giInput, MaterialParameter matParam)
{
    EvaluateSpecularBSDF_TK(specular, normalWorld, giInput.worldViewDir, matParam, giInput.light.dir, giInput.light.color, giInput.atten);
    float3 specularGI = 0.0f;
    EvaluateSpecularGI_TK(specularGI, normalWorld, giInput, matParam);
    specular += specularGI;
}


#endif