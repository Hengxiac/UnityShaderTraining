Shader "NBR/OutlineSobel"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_TestColor("Test color", Color) = (1, 1, 1, 1)
	}

	CGINCLUDE
	#include"UnityCG.cginc"
	
	uniform sampler2D _MainTex;
	uniform sampler2D _MainTex_ST;
	uniform float4 _MainTex_TexelSize;
	sampler2D_float _CameraDepthTexture;
	sampler2D _CameraDepthNormalsTexture;

	uniform float4 _EdgeColor;
	uniform float _Exponent;
	uniform float _SampleDistance;
	uniform float _FilterPower;
	uniform float _Threshold;
	uniform float4 _TestColor;
	uniform float _BgFade;
	uniform float3 _LightDir;
	uniform int _bToonShader;

	struct appdata
	{
		float4 vertex: POSITION;
		float4 normal: NORMAL;
		float2 uv: TEXCOORD0;
	};

	struct v2f
	{
		float2 uv: TEXCOORD0;
		float4 vertex: SV_POSITION;
	};


	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}


	float4 GetPixelValue(in float2 uv)
	{
		half3 normal;
		float depth;
		DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv), depth, normal);
		return fixed4(normal, depth);
	}

	float3 toonShading(float3 color, float3 lightDirection, float3 normal)
	{
		float celGradient[1] = {
			0.4,
		};

		float celCoef[2] = {
			0.35,
			1.0
		};
		float angle = dot(lightDirection, normal);
		if (angle < celGradient[0])
		{
			color = color * celCoef[0];
		}
		else
		{
			color = color * celCoef[1];
		}

		return color;
	}

	float4 fragDepthNormalLaplacian(v2f i) : SV_Target
	{
		float3 lightDirection = normalize(_LightDir - i.vertex);
		float3 normal = normalize(GetPixelValue(i.uv).xyz);
		float4 col = tex2D(_MainTex, i.uv);
		float4 orValue = GetPixelValue(i.uv);
		float2 offsets[9] = {
				float2(-1, 1),
				float2(0, 1),
				float2(1, 1),
				float2(-1, 0),
				float2(0, 0),
				float2(1, 0),
				float2(-1, -1),
				float2(0, -1),
				float2(1, -1)
		};

		float4 sampledValue = float4(0, 0, 0, 0);
		float3x3 laplacianOperator = float3x3(
			0, 1, 0,
			1, -4, 1,
			0, 1, 0
			);
		float2 sampleDist = _MainTex_TexelSize * _SampleDistance;
		for (int m = 0; m < 3; m++)
			for (int n = 0; n < 3; n++)
			{
				sampledValue += GetPixelValue(i.uv + offsets[m * 3 + n] * sampleDist) * laplacianOperator[m][n];
			}
		// sampledValue /= 8;
		col = lerp(float4(1, 1, 1, 1), _EdgeColor, 1.0f - saturate(_Threshold - length(orValue - sampledValue)));
		col = col * lerp(tex2D(_MainTex, i.uv), _TestColor, _BgFade);
		
		if (_bToonShader == 1)
		{
			col.xyz = toonShading(col.xyz, lightDirection, normal);
		}
		
		return col;
	}
	

	float4 fragDepthSobel(v2f i) : SV_Target
	{
		float3 lightDirection = normalize(_LightDir - i.vertex);
		float3 normal = normalize(GetPixelValue(i.uv).xyz);
		float2 offsets[9] = {
			float2(-1, 1),
			float2(0, 1),
			float2(1, 1),
			float2(-1, 0),
			float2(0, 0),
			float2(1, 0),
			float2(-1, -1),
			float2(0, -1),
			float2(1, -1)
		};

		const float4 horizontalDiagCoef = float4(-1, -1, 1, 1);
		const float4 horizontalAxialCoef = float4(0, -1, 0, 1);
		const float4 verticalDiagCoeff = float4(1, 1, -1, -1);
		const float verticalAxialCoef = float4(1, 0, -1, 0);
		// boardlands implementation of sobel filter
		// diagonal / axial values
		float4 depthDiag;
		float4 depthAxial;

		float2 distance = _SampleDistance * _MainTex_TexelSize.xy;
		
		/*
		depthDiag.x = GetPixelValue(i.uv + offsets[6] * _MainTex_TexelSize.xy).w; // (-1, -1)
		depthDiag.y = GetPixelValue(i.uv + offsets[0] * _MainTex_TexelSize.xy).w; // (-1, 1)
		depthDiag.z = GetPixelValue(i.uv + offsets[2] * _MainTex_TexelSize.xy).w;// (1, 1)
		depthDiag.w = GetPixelValue(i.uv + offsets[8] * _MainTex_TexelSize.xy).w; // (1, -1)

		depthAxial.x = GetPixelValue(i.uv + offsets[3] * _MainTex_TexelSize.xy).w; // (-1, 0)
		depthAxial.y = GetPixelValue(i.uv + offsets[1] * _MainTex_TexelSize.xy).w; // (0, 1)
		depthAxial.z = GetPixelValue(i.uv + offsets[5] * _MainTex_TexelSize.xy).w; // (1, 0)
		depthAxial.w = GetPixelValue(i.uv + offsets[7] * _MainTex_TexelSize.xy).w; // (0, -1)
		*/
		depthDiag.x = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[6] * distance)); // (-1, -1)
		depthDiag.y = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[0] * distance)); // (-1, 1)
		depthDiag.z = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[2] * distance));// (1, 1)
		depthDiag.w = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[8] * distance)); // (1, -1)

		depthAxial.x = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[3] * distance)); // (-1, 0)
		depthAxial.y = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[1] * distance)); // (0, 1)
		depthAxial.z = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[5] * distance)); // (1, 0)
		depthAxial.w = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + offsets[7] * distance)); // (0, -1)

		// float centerDepth = GetPixelValue(i.uv).w;
		float centerDepth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv));

		depthDiag /= centerDepth;
		depthAxial -= centerDepth;

		float4 sobelHorizontal = horizontalDiagCoef * depthDiag + horizontalAxialCoef * depthAxial;
		float4 sobelVertical = verticalDiagCoeff * depthDiag + verticalAxialCoef * depthAxial;

		float sobelH = dot(sobelHorizontal, float4(1, 1, 1, 1));
		float sobelV = dot(sobelVertical, float4(1, 1, 1, 1));

		float sobel = sqrt(sobelH * sobelH + sobelV * sobelV);
		sobel = 1.0 - pow(saturate(sobel), _Exponent);
		float4 color = tex2D(_MainTex, i.uv.xy);
		color = _EdgeColor * color * (1 - sobel) + sobel;
		color = color * lerp(tex2D(_MainTex, i.uv.xy), _TestColor, _BgFade);
		if (_bToonShader == 1)
		{
			color.xyz = toonShading(color.xyz, lightDirection, normal);
		}

		return color;
	}


	float4 fragColor(v2f i) : COLOR
  	{
		float3 lightDirection = normalize(_LightDir - i.vertex);
		float3 normal = normalize(GetPixelValue(i.uv).xyz);

		float2 offsets[9] = {
			float2(-1, 1),
			float2(0, 1),
			float2(1, 1),
			float2(-1, 0),
			float2(0, 0),
			float2(1, 0),
			float2(-1, -1),
			float2(0, -1),
			float2(1, -1)
		};

		float3x3 sobelHorizontal = float3x3(
			-1, 0, 1,
			-2, 0, 2,
			-1, 0, 1
			);
		float3x3 sobelVertical = float3x3(
			-1, -2, -1,
			0, 0, 0,
			1, 2, 1
			);
		float4 sobelH = float4(0, 0, 0, 0);
		float4 sobelV = float4(0, 0, 0, 0);
		float2 adjacentPixel = _MainTex_TexelSize.xy * _SampleDistance;
		for (int m = 0; m < 3; m++)
			for (int n = 0; n < 3; n++)
			{
				sobelH += tex2D(_MainTex, i.uv + offsets[m * 3 + n] * adjacentPixel) * sobelHorizontal[m][n];
				sobelV += tex2D(_MainTex, i.uv + offsets[m * 3 + n] * adjacentPixel) * sobelVertical[m][n];
			}

		float sobel = sqrt(sobelH * sobelH + sobelV * sobelV);

		float4 sceneColor = tex2D(_MainTex, i.uv);
		// float4 sceneColor = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex));
		// Get edge value based on sobel value and threshold
		float edgeMask = saturate(lerp(0.0f, sobel, _Threshold));
		float3 EdgeMaskColor = float3(edgeMask, edgeMask, edgeMask);
		sceneColor = lerp(sceneColor, _TestColor, _BgFade);

		float3 finalColor = saturate((EdgeMaskColor * _EdgeColor.rgb) + (sceneColor.rgb - EdgeMaskColor));

		if (_bToonShader == 1)
		{
			finalColor = toonShading(finalColor, lightDirection, normal);
		}
		return float4(finalColor, 1);

	}
	ENDCG

	SubShader
	{
		Tags{
			"IgnoreProjector" = "True"
			"Queue" = "Overlay+1"
			"RenderType" = "Overlay"
		}
		// Using color difference
		Pass
		{
			Cull Off ZWrite Off ZTest Always
			CGPROGRAM
			#pragma target 3.0   
			#pragma vertex vert
			#pragma fragment fragColor
			ENDCG
		}

		// Using depth normal texture sobel filter
		Pass
		{
			Cull Off ZWrite Off ZTest Always
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment fragDepthSobel
			ENDCG
		}

		// Using depth normal texture laplacian filter
		Pass
		{
			Cull Off ZWrite Off ZTest Always
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment fragDepthNormalLaplacian
			ENDCG
		}
	}

Fallback off
}
