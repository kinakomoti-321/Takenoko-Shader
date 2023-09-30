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
        return (1.0f - r) / (1.0f + r);
    }
    static inline float3 n_max(float3 r){
        return (1.0f + sqrt(r)) / (1.0f - sqrt(r));
    }
    static inline float3 rToIOR(float3 col,float3 tint){
        return tint * n_min(col) + (1.0f - tint) * n_max(col);
    }
    static inline float3 rToKappa(float3 col,float3 ior){
        float3 nr = (ior + 1.0f) * (ior + 1.0f) * col - (ior - 1.0f) * (ior - 1.0f);
        return sqrt(nr / (1.0f - col));
    }
    static inline float3 getR(float3 ior,float3 kappa){
        return ((ior-1.0f) * (ior - 1.0f) + kappa * kappa) / ((ior + 1.0f) * (ior + 1.0f) + kappa * kappa);
    }
    static inline float3 getG(float3 ior,float3 kappa){
        float3 r = getR(ior,kappa);
        return (n_max(r) - ior) / (n_max(r) - n_min(r));
    }
#endif
