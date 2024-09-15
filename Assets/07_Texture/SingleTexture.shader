// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "My07/SingleTexture"
{
    Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		//声明一个纹理
		_MainTex ("Main Tex", 2D) = "white" {}
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {		
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			// 在 CG 代码片中声明和上述属性类型相匹配的变量，以便和材质面板中的属性 建立联系
			fixed4 _Color;
			sampler2D _MainTex;
			//还需要为纹理类型的属性声明一个 float4 类型的变量 _MainTex_ST 
			//在 Unity 中，我们需要使用纹理名 _ST 的方式来声明某个纹理的 **属性**。
			//			ST 是缩放 (scale ) 和平移 (translation ) 的缩写；
			//_MainTex_ST.xy 存储的是缩放值，而 _MainTex_ST.zw 存储的是偏移值
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;
			
			//定义顶点 着色器的输入和 输出结构体
			//首先在 a2v 结构体中使用 TEXCOORDO 语义声明了 一个新的变量texcoord, 
			//		这样 Unity 就会将模型的第一组纹理坐标存储到该变量中；
			//然后，在 v2f 结构体中 添加了用于存储纹理坐标的变量 UV, 以便在片元着色器中使用该坐标进行纹理采样
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				// 使用纹理的属性值_MainTex_ST 来对顶点纹理坐标进行变换 ： 先对顶点坐标 缩放，再偏移
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				// Or just call the built-in function 内置宏可以完成上面的步骤
//				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				// 使用 CG 的 tex2D 函数对 纹理进行采样 ： 第一个参数是需要被采样的纹理，第 二个参数是一个 float2 类型的纹理坐标， 它将返回计算得到的纹素值
				// 使用 采样结果 和 颜色属性_Color 的乘积来作为  材质的反射率 albedo
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Specular"
}
