#include "./constant.cginc"
float3 colorPalet(float3 a,float3 b,float3 c,float3 d,float t){
    return a + b * cos(TAU*(c*t+d));
}