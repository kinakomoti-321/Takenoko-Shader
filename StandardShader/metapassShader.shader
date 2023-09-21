Shader "Custom/metaPassShader"{
    
    Properties {
        _Color ("Color", Color)=(1,1,1,1)
        _MainTex ("Albedo (RGB)",2D)="white"{}
        _Glossiness ("Smoothness", Range(0,1))=0.5
        _Metallic ("Metallic", Range(0,1))=0.0
        [HDR] _EmissionColor("Emission Color", Color) = (0, 0, 0, 1)
    }


    CustomEditor "TakenokoStandardGUI"
    
    SubShader {
        Pass
        {
            Name "META"
            Tags { "LightMode" = "Meta" }

            Cull Off

            CGPROGRAM
            #include "UnityStandardMeta.cginc"

            #pragma vertex vert_meta // change name and implement if customizing vertex shader
            #pragma fragment frag_meta_custom // changed to customized fragment shader name

            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION

            half3 _SpecularColor;

            // customized fragment shader
            float4 frag_meta_custom(v2f_meta i) : SV_Target
            {
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

                // required but no effect for EnergyConservationBetweenDiffuseAndSpecular
                half oneMinusReflectivity = 0;

                // do it
                half smoothness = _Glossiness;
                half3 albedo = _Color;
                half3 specularColor = _SpecularColor;
                half3 emissionColor = _EmissionColor;

                // assign result to output
                albedo = EnergyConservationBetweenDiffuseAndSpecular(albedo, specularColor, oneMinusReflectivity);
                #if defined(EDITOR_VISUALIZATION)
                    o.Albedo = albedo;
                #else
                    o.Albedo = UnityLightmappingAlbedo(albedo, specularColor, smoothness);
                #endif
                o.SpecularColor = specularColor;
                o.Emission = emissionColor;

                return UnityMetaFragment(o);
            }

            ENDCG
        }
    }
}