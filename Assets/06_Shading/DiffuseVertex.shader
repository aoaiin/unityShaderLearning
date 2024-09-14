Shader "My06/DiffuseVertexLambert"
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
                float3 color : COLOR;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //漫反射 = 光照颜色 * 漫反射颜色 * max(0, dot(法线, 光线))
                // 这种计算也称为 Lambert 光照模型
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

                o.color = ambient + diffuse;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                return fixed4(i.color,1);
            }


            ENDCG
        }
    }
    FallBack "Diffuse"
}
