Shader "Unlit/CameraChecker"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        ZWrite On

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

            float _VRChatCameraMode;
            float _VRChatMirrorMode;
            float3 _VRChatMirrorCameraPos;

            //https://github.com/cnlohr/shadertrixx
            bool isVR(){
                #if UNITY_SINGLE_PASS_STEREO
                    return true;
                #else
                    return false;
                #endif
            }

            bool isDesktop() {
                return !isVR() && abs(UNITY_MATRIX_V[0].y) < 0.0000005;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 col = 0;

                //CameraMode
                [branch] switch(_VRChatCameraMode){
                    case 0:
                        if(isVR()){
                            col = float3(0.0,1.0,1.0);                    
                        }

                        if(isDesktop()){
                            col = float3(1.0,1.0,0.0);                    
                        }
                        break;
                    case 1:
                        col = float3(1.0,0.0,0.0);
                        break;
                    case 2:
                        col = float3(0.0,1.0,0.0);
                        break;
                    case 3:
                        col = float3(0.0,0.0,1.0);
                        break;
                    case 4:
                        col = float3(1.0,0.0,1.0);
                        break;
                }
                    

                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
