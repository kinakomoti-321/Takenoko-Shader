
#ifndef LIGHTMAP_SAMPLER
    #define LIGHTMAP_SAMPLER

    #include "TakenokoStandardBSDF.cginc"
    #include "../common/color.cginc"
    SamplerState lightmap_trilinear_clamp_sampler;


    float shEvaluateDiffuseL1Geomerics(float L0, float3 L1, float3 n)
    {
        float R0 = L0;

        float3 R1 = 0.5f * L1;

        float lenR1 = length(R1);

        float q = dot(normalize(R1), n) * 0.5 + 0.5;

        float p = 1.0f + 2.0f * lenR1 / R0;

        float a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);

        return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
    }


    sampler2D _RNM0, _RNM1, _RNM2;
    float4 _RNM0_TexelSize;

    inline void BakerySH(inout float3 diffuse,inout float3 specular,float3 normalWorld,float2 lmUV,float3 viewDir,MaterialParameter matParam){
        float3 L0 = DecodeLightmap(unity_Lightmap.Sample(lightmap_trilinear_clamp_sampler,lmUV));
        float3 nL1x = tex2D(_RNM0, lmUV) * 2.0 - 1.0;
        float3 nL1y = tex2D(_RNM1, lmUV) * 2.0 - 1.0;
        float3 nL1z = tex2D(_RNM2, lmUV) * 2.0 - 1.0;

        float3 L1x = nL1x * L0 * 2;
        float3 L1y = nL1y * L0 * 2;
        float3 L1z = nL1z * L0 * 2;

        float3 sh;

        #ifdef _SHMODE_NONLINER
            float lumaL0 = dot(L0, 1);
            float lumaL1x = dot(L1x, 1);
            float lumaL1y = dot(L1y, 1);
            float lumaL1z = dot(L1z, 1);
            float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);

            sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
            float regularLumaSH = dot(sh, 1);

            sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
        #else
            sh = L0 + L1x * normalWorld.x + L1y * normalWorld.y + L1z * normalWorld.z;
        #endif


        diffuse = max(L0,0.0);
        
        #ifdef _SH_SPECULAR
            float3 dominantDir = float3(colorToLuminance(nL1x),colorToLuminance(nL1y),colorToLuminance(nL1z));
            float focus = saturate(length(dominantDir));
            float3 lightDirection = normalize(dominantDir);
            float3 halfvector = normalize(viewDir + lightDirection);
            float3 sh_specular = 0.0f;
            EvaluateSpecularBSDF_TK(sh_specular,normalWorld,viewDir,matParam,lightDirection,sh * focus,1.0);
            specular = sh_specular;
        #else
            specular = 0.0;
        #endif
    }

    inline void BakeryMonoSH(inout float3 diffuse,inout float3 specular,float3 normalWorld,float2 lmUV,float3 viewDir,MaterialParameter matParam){
        float3 L0 = DecodeLightmap(unity_Lightmap.Sample(lightmap_trilinear_clamp_sampler,lmUV));
        float3 dominantDir = unity_LightmapInd.Sample(lightmap_trilinear_clamp_sampler, lmUV).xyz;
        // float3 dominantDir = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lmUV).xyz;
        // float3 L0 = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, lmUV));
        float3 nL1 = dominantDir * 2.0 - 1.0;
        float3 L1x = nL1.x * L0 * 2.0;
        float3 L1y = nL1.y * L0 * 2.0;
        float3 L1z = nL1.z * L0 * 2.0;

        float3 sh;

        #ifdef _SHMODE_NONLINER
            float lumaL0 = dot(L0, 1);
            float lumaL1x = dot(L1x, 1);
            float lumaL1y = dot(L1y, 1);
            float lumaL1z = dot(L1z, 1);
            float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);

            sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
            float regularLumaSH = dot(sh, 1);

            sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
        #else
            sh = L0 + L1x * normalWorld.x + L1y * normalWorld.y + L1z * normalWorld.z;
        #endif


        diffuse = max(sh,0.0);

        dominantDir = nL1;
        float focus = saturate(length(dominantDir));
        float3 lightDirection = normalize(dominantDir);
        float3 halfvector = normalize(viewDir + lightDirection);
        float3 sh_specular = 0.0f;
        EvaluateSpecularBSDF_TK(sh_specular,normalWorld,viewDir,matParam,lightDirection,sh * focus,1.0);
        specular = sh_specular;
    }

    inline void NormalLightmap(inout float3 diffuse, float2 lmUV){
        diffuse = DecodeLightmap(unity_Lightmap.Sample(lightmap_trilinear_clamp_sampler,lmUV));
    }

    inline void sample_lightmap(inout float3 diffuse,inout float3 specular,float3 normalWorld, float2 lmUV,float3 viewDir,MaterialParameter matParam){
        #ifdef _LIGHTMAPMODE_NONE
            NormalLightmap(diffuse,lmUV);
            specular = 0;
        #elif _LIGHTMAPMODE_SH
            BakerySH(diffuse,specular,normalWorld,lmUV,viewDir,matParam);
        #elif _LIGHTMAPMODE_MONOSH
            BakeryMonoSH(diffuse,specular,normalWorld,lmUV,viewDir,matParam);
        #endif

        
    }

#endif

