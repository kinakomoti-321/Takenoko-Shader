using UnityEditor;
using UnityEngine;

public class TakenokoStandardGUI : ShaderGUI
{
    private bool mainTextureMenu_ = false;
    bool emissionEnabled_ = false;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //base.OnGUI(materialEditor, properties);
        Material targetMat = materialEditor.target as Material;

        GUIStyle foldoutStyle = new GUIStyle(EditorStyles.foldout);
        foldoutStyle.fontStyle = FontStyle.Bold;
        foldoutStyle.fontSize = 16;

        GUIStyle boxStyle = new GUIStyle(GUI.skin.box);
        boxStyle.normal.background = EditorGUIUtility.Load("builtin skins/darkskin/images/cn entryback.png") as Texture2D;
        boxStyle.normal.textColor = Color.white;
        boxStyle.border = new RectOffset(4, 4, 4, 4);

        Rect foldoutRect = EditorGUILayout.GetControlRect();
        mainTextureMenu_ = EditorGUI.Foldout(foldoutRect, mainTextureMenu_, "Main Texture", true, foldoutStyle);


        //MainTextureMenu
        if (mainTextureMenu_)
        {
            EditorGUI.indentLevel++;

            //BaseColor
            Color basecolor = EditorGUILayout.ColorField("BaseColor", targetMat.GetColor("_BaseColor"));
            targetMat.SetColor("_BaseColor", basecolor);

            EditorGUI.BeginChangeCheck();
            Texture basecolorTexture = (Texture)EditorGUILayout.ObjectField("Basecolor Texture", targetMat.GetTexture("_BaseColorMap"), typeof(Texture), false);
            if (EditorGUI.EndChangeCheck())
            {
                targetMat.SetTexture("_BaseColorMap", basecolorTexture);
            }

            GUILayout.Space(5);

            //Metallic
            float metallic = EditorGUILayout.Slider("Metallic", targetMat.GetFloat("_Metallic"), 0.0f, 1.0f);
            targetMat.SetFloat("_Metallic", metallic);

            EditorGUI.BeginChangeCheck();
            Texture metallicTexture = (Texture)EditorGUILayout.ObjectField("Metallic Texture", targetMat.GetTexture("_MetallicMap"), typeof(Texture), false);
            if (EditorGUI.EndChangeCheck())
            {
                targetMat.SetTexture("_MetallicMap", metallicTexture);
            }


            //Roughness
            float roughness = EditorGUILayout.Slider("Roughness", targetMat.GetFloat("_Roughness"), 0.0f, 1.0f);
            targetMat.SetFloat("_Roughness", roughness);

            EditorGUI.BeginChangeCheck();
            Texture roughnessTexture = (Texture)EditorGUILayout.ObjectField("Roughness Texture", targetMat.GetTexture("_RoughnessMap"), typeof(Texture), false);
            if (EditorGUI.EndChangeCheck())
            {
                targetMat.SetTexture("_RoughnessMap", roughnessTexture);
            }


            //Normal
            EditorGUI.BeginChangeCheck();
            Texture normalTexture = (Texture)EditorGUILayout.ObjectField("Normal Texture", targetMat.GetTexture("_BumpMap"), typeof(Texture), false);
            if (EditorGUI.EndChangeCheck())
            {
                targetMat.SetTexture("_BumpMap", normalTexture);
            }


            //Height
            EditorGUI.BeginChangeCheck();
            Texture heightTexture = (Texture)EditorGUILayout.ObjectField("Height Texture", targetMat.GetTexture("_HeightMap"), typeof(Texture), false);
            if (EditorGUI.EndChangeCheck())
            {
                targetMat.SetTexture("_HeightMap", heightTexture);
            }


            EditorGUI.BeginChangeCheck();
            emissionEnabled_ = EditorGUILayout.Toggle("Emission", emissionEnabled_);
            if (EditorGUI.EndChangeCheck())
            {
                targetMat.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
            }

            if (emissionEnabled_)
            {
                EditorGUILayout.BeginVertical("Box");
                EditorGUILayout.LabelField("Emission Settings", EditorStyles.boldLabel);

                EditorGUI.indentLevel++;
                Color emissionColor = EditorGUILayout.ColorField("Emission Color", targetMat.GetColor("_EmissionColor"));

                EditorGUILayout.EndVertical();
            }

        }
    }
}
