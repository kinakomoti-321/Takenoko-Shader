Shader "Example"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}
        _Roughness("Roughness", Range(0.0, 1.0)) = 0.5
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half2 texcoord : TEXCOORD0;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                half3 worldNormal : TEXCOORD2;
                half3 viewDir : TEXCOORD3;
            };

            float3 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Metallic;
            float _Roughness;
            float3 _LightColor0;

            // 誘電体の反射率（F0）は4%とする
            #define _DielectricF0 0.04

            inline half Fd_Burley(half ndotv, half ndotl, half ldoth, half roughness)
            {
                half fd90 = 0.5 + 2 * ldoth * ldoth * roughness;
                half lightScatter = (1 + (fd90 - 1) * pow(1 - ndotl, 5));
                half viewScatter = (1 + (fd90 - 1) * pow(1 - ndotv, 5));

                half diffuse = lightScatter * viewScatter;
                // 本来はこのDiffuseをπで割るべきだけどUnityではレガシーなライティングとの互換性を保つため割らない
                //diffuse /= UNITY_PI;
                return diffuse;
            }
            
            inline float V_SmithGGXCorrelated(float ndotl, float ndotv, float alpha)
            {
                float lambdaV = ndotl * (ndotv * (1 - alpha) + alpha);
                float lambdaL = ndotv * (ndotl * (1 - alpha) + alpha);

                return 0.5f / (lambdaV + lambdaL + 0.0001);
            }

            inline half D_GGX(half perceptualRoughness, half ndoth, half3 normal, half3 halfDir) {
                half3 ncrossh = cross(normal, halfDir);
                half a = ndoth * perceptualRoughness;
                half k = perceptualRoughness / (dot(ncrossh, ncrossh) + a * a);
                half d = k * k * UNITY_INV_PI;
                return min(d, 65504.0h);
            }

            inline half3 F_Schlick(half3 f0, half cos)
            {
                return f0 + (1 - f0) * pow(1 - cos, 5);
            }

            half4 BRDF(half3 albedo, half metallic, half perceptualRoughness, float3 normal, float3 viewDir, float3 lightDir, float3 lightColor)
            {
                float3 halfDir = normalize(lightDir + viewDir);
                half ndotv = abs(dot(normal, viewDir));
                float ndotl = max(0, dot(normal, lightDir));
                float ndoth = max(0, dot(normal, halfDir));
                half ldoth = max(0, dot(lightDir, halfDir));
                half reflectivity = lerp(_DielectricF0, 1, metallic);
                half3 f0 = lerp(_DielectricF0, albedo, metallic);
                
                // Diffuse
                half diffuseTerm = Fd_Burley(ndotv, ndotl, ldoth, perceptualRoughness) * ndotl;
                half3 diffuse = albedo * (1 - reflectivity) * lightColor * diffuseTerm;
                
                // Specular
                float alpha = perceptualRoughness * perceptualRoughness;
                float V = V_SmithGGXCorrelated(ndotl, ndotv, alpha);
                float D = D_GGX(perceptualRoughness, ndotv, normal, halfDir);
                float3 F = F_Schlick(f0, ldoth); // マイクロファセットベースのスペキュラBRDFではcosはldothが使われる
                float3 specular = V * D * F * ndotl * lightColor;
                // 本来はSpecularにπを掛けるべきではないが、Unityではレガシーなライティングとの互換性を保つため、Diffuseを割らずにSpecularにPIを掛ける
                specular *= UNITY_PI;
                specular = max(0, specular);

                half3 color = diffuse + specular;
                float3 test = V * D * F * ndotl;
                return half4(test , 1);
            }
            
            v2f vert(appdata v)
            {
                v2f o = (v2f)0;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = UnityWorldSpaceViewDir(o.worldPos);

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                half metallic = _Metallic;
                half perceptualRoughness = _Roughness;

                i.worldNormal = normalize(i.worldNormal);
                i.viewDir = normalize(i.viewDir);

                half4 c = BRDF(albedo, metallic, perceptualRoughness, i.worldNormal, i.viewDir, _WorldSpaceLightPos0.xyz, _LightColor0.rgb);
                //float3 halfvector = normalize(i.viewDir + _WorldSpaceLightPos0.xyz);
                return c;
            }

            ENDCG
        }
    }
}