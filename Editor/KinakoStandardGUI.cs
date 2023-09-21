using UnityEditor;
using UnityEngine;

public class KinakoStandardGUI : ShaderGUI
{
    bool emissionEnabled = false;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

        Material targetMat = materialEditor.target as Material;
        
        EditorGUI.BeginChangeCheck();
        emissionEnabled = EditorGUILayout.Toggle("Emission",emissionEnabled);
        if(EditorGUI.EndChangeCheck()){
            targetMat.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
        }

        if(emissionEnabled){
            EditorGUILayout.BeginVertical("Box");
            EditorGUILayout.LabelField("Emission Settings", EditorStyles.boldLabel);

            EditorGUI.indentLevel++;
            Color emissionColor = EditorGUILayout.ColorField("Emission Color",targetMat.GetColor("_EmissionColor"));

            EditorGUILayout.EndVertical();
        }

    }
}
