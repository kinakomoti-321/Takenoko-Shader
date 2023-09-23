using System;
using Codice.Client.BaseCommands.TubeClient;
using UnityEditor;
using UnityEngine;

public class TakenokoStandardGUI : ShaderGUI
{
    private bool mainTextureMenu_ = true;
    private bool diffuseMenu_ = false;
    private bool specularMenu_ = false;
    private bool thinfilmMenu_ = false;
    private bool bakeMenu_ = false;
    private Rect mainTextureFoldoutRect;
    private Rect diffuseFoldoutRect;
    private Rect specularFoldoutRect;
    private Rect thinfilmFoldoutRect;
    private Rect bakeFoldoutRect;

    bool emissionEnabled_ = false;
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

        }

        GUILayout.Space(10);

        // BakeMenu
        bakeFoldoutRect = EditorGUILayout.GetControlRect();
        bakeMenu_ = EditorGUI.Foldout(bakeFoldoutRect, bakeMenu_, "Bake Setting", true, foldoutStyle);
        if (bakeMenu_)
        {

        }

        GUILayout.Space(10);
    }

    private void MainMenuGUI(MaterialEditor materialEditor, Material targetMat, MaterialProperty[] properties)
    {
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
        TextureGUI(materialEditor, targetMat, "_BaseColorMap");
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Basecolor");
        SetColorGUI(materialEditor, targetMat, "_BaseColor");
        TextureScaleOffsetGUI(materialEditor, targetMat, "_BaseColorMap");
        EditorGUILayout.EndVertical();

        EditorGUILayout.EndHorizontal();

        GUILayout.Space(5);

        //Metallic
        EditorGUILayout.LabelField("Metallic", titleLabelStyle);
        EditorGUILayout.BeginHorizontal(boxStyle);

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Metallic Texture");
        TextureGUI(materialEditor, targetMat, "_MetallicMap");
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Metallic");
        SetFloatSliderGUI(materialEditor, targetMat, "_Metallic", 0.0f, 1.0f);
        TextureScaleOffsetGUI(materialEditor, targetMat, "_MetallicMap");
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
        EditorGUILayout.LabelField("Height", titleLabelStyle);
        EditorGUILayout.BeginHorizontal(boxStyle);

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Height Texture");
        TextureGUI(materialEditor, targetMat, "_HeightMap");
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical();
        EditorGUILayout.PrefixLabel("Strength");
        TextureScaleOffsetGUI(materialEditor, targetMat, "_HeightMap");

        EditorGUILayout.EndVertical();
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(5);

        EditorGUILayout.LabelField("Emission", titleLabelStyle);
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
    }

    private void BakeMenuGUI(MaterialEditor materialEditor, Material targetMat, MaterialProperty[] properties)
    {
        GUIStyle boxStyle = new GUIStyle(GUI.skin.box);
        boxStyle.normal.background = EditorGUIUtility.Load("builtin skins/darkskin/images/cn entryback.png") as Texture2D;
        boxStyle.normal.textColor = Color.white;
        boxStyle.border = new RectOffset(4, 4, 4, 4);

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
