using System;
using Codice.Client.BaseCommands.TubeClient;
using Codice.Foreign;
using UnityEditor;
using UnityEditor.Graphs;
using UnityEngine;

public class TakenokoStandardGUI : ShaderGUI
{
    private String mainTextureMenuKey_ = "MainTextureMenu";
    private String diffuseMenuKey_ = "DiffuseMenu";
    private String specularMenuKey_ = "SpecularMenu";
    private String thinfilmMenuKey_ = "ThinfilmMenu";
    private String bakeMenuKey_ = "BakeMenu";


    private Rect mainTextureFoldoutRect;
    private Rect diffuseFoldoutRect;
    private Rect specularFoldoutRect;
    private Rect thinfilmFoldoutRect;
    private Rect bakeFoldoutRect;

    private String emissionEnableKey = "EmissionEnable";

    private String thinfilmEnableKey = "ThinfilmEnable";

    private String specularOcclusionKey_ = "SpecularOcclusion";
    private String shSpecularKey_ = "SHSpecular";
    private String lightMapModeKey_ = "LightmapMode";
    private String shModeKey_ = "SHMode";

    private GUIContent[] lightmapFormatOptions = new GUIContent[]
    {
    new GUIContent("Normal"),
    new GUIContent("SH"),
    new GUIContent("MonoSH")
    };

    private GUIContent[] shModeOptions = new GUIContent[]
    {
    new GUIContent("Linearly"),
    new GUIContent("NonLinearly")
    };

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material targetMat = materialEditor.target as Material;

        GUIStyle foldoutStyle = new GUIStyle(EditorStyles.foldout);
        foldoutStyle.fontStyle = FontStyle.Bold;
        foldoutStyle.fontSize = 16;

        GUIStyle boxStyle = new GUIStyle(GUI.skin.box);
        boxStyle.normal.background = EditorGUIUtility.Load("builtin skins/darkskin/images/cn entryback.png") as Texture2D;
        boxStyle.normal.textColor = Color.white;
        boxStyle.border = new RectOffset(4, 4, 4, 4);

        bool mainTextureMenu_ = EditorPrefs.GetBool(mainTextureMenuKey_, false);
        bool diffuseMenu_ = EditorPrefs.GetBool(diffuseMenuKey_, false);
        bool specularMenu_ = EditorPrefs.GetBool(specularMenuKey_, false);
        bool thinfilmMenu_ = EditorPrefs.GetBool(thinfilmMenuKey_, false);
        bool bakeMenu_ = EditorPrefs.GetBool(bakeMenuKey_, false);

        mainTextureFoldoutRect = EditorGUILayout.GetControlRect();
        mainTextureMenu_ = EditorGUI.Foldout(mainTextureFoldoutRect, mainTextureMenu_, "Main Texture", true, foldoutStyle);

        //MainTextureMenu
        if (mainTextureMenu_)
        {
            EditorGUI.indentLevel++;
            MainMenuGUI(materialEditor, targetMat, properties);
            EditorGUI.indentLevel--;
        }

        GUILayout.Space(10);

        // Diffuse
        diffuseFoldoutRect = EditorGUILayout.GetControlRect();
        diffuseMenu_ = EditorGUI.Foldout(diffuseFoldoutRect, diffuseMenu_, "Diffuse Setting", true, foldoutStyle);
        if (diffuseMenu_)
        {

        }

        GUILayout.Space(10);

        // SpecularMenu
        specularFoldoutRect = EditorGUILayout.GetControlRect();
        specularMenu_ = EditorGUI.Foldout(specularFoldoutRect, specularMenu_, "Specular Setting", true, foldoutStyle);
        if (specularMenu_)
        {

        }

        GUILayout.Space(10);

        // ThinfilmMenu
        thinfilmFoldoutRect = EditorGUILayout.GetControlRect();
        thinfilmMenu_ = EditorGUI.Foldout(thinfilmFoldoutRect, thinfilmMenu_, "ThinFilm Setting", true, foldoutStyle);
        if (thinfilmMenu_)
        {
            ThinFilmMenuGUI(materialEditor, targetMat, properties);
        }

        GUILayout.Space(10);

        // BakeMenu
        bakeFoldoutRect = EditorGUILayout.GetControlRect();
        bakeMenu_ = EditorGUI.Foldout(bakeFoldoutRect, bakeMenu_, "Bake Setting", true, foldoutStyle);
        if (bakeMenu_)
        {
            BakeMenuGUI(materialEditor, targetMat, properties);
        }

        GUILayout.Space(10);

