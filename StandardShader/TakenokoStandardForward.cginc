#ifndef TK_STANDARD_FORWARD_BASE
    #define TK_STANDARD_FORWARD_BASE

    #include "Lightmap.cginc"
    #include "../common/noise.cginc"
    #include "../common/matrix.cginc"
    #include "CommonStruct.cginc"

    struct TKStandardVertexInput
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float2 lightmapUV : TEXCOORD1;
        float4 normal : NORMAL;
        float4 tangent : TANGENT;
    };

    struct TKStandardVertexOutput
    {
        float4 vertex : SV_POSITION;

        float2 uv : TEXCOORD0;
        float2 lightmapUV : TEXCOORD1;
        
        float4 screenPos : TEXCOORD4;
        float3 objectPos : TEXCOORD5;
        float3 worldPos : TEXCOORD6;
        float3 worldNormal : TEXCOORD7;
        float3 worldTangent : TEXCOORD8;
        float3 worldBinormal : TEXCOORD12;
        float3 eyeDir : TEXCOORD9;
        float4 clipPos : TEXCOORD10;
        float depth : TEXCOORD11;
    };

    float4 _BaseColor;
    float _Roughness;
    float _Metallic;

    sampler2D _BaseColorMap;
    float4 _BaseColorMap_ST;

    sampler2D _RoughnessMap;
    float4 _RoughnessMap_ST;

    sampler2D _MetallicMap;
    float4 _MetallicMap_ST;

    sampler2D _BumpMap;
    float4 _BumpMap_ST;

    float4 _EmissionColor;
    sampler2D _EmissionMap;


    TKStandardVertexOutput VertTakenokoStandardForwardBase (TKStandardVertexInput v)
    {
        TKStandardVertexOutput o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        o.lightmapUV = v.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;

        o.objectPos = v.vertex;
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldTangent = mul(unity_ObjectToWorld, v.tangent.xyz);
        o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
        o.eyeDir = normalize(_WorldSpaceCameraPos - o.worldPos);
        o.clipPos = o.vertex;

        return o;
    }

    float3 getNormalMap(float2 uv){
        float3 normal = UnpackNormal(tex2D(_BumpMap,uv));
        normal = normalize(normal);
        return normal;
    }


    fixed4 FragTakenokoStandardForwardBase(TKStandardVertexOutput i) : SV_Target
    {
        float3 shade_color;

        MaterialParameter mat_param;

        float3 basecolor = _BaseColor.rgb * tex2D(_BaseColorMap,i.uv).rgb;
        float roughness = _Roughness * tex2D(_RoughnessMap,i.uv).r;
        float metallic = _Metallic * tex2D(_MetallicMap,i.uv).r;
        
        float3 normalWorld = i.worldNormal;

        float3 normal = UnpackNormal(tex2D(_BumpMap,i.uv));
        normal = normalize(normal);
        normalWorld = localToWorld(i.worldTangent,i.worldNormal,i.worldBinormal,float3(normal.x,normal.z,-normal.y));
        normalWorld = normalize(normalWorld);

        #ifdef LIGHTMAP_ON
            float3 lightmapDiffuse = 0;
            float3 lightmapSpecular = 0;
            sample_lightmap(lightmapDiffuse,lightmapSpecular,normalWorld,i.lightmapUV);
            shade_color = lightmapDiffuse * basecolor + _EmissionColor.rgb;
        #else
            float3 shlight = ShadeSH9(float4(normalWorld,1.0));
            shade_color = shlight * basecolor + _EmissionColor.rgb;
        #endif

        return fixed4(shade_color,1.0);
    }
#endif