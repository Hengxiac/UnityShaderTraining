using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RenderObj : MonoBehaviour {
    public Mesh targetMesh;
    public Matrix4x4 localToWorld;
    public Material mat;
    public Vector3 extent;

	// Use this for initialization
	void Start () {
	       	
	}

    public void Init()
    {
        localToWorld = transform.localToWorldMatrix;
        extent = targetMesh.bounds.extents;
    }
}
