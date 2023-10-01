Shader "Unlit/Triplanar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Dither ("Dither", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normalWorld : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                float4 screenPos : TEXCOORD4;
            };

            Texture2D _MainTex;
            SamplerState sampler_MainTex;
            float4 _MainTex_ST;

            int _Dither;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWorld = mul(unity_ObjectToWorld, v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.screenPos = ComputeScreenPos(o.vertex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            static const int pattern[16] = {
                0, 8, 2, 10,
                12, 4, 14, 6,
                3, 11, 1, 9,
                15, 7, 13, 5
            };


            // float3 triplanar(float3 pos, float3 normal)
            // {
            //     float2 uvX = pos.yz;
            //     float2 uvY = pos.xz;
            //     float2 uvZ = pos.xy;

            //     uvY += 0.5;
            //     uvZ += 0.5;

            //     uvX = (normal.x < 0.0) ? uvX * - 1.0 : uvX;
            //     uvY = (normal.y < 0.0) ? uvY * - 1.0 : uvY;
            //     uvZ = (normal.z < 0.0) ? uvZ * - 1.0 : uvZ;

            //     float3 x = tex2D(_MainTex, uvX).rgb;
            //     float3 y = tex2D(_MainTex, uvY).rgb;
            //     float3 z = tex2D(_MainTex, uvZ).rgb;


            //     float3 blend = abs(normal);
            //     blend = blend / (blend.x + blend.y + blend.z);
            //     return blend.x * x + blend.y * y + blend.z * z;
            // }
            float DitherGradientNoise(int frame, int2 pixel)
            {
                int f = trunc(float(frame)) % 64;
                int2 iP = trunc(float2(pixel.x, pixel.y));
                pixel = float2(iP) + 5.588238f * float(f);
                return frac(52.9829189f * frac(0.06711056f * pixel.x + 0.00583715f * pixel.y));
            }

            float3 DitherTriplaner(float3 pos, float3 normal, int2 pixelId)
            {
                float3 blend = abs(normal);
                blend = pow(blend, 10.0);
                blend = blend / (blend.x + blend.y + blend.z);

                float dither = DitherGradientNoise(1, pixelId);
                dither -= 0.5;
                float index = 0;
                index = blend.x - dither > blend.y ? 0 : 1;
                index = blend.z - dither > max(blend.x, blend.y) ? 2 : index;

                float2 uvX = pos.yz;
                float2 uvY = pos.xz;
                float2 uvZ = pos.xy;

                float4 ddx_ddy_uvX = float4(ddx(uvX), ddy(uvX));
                float4 ddx_ddy_uvY = float4(ddx(uvY), ddy(uvY));
                float4 ddx_ddy_uvZ = float4(ddx(uvZ), ddy(uvZ));

                float2 uvs[3] = {
                    uvX, uvY, uvZ
                };
                float4 ddx_ddy_uvs[3] = {
                    ddx_ddy_uvX, ddx_ddy_uvY, ddx_ddy_uvZ
                };

                float2 tri_uv = uvs[index];
                float4 ddx_ddy_tri_uv = ddx_ddy_uvs[index];
                float3 col = 0;

                if (index == 0)
                {
                    tri_uv = uvX;
                    ddx_ddy_tri_uv = ddx_ddy_uvX;
                    col = _MainTex.SampleGrad(sampler_MainTex, tri_uv, ddx_ddy_tri_uv.xy, ddx_ddy_tri_uv.zw).rgb;
                }
                else if (index == 1)
                {
                    tri_uv = uvY;
                    ddx_ddy_tri_uv = ddx_ddy_uvY;
                    col = _MainTex.SampleGrad(sampler_MainTex, tri_uv, ddx_ddy_tri_uv.xy, ddx_ddy_tri_uv.zw).rgb;
                }
                else if (index == 2)
                {
                    tri_uv = uvZ;
                    ddx_ddy_tri_uv = ddx_ddy_uvZ;
                    col = _MainTex.SampleGrad(sampler_MainTex, tri_uv, ddx_ddy_tri_uv.xy, ddx_ddy_tri_uv.zw).rgb;
                }

                float3 ddx_col = ddx(col);
                float3 ddy_col = ddy(col);
                
                return col;
            }

            float3 biplanar(float3 pos, float3 normal, float k)
            {
                float3 dpdx = ddx(pos);
                float3 dpdy = ddy(pos);
                normal = abs(normal);

                int3 ma = (normal.x > normal.y && normal.x > normal.z) ? int3(0, 1, 2) :
                (normal.y > normal.z) ? int3(1, 2, 0) :
                int3(2, 0, 1) ;
                int3 mi = (normal.x < normal.y && normal.x < normal.z) ? int3(0, 1, 2) :
                (normal.y < normal.z) ? int3(1, 2, 0) :
                int3(2, 0, 1) ;
                int3 me = 3 - mi - ma;
                
                float3 x_sample = _MainTex.SampleGrad(sampler_MainTex, float2(pos[ma.y], pos[ma.z]),
                float2(dpdx[ma.y], dpdx[ma.z]),
                float2(dpdy[ma.y], dpdy[ma.z]));
                float3 y_sample = _MainTex.SampleGrad(sampler_MainTex, float2(pos[me.y], pos[me.z]),
                float2(dpdx[me.y], dpdx[me.z]),
                float2(dpdy[me.y], dpdy[me.z]));
                
                float2 weight = float2(normal[ma.x], normal[me.x]);
                weight = clamp((weight - 0.5773) / (1.0 - 0.5773), 0.0, 1.0);
                weight = pow(weight, k / 8.0);
                return (weight.x * x_sample + weight.y * y_sample) / (weight.x + weight.y);
            }
            fixed4 frag(v2f i) : SV_Target
            {
                float3 col = 0;
                float3 normal = normalize(i.normalWorld);

                float2 screenPos = i.screenPos.xy / i.screenPos.w;
                float2 screenPosInPixel = screenPos * _ScreenParams.xy;

                int ditherUV_X = (int)floor(screenPosInPixel.x) % 4;
                int ditherUV_Y = (int)floor(screenPosInPixel.y) % 4;
                int dither = pattern[ditherUV_X + ditherUV_Y * 4];

                //col = StochasticTriplaner(i.worldPos, normal, screenPosInPixel);
                col = biplanar(i.worldPos, normal, 8.0);
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
