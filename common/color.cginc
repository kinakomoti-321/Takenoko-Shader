#ifndef _COLOR_H
    #define _COLOR_H
    #include "./constant.cginc"
    float3 colorPalet(float3 a,float3 b,float3 c,float3 d,float t){
        return a + b * cos(TAU*(c*t+d));
    }

    static inline float colorToLuminance(float3 col){
        return dot(col, float3(0.2126, 0.7152, 0.0722));
    }
#endif