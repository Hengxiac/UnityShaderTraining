using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleVolume : MonoBehaviour {
    private RenderTexture renderTexture;
    public Transform[] cubeTransform;
    public Mesh cubeMesh;
    public Material pureColorMaterial;

    public skybox skydraw;

	// Use this for initialization
	void Start () {
        renderTexture = new RenderTexture(Screen.width, Screen.height, 24);
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    private void OnPostRender()
    {
        Camera cam = Camera.current;
        Graphics.SetRenderTarget(renderTexture);
        GL.Clear(true, true, Color.gray);

        // Start Drawcall
        pureColorMaterial.color = new Color(0, 0.8f, 0);
        pureColorMaterial.SetPass(0);
        foreach (var oneCube in cubeTransform)
        {
            Graphics.DrawMeshNow(cubeMesh, oneCube.localToWorldMatrix);
        }
        skydraw.DrawSkybox(cam, renderTexture.colorBuffer, renderTexture.depthBuffer);
        Graphics.Blit(renderTexture, cam.targetTexture);
    }
}
