using System;
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
        DitheredTriplanar
    }

    private enum SamplerModeEnum
    {
        None,
        Stochastic,
        Hex,
        Volonoi
    }

    private enum DebugModeEnum
    {
        None,
        BaseColor,
        Normal,
    }

    private GUIContent BaseColorText = new GUIContent("BaseColor");
    private GUIContent RoughnessText = new GUIContent("Roughness");
    private GUIContent NormalText = new GUIContent("Normal Map");
    private GUIContent HeightText = new GUIContent("Height Map");

    MaterialProperty MappingMode;
    MaterialProperty MappingPosObj;
    MaterialProperty SamplerMode;

    MaterialProperty Color;
    MaterialProperty MainTex;
    MaterialProperty Cutoff;
    MaterialProperty Metallic;
    MaterialProperty MetallicGlossMap;
    MaterialProperty Roughness;
    MaterialProperty RoughnessMap;

    MaterialProperty BumpScale;
    MaterialProperty BumpMap;

    MaterialProperty Emission;
    MaterialProperty EmissionMode;
    MaterialProperty EmissionColor;
    MaterialProperty EmissionMap;

    MaterialProperty ThinFilm_ON;
    MaterialProperty ThinFilmMiddleIOR;
    MaterialProperty ThinFilmMiddleThickness;
    MaterialProperty ThinFilmMiddleThicknessMin;
    MaterialProperty ThinFilmMiddleThicknessMax;
    MaterialProperty ThinFilmMiddleThicknessMap;
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
            using (new EditorGUILayout.VerticalScope("HelpBox"))
            {
                GUILayout.Space(5);
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

                materialEditor.ShaderProperty(Color, "BaseColor Tint");
                materialEditor.ShaderProperty(MainTex, "BaseColor Map");
                GUILayout.Space(10);
                materialEditor.ShaderProperty(Roughness, "Roughness");
                materialEditor.ShaderProperty(RoughnessMap, "Roughness Map");
                GUILayout.Space(10);
                materialEditor.ShaderProperty(Metallic, "Metallic");
                materialEditor.ShaderProperty(MetallicGlossMap, "Metallic Map");
                GUILayout.Space(10);
                materialEditor.ShaderProperty(BumpMap, "Normal Map");
                GUILayout.Space(5);
            }

            using (new EditorGUILayout.VerticalScope("HelpBox"))
            {
                GUILayout.Space(5);
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
                GUILayout.Space(5);
            }

            using (new EditorGUILayout.VerticalScope("HelpBox"))
            {
                GUILayout.Space(5);
                materialEditor.ShaderProperty(ThinFilm_ON, "Thin-Film");
                if (ThinFilm_ON.floatValue > 0.0)
                {
                    materialEditor.ShaderProperty(ThinFilmMiddleIOR, "IOR");
                    materialEditor.ShaderProperty(ThinFilmMiddleThickness, "Film Thickness");
                    materialEditor.ShaderProperty(ThinFilmMiddleThicknessMap, "Film Thickness Map");
                    materialEditor.ShaderProperty(ThinFilmMiddleThicknessMin, "Film Thickness minimum(nm)");
                    materialEditor.ShaderProperty(ThinFilmMiddleThicknessMax, "Film Thickness maximum(nm)");
                }
                GUILayout.Space(5);
            }

            using (new EditorGUILayout.VerticalScope("HelpBox"))
            {
                GUILayout.Space(5);
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


            using (new EditorGUILayout.VerticalScope("HelpBox"))
            {
                DebugModeEnum debugMode = (DebugModeEnum)DebugMode.floatValue;
                debugMode = (DebugModeEnum)EditorGUILayout.Popup("Debug Mode", (int)debugMode, Enum.GetNames(typeof(DebugModeEnum)));
                DebugMode.floatValue = (float)debugMode;
            }
        }
        if (EditorGUI.EndChangeCheck())
        {
            SetMaterialKeywords(material);
        }

    }

    public void setMaterialProperty(MaterialProperty[] properties)
    {
        MappingMode = FindProperty("_MappingMode", properties);
        MappingPosObj = FindProperty("_MappingPosObj", properties);
        SamplerMode = FindProperty("_SamplerMode", properties);
        Color = FindProperty("_Color", properties);
        MainTex = FindProperty("_MainTex", properties);

        Cutoff = FindProperty("_Cutoff", properties);
        Metallic = FindProperty("_Metallic", properties);
        MetallicGlossMap = FindProperty("_MetallicGlossMap", properties);
        Roughness = FindProperty("_Roughness", properties);
        RoughnessMap = FindProperty("_RoughnessMap", properties);

        BumpScale = FindProperty("_BumpScale", properties);
        BumpMap = FindProperty("_BumpMap", properties);

        Emission = FindProperty("_Emission", properties);
        EmissionMode = FindProperty("_EmissionMode", properties);
        EmissionColor = FindProperty("_EmissionColor", properties);
        EmissionMap = FindProperty("_EmissionMap", properties);

        ThinFilm_ON = FindProperty("_ThinFilm_ON", properties);
        ThinFilmMiddleIOR = FindProperty("_ThinFilmMiddleIOR", properties);
        ThinFilmMiddleThickness = FindProperty("_ThinFilmMiddleThickness", properties);
        ThinFilmMiddleThicknessMin = FindProperty("_ThinFilmMiddleThicknessMin", properties);
        ThinFilmMiddleThicknessMax = FindProperty("_ThinFilmMiddleThicknessMax", properties);
        ThinFilmMiddleThicknessMap = FindProperty("_ThinFilmMiddleThicknessMap", properties);

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
                break;
            case MappingModeEnum.Triplanar:
                SetKeyward(material, "_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_MAPPINGMODE_TRIPLANAR", true);
                SetKeyward(material, "_MAPPINGMODE_BIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_DITHER_TRIPLANAR", false);
                break;
            case MappingModeEnum.Biplanar:
                SetKeyward(material, "_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_MAPPINGMODE_TRIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_BIPLANAR", true);
                SetKeyward(material, "_MAPPINGMODE_DITHER_TRIPLANAR", false);
                break;
            case MappingModeEnum.DitheredTriplanar:
                SetKeyward(material, "_MAPPINGMODE_NONE", false);
                SetKeyward(material, "_MAPPINGMODE_TRIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_BIPLANAR", false);
                SetKeyward(material, "_MAPPINGMODE_DITHER_TRIPLANAR", true);
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
            case SamplerModeEnum.Hex:
                SetKeyward(material, "_SAMPLERMODE_NONE", false);
                SetKeyward(material, "_SAMPLERMODE_STOCHASTIC", false);
                SetKeyward(material, "_SAMPLERMODE_HEX", true);
                SetKeyward(material, "_SAMPLERMODE_VOLONOI", false);
                break;
            case SamplerModeEnum.Volonoi:
                SetKeyward(material, "_SAMPLERMODE_NONE", false);
                SetKeyward(material, "_SAMPLERMODE_STOCHASTIC", false);
                SetKeyward(material, "_SAMPLERMODE_HEX", false);
                SetKeyward(material, "_SAMPLERMODE_VOLONOI", true);
                break;
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

}
