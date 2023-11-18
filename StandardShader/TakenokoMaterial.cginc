#ifndef _TK_MATERIAL
#define _TK_MATERIAL

#include "TakenokoSampler.cginc"
#include "../common/color.cginc"

struct MappingInfoTK
{
    float2 uv;
    float3 worldPos;
    float3 worldNormal;
    float3 worldTangent;
    float3 worldBinormal;
    float2 pixelId;
    float3 viewDir;
};

struct MaterialParameter
{
    float3 basecolor;
    float roughness;
    float metallic;
    float3 emission;
    float alpha;

    #if defined(_TK_THINFILM_ON)
        bool thinFilmMask;
        float top_ior;
        float middle_ior;
        float middle_thickness;
        float3 bottom_ior;
        float3 bottom_kappa;
    #endif

    #if defined(_TK_CLOTH_ON)
        float3 clothAlbedo1;
        float3 clothAlbedo2;
        float clothKd1;
        float clothKd2;
        float clothIOR1;
        float clothIOR2;
        float clothGammaS1;
        float clothGammaS2;
        float clothGammaV1;
        float clothGammaV2;
        float clothAlpha1;
        float clothAlpha2;
        float4 clothTangentOffset1;
        float4 clothTangentOffset2;
    #endif
};

static inline float3 ShlickFresnelF0(float3 F0, float wdotn)
{
    float term1 = 1.0f - wdotn;
    return F0 + (1.0f - F0) * term1 * term1 * term1 * term1 * term1;
}

inline float3 DetailMapCombineTK(float3 maintex, float3 detailtex, float mask)
{
    #ifdef _TK_DETAIL_BLEND_LINNER
        return lerp(maintex, detailtex, mask);
    #elif _TK_DETAIL_BLEND_ADD
        return lerp(maintex, maintex + detailtex, mask);
    #elif _TK_DETAIL_BLEND_MULTIPLY
        return lerp(maintex, maintex * detailtex, mask);
    #elif _TK_DETAIL_BLEND_SUBTRACT
        return lerp(maintex, maintex - detailtex, mask);
    #else
        return lerp(maintex, detailtex, mask);
    #endif
}

