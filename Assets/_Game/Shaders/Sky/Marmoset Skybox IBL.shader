// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Marmoset Skyshop
// Copyright 2013 Marmoset LLC
// http://marmoset.co

Shader "Marmoset/Skybox IBL" {
Properties {
	_SkyCubeIBL ("Cubemap", Cube) = "white" {}
}

SubShader {
	Tags { "Queue"="Background" "RenderType"="Background" }
	Cull Off ZWrite Off Fog { Mode Off }

	Pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma glsl
		#pragma target 3.0
		
		#define MARMO_HQ
		#define MARMO_SKY_ROTATION
		
		#pragma multi_compile MARMO_SKY_BLEND_OFF MARMO_SKY_BLEND_ON
		
		#if MARMO_SKY_BLEND_ON
			#define MARMO_SKY_BLEND
		#endif
		
		uniform samplerCUBE _SkyCubeIBL;		
		#ifdef MARMO_SKY_BLEND
		uniform samplerCUBE _SkyCubeIBL1;
		#endif
		
		#include "UnityCG.cginc"
		#include "MarmosetCore.cginc"

		struct appdata_t {
			float4 vertex : POSITION;
			float3 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 vertex : POSITION;
			float3 texcoord : TEXCOORD0;
			#ifdef MARMO_SKY_BLEND
			float3 texcoord1 : TEXCOORD1;
			#endif
		};

		v2f vert (appdata_t v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.texcoord = skyRotate(_SkyMatrix, v.texcoord);
			#ifdef MARMO_SKY_BLEND
				o.texcoord1 = skyRotate(_SkyMatrix1, v.texcoord);
			#endif
			return o;
		}
		
		half4 frag (v2f i) : COLOR
		{
			float4 col = texCUBE(_SkyCubeIBL, i.texcoord);
			col.rgb = fromRGBM(col);			
			col.rgb *= 1;	
			
			#ifdef MARMO_SKY_BLEND			
				float4 col1 = texCUBE(_SkyCubeIBL1, i.texcoord1);
				col1.rgb = fromRGBM(col1);
				col1.rgb *= _ExposureIBL1.z;
				col.rgb = lerp(col1.rgb, col.rgb, _BlendWeightIBL);
			#endif
			
			col.a = 1.0;
			return col;
		}
		ENDCG 
	}
}

Fallback Off

}
