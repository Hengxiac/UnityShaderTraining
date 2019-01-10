using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForwardRendering : MonoBehaviour {

    public Transform[] cubeTransforms;
    public Material mat;
    public Mesh cubeMesh;
    private RenderTexture cameraTarget;
	// Use this for initialization
	void Start () {
        cameraTarget = new RenderTexture(Screen.width, Screen.height, 24);
	}

    public void OnPostRender()
    {
        Camera cam = Camera.current;
        Graphics.SetRenderTarget(cameraTarget);
        GL.Clear(true, true, Color.green);
        mat.SetPass(0);

        foreach (var cube in cubeTransforms)
        {
            Graphics.DrawMeshNow(cubeMesh, cube.localToWorldMatrix);
        }
        Graphics.Blit(cameraTarget, cam.targetTexture);
    }
}