void SetMaterialParameterTK(inout MaterialParameter matParam, MappingInfoTK mapInfo, inout float3 shadingNormal)
{
    float3 viewDir = worldToLocal(mapInfo.worldTangent, mapInfo.worldNormal, mapInfo.worldBinormal, mapInfo.viewDir);
    float2 pallaxoffset = SAMPLE2D_PALLAX_TK(_PallaxMap, sampler_PallaxMap, mapInfo.uv, _PallaxMap_ST, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId, viewDir);
    float4 uvOffset = float4(0, 0, pallaxoffset);

    //Basecolor
    float4 baseColor = SAMPLE2D_MAINTEX_TK(_MainTex, sampler_MainTex, mapInfo.uv, _MainTex_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId);
    matParam.basecolor = _Color * baseColor.xyz;
    matParam.alpha = baseColor.a;
    matParam.roughness = _Roughness * SAMPLE2D_MAINTEX_TK(_RoughnessMap, sampler_RoughnessMap, mapInfo.uv, _RoughnessMap_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId).r;
    matParam.metallic = _Metallic * SAMPLE2D_MAINTEX_TK(_MetallicGlossMap, sampler_MetallicGlossMap, mapInfo.uv, _MetallicGlossMap_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId).r;

    matParam.emission = _EmissionColor * SAMPLE2D_MAINTEX_TK(_EmissionMap, sampler_EmissionMap, mapInfo.uv, _EmissionMap_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId);

    shadingNormal = normalize(SAMPLE2D_NORMALMAP_TK(_BumpMap, sampler_BumpMap, mapInfo.uv, _BumpMap_ST + uvOffset,
    mapInfo.worldPos, mapInfo.worldNormal, mapInfo.worldTangent, mapInfo.worldBinormal, mapInfo.pixelId, _BumpScale));
    


    #if defined(_TK_DETAIL_ON)
        float detail_mask = SAMPLE2D_DETAILMAP_TK(_DetailMaskMap, sampler_MainTex, mapInfo.uv, _DetailMaskMap_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId).r * _DetailMaskFactor;
        float3 detail_basecolor = SAMPLE2D_DETAILMAP_TK(_DetailAlbedoMap, sampler_MainTex, mapInfo.uv, _DetailAlbedoMap_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId).rgb * _DetailAlbedo;
        float detail_roughness = SAMPLE2D_DETAILMAP_TK(_DetailRoughnessMap, sampler_MainTex, mapInfo.uv, _DetailRoughnessMap_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId).r * _DetailRoughness;
        float detail_metallic = SAMPLE2D_DETAILMAP_TK(_DetailMetallicMap, sampler_MainTex, mapInfo.uv, _DetailMetallicMap_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId).r * _DetailMetallic;
        float3 detail_normal = SAMPLE2D_DETAILNORMALMAP_TK(_DetailNormalMap, sampler_MainTex, mapInfo.uv, _DetailNormalMap_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.worldTangent, mapInfo.worldBinormal, mapInfo.pixelId, _DetalNormalMapScale);

        matParam.basecolor = DetailMapCombineTK(matParam.basecolor, detail_basecolor, detail_mask);
        matParam.roughness = DetailMapCombineTK(matParam.roughness, detail_roughness, detail_mask).r;
        matParam.metallic = DetailMapCombineTK(matParam.metallic, detail_metallic, detail_mask).r;

        float3 blendnormal = BlendNormals(shadingNormal, detail_normal);
        shadingNormal = lerp(shadingNormal, blendnormal, detail_mask);

    #endif

    //ThinFilm Parametor
    #if defined(_TK_THINFILM_ON)
        float thickness_value = SAMPLE2D_MAINTEX_TK(_ThinFilmMiddleThicknessMap, sampler_MainTex, mapInfo.uv, _ThinFilmMiddleThicknessMap_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId) * _ThinFilmMiddleThickness;
        float thickness = lerp(_ThinFilmMiddleThicknessMin, _ThinFilmMiddleThicknessMax, thickness_value); //nm

        matParam.middle_thickness = thickness;
        matParam.middle_ior = _ThinFilmMiddleIOR;
        matParam.top_ior = 1.0;

        float3 dietric_ior = 1.5;
        float3 dietric_kappa = 0.0;

        float3 metal_color = clamp(matParam.basecolor.rgb, 0.001, 0.999); //avoid NaN
        float3 edge_tint = ShlickFresnelF0(metal_color, 0.75); //Magic Number TODO:Find better value
        float3 metallic_ior = rToIOR(metal_color, edge_tint);
        float3 metallic_kappa = rToKappa(metal_color, metallic_ior);

        float3 metallic_color = getR(metallic_ior, metallic_kappa);
        float3 metallic_tint = getG(metallic_ior, metallic_kappa);
        
        metallic_ior = rToIOR(metallic_color, metallic_tint);
        metallic_kappa = rToKappa(metallic_color, metallic_ior);

        matParam.bottom_ior = lerp(dietric_ior, metallic_ior, matParam.metallic);
        matParam.bottom_kappa = lerp(dietric_kappa, metallic_kappa, matParam.metallic);

        matParam.thinFilmMask = SAMPLE2D_MAINTEX_TK(_ThinFilmMaskMap, sampler_MainTex, mapInfo.uv, _ThinFilmMaskMap_ST + uvOffset, mapInfo.worldPos, mapInfo.worldNormal, mapInfo.pixelId).r > 0.5;
    #endif

    #if defined(_TK_CLOTH_ON)
        matParam.clothAlbedo1 = _ClothAlbedo1 * matParam.basecolor;
        matParam.clothAlbedo2 = _ClothAlbedo2 * matParam.basecolor;
        matParam.clothKd1 = _ClothKd1;
        matParam.clothKd2 = _ClothKd2;
        matParam.clothIOR1 = _ClothIOR1;
        matParam.clothIOR2 = _ClothIOR2;
        matParam.clothGammaS1 = _ClothGammaS1;
        matParam.clothGammaS2 = _ClothGammaS2;
        matParam.clothGammaV1 = _ClothGammaV1;
        matParam.clothGammaV2 = _ClothGammaV2;
        matParam.clothAlpha1 = _ClothAlpha1;
        matParam.clothAlpha2 = _ClothAlpha2;
        matParam.clothTangentOffset1 = _ClothTangentOffset1;
        matParam.clothTangentOffset2 = _ClothTangentOffset2;
    #endif
}
#endif