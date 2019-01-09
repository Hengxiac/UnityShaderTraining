using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct skybox {
    private static Mesh m_mesh;
    private static int _Corners = Shader.PropertyToID("_Corner");
    private static Vector4[] corners = new Vector4[4];
    public Material skyboxMaterial;

    public static Mesh Cubemaps
    {
        get
        {
            if (m_mesh != null)
            {
                return m_mesh;
            }
            m_mesh = new Mesh();
            m_mesh.vertices = new Vector3[] {
                new Vector4(-1, -1, 0, 1),
                new Vector4(-1, 1 , 0 ,1),
                new Vector4(1, 1, 0, 1),
                new Vector4(1, -1, 0, 1)
            };
            m_mesh.uv = new Vector2[] {
                new Vector2(0, 1),
                new Vector2(0, 0),
                new Vector2(1, 0),
                new Vector2(1, 1)
            };

            m_mesh.SetIndices(new int[] { 0, 1, 2, 3 }, MeshTopology.Quads, 0);
            return m_mesh;
        }
    }

    public void DrawSkybox (Camera cam, RenderBuffer cameraTarget, RenderBuffer depth)
    {
        corners[0] = cam.ViewportToWorldPoint(new Vector3(0, 0, cam.farClipPlane));
        corners[1] = cam.ViewportToWorldPoint(new Vector3(1, 0, cam.farClipPlane));
        corners[2] = cam.ViewportToWorldPoint(new Vector3(0, 1, cam.farClipPlane));
        corners[3] = cam.ViewportToWorldPoint(new Vector3(1, 1, cam.farClipPlane));

        skyboxMaterial.SetVectorArray(_Corners, corners);
        skyboxMaterial.SetPass(0);
        Graphics.SetRenderTarget(cameraTarget, depth);
        Graphics.DrawMeshNow(Cubemaps, Matrix4x4.identity);
    }
}
