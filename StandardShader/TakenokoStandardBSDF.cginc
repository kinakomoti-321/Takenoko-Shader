#ifndef TK_STANDARD_BSDF
    #define TK_STANDARD_BSDF

    inline void EvaluateBSDF_TK(
    inout float3 diffuse,inout float3 specular,float3 normal_world,float3 light_dir,float3 light_color,
    float3 basecolor,float metallic,float roughness)
    {
        diffuse = max(dot(light_dir,normal_world),0.0) * light_color;
        specular = 0;
    } 

#endif