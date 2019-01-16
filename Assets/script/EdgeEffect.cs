using System.Collections;
using UnityEngine;

[ExecuteInEditMode]
[AddComponentMenu("AnimeStyle/PostProcess/Edge Detection")]
public class EdgeEffect : MonoBehaviour
{
    public bool toonshader = true;
    public Material mat;
    public EdgeDetectMode mode = EdgeDetectMode.SobelColor;
    public Color edgeColor = new Color(0, 0, 0);
    [Range(0.0f, 4.0f)]
    public float threshold = 1.0f;

    [Range(0.0f, 4.0f)]
    public float edgeExp_SobelDepth = 1.0f;

    [Range(0.0f, 2.0f)]
    public float sampleDist = 1.0f;

    // [Range(0.0f, 2.0f)]
    // public float filterPower = 1.0f;

    [Range(0.0f, 1.0f)]
    public float fadeFactor = 0.0f;
    public Light directionalLight;
    // public Texture tex;

    public enum EdgeDetectMode
    {
        SobelColor = 0,
        SobelDepth = 1, 
        LaplacianDepthNormal = 2,
    }

    // Start is called before the first frame update
    void Start()
    {
        /*
        if (compositionScript == true)
        {
            if (mode == EdgeDetectMode.SobelDepth)
            {
                Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
            }
            else if (mode == EdgeDetectMode.LaplacianDepthNormal)
            {
                Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
            }
        }
        else
        */
        // if (mode != EdgeDetectMode.SobelColor)
        {
            Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    [ImageEffectOpaque]
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetVector("_EdgeColor", edgeColor);
        mat.SetFloat("_Exponent", edgeExp_SobelDepth);
        mat.SetFloat("_SampleDistance", sampleDist);
        // mat.SetFloat("_FilterPower", filterPower);
        mat.SetFloat("_Threshold", threshold);
        mat.SetFloat("_BgFade", fadeFactor);
        mat.SetVector("_LightDir", directionalLight.transform.position);
        mat.SetInt("_bToonShader", toonshader? 1 : 0);
        Graphics.Blit(source, destination, mat, (int)mode);
    }
}
