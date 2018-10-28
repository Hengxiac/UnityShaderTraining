﻿Shader "Custom/skyboxShader" 
{
	Properties 
	{
		_SkyboxTexture("Skybox Texture", Cube) = "white" {}
	}
	
	SubShader
	{
		Pass
		{
			Cull off ZWrite off
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 worldPos: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};


			float4 _Corner[4];
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = v.vertex;
				o.worldPos = _Corner[v.uv.x + v.uv.y * 2].xyz;
				return o;
			}
			TextureCube _SkyboxTexture; SamplerState sampler_SkyboxTexture;

			float4 frag (v2f i) : COLOR
			{
				float3 viewDir = normalize(i.worldPos - _WorldSpaceCameraPos);
				return _SkyboxTexture.Sample(sampler_SkyboxTexture, viewDir);
			}

			ENDCG
		}
	}
}
