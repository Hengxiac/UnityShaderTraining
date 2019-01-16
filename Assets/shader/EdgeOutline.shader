/*
Shader "NBR/EdgeOutline"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		_TestColor("TestColor", Color) = (1,1,1,1)
	}

		CGINCLUDE

#include "UnityCG.cginc"
	sampler2D _MainTex_ST;
	uniform float _Threshold;
	uniform float _SampleDistance;
	uniform float _Exponent;
	uniform float4 _EdgesColor;
	uniform float4 _TestColor;
	uniform float _BgFade;
	ENDCG

    SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};

			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};

			sampler2D _CameraDepthNormalsTexture;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			float4 GetPixelValue(in float2 uv)
			{
				half3 normal;
				float depth;
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv), depth, normal);
				return fixed4(normal, depth);
			}

			float4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 orValue = GetPixelValue(i.uv);
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

				float3x3 sobelHorizontal = float3x3(
					-1, 0 ,1,
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
				float adjacentPixel = _MainTex_TexelSize.xy * _SampleDistance;
				for (int m = 0; m < 3; m++)
					for (int n = 0; n < 3; n++)
					{
						// sampledValue += GetPixelValue(i.uv + offsets[m * 3 + n] * adjacentPixel) * laplacianOperator[m][n];
						sobelH += GetPixelValue(i.uv + offsets[m * 3 + n] * adjacentPixel) * sobelHorizontal[m][n];
						sobelV += GetPixelValue(i.uv + offsets[m * 3 + n] * adjacentPixel) * sobelHorizontal[m][n];
					}

				float sobel = sqrt(sobelH.w * sobelH.w + sobelV.w * sobelV.w);
				// sobel = 1 - pow(saturate(sobel), _Exponent);

				float Edges_value = saturate(lerp(0.0, sobel, _Threshold));
				float3 EdgesMask_Var = float3(Edges_value, Edges_value, Edges_value); // EdgesMask		
				float4 SceneColor = tex2D(_MainTex, i.uv);
				SceneColor = lerp(SceneColor, _TestColor, _BgFade);
				float3 FinalColor = saturate((EdgesMask_Var*_EdgesColor.rgb) + (SceneColor.rgb - EdgesMask_Var));
				return float4(FinalColor, 1);

				// float laplacian = 1 - pow(saturate(sampledValue), _Exponent);
				// float4 color = tex2D(_MainTex, i.uv);

				// color = _EdgesColor * color * (1 - sobel) + sobel;
				// color = _EdgesColor * color * (1 - laplacian) + laplacian;
				// return lerp(col, _EdgeColor, step(_Threshold, length(orValue - sampledValue)));

				// return color * lerp(tex2D(_MainTex, i.uv), _TestColor, _BgFade);
			}

			ENDCG
		}
	}
}
*/
Shader "NBR/EdgeOutline"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	// _Threshold("Threshold", float) = 0.01
	_TestColor("TestColor", Color) = (1,1,1,1)
	}
		CGINCLUDE
		uniform float4 _LightDir;
	uniform float _BgFade;
	uniform float4 _TestColor;

	ENDCG

		SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
			};

			struct v2f
			{
				float2 uv: TEXCOORD0;
				float4 vertex: SV_POSITION;
			};

			sampler2D _CameraDepthNormalsTexture;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _Threshold;
			fixed4 _EdgesColor;
			float _SampleDistance;
			float _Exponent;
			
			float4 GetPixelValue(in float2 uv)
			{
				half3 normal;
				float depth;
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv), depth, normal);
				return fixed4(normal, depth);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 lightDirection = normalize(_LightDir.xyz - i.vertex);
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 orValue = GetPixelValue(i.uv);
				float3 normal = normalize(orValue.xyz);

				float celGradient[3] = {
					0.3,
					0.6,
					0.8
				};

				float celCoef[4] = {
					0.2,
					0.5,
					0.9,
					1.0
				};

				float2 offsets[9] = {
					float2(-1, 1),
					float2(0, 1),
					float2(1, 1),
					float2(-1, 0),
					float2(1, 0),
					float2(0, 1),
					float2(1, -1),
					float2(1, 0),
					float2(1, 1)
				};

				fixed4 sampledValue = fixed4(0, 0, 0, 0);
				float3x3 laplacianOperator = float3x3(
					0, 1, 0,
					1, -4, 1,
					0, 1, 0
					);
				float2 distance = _MainTex_TexelSize.xy * _SampleDistance;
				for (int m = 0; m < 3; m++)
					for (int n = 0; n < 3; n++)
					{
						sampledValue += GetPixelValue(i.uv + offsets[m * 3 + n] * distance) * laplacianOperator[m][n];
					}
				// sampledValue /= 8;

				// return lerp(col, _EdgeColor, step(_Threshold, length(orValue - sampledValue)));
				col = lerp(col, _EdgesColor, step(_Threshold, length(orValue - sampledValue)));

				float angle = dot(lightDirection, normal);
				if (angle < celGradient[0])
				{
					col.xyz = col.xyz * celCoef[0];
				}
				/*
				else if (angle < celGradient[1])
				{
					col.xyz = col.xyz * celCoef[1];
				}
				else if (angle < celGradient[2])
				{
					col.xyz = col.xyz * celCoef[2];
				}
				*/
				else
				{
					col.xyz = col.xyz * celCoef[3];
				}

				return col; //* lerp(col, _TestColor, _BgFade);
			}

			ENDCG
		}

	}
}
