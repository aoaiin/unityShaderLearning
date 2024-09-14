Shader "My06/HalfLambert"
{
     Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        pass{
            // 只有定义了正确的 LightMode, 我们才能得到 一些 Unity 的内置光照变量
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // 不用在顶点着色器中计算光照
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);
                
                // Half Lambert : 这里对结果 进行了缩放、偏移；映射到0-1之间
                // 背光面也可以有明暗变化，不同的点积结果会映射到不同的值上。
                fixed3 halfLambert = (dot(worldNormal,worldLight)) * 0.5 + 0.5;

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                fixed3 color = ambient + diffuse;
                return fixed4(color,1);
            }


            ENDCG
        }
    }
    FallBack "Diffuse"
}
