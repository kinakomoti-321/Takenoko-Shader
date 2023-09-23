#ifndef TK_STANDARD_BSDF
    #define TK_STANDARD_BSDF
    
    #include "UnityStandardBRDF.cginc"
    #include "../common/constant.cginc"

    #define HILIGHT_SPECULAR_MAX 65504f
    #define saturateHilight(x) min(x, HILIGHT_SPECULAR_MAX)

    struct MaterialParameter{
        float3 basecolor;
        float roughness;
        float metallic;
        float3 emission;
    };

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
    
    static inline float3 ShlickFresnelF0(float3 F0,float wdotn){
        float term1 = 1.0f - wdotn;
        return F0 + (1.0f - F0) * term1 * term1 * term1 * term1 * term1;
    }

    static inline float3 ShlickFresnelF90(float3 F90,float wdotn){
        float term1 = 1.0f - wdotn;
        return 1.0f + (F90 - 1.0f) * term1 * term1 * term1 * term1 * term1;
    }

    //Normal Distribution GGX
    static inline float GGX_D(float hdotn,float roughness){
        float alpha = hdotn * roughness;
        float term = roughness / (1.0f - hdotn * hdotn + alpha * alpha);
        return term * term * INVPI;
    }

    //Visible term
    static inline float GGX_V2_Heightcorrelated(float vdotn, float ldotn,float roughness){
        float alpha2 = roughness * roughness;
        float VisibleV = ldotn * sqrt(vdotn * vdotn * (1.0f - alpha2) + alpha2);    
        float VisibleL = vdotn * sqrt(ldotn * ldotn * (1.0f - alpha2) + alpha2);
        return 0.5 / (VisibleV + VisibleL);
    }


    inline float3 SpecularGGX(float ldoth,float hdotn,float vdotn,float ldotn,float roughness,float3 F0){
        float D = GGX_D(hdotn,roughness);
        float V = GGX_V2_Heightcorrelated(vdotn,ldotn,roughness);
        float3 F = ShlickFresnelF0(F0,ldoth);
        return D * V * F;
    }
    
    inline float3 DisneyDiffuse(float ldoth,float vdotn,float ldotn,float3 basecolor,float roughness){
        float Fd90 = 0.5 + 2.0 * ldoth * ldoth * roughness;
        float FdView = ShlickFresnelF90(Fd90,vdotn);
        float FdLight = ShlickFresnelF90(Fd90,ldotn);
        return basecolor * FdView * FdLight * INVPI;
    }

    inline void EvaluateBSDF_TK(
    inout float3 diffuse,inout float3 specular,float3 normalWorld,UnityGIInput giInput,MaterialParameter matParam)
    {
        float3 lightDirection = giInput.light.dir;
        float3 viewDirection = giInput.worldViewDir;
        float3 lightEmission = giInput.light.color * giInput.atten;

        float3 halfVector = Unity_SafeNormalize(lightDirection + viewDirection);

        float vdotn = saturate(dot(viewDirection, normalWorld));
        float ldotn = saturate(dot(lightDirection, normalWorld));
        float hdotn = saturate(dot(halfVector, normalWorld));  
        float ldoth = saturate(dot(halfVector, lightDirection));

        float3 disneyDif = max(DisneyDiffuse(ldoth,vdotn,ldotn,matParam.basecolor,matParam.roughness) * ldotn * lightEmission,0.0f);

        float3 F0 = lerp(0.04f,matParam.basecolor,matParam.metallic);
        float3 ggx_specular = max(SpecularGGX(ldoth,hdotn,vdotn,ldotn,matParam.roughness,F0) * ldotn * lightEmission,0.0f);


        diffuse = disneyDif;
        specular = ggx_specular; 

        //Unity Correction PI
        diffuse *= PI;
        specular *= PI;
    } 

    inline void EvaluateLighting_TK(inout float3 diffuse,inout float3 specular,float3 normalWorld,UnityGIInput giInput,MaterialParameter matParam){
        EvaluateBSDF_TK(diffuse,specular,normalWorld,giInput,matParam);

        float3 refDir = reflect(-giInput.worldViewDir,normalWorld);

        float perceptualRoughness = matParam.roughness * (1.7 - 0.7 * matParam.roughness);
        float miplevel = perceptualRoughnessToMipmapLevel(perceptualRoughness);
        half4 envRefProbe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, refDir, miplevel);
        float3 envSpec0 = DecodeHDR(envRefProbe0,giInput.probeHDR[0]);

        float3 F0 = lerp(0.08,matParam.basecolor,matParam.metallic);
        float3 fresnel = ShlickFresnelF0(F0,saturate(dot(normalWorld,giInput.worldViewDir)));

        specular += envSpec0 * fresnel;
    }

    inline void EvaluateSpecularOnly_TK(inout float3 specular,float3 normalWorld,
    float3 viewDirection,MaterialParameter matParam,float3 lightDirection,float3 lightColor){
        float halfVector = Unity_SafeNormalize(lightDirection + viewDirection);

        float vdotn = saturate(dot(viewDirection,normalWorld));
        float ldotn = saturate(dot(lightDirection,normalWorld));
        float hdotn = saturate(dot(halfVector,normalWorld));
        float ldoth = saturate(dot(halfVector,lightDirection));

        float3 F0 = lerp(0.04f,matParam.basecolor,matParam.metallic);
        float3 ggx_specular = max(SpecularGGX(ldoth,hdotn,vdotn,ldotn,matParam.roughness,F0) * ldotn * lightColor,0.0);

        
        specular = ggx_specular;
    }

#endif