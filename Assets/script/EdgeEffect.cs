using System.Collections;
using UnityEngine;

[ExecuteInEditMode]
public class EdgeEffect : MonoBehaviour
{
    public Material mat;
    // public Texture tex;
    // Start is called before the first frame update
    void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
        // mat.SetTexture("_MainTex", tex);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetFloat("Threshold", 0.01f);
        mat.SetVector("_EdgeColor", new Vector4(0, 0, 0, 1));
        Graphics.Blit(source, destination, mat);
    }
}
