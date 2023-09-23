#ifndef TK_STANDARD_BSDF
    #define TK_STANDARD_BSDF
    
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

    static inline float3 ShlickFresnel(float3 F0,float wdotn){
        float term1 = 1.0f - wdotn;
        return F0 + (1.0f - F0) * term1 * term1 * term1 * term1 * term1;
    }

    inline float3 SpecularGGX(float ldoth,float hdotn,float vdotn,float ldotn,float roughness,float3 F0){
        float D = GGX_D(hdotn,roughness);
        float V = GGX_V2_Heightcorrelated(vdotn,ldotn,roughness);
        float3 F = ShlickFresnel(F0,ldoth);
        return D * V * F;
    }


    inline void EvaluateBSDF_TK(
    inout float3 diffuse,inout float3 specular,float3 normalWorld,UnityGIInput giInput,MaterialParameter matParam)
    {
        float3 lightDirection = giInput.light.dir;
        float3 viewDirection = giInput.worldViewDir;
        float3 lightEmission = giInput.light.color * giInput.atten;

        float3 halfVector = normalize(lightDirection + viewDirection);

        float vdotn = saturate(dot(viewDirection, normalWorld));
        float ldotn = saturate(dot(lightDirection, normalWorld));
        float hdotn = saturate(dot(halfVector, normalWorld));  
        float ldoth = saturate(dot(halfVector, lightDirection));

        float3 lambert = max(0.0f, ldotn) * matParam.basecolor * lightEmission;
        float3 ggx_specular = SpecularGGX(ldoth,hdotn,vdotn,ldotn,matParam.roughness,matParam.basecolor) * lightEmission;


        diffuse = lambert;
        specular = ggx_specular; 
    } 

#endif