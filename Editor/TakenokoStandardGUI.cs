using System;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using Codice.Client.BaseCommands.TubeClient;
using Codice.Foreign;
using NUnit.Framework;
using UnityEditor;
using UnityEditor.Graphs;
using UnityEngine;

public class TakenokoStandardGUI : ShaderGUI
{
    private enum LightmapFormatEnum
    {
        None,
        SH,
        MonoSH
    }

    private enum EmissionModeEnum
    {
        None,
        Realtime,
        Bake
    }

    private enum MappingModeEnum
    {
        UV,
        Triplanar,
        Biplanar,
        DitheredTriplanar,
        XYZMask,
    }

    private enum ParallaxModeEnum
    {
        None,
        Simple,
        Steep,
    }

    private enum SamplerModeEnum
    {
        None,
        Stochastic,
        // Hex,
        // Volonoi
    }

    private enum DebugModeEnum
    {
        None,
        BaseColor,
        Normal,
    }

    public enum BlendModeEnum
    {
        Opaque,
        Cutout,
        Fade,
        Transparent
    }

    public enum DetailBlendModeEnum
    {
        Linner,
        Multiply,
        Add,
        Subtract,
    }

    MaterialProperty MappingMode;
    MaterialProperty MappingPosObj;
    MaterialProperty SamplerMode;
    MaterialProperty BlendMode;

    MaterialProperty Color;
    MaterialProperty MainTex;
    MaterialProperty Cutoff;
    MaterialProperty Metallic;
    MaterialProperty MetallicGlossMap;
    MaterialProperty Roughness;
    MaterialProperty RoughnessMap;

    MaterialProperty BumpScale;
    MaterialProperty BumpMap;

    MaterialProperty PallaxScale;
    MaterialProperty PallaxMap;
    MaterialProperty PallaxMode;

    //DetailMaps
    MaterialProperty Detail_ON;
    MaterialProperty DetailBlendMode;
    MaterialProperty DetailMappingMode;
    MaterialProperty DetailSamplerMode;
    MaterialProperty DetailMaskFactor;
    MaterialProperty DetailMaskMap;
    MaterialProperty DetailAlbedo;
    MaterialProperty DetailAlbedoMap;
    MaterialProperty DetailRoughness;
    MaterialProperty DetailRoughnessMap;
    MaterialProperty DetailMetallic;
    MaterialProperty DetailMetallicMap;
    MaterialProperty DetalNormalMapScale;
    MaterialProperty DetailNormalMap;


    MaterialProperty Emission;
    MaterialProperty EmissionMode;
    MaterialProperty EmissionColor;
    MaterialProperty EmissionMap;

    MaterialProperty ThinFilm_ON;
    MaterialProperty ThinFilmMaskMap;
    MaterialProperty ThinFilmMiddleIOR;
    MaterialProperty ThinFilmMiddleThickness;
    MaterialProperty ThinFilmMiddleThicknessMin;
    MaterialProperty ThinFilmMiddleThicknessMax;
    MaterialProperty ThinFilmMiddleThicknessMap;

    MaterialProperty Cloth_ON;
    MaterialProperty ClothAlbedo1;
    MaterialProperty ClothAlbedo2;
    MaterialProperty ClothIOR1;
    MaterialProperty ClothIOR2;
    MaterialProperty ClothKd1;
    MaterialProperty ClothKd2;
    MaterialProperty ClothGammaV1;
    MaterialProperty ClothGammaV2;
    MaterialProperty ClothGammaS1;
    MaterialProperty ClothGammaS2;
    MaterialProperty ClothAlpha1;
    MaterialProperty ClothAlpha2;
    MaterialProperty ClothTangentOffset1;
    MaterialProperty ClothTangentOffset2;

    MaterialProperty SrcBlend;
    MaterialProperty DstBlend;
    MaterialProperty ZWrite;
    MaterialProperty LightmapMode;
    MaterialProperty LightmapPower;
    MaterialProperty SHModeNonLiner;
    MaterialProperty SpecularOcclusion;
    MaterialProperty SHSpecular;

    MaterialProperty AddLightmap1_ON;
    MaterialProperty AddLightmap1_Power;
    MaterialProperty AddLightmap1;

    MaterialProperty AddLightmap2_ON;
    MaterialProperty AddLightmap2_Power;
    MaterialProperty AddLightmap2;
    MaterialProperty AddLightmap3_ON;
    MaterialProperty AddLightmap3_Power;
    MaterialProperty AddLightmap3;

    MaterialProperty DebugMode;

