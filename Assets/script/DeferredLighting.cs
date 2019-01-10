using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[System.Serializable]
public struct DeferredLighting
{

    public Light directionalLight;
    private static int _InvVP = Shader.PropertyToID("_InvVP");
    private static int _CurrentLightDir = Shader.PropertyToID("_CurrentLightDir");
    private static int _LightFInalColor = Shader.PropertyToID("_LightFinalColor");
    private static int _CubeMap = Shader.PropertyToID("_CubeMap");
    public Material lightingMat;
    public Cubemap cubemap;

    public void DrawLight(RenderTexture[] gbuffers, int[] gbufferIDs, RenderTexture target, Camera cam)
    {
        Matrix4x4 proj = GL.GetGPUProjectionMatrix(cam.projectionMatrix, false);
        Matrix4x4 vp = proj * cam.worldToCameraMatrix;
        Shader.SetGlobalMatrix(_InvVP, vp.inverse);
        lightingMat.SetMatrix(_InvVP, vp.inverse);
        lightingMat.SetTexture(_CubeMap, cubemap);
        lightingMat.SetVector(_CurrentLightDir, -directionalLight.transform.forward);
        lightingMat.SetVector(_LightFInalColor, directionalLight.color * directionalLight.intensity);
        /*
        for (int i = 0; i < gbufferIDs.Length; i++)
        {
            lightingMat.SetTexture(gbufferIDs[i], gbuffers[i]);
        }
        */
        Graphics.Blit(null, target, lightingMat, 0);
    }
}
