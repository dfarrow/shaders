Shader "Custom/BlendAdvanced" {
	Properties {

		// Main texture
		_Color ("Base Texture Color", Color) = (1,1,1,1)
		_MainTex ("Base Texture Albedo (RGB)", 2D) = "white" {}

		// The blending texture blend amount
		 _Blend ("Blend Textures Amount", Range(0.0,1.0)) = 0.0

		// The Blend texture
		_BlendColor ("Blend Texture Color", Color) = (1,1,1,1)
        _BlendTex ("Blend Texture Albedo (RGB)", 2D) = "white" {}
		 
		// The Specular texture
		_SpecMap ("Specular map", 2D) = "white" {}  
		_Glossiness ("Smoothness", Range(0,1)) = 0.5

		// Emission
		[HDR]_EmitColor ("Color", Color) = (1,1,1,1)
		_EmitMap ("Emission Texture", 2D) = "black" {} 
		_EmitStrength ("Emit Strength", Range( 0.0, 8.0 )) = 0

		_Metallic ("Metallic", Range(0,1)) = 0.0 
		
		// Normal
		_BumpMap ("Normal map", 2D) = "bump" {}
		_BumpAmount ("Normal strength", Range(-6,6)) = 0.0 

		// A secondary detail texture
		_Detail ("Detail", 2D) = "gray" {}
		_DetailAmount ("Detail Amount", Range(0.0,1.0)) = 0.0
	}


	SubShader {
		Tags { "RenderType"="Geometry+1500" }
		 
		LOD 300
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard forwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BlendTex;
		sampler2D _Detail;
		sampler2D _BumpMap;
		sampler2D _SpecMap;
		sampler2D _EmitMap; 

		struct Input {
			float2 uv_MainTex;
			float2 uv_BlendTex;
			float2 uv_Detail;
			float2 uv_BumpMap; 
			float2 uv_SpecMap; 
			float2 uv_EmitMap; 
		}; 

		half _Glossiness;
		half _Metallic;
		float _Transparency;
		half _EmitStrength;
		fixed4 _EmitColor;
		fixed4 _Color;
		fixed4 _BlendColor;
		half _Blend;
		half _DetailAmount;
		half _BumpAmount;
		half _Specular;	

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END
	 
		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 b = tex2D (_BlendTex, IN.uv_BlendTex) * _BlendColor;
			// Albedo map
			o.Albedo =  (c.rgb * 4 * (1-_Blend)) + (b.rgb * 4  * (_Blend)); // Set the Abedo to the main texture combined with the blend texture
			o.Albedo *= tex2D (_Detail, IN.uv_Detail).rgb ; // Add the secondary detail texture to albedo
  
			fixed4 specTex = tex2D (_SpecMap, IN.uv_SpecMap); 

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;

			// Specular and gloss
			o.Smoothness = specTex.rgb * _Glossiness;

			// Set normal map
			float3 normalMap = UnpackNormal ( ( tex2D (_BumpMap, IN.uv_BumpMap) ));

			// Set normal strength
			normalMap.x *= _BumpAmount;
			normalMap.y *= _BumpAmount;

			o.Normal = normalize(normalMap);
  
			// Emission  
			o.Emission = tex2D(_EmitMap, IN.uv_EmitMap) * _EmitStrength * _EmitColor;
			

		}
		ENDCG
	}
	FallBack "Diffuse"
}
