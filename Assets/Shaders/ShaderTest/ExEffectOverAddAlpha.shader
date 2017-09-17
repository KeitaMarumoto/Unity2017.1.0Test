// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Effect/ExOverAddAlpha" {
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_AlpColor ("AlpColor(RGBA)", Color) = (1,1,1,1)
		_AddColor ("AddColor(RGB)", Color) = (0,0,0,0)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[KeywordEnum(None, Front, Back)] _Cull("Culling", Int) = 0
		_ScrollSpeed ("Scroll Speed( only XY )", Vector) = (0, 0, 0, 0) 
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull[_Cull]
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
			};
			
			fixed4 _AlpColor;
			fixed4 _AddColor;
			half4 _ScrollSpeed;

			float4 _MainTex_ST;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _AlpColor;
				OUT.color.rgb *= OUT.color.a;								//事前乗算
				OUT.color.rgb += IN.color.rgb * _AddColor.rgb * IN.color.a;	//加算成分追加
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 tex = tex2D(_MainTex, IN.texcoord * _MainTex_ST.xy + _MainTex_ST.zw + float2(_Time.x * _ScrollSpeed.x, _Time.x * _ScrollSpeed.y));
				tex.rgb *= tex.a;
				return tex * IN.color;
			}
		ENDCG
		}
	}
}