    MaterialProperty RenderModeMenu;
    MaterialProperty MainTexMenu;
    MaterialProperty EmissionMenu;
    MaterialProperty ThinFilmMenu;
    MaterialProperty LightmapMenu;
    MaterialProperty DebugMenu;
    MaterialProperty ExperimentalMenu;

    bool firstTime = true;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material material = materialEditor.target as Material;
        if (firstTime)
        {
            setMaterialProperty(properties);
            firstTime = false;
        }


        EditorGUI.BeginChangeCheck();
        {

            if (MenuFoldout(RenderModeMenu, "RenderMode"))
            {

                GUILayout.Space(5);
                EditorGUI.indentLevel++;
                using (new EditorGUILayout.VerticalScope("HelpBox"))
                {
                    GUILayout.Space(5);
                    BlendModeEnum renderMode = (BlendModeEnum)BlendMode.floatValue;
                    renderMode = (BlendModeEnum)EditorGUILayout.EnumPopup("Rendering Mode", renderMode);
                    BlendMode.floatValue = (float)renderMode;
                    if (renderMode == BlendModeEnum.Cutout)
                    {
                        materialEditor.ShaderProperty(Cutoff, "Alpha Cutoff");
                    }
                    GUILayout.Space(5);
                }

                EditorGUI.indentLevel--;
                GUILayout.Space(5);
            }

            GUILayout.Space(10);

            if (MenuFoldout(MainTexMenu, "Main Paramater"))
            {
                GUILayout.Space(5);
                EditorGUI.indentLevel++;
                GUILayout.Label("Main Texture", EditorStyles.boldLabel);
                using (new EditorGUILayout.VerticalScope("HelpBox"))
                {
                    GUILayout.Space(5);

                    using (new EditorGUILayout.VerticalScope("HelpBox"))
                    {
                        MappingModeEnum mappingMode = (MappingModeEnum)MappingMode.floatValue;
                        mappingMode = (MappingModeEnum)EditorGUILayout.Popup("Mapping Mode", (int)mappingMode, Enum.GetNames(typeof(MappingModeEnum)));
                        MappingMode.floatValue = (float)mappingMode;
                        if (mappingMode != MappingModeEnum.UV)
                        {
                            //materialEditor.ShaderProperty(MappingPosObj, "Mapping Position Object");
                        }

                        SamplerModeEnum samplerMode = (SamplerModeEnum)SamplerMode.floatValue;
                        samplerMode = (SamplerModeEnum)EditorGUILayout.Popup("Sampler Mode", (int)samplerMode, Enum.GetNames(typeof(SamplerModeEnum)));
                        SamplerMode.floatValue = (float)samplerMode;
                    }

                    GUILayout.Space(5);

                    materialEditor.ShaderProperty(Color, "BaseColor Tint");
                    materialEditor.ShaderProperty(MainTex, "BaseColor Map");
                    GUILayout.Space(10);
                    materialEditor.ShaderProperty(Roughness, "Roughness");
                    materialEditor.ShaderProperty(RoughnessMap, "Roughness Map");
                    GUILayout.Space(10);
                    materialEditor.ShaderProperty(Metallic, "Metallic");
                    materialEditor.ShaderProperty(MetallicGlossMap, "Metallic Map");
                    GUILayout.Space(10);
                    materialEditor.ShaderProperty(BumpScale, "Normal Scale");
                    materialEditor.ShaderProperty(BumpMap, "Normal Map");
                    GUILayout.Space(10);
                    materialEditor.ShaderProperty(PallaxScale, "Height Scale");
                    materialEditor.ShaderProperty(PallaxMap, "Height Map");

                    ParallaxModeEnum pallaxMode = (ParallaxModeEnum)PallaxMode.floatValue;
                    pallaxMode = (ParallaxModeEnum)EditorGUILayout.Popup("Height Mode", (int)pallaxMode, Enum.GetNames(typeof(ParallaxModeEnum)));
                    PallaxMode.floatValue = (float)pallaxMode;

                    GUILayout.Space(5);
                }

                GUILayout.Space(5);
                GUILayout.Label("Detail Maps", EditorStyles.boldLabel);
                using (new EditorGUILayout.VerticalScope("HelpBox"))
                {
                    GUILayout.Space(5);
                    materialEditor.ShaderProperty(Detail_ON, "Use Detail Map");
                    if (Detail_ON.floatValue > 0.0)
                    {
                        DetailBlendModeEnum detailBlendMode = (DetailBlendModeEnum)DetailBlendMode.floatValue;
                        detailBlendMode = (DetailBlendModeEnum)EditorGUILayout.Popup("Detail Blend Mode", (int)detailBlendMode, Enum.GetNames(typeof(DetailBlendModeEnum)));
                        DetailBlendMode.floatValue = (float)detailBlendMode;

                        MappingModeEnum detailMappingMode = (MappingModeEnum)DetailMappingMode.floatValue;
                        detailMappingMode = (MappingModeEnum)EditorGUILayout.Popup("Detail Mapping Mode", (int)detailMappingMode, Enum.GetNames(typeof(MappingModeEnum)));
                        DetailMappingMode.floatValue = (float)detailMappingMode;

                        SamplerModeEnum detalSamplerMode = (SamplerModeEnum)DetailSamplerMode.floatValue;
                        detalSamplerMode = (SamplerModeEnum)EditorGUILayout.Popup("Detail Sampler Mode", (int)detalSamplerMode, Enum.GetNames(typeof(SamplerModeEnum)));
                        DetailSamplerMode.floatValue = (float)detalSamplerMode;

                        materialEditor.ShaderProperty(DetailMaskFactor, "Detail Mask Factor");
                        materialEditor.ShaderProperty(DetailMaskMap, "Detail Mask Map");
                        GUILayout.Space(10);
                        materialEditor.ShaderProperty(DetailAlbedo, "Detail Albedo");
                        materialEditor.ShaderProperty(DetailAlbedoMap, "Detail Albedo Map");
                        GUILayout.Space(10);
                        materialEditor.ShaderProperty(DetailRoughness, "Detail Roughness");
                        materialEditor.ShaderProperty(DetailRoughnessMap, "Detail Roughness Map");
                        GUILayout.Space(10);
                        materialEditor.ShaderProperty(DetailMetallic, "Detail Metallic");
                        materialEditor.ShaderProperty(DetailMetallicMap, "Detail Metallic Map");
                        GUILayout.Space(10);
                        materialEditor.ShaderProperty(DetalNormalMapScale, "Detail Normal Scale");
                        materialEditor.ShaderProperty(DetailNormalMap, "Detail Normal Map");
                    }
                    GUILayout.Space(5);
                }
                EditorGUI.indentLevel--;
                GUILayout.Space(5);
            }

            GUILayout.Space(10);

            if (MenuFoldout(EmissionMenu, "Emission"))
            {
                using (new EditorGUILayout.VerticalScope("HelpBox"))
                {
                    GUILayout.Space(5);

                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(Emission, "Emission");
                    if (Emission.floatValue > 0)
                    {
                        materialEditor.ShaderProperty(EmissionColor, "Emission Color");
                        materialEditor.ShaderProperty(EmissionMap, "Emission Map");
                        // materialEditor.ShaderProperty(EmissionMode, "Emission Mode");

                        EmissionModeEnum emissionMode = (EmissionModeEnum)EmissionMode.floatValue;
                        emissionMode = (EmissionModeEnum)EditorGUILayout.Popup("Emission Mode", (int)emissionMode, Enum.GetNames(typeof(EmissionModeEnum)));
                        EmissionMode.floatValue = (float)emissionMode;
                    }
                    EditorGUI.indentLevel--;
                    GUILayout.Space(5);
                }
            }

            GUILayout.Space(10);

            if (MenuFoldout(ThinFilmMenu, "Thin-Film"))
            {
                using (new EditorGUILayout.VerticalScope("HelpBox"))
                {
                    GUILayout.Space(5);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(ThinFilm_ON, "Thin-Film");
                    materialEditor.ShaderProperty(ThinFilmMaskMap, "Mask Map");
                    if (ThinFilm_ON.floatValue > 0.0)
                    {
                        materialEditor.ShaderProperty(ThinFilmMiddleIOR, "IOR");
                        materialEditor.ShaderProperty(ThinFilmMiddleThickness, "Film Thickness");
                        materialEditor.ShaderProperty(ThinFilmMiddleThicknessMap, "Film Thickness Map");
                        materialEditor.ShaderProperty(ThinFilmMiddleThicknessMin, "Film Thickness minimum(nm)");
                        materialEditor.ShaderProperty(ThinFilmMiddleThicknessMax, "Film Thickness maximum(nm)");
                    }
                    EditorGUI.indentLevel--;
                    GUILayout.Space(5);
                }
            }

            GUILayout.Space(10);

            if (MenuFoldout(LightmapMenu, "Lightmap"))
            {
                GUILayout.Space(5);
                using (new EditorGUILayout.VerticalScope("HelpBox"))
                {
                    GUILayout.Space(5);
                    EditorGUI.indentLevel++;
                    LightmapFormatEnum lightmapFormat = (LightmapFormatEnum)LightmapMode.floatValue;
                    lightmapFormat = (LightmapFormatEnum)EditorGUILayout.Popup("Lightmap Format", (int)lightmapFormat, Enum.GetNames(typeof(LightmapFormatEnum)));
                    LightmapMode.floatValue = (float)lightmapFormat;

                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(LightmapPower, "Lightmap Power");
                    switch (lightmapFormat)
                    {
                        case LightmapFormatEnum.None:
                            break;
                        case LightmapFormatEnum.SH:
                            materialEditor.ShaderProperty(SHModeNonLiner, "SH Mode NonLiner");
                            materialEditor.ShaderProperty(SHSpecular, "SH Specular");
                            break;
                        case LightmapFormatEnum.MonoSH:
                            materialEditor.ShaderProperty(SHModeNonLiner, "NonLiner SH Evaluation");
                            materialEditor.ShaderProperty(SHSpecular, "SH Specular Approximation");
                            break;
                    }
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(SpecularOcclusion, "Specular Occlusion");

                    materialEditor.ShaderProperty(AddLightmap1_ON, "Add Lightmap1");
                    if (AddLightmap1_ON.floatValue > 0.0)
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(AddLightmap1_Power, "Add Lightmap1 Power");
                        materialEditor.ShaderProperty(AddLightmap1, "Add Lightmap1");
                        EditorGUI.indentLevel--;
                    }
                    materialEditor.ShaderProperty(AddLightmap2_ON, "Add Lightmap2");
                    if (AddLightmap2_ON.floatValue > 0.0)
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(AddLightmap2_Power, "Add Lightmap2 Power");
                        materialEditor.ShaderProperty(AddLightmap2, "Add Lightmap2");
                        EditorGUI.indentLevel--;
                    }

                    materialEditor.ShaderProperty(AddLightmap3_ON, "Add Lightmap3");
                    if (AddLightmap3_ON.floatValue > 0.0)
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(AddLightmap3_Power, "Add Lightmap3 Power");
                        materialEditor.ShaderProperty(AddLightmap3, "Add Lightmap3");
                        EditorGUI.indentLevel--;
                    }
                    GUILayout.Space(5);
                }
                EditorGUI.indentLevel--;
                GUILayout.Space(5);
            }


            GUILayout.Space(10);

            if (MenuFoldout(DebugMenu, "Debug"))
            {
                GUILayout.Space(5);
                EditorGUI.indentLevel++;
                using (new EditorGUILayout.VerticalScope("HelpBox"))
                {
                    DebugModeEnum debugMode = (DebugModeEnum)DebugMode.floatValue;
                    debugMode = (DebugModeEnum)EditorGUILayout.Popup("Debug Mode", (int)debugMode, Enum.GetNames(typeof(DebugModeEnum)));
                    DebugMode.floatValue = (float)debugMode;
                }
                EditorGUI.indentLevel--;
                GUILayout.Space(5);
            }

            GUILayout.Space(10);

            if (MenuFoldout(ExperimentalMenu, "Experimental"))
            {
                GUILayout.Space(5);
                EditorGUI.indentLevel++;
                using (new EditorGUILayout.VerticalScope("HelpBox"))
                {
                    materialEditor.ShaderProperty(Cloth_ON, "Cloth");
                    materialEditor.ShaderProperty(ClothAlbedo1, "Albedo1");
                    materialEditor.ShaderProperty(ClothAlbedo2, "Albedo2");
                    materialEditor.ShaderProperty(ClothIOR1, "IOR1");
                    materialEditor.ShaderProperty(ClothIOR2, "IOR2");
                    materialEditor.ShaderProperty(ClothKd1, "Kd1");
                    materialEditor.ShaderProperty(ClothKd2, "Kd2");
                    materialEditor.ShaderProperty(ClothGammaV1, "GammaV1");
                    materialEditor.ShaderProperty(ClothGammaV2, "GammaV2");
                    materialEditor.ShaderProperty(ClothGammaS1, "GammaS1");
                    materialEditor.ShaderProperty(ClothGammaS2, "GammaS2");
                    materialEditor.ShaderProperty(ClothAlpha1, "Alpha1");
                    materialEditor.ShaderProperty(ClothAlpha2, "Alpha2");
                    materialEditor.ShaderProperty(ClothTangentOffset1, "TangentOffset1");
                    materialEditor.ShaderProperty(ClothTangentOffset2, "TangentOffset2");
                }
                EditorGUI.indentLevel--;
                GUILayout.Space(5);
            }

        }
        if (EditorGUI.EndChangeCheck())
        {
            SetMaterialKeywords(material);
            foreach (var obj in BlendMode.targets)
            {
                SetupBlendMode((Material)obj, (BlendModeEnum)BlendMode.floatValue);
            }
        }

    }

    public void setMaterialProperty(MaterialProperty[] properties)
    {
        RenderModeMenu = FindProperty("_RenderModeMenu", properties);
        MainTexMenu = FindProperty("_MainTexMenu", properties);
        EmissionMenu = FindProperty("_EmissionMenu", properties);
        ThinFilmMenu = FindProperty("_ThinFilmMenu", properties);
        LightmapMenu = FindProperty("_LightmapMenu", properties);
        DebugMenu = FindProperty("_DebugMenu", properties);
        ExperimentalMenu = FindProperty("_ExperimentalMenu", properties);

        MappingMode = FindProperty("_MappingMode", properties);
        MappingPosObj = FindProperty("_MappingPosObj", properties);
        SamplerMode = FindProperty("_SamplerMode", properties);
        BlendMode = FindProperty("_BlendMode", properties);
        Cutoff = FindProperty("_Cutoff", properties);

        Color = FindProperty("_Color", properties);
        MainTex = FindProperty("_MainTex", properties);

        Cutoff = FindProperty("_Cutoff", properties);

        Metallic = FindProperty("_Metallic", properties);
        MetallicGlossMap = FindProperty("_MetallicGlossMap", properties);
        Roughness = FindProperty("_Roughness", properties);
        RoughnessMap = FindProperty("_RoughnessMap", properties);

        BumpScale = FindProperty("_BumpScale", properties);
        BumpMap = FindProperty("_BumpMap", properties);

        PallaxScale = FindProperty("_PallaxScale", properties);
        PallaxMap = FindProperty("_PallaxMap", properties);
        PallaxMode = FindProperty("_PallaxMode", properties);

        Emission = FindProperty("_Emission", properties);
        EmissionMode = FindProperty("_EmissionMode", properties);
        EmissionColor = FindProperty("_EmissionColor", properties);
        EmissionMap = FindProperty("_EmissionMap", properties);

        Detail_ON = FindProperty("_Detail_ON", properties);
        DetailBlendMode = FindProperty("_DetailBlendMode", properties);
        DetailMappingMode = FindProperty("_DetailMappingMode", properties);
        DetailSamplerMode = FindProperty("_DetailSamplerMode", properties);
        DetailMaskFactor = FindProperty("_DetailMaskFactor", properties);
        DetailMaskMap = FindProperty("_DetailMaskMap", properties);
        DetailAlbedo = FindProperty("_DetailAlbedo", properties);
        DetailAlbedoMap = FindProperty("_DetailAlbedoMap", properties);
        DetailRoughness = FindProperty("_DetailRoughness", properties);
        DetailRoughnessMap = FindProperty("_DetailRoughnessMap", properties);
        DetailMetallic = FindProperty("_DetailMetallic", properties);
        DetailMetallicMap = FindProperty("_DetailMetallicMap", properties);
        DetalNormalMapScale = FindProperty("_DetalNormalMapScale", properties);
        DetailNormalMap = FindProperty("_DetailNormalMap", properties);

        ThinFilm_ON = FindProperty("_ThinFilm_ON", properties);
        ThinFilmMaskMap = FindProperty("_ThinFilmMaskMap", properties);
        ThinFilmMiddleIOR = FindProperty("_ThinFilmMiddleIOR", properties);
        ThinFilmMiddleThickness = FindProperty("_ThinFilmMiddleThickness", properties);
        ThinFilmMiddleThicknessMin = FindProperty("_ThinFilmMiddleThicknessMin", properties);
        ThinFilmMiddleThicknessMax = FindProperty("_ThinFilmMiddleThicknessMax", properties);
        ThinFilmMiddleThicknessMap = FindProperty("_ThinFilmMiddleThicknessMap", properties);

        Cloth_ON = FindProperty("_Cloth_ON", properties);
        ClothAlbedo1 = FindProperty("_ClothAlbedo1", properties);
        ClothAlbedo2 = FindProperty("_ClothAlbedo2", properties);
        ClothIOR1 = FindProperty("_ClothIOR1", properties);
        ClothIOR2 = FindProperty("_ClothIOR2", properties);
        ClothKd1 = FindProperty("_ClothKd1", properties);
        ClothKd2 = FindProperty("_ClothKd2", properties);
        ClothGammaV1 = FindProperty("_ClothGammaV1", properties);
        ClothGammaV2 = FindProperty("_ClothGammaV2", properties);
        ClothGammaS1 = FindProperty("_ClothGammaS1", properties);
        ClothGammaS2 = FindProperty("_ClothGammaS2", properties);
        ClothAlpha1 = FindProperty("_ClothAlpha1", properties);
        ClothAlpha2 = FindProperty("_ClothAlpha2", properties);
        ClothTangentOffset1 = FindProperty("_ClothTangentOffset1", properties);
        ClothTangentOffset2 = FindProperty("_ClothTangentOffset2", properties);

        SrcBlend = FindProperty("_SrcBlend", properties);
        DstBlend = FindProperty("_DstBlend", properties);
        ZWrite = FindProperty("_ZWrite", properties);

        LightmapMode = FindProperty("_LightmapMode", properties);
        LightmapPower = FindProperty("_LightmapPower", properties);
        SHModeNonLiner = FindProperty("_SHModeNonLiner", properties);
        SpecularOcclusion = FindProperty("_SpecularOcclusion", properties);
        SHSpecular = FindProperty("_SHSpecular", properties);

        AddLightmap1_ON = FindProperty("_AddLightmap1_ON", properties);
        AddLightmap1_Power = FindProperty("_AddLightmap1_Power", properties);
        AddLightmap1 = FindProperty("_AddLightmap1", properties);

        AddLightmap2_ON = FindProperty("_AddLightmap2_ON", properties);
        AddLightmap2_Power = FindProperty("_AddLightmap2_Power", properties);
        AddLightmap2 = FindProperty("_AddLightmap2", properties);

        AddLightmap3_ON = FindProperty("_AddLightmap3_ON", properties);
        AddLightmap3_Power = FindProperty("_AddLightmap3_Power", properties);
        AddLightmap3 = FindProperty("_AddLightmap3", properties);

        DebugMode = FindProperty("_DebugMode", properties);
    }

    void SetKeyward(Material material, String shaderKey, bool state)
    {
        if (state)
        {
            material.EnableKeyword(shaderKey);
        }
        else
        {
            material.DisableKeyword(shaderKey);
        }
    }

    void SetKeyward(Material material, String shaderKey, float value)
    {
        bool state = value > 0.0;
        if (state)
        {
            material.EnableKeyword(shaderKey);
        }
        else
        {
            material.DisableKeyword(shaderKey);
        }
    }

    bool MenuFoldout(MaterialProperty mat, String menu_name)
    {
        GUIStyle button = new GUIStyle(EditorStyles.toolbar);
        button.fontStyle = FontStyle.Bold;
        button.fontSize = 16;

        bool state = mat.floatValue > 0.0;
        // state = EditorGUILayout.Foldout(state, new GUIContent(menu_name, "Tooltip"), button);
        if (GUILayout.Button(new GUIContent(menu_name), button))
        {
            state = !state;
        }
        mat.floatValue = state ? 1.0f : 0.0f;
        return state;
    }

    void SetMaterialKeywords(Material material)
    {
        SetKeyward(material, "_EMISSION", Emission.floatValue);

        MappingModeEnum mappingMode = (MappingModeEnum)MappingMode.floatValue;
        switch (mappingMode)
        {
            case MappingModeEnum.UV:
                SetKeyward(material, "_MAPPINGMODE_NONE", true);
                SetKeyward(material, "_MAPPINGMODE_TRIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_BIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_DITHER_TRIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_XYZMASK", false);
                break;
            case MappingModeEnum.Triplanar:
                SetKeyward(material, "_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_MAPPINGMODE_TRIPLANAR", true);
                SetKeyward(material, "_MAPPINGMODE_BIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_DITHER_TRIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_XYZMASK", false);
                break;
            case MappingModeEnum.Biplanar:
                SetKeyward(material, "_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_MAPPINGMODE_TRIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_BIPLANAR", true);
                SetKeyward(material, "_MAPPINGMODE_DITHER_TRIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_XYZMASK", false);
                break;
            case MappingModeEnum.DitheredTriplanar:
                SetKeyward(material, "_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_MAPPINGMODE_TRIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_BIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_DITHER_TRIPLANAR", true);
                SetKeyward(material, "_MAPPINGMODE_XYZMASK", false);
                break;
            case MappingModeEnum.XYZMask:
                SetKeyward(material, "_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_MAPPINGMODE_TRIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_BIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_DITHER_TRIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_XYZMASK", true);
                break;

        }

        SamplerModeEnum samplerMode = (SamplerModeEnum)SamplerMode.floatValue;
        switch (samplerMode)
        {
            case SamplerModeEnum.None:
                SetKeyward(material, "_SAMPLERMODE_NONE", true);
                SetKeyward(material, "_SAMPLERMODE_STOCHASTIC", false);
                SetKeyward(material, "_SAMPLERMODE_HEX", false);
                SetKeyward(material, "_SAMPLERMODE_VOLONOI", false);
                break;
            case SamplerModeEnum.Stochastic:
                SetKeyward(material, "_SAMPLERMODE_NONE", false);
                SetKeyward(material, "_SAMPLERMODE_STOCHASTIC", true);
                SetKeyward(material, "_SAMPLERMODE_HEX", false);
                SetKeyward(material, "_SAMPLERMODE_VOLONOI", false);
                break;
                // case SamplerModeEnum.Hex:
                //     SetKeyward(material, "_SAMPLERMODE_NONE", false);
                //     SetKeyward(material, "_SAMPLERMODE_STOCHASTIC", false);
                //     SetKeyward(material, "_SAMPLERMODE_HEX", true);
                //     SetKeyward(material, "_SAMPLERMODE_VOLONOI", false);
                //     break;
                // case SamplerModeEnum.Volonoi:
                //     SetKeyward(material, "_SAMPLERMODE_NONE", false);
                //     SetKeyward(material, "_SAMPLERMODE_STOCHASTIC", false);
                //     SetKeyward(material, "_SAMPLERMODE_HEX", false);
                //     SetKeyward(material, "_SAMPLERMODE_VOLONOI", true);
                //     break;
        }

        ParallaxModeEnum pallaxMode = (ParallaxModeEnum)PallaxMode.floatValue;
        switch (pallaxMode)
        {
            case ParallaxModeEnum.None:
                SetKeyward(material, "_PARALLAXMODE_NONE", true);
                SetKeyward(material, "_PARALLAXMODE_SIMPLE", false);
                SetKeyward(material, "_PARALLAXMODE_STEEP", false);
                break;
            case ParallaxModeEnum.Simple:
                SetKeyward(material, "_PARALLAXMODE_NONE", false);
                SetKeyward(material, "_PARALLAXMODE_SIMPLE", true);
                SetKeyward(material, "_PARALLAXMODE_STEEP", false);
                break;
            case ParallaxModeEnum.Steep:
                SetKeyward(material, "_PARALLAXMODE_NONE", false);
                SetKeyward(material, "_PARALLAXMODE_SIMPLE", false);
                SetKeyward(material, "_PARALLAXMODE_STEEP", true);
                break;
        }
        MappingModeEnum detailMappingMode = (MappingModeEnum)DetailMappingMode.floatValue;
        switch (detailMappingMode)
        {
            case MappingModeEnum.UV:
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_NONE", true);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_TRIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_BIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_DITHER_TRIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_XYZMASK", false);
                break;
            case MappingModeEnum.Triplanar:
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_TRIPLANAR", true);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_BIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_DITHER_TRIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_XYZMASK", false);
                break;
            case MappingModeEnum.Biplanar:
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_TRIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_BIPLANAR", true);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_DITHER_TRIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_XYZMASK", false);
                break;
            case MappingModeEnum.DitheredTriplanar:
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_TRIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_BIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_DITHER_TRIPLANAR", true);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_XYZMASK", false);
                break;
            case MappingModeEnum.XYZMask:
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_TRIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_BIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_DITHER_TRIPLANAR", false);
                SetKeyward(material, "_TK_DETAIL_MAPPINGMODE_XYZMASK", true);
                break;

        }
        DetailBlendModeEnum detailBlendMode = (DetailBlendModeEnum)DetailBlendMode.floatValue;
        switch (detailBlendMode)
        {
            case DetailBlendModeEnum.Linner:
                SetKeyward(material, "_TK_DETAIL_BLEND_LINNER", true);
                SetKeyward(material, "_TK_DETAIL_BLEND_MULTIPLY", false);
                SetKeyward(material, "_TK_DETAIL_BLEND_ADD", false);
                SetKeyward(material, "_TK_DETAIL_BLEND_SUBTRACT", false);
                break;
            case DetailBlendModeEnum.Multiply:
                SetKeyward(material, "_TK_DETAIL_BLEND_LINNER", false);
                SetKeyward(material, "_TK_DETAIL_BLEND_MULTIPLY", true);
                SetKeyward(material, "_TK_DETAIL_BLEND_ADD", false);
                SetKeyward(material, "_TK_DETAIL_BLEND_SUBTRACT", false);
                break;
            case DetailBlendModeEnum.Add:
                SetKeyward(material, "_TK_DETAIL_BLEND_LINNER", false);
                SetKeyward(material, "_TK_DETAIL_BLEND_MULTIPLY", false);
                SetKeyward(material, "_TK_DETAIL_BLEND_ADD", true);
                SetKeyward(material, "_TK_DETAIL_BLEND_SUBTRACT", false);
                break;
            case DetailBlendModeEnum.Subtract:
                SetKeyward(material, "_TK_DETAIL_BLEND_LINNER", false);
                SetKeyward(material, "_TK_DETAIL_BLEND_MULTIPLY", false);
                SetKeyward(material, "_TK_DETAIL_BLEND_ADD", false);
                SetKeyward(material, "_TK_DETAIL_BLEND_SUBTRACT", true);
                break;
        }

        SamplerModeEnum detailSamplerMode = (SamplerModeEnum)DetailSamplerMode.floatValue;

        switch (detailSamplerMode)
        {
            case SamplerModeEnum.None:
                SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_NONE", true);
                SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_STOCHASTIC", false);
                SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_HEX", false);
                SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_VOLONOI", false);
                break;
            case SamplerModeEnum.Stochastic:
                SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_NONE", false);
                SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_STOCHASTIC", true);
                SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_HEX", false);
                SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_VOLONOI", false);
                break;
                // case SamplerModeEnum.Hex:
                //     SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_NONE", false);
                //     SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_STOCHASTIC", false);
                //     SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_HEX", true);
                //     SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_VOLONOI", false);
                //     break;
                // case SamplerModeEnum.Volonoi:
                //     SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_NONE", false);
                //     SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_STOCHASTIC", false);
                //     SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_HEX", false);
                //     SetKeyward(material, "_TK_DETAIL_SAMPLERMODE_VOLONOI", true);
                //     break;
        }



        LightmapFormatEnum lightmapFormat = (LightmapFormatEnum)LightmapMode.floatValue;

        switch (lightmapFormat)
        {
            case LightmapFormatEnum.None:
                SetKeyward(material, "_LIGHTMAPMODE_NONE", true);
                SetKeyward(material, "_LIGHTMAPMODE_SH", false);
                SetKeyward(material, "_LIGHTMAPMODE_MONOSH", false);
                break;
            case LightmapFormatEnum.SH:
                SetKeyward(material, "_LIGHTMAPMODE_NONE", false);
                SetKeyward(material, "_LIGHTMAPMODE_SH", true);
                SetKeyward(material, "_LIGHTMAPMODE_MONOSH", false);
                break;
            case LightmapFormatEnum.MonoSH:
                SetKeyward(material, "_LIGHTMAPMODE_NONE", false);
                SetKeyward(material, "_LIGHTMAPMODE_SH", false);
                SetKeyward(material, "_LIGHTMAPMODE_MONOSH", true);
                break;
        }

        EmissionModeEnum emissionMode = (EmissionModeEnum)EmissionMode.floatValue;

        switch (emissionMode)
        {
            case EmissionModeEnum.None:
                material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.None;
                break;
            case EmissionModeEnum.Realtime:
                material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.RealtimeEmissive;
                break;
            case EmissionModeEnum.Bake:
                material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
                break;
        }

        if (Emission.floatValue == 0.0)
        {
            material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.None;
        }

        DebugModeEnum debugModeEnum = (DebugModeEnum)DebugMode.floatValue;
        switch (debugModeEnum)
        {
            case DebugModeEnum.None:
                SetKeyward(material, "_DEBUGMODE_NONE", true);
                SetKeyward(material, "_DEBUGMODE_BASECOLOR", false);
                SetKeyward(material, "_DEBUGMODE_NORMAL", false);
                break;
            case DebugModeEnum.BaseColor:
                SetKeyward(material, "_DEBUGMODE_NONE", false);
                SetKeyward(material, "_DEBUGMODE_BASECOLOR", true);
                SetKeyward(material, "_DEBUGMODE_NORMAL", false);
                break;
            case DebugModeEnum.Normal:
                SetKeyward(material, "_DEBUGMODE_NONE", false);
                SetKeyward(material, "_DEBUGMODE_BASECOLOR", false);
                SetKeyward(material, "_DEBUGMODE_NORMAL", true);
                break;
        }
    }

    public static void SetupBlendMode(Material material, BlendModeEnum blendMode)
    {
        switch (blendMode)
        {
            case BlendModeEnum.Opaque:
                material.SetOverrideTag("RenderType", "Opaque");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = -1;
                break;
            case BlendModeEnum.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.EnableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                break;
            case BlendModeEnum.Fade:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.EnableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendModeEnum.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
        }
    }
}
