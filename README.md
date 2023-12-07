# Takenoko Shader
Takenoko ShaderはUnity向けのPBR Standard Shaderです。
標準のStandard Shaderにいくつか実験的機能を追加し、より現実に近いシェーディングになるように設計されています。また、特殊な反射現象の再現を目的としており、現在では薄膜干渉をサポートしています。

Documentaion

Booth
https://kinankocraft.booth.pm/items/5267948

## Feature
- Roughness-Metallic ワークフロー
当シェーダーは質感のパラメーターとしてRoughness,Metallicワークフローを採用しています

- Thin-Film Interference
干渉薄膜という構造色の一種をPBR的に再現する機能
金属の焼けや油の虹色などにご使用いただけます

- SH,Mono SH Lightmap対応
SH及びMonoSH形式のLightmapに対応しています(これらの生成にはBakeryが必要です)

また、Lightmapからハイライトを疑似的に計算できるApproximate Specular機能や暗いところにおける反射を抑制するSpecular Occlusion機能が搭載されています。

- Additional Lightmap、Lightmapの切り替え
手動でLightmapを追加することが出来ます。
各Lightmapは強さをInspector上で変更することが可能なため、照明のON,OFF表現などに用いることができます。

## TODO
- ScreenSpaceReflection
- sheen and cross
- HexTiling 
- Multiple-Scattering
- LTC

