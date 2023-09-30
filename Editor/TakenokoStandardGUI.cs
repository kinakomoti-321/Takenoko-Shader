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

    private GUIContent BaseColorText = new GUIContent("BaseColor");
    private GUIContent RoughnessText = new GUIContent("Roughness");
    private GUIContent NormalText = new GUIContent("Normal Map");
    private GUIContent HeightText = new GUIContent("Height Map");

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
    MaterialProperty SHModeNonLiner;
    MaterialProperty SpecularOcclusion;
    MaterialProperty SHSpecular;

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
                GUILayout.Space(5);
            }


        }
        if (EditorGUI.EndChangeCheck())
        {
            SetMaterialKeywords(material);
        }

    }

    public void setMaterialProperty(MaterialProperty[] properties)
    {
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
        SHModeNonLiner = FindProperty("_SHModeNonLiner", properties);
        SpecularOcclusion = FindProperty("_SpecularOcclusion", properties);
        SHSpecular = FindProperty("_SHSpecular", properties);
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
    }

}
