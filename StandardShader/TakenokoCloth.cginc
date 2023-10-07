#ifndef _CLOTH_
#define _CLOTH_

#include "../common/constant.cginc"
#include "../common/math.cginc"
#include "../common/matrix.cginc"
#include "TakenokoMaterial.cginc"

//A Practical Microcylinder Appearance Model for Cloth Rendering
//https://escholarship.org/content/qt6v11p5b0/qt6v11p5b0_noSplash_21f194c359ebb735072832a2863993e6.pdf

//Implementation by Ushio
//https://gist.github.com/Ushio/351c1dba504e21ec5d30a3e32e435715
#if defined(_TK_CLOTH_ON)
    struct ClothGeometryParameter
    {
        float theta_d;
        float theta_h;
        float phi_d;
        float cosPhiI;
        float cosPhiO;
        float cosThetaI;
        float cosThetaO;
        float psi_d;
        float cosPsiI;
        float cosPsiO;
    };

    struct ClothParameter
    {
        float3 albedo;
        float gamma_s;
        float gamma_v;
        float k_d;
        float eta_t;
    };

    inline void setClothParameterTK(float3 u, float3 v, float3 n, float3 wi, float3 wo, inout ClothGeometryParameter param)
    {
        float sinThetaI = clamp(dot(wi, u), -1.0, 1.0);
        float thetaI = asin(sinThetaI);
        float sinThetaO = clamp(dot(wo, u), -1.0, 1.0);
        float thetaO = asin(sinThetaO);

        float wi_on_normal = normalize(wi - u * sinThetaI);
        float wo_on_normal = normalize(wo - u * sinThetaO);

        float cosPhiD = clamp(dot(wi_on_normal, wo_on_normal), -1.0, 1.0);

        float phi_d = acos(cosPhiD);
        float theta_h = (thetaI + thetaO) * 0.5;
        float theta_d = (thetaI - thetaO) * 0.5;

        float cosThetaO = cos(thetaO);

        float3 wi_on_tangent_normal = normalize(wi - v * dot(wi, v));
        float3 wo_on_tangent_normal = normalize(wo - v * dot(wo, v));

        float cosPsiI = clamp(dot(wi_on_tangent_normal, wo_on_tangent_normal), -1.0, 1.0);
        float psi_d = acos(cosPsiI);

        param.theta_d = theta_d;
        param.theta_h = theta_h;
        param.cosPhiI = dot(n, wi_on_normal);
        param.cosPhiO = dot(n, wo_on_normal);
        param.phi_d = phi_d;
        param.cosThetaI = cos(thetaI);
        param.cosThetaO = cos(thetaO);
        param.psi_d = psi_d;
        param.cosPsiI = dot(n, wi_on_tangent_normal);
        param.cosPsiO = dot(n, wo_on_tangent_normal);
    }

    static inline float normalized_gaussian(float beta, float theta)
    {
        return exp(-theta * theta / (2.0f * beta * beta)) / (sqrt(PI2 * beta * beta));
    }

    static inline float microcylinder_fresnel_dielectrics(float cosTheta, float eta_t, float eta_i)
    {
        float c = cosTheta;
        float g = sqrt(square(eta_t) / square(eta_i) - 1.0 + square(c));

        float a = 0.5 * square(g - c) / square(g + c);
        float b = 1.0 + square(c * (g + c) - 1.0) / square(c * (g - c) + 1.0);
        return a * b;
    }

    static inline float u_gaussian(float x)
    {
        const float sd = RADIAN(20.0);
        const float sqr_sd_2 = sd * sd * 2.0;
        return exp(-x * x / sqr_sd_2);
    }

    static inline float microcylinder_M(float cosPhiI, float cosPhiO, float phi_d)
    {
        float m_i = max(cosPhiI, 0.0);
        float m_o = max(cosPhiO, 0.0);
        float u = u_gaussian(phi_d);
        float corrated = min(m_i, m_o);
        float uncorrated = m_i * m_o;
        return lerp(uncorrated, corrated, u);
    }

    static inline float microcylinder_P(float cosPsiI, float cosPsiO, float psi_d)
    {
        float m_i = max(cosPsiI, 0.0);
        float m_o = max(cosPsiO, 0.0);
        float u = u_gaussian(psi_d);
        float corrated = min(m_i, m_o);
        float uncorrated = m_i * m_o;
        return lerp(uncorrated, corrated, u);
    }

    static inline float fr_cosTheta(float theta_d, float phi_d)
    {
        return cos(theta_d) * cos(phi_d * 0.5);
    }

    static inline float scattering_rs(float phi_d, float theta_h, float gamma_s)
    {
        return cos(phi_d * 0.5) * normalized_gaussian(gamma_s, theta_h);
    }

    static inline float scattering_rv(float theta_h, float gamma_v, float kd, float cosThetaI, float cosThetaO)
    {
        return ((1.0 - kd) * normalized_gaussian(gamma_v, theta_h) + kd) / (cosThetaI + cosThetaO);
    }


    inline float3 microcylinder_bsdf(float theta_d, float theta_h, float phi_d, float cosThetaI, float cosThetaO, ClothParameter cparam)
    {
        float gamma_s = cparam.gamma_s;
        float gamma_v = cparam.gamma_v;
        float k_d = cparam.k_d;
        float3 albedo = cparam.albedo;

        float eta_i = 1.0;
        float eta_t = cparam.eta_t;

        float Fr_cosTheta_i = fr_cosTheta(theta_d, phi_d);

        float Fr = microcylinder_fresnel_dielectrics(Fr_cosTheta_i, eta_t, eta_i);
        float Ft = (1.0 - Fr);
        float F = Ft * Ft;

        float rs = Fr * scattering_rs(phi_d, theta_h, gamma_s);
        float rv = F * scattering_rv(theta_h, gamma_v, k_d, cosThetaI, cosThetaO);

        return (rs + rv * albedo) / pow(cos(theta_d), 2.0);
    }

    inline float3 ClothBSDF_TK(float3 u, float3 v, float3 n,
    float3 wi, float3 wo, float cosThetaI, MaterialParameter matparam)
    {
        float4 tangent_offset_u = matparam.clothTangentOffset1;
        float4 tangent_offset_v = matparam.clothTangentOffset2;

        int Nu = 4;
        int Nv = 4;

        float3 uValue = 0.0;
        float3 vValue = 0.0;
        float Q = 0.0;

        ClothGeometryParameter gparam;

        ClothParameter cparam1;
        ClothParameter cparam2;

        cparam1.albedo = matparam.clothAlbedo1;
        cparam1.gamma_s = matparam.clothGammaS1;
        cparam1.gamma_v = matparam.clothGammaV1;
        cparam1.k_d = matparam.clothKd1;
        cparam1.eta_t = matparam.clothIOR1;
        
        cparam2.albedo = matparam.clothAlbedo2;
        cparam2.gamma_s = matparam.clothGammaS2;
        cparam2.gamma_v = matparam.clothGammaV2;
        cparam2.k_d = matparam.clothKd2;
        cparam2.eta_t = matparam.clothIOR2;

        float alpha_0 = matparam.clothAlpha1;
        float alpha_1 = matparam.clothAlpha2;

        for (int i = 0; i < Nu; i++)
        {
            float3 v_shape = v;
            float3 u_shape = vector_quat_rotate(u, VectorToQuatunion(v_shape, RADIAN(tangent_offset_u[i])));
            float3 n_shape = vector_quat_rotate(n, VectorToQuatunion(v_shape, RADIAN(tangent_offset_u[i])));

            setClothParameterTK(u_shape, v_shape, n_shape, wi, wo, gparam);

            float3 fr = microcylinder_bsdf(gparam.theta_d, gparam.theta_h, gparam.phi_d, gparam.cosThetaI, gparam.cosThetaO, cparam1);
            
            float m_value = microcylinder_M(gparam.cosPhiI, gparam.cosPhiO, gparam.phi_d);
            float p_value = microcylinder_P(gparam.cosPsiI, gparam.cosPsiO, gparam.psi_d);
            uValue += p_value * m_value * fr * cosThetaI;
            
            Q += alpha_0 * p_value / Nu;
        }

        uValue /= Nu;

        for (int i = 0; i < Nv; i++)
        {
            float3 v_shape = u;
            float3 u_shape = vector_quat_rotate(v, VectorToQuatunion(v_shape, RADIAN(tangent_offset_v[i])));
            float3 n_shape = vector_quat_rotate(n, VectorToQuatunion(v_shape, RADIAN(tangent_offset_v[i])));

            setClothParameterTK(u_shape, v_shape, n_shape, wi, wo, gparam);

            float3 fr = microcylinder_bsdf(gparam.theta_d, gparam.theta_h, gparam.phi_d, gparam.cosThetaI, gparam.cosThetaO, cparam2);

            float m_value = microcylinder_M(gparam.cosPhiI, gparam.cosPhiO, gparam.phi_d);
            float p_value = microcylinder_P(gparam.cosPsiI, gparam.cosPsiO, gparam.psi_d);
            uValue += p_value * m_value * fr * cosThetaI;

            Q += alpha_1 * p_value / Nv;
        }

        vValue /= Nv;

        cosThetaI = abs(dot(n, wi));
        float3 fr_cosTheta = uValue * alpha_0 + vValue * alpha_1;

        return max(fr_cosTheta / Q, 0.0);
    }
#endif

#endif