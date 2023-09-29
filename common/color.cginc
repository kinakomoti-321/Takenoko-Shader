#ifndef _COLOR_H
    #define _COLOR_H
    #include "./constant.cginc"
    float3 colorPalet(float3 a,float3 b,float3 c,float3 d,float t){
        return a + b * cos(TAU*(c*t+d));
    }

    static inline float colorToLuminance(float3 col){
        return dot(col, float3(0.2126, 0.7152, 0.0722));
    }

    static inline float3 n_min(float3 r){
        return (1.0 - r) / (1.0 + r);
    }
    static inline float3 n_max(float3 r){
        return (1.0 + sqrt(r)) / (1.0 - sqrt(r));
    }

    static inline float3 colorToIOR(float3 baseColor,float3 edgeTint){
        return n_min(baseColor) * edgeTint + (1.0 - edgeTint) * n_max(baseColor); 
    }
    
    static inline float3 colorToKappa(float3 baseColor,float3 ior){
        float3 nr = (ior + 1.0) * (ior + 1.0) * baseColor - (ior - 1.0) * (ior - 1.0); 
        return sqrt(nr/(1.0 - baseColor));
    }
#endif