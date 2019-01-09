using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleVolume : MonoBehaviour {
    private static int _DepthTexture = Shader.PropertyToID("_DepthTexture");

    private RenderTexture renderTexture;
    private RenderBuffer[] GBuffers;
    private RenderTexture[] GBufferTextures;
    private int[] GBufferIDs;

    public Transform[] cubeTransform;
    public Mesh cubeMesh;
    // public Material pureColorMaterial;
    public Material deferredMat;
    public skybox skydraw;

    public DeferredLighting lighting;
    private RenderTexture depthTexture;

    // Use this for initialization
    void Start () {
        renderTexture = new RenderTexture(Screen.width, Screen.height, 0);
        GBufferTextures = new RenderTexture[]
        {
            new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear),
            new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear),
            new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear),
            new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear)
        };

        depthTexture = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Depth, RenderTextureReadWrite.Linear);
        GBuffers = new RenderBuffer[GBufferTextures.Length];

        for (int i = 0; i < GBuffers.Length; i++)
        {
            GBuffers[i] = GBufferTextures[i].colorBuffer;
        }

        GBufferIDs = new int[]
        {
            Shader.PropertyToID("_GBuffer0"),
            Shader.PropertyToID("_GBuffer1"),
            Shader.PropertyToID("_GBuffer2"),
            Shader.PropertyToID("_GBuffer3")
        };
    }


    int screenWidth;
    int screenHeight;
    private static void ReSize(RenderTexture rt, int width, int height)
    {
        rt.Release();
        rt.width = width;
        rt.height = height;
        rt.Create();
    }

    private void OnPostRender()
    {
        Camera cam = Camera.current;
        if (screenHeight != cam.pixelHeight  || screenWidth != cam.pixelWidth )
        {
            screenHeight = (int)(cam.pixelHeight);
            screenWidth = (int)(cam.pixelWidth);
            ReSize(renderTexture, screenWidth, screenHeight);
            ReSize(depthTexture, screenWidth, screenHeight);
            foreach (var i in GBufferTextures)
            {
                ReSize(i, screenWidth, screenHeight);
            }
            for (int i = 0; i < GBuffers.Length; ++i)
            {
                GBuffers[i] = GBufferTextures[i].colorBuffer;
            }
        }

        Shader.SetGlobalTexture(_DepthTexture, depthTexture);
        // Graphics.SetRenderTarget(renderTexture);

        for (int i = 0; i < GBufferIDs.Length; ++i)
        {
            Shader.SetGlobalTexture(GBufferIDs[i], GBufferTextures[i]);
        }
        Graphics.SetRenderTarget(GBuffers, depthTexture.depthBuffer);
        GL.Clear(true, true, Color.green);
        // Start Drawcall
        // pureColorMaterial.color = new Color(0, 0.8f, 0);
        // pureColorMaterial.SetPass(0);
        deferredMat.SetPass(0);
        foreach (var oneCube in cubeTransform)
        {
            Graphics.DrawMeshNow(cubeMesh, oneCube.localToWorldMatrix);
        }
        lighting.DrawLight(GBufferTextures, GBufferIDs, renderTexture, cam);
        skydraw.DrawSkybox(cam, renderTexture.colorBuffer, depthTexture.depthBuffer);
        Graphics.Blit(renderTexture, cam.targetTexture);
    }
}
