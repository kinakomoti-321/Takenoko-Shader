Shader "Noise/noise_test"
{
    Properties
    {
        _ScaleOffset("ScaleOffset", Vector) = (1,1,0,0)
        _NoiseType("NoiseType",Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"


            #include "../common/noise.cginc"
            #include "../common/color.cginc"

            float4 _ScaleOffset;
            int _NoiseType;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * _ScaleOffset.xy + _ScaleOffset.zw;
                float3 col = ValueNoise(uv);

                if(_NoiseType == 1){
                    col = ParlignNoise(uv);
                }
                else if(_NoiseType == 2){
                    col = float3(hash22(floor(uv)),0.0);
                } 
                else if(_NoiseType == 3){
                    col = SimplexNoise(uv);
                }
                else if(_NoiseType == 4){
                    //col = CyclicNoise(float3(uv,_Time.y));
                    col = colorPalet(0.5,0.5,1.0,float3(0.3,0.2,0.2),  0.25+ -0.3 * CyclicNoise(float3(uv,_Time.y)));
                }
                else if(_NoiseType == 5){
                    float2 uv1;
                    uv1.x = FBMParlign(uv);
                    uv1.y = FBMParlign(uv + float2(1.0,1.0));

                    float2 uv2;
                    uv2.x = FBMParlign(uv + uv1 + float2(8.23,3.12) + _Time.y * 0.123);
                    uv2.y = FBMParlign(uv + uv1 + _Time.y * 1.456);
                    col = colorPalet(0.5,0.5,1.0,float3(0.3,0.2,0.2),FBMParlign(uv2));
                }
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