        EditorPrefs.SetBool(mainTextureMenuKey_, mainTextureMenu_);
        EditorPrefs.SetBool(diffuseMenuKey_, diffuseMenu_);
        EditorPrefs.SetBool(specularMenuKey_, specularMenu_);
        EditorPrefs.SetBool(thinfilmMenuKey_, thinfilmMenu_);
        EditorPrefs.SetBool(bakeMenuKey_, bakeMenu_);
    }

    private void MainMenuGUI(MaterialEditor materialEditor, Material targetMat, MaterialProperty[] properties)
    {
        Array.Copy(properties, 0, properties, 0, 5);
        GUIStyle boxStyle = new GUIStyle(GUI.skin.box);
        boxStyle.normal.background = EditorGUIUtility.Load("builtin skins/darkskin/images/cn entryback.png") as Texture2D;
        boxStyle.normal.textColor = Color.white;
        boxStyle.border = new RectOffset(4, 4, 4, 4);

        GUIStyle titleLabelStyle = new GUIStyle(EditorStyles.boldLabel);
        titleLabelStyle.fontSize = 14;

        // BaseColor
        EditorGUILayout.LabelField("BaseColor", titleLabelStyle);
        EditorGUILayout.BeginHorizontal(boxStyle);

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Basecolor Texture");
        TextureGUI(materialEditor, targetMat, "_MainTex");
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Basecolor");
        SetColorGUI(materialEditor, targetMat, "_Color");
        TextureScaleOffsetGUI(materialEditor, targetMat, "_MainTex");
        EditorGUILayout.EndVertical();

        EditorGUILayout.EndHorizontal();

        GUILayout.Space(5);

        //Metallic
        EditorGUILayout.LabelField("Metallic", titleLabelStyle);
        EditorGUILayout.BeginHorizontal(boxStyle);

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Metallic Texture");
        TextureGUI(materialEditor, targetMat, "_MetallicGlossMap");

        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Metallic");
        SetFloatSliderGUI(materialEditor, targetMat, "_Metallic", 0.0f, 1.0f);
        TextureScaleOffsetGUI(materialEditor, targetMat, "_MetallicGlossMap");
        EditorGUILayout.EndVertical();

        EditorGUILayout.EndHorizontal();

        GUILayout.Space(5);

        //Roughness
        EditorGUILayout.LabelField("Roughness", titleLabelStyle);
        EditorGUILayout.BeginHorizontal(boxStyle);

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Roughness Texture");
        TextureGUI(materialEditor, targetMat, "_RoughnessMap");
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Roughness");
        SetFloatSliderGUI(materialEditor, targetMat, "_Roughness", 0.0f, 1.0f);
        TextureScaleOffsetGUI(materialEditor, targetMat, "_RoughnessMap");
        EditorGUILayout.EndVertical();

        EditorGUILayout.EndHorizontal();

        GUILayout.Space(5);

        //Normal
        EditorGUILayout.LabelField("Normal", titleLabelStyle);
        EditorGUILayout.BeginHorizontal(boxStyle);

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Normal Texture");
        TextureGUI(materialEditor, targetMat, "_BumpMap");
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical();

        EditorGUILayout.PrefixLabel("Strength");
        TextureScaleOffsetGUI(materialEditor, targetMat, "_BumpMap");

        EditorGUILayout.EndVertical();
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(5);

        //Height
        // EditorGUILayout.LabelField("Height", titleLabelStyle);
        // EditorGUILayout.BeginHorizontal(boxStyle);

        // EditorGUILayout.BeginVertical();
        // EditorGUILayout.PrefixLabel("Height Texture");
        // TextureGUI(materialEditor, targetMat, "_HeightMap");
        // EditorGUILayout.EndVertical();

        // EditorGUILayout.BeginVertical();
        // EditorGUILayout.PrefixLabel("Strength");
        // TextureScaleOffsetGUI(materialEditor, targetMat, "_HeightMap");

        // EditorGUILayout.EndVertical();
        // EditorGUILayout.EndHorizontal();

        GUILayout.Space(5);

        EditorGUILayout.LabelField("Emission", titleLabelStyle);

        bool emissionEnabled_ = EditorPrefs.GetBool(emissionEnableKey, false);
        emissionEnabled_ = EditorGUILayout.Toggle("Emission", emissionEnabled_);
        EditorGUI.BeginChangeCheck();
        if (EditorGUI.EndChangeCheck())
        {
            if (!emissionEnabled_)
                targetMat.globalIlluminationFlags = MaterialGlobalIlluminationFlags.RealtimeEmissive;
            else
                targetMat.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
        }

        if (emissionEnabled_)
        {

            EditorGUILayout.BeginHorizontal(boxStyle);

            EditorGUILayout.BeginVertical();
            EditorGUILayout.PrefixLabel("Emission Texture");
            TextureGUI(materialEditor, targetMat, "_EmissionMap");
            EditorGUILayout.EndVertical();

            EditorGUILayout.BeginVertical();
            EditorGUILayout.PrefixLabel("_EmissionColor");
            SetColorGUI(materialEditor, targetMat, "_EmissionColor", "", true);
            TextureScaleOffsetGUI(materialEditor, targetMat, "_EmissionMap");
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndHorizontal();

        }
        EditorPrefs.SetBool(emissionEnableKey, emissionEnabled_);
    }

    private void ThinFilmMenuGUI(MaterialEditor materialEditor, Material targetMat, MaterialProperty[] properties)
    {
        GUIStyle boxStyle = new GUIStyle(GUI.skin.box);
        boxStyle.normal.background = EditorGUIUtility.Load("builtin skins/darkskin/images/cn entryback.png") as Texture2D;
        boxStyle.normal.textColor = Color.white;
        boxStyle.border = new RectOffset(4, 4, 4, 4);

        // _ThinFilmMiddleIOR("Middle Layer IOR", Range(1.0, 3.0)) = 1.5
        // _ThinFilmMiddleThickness("Middle Layer Thickness", Range(0.0, 1.0)) = 0.5
        // _ThinFilmMiddleThicknessMin("Middle Layer Thickness Minimum(nm)",Float) = 0.0
        // _ThinFilmMiddleThicknessMax("Middle Layer Thickness Maximum(nm)",Float) = 1000.0
        // _ThinFilmMiddleThicknessMap("Middle Layer Thickness Map", 2D) = "white" {}

        SetToggleShaderKeyGUI(materialEditor, targetMat, thinfilmEnableKey, "_TK_THINFILM_ON");

        //Thickness
        SetFloatSliderGUI(materialEditor, targetMat, "_ThinFilmMiddleIOR", 1.0f, 10.0f);
        SetFloatSliderGUI(materialEditor, targetMat, "_ThinFilmMiddleThickness", 0.0f, 1.0f);
        SetFloatSliderGUI(materialEditor, targetMat, "_ThinFilmMiddleThicknessMin", 0.0f, 1000.0f);
        SetFloatSliderGUI(materialEditor, targetMat, "_ThinFilmMiddleThicknessMax", 0.0f, 1000.0f);

        TextureGUI(materialEditor, targetMat, "_ThinFilmMiddleThicknessMap");
        TextureScaleOffsetGUI(materialEditor, targetMat, "_ThinFilmMiddleThicknessMap");
    }

    private void BakeMenuGUI(MaterialEditor materialEditor, Material targetMat, MaterialProperty[] properties)
    {
        GUIStyle boxStyle = new GUIStyle(GUI.skin.box);
        boxStyle.normal.background = EditorGUIUtility.Load("builtin skins/darkskin/images/cn entryback.png") as Texture2D;
        boxStyle.normal.textColor = Color.white;
        boxStyle.border = new RectOffset(4, 4, 4, 4);


        int lightmapFormatIndex = EditorPrefs.GetInt(lightMapModeKey_, 0);
        EditorGUI.BeginChangeCheck();
        lightmapFormatIndex = EditorGUILayout.Popup(new GUIContent("Lightmap Format"), lightmapFormatIndex, lightmapFormatOptions);
        if (EditorGUI.EndChangeCheck())
        {
            switch (lightmapFormatIndex)
            {
                case 0:
                    targetMat.EnableKeyword("_LIGHTMAPMODE_NONE");
                    targetMat.DisableKeyword("_LIGHTMAPMODE_SH");
                    targetMat.DisableKeyword("_LIGHTMAPMODE_MONOSH");
                    break;
                case 1:
                    targetMat.EnableKeyword("_LIGHTMAPMODE_SH");
                    targetMat.DisableKeyword("_LIGHTMAPMODE_NONE");
                    targetMat.DisableKeyword("_LIGHTMAPMODE_MONOSH");
                    break;
                case 2:
                    targetMat.EnableKeyword("_LIGHTMAPMODE_MONOSH");
                    targetMat.DisableKeyword("_LIGHTMAPMODE_NONE");
                    targetMat.DisableKeyword("_LIGHTMAPMODE_SH");
                    break;
            }
        }

        EditorPrefs.SetInt(lightMapModeKey_, lightmapFormatIndex);

        int shModeIndex = EditorPrefs.GetInt(shModeKey_, 0);
        EditorGUI.BeginChangeCheck();
        shModeIndex = EditorGUILayout.Popup(new GUIContent("SH Mode"), shModeIndex, shModeOptions);
        if (EditorGUI.EndChangeCheck())
        {
            switch (shModeIndex)
            {
                case 0:
                    targetMat.DisableKeyword("_SHMODE_NONLINER");
                    break;
                case 1:
                    targetMat.EnableKeyword("_SHMODE_NONLINER");
                    break;
            }
        }
        EditorPrefs.SetInt(shModeKey_, shModeIndex);

        // Specular Occlusion Toggle
        bool specularOcclusionToggle = EditorPrefs.GetBool(specularOcclusionKey_, false);
        EditorGUI.BeginChangeCheck();
        specularOcclusionToggle = EditorGUILayout.Toggle("Specular Occlusion", specularOcclusionToggle);
        if (EditorGUI.EndChangeCheck())
        {
            if (specularOcclusionToggle)
            {
                targetMat.EnableKeyword("_SPECULAR_OCCLUSION");
            }
            else
            {
                targetMat.DisableKeyword("_SPECULAR_OCCLUSION");
            }
        }

        EditorPrefs.SetBool(specularOcclusionKey_, specularOcclusionToggle);

        bool shSpecularToggle = EditorPrefs.GetBool(shSpecularKey_, false);
        EditorGUI.BeginChangeCheck();
        shSpecularToggle = EditorGUILayout.Toggle("SH Specular", shSpecularToggle);
        if (EditorGUI.EndChangeCheck())
        {
            if (shSpecularToggle)
            {
                targetMat.EnableKeyword("_SH_SPECULAR");
            }
            else
            {
                targetMat.DisableKeyword("_SH_SPECULAR");
            }
        }
        EditorPrefs.SetBool(shSpecularKey_, shSpecularToggle);

        //materialEditor.PropertiesDefaultGUI(properties);
    }

    private void TextureGUI(MaterialEditor materialEditor, Material targetMat, String texName, String name = "")
    {
        EditorGUI.BeginChangeCheck();
        Texture texture;
        if (name == "")
        {
            texture = (Texture)EditorGUILayout.ObjectField(GUIContent.none, targetMat.GetTexture(texName), typeof(Texture), false, GUILayout.Height(100), GUILayout.Width(100));
        }
        else
        {
            texture = (Texture)EditorGUILayout.ObjectField(name, targetMat.GetTexture(texName), typeof(Texture), false, GUILayout.Height(100), GUILayout.Width(100));
        }

        if (EditorGUI.EndChangeCheck())
        {
            targetMat.SetTexture(texName, texture);
        }
    }

    private void SetToggleShaderKeyGUI(MaterialEditor materialEditor, Material tergetMat, String key, String shaderKeyward)
    {
        bool toggle = EditorPrefs.GetBool(key, false);
        EditorGUI.BeginChangeCheck();
        toggle = EditorGUILayout.Toggle(shaderKeyward, toggle);
        if (EditorGUI.EndChangeCheck())
        {
            if (toggle)
            {
                tergetMat.EnableKeyword(shaderKeyward);
            }
            else
            {
                tergetMat.DisableKeyword(shaderKeyward);
            }
        }
        EditorPrefs.SetBool(key, toggle);
    }

    private void TextureScaleOffsetGUI(MaterialEditor materialEditor, Material targetMat, String texName)
    {
        EditorGUI.BeginChangeCheck();
        EditorGUILayout.PrefixLabel("Texture Scale");
        Vector2 textureScale = targetMat.GetTextureScale(texName);
        Vector2 newTextureScale = EditorGUILayout.Vector2Field(GUIContent.none, textureScale);

        EditorGUILayout.PrefixLabel("Texture Offset");
        Vector2 textureOffset = targetMat.GetTextureOffset(texName);
        Vector2 newTextureOffset = EditorGUILayout.Vector2Field(GUIContent.none, textureOffset);
        if (EditorGUI.EndChangeCheck())
        {
            targetMat.SetTextureScale(texName, newTextureScale);
            targetMat.SetTextureOffset(texName, newTextureOffset);
        }
    }

    private void SetColorGUI(MaterialEditor materialEditor, Material targetMat, String colorName, String name = "", bool isHDR = false)
    {
        EditorGUI.BeginChangeCheck();
        Color color;
        if (name == "")
        {
            color = EditorGUILayout.ColorField(GUIContent.none, targetMat.GetColor(colorName), true, true, isHDR);
        }
        else
        {
            color = EditorGUILayout.ColorField(new GUIContent(name), targetMat.GetColor(colorName), true, true, isHDR);
        }
        if (EditorGUI.EndChangeCheck())
        {
            targetMat.SetColor(colorName, color);
        }
    }

    private void SetFloatSliderGUI(MaterialEditor materialEditor, Material targetMat, String floatName, float mint, float maxt, String name = "")
    {
        EditorGUI.BeginChangeCheck();
        float floatValue;

        if (name == "")
        {
            floatValue = EditorGUILayout.Slider(targetMat.GetFloat(floatName), mint, maxt);
        }
        else
        {
            floatValue = EditorGUILayout.Slider(name, targetMat.GetFloat(floatName), mint, maxt);
        }

        if (EditorGUI.EndChangeCheck())
        {
            targetMat.SetFloat(floatName, floatValue);
        }
    }
}
