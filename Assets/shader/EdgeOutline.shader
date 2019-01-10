Shader "NBR/EdgeOutline"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		_Threshold("Threshold", float) = 0.01
		_EdgeColor("Edge color", Color) = (0, 0, 0, 1)
    }
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
			fixed4 _EdgeColor;

			float4 GetPixelValue(in float2 uv)
			{
				half3 normal;
				float depth;
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv), depth, normal);
				return fixed4(normal, depth);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 orValue = GetPixelValue(i.uv);
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
				for (int m = 0; m < 3; m++)
					for (int n = 0; n < 3; n++)
					{
						sampledValue += GetPixelValue(i.uv + offsets[m * 3 + n] * _MainTex_TexelSize.xy) * laplacianOperator[m][n];
					}
				// sampledValue /= 8;

				return lerp(col, _EdgeColor, step(_Threshold, length(orValue - sampledValue)));
			}

			ENDCG
		}













	}
}
