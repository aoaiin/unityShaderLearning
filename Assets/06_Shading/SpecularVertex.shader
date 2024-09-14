Shader "My06/SpecularVertex"
{
    Properties
    {
        // _Specular 用于控制材质的高光反射颜色，而_Gloss 用于控制高光区域的大小。
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0,256)) = 20
    }
    SubShader
    {
        pass{
            // 只有定义了正确的 LightMode, 我们才能得到一些 Unity 的内置光照变蜇，例如_LigbtColorO 。
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 color : COLOR;
            };
            

            // 使用逐顶点的方法得到的高光效果有比较大的问题，我们可以在图 6.10 中看出高光部分明显 不平滑。这主要是因为，高光反射部分的计算是非线性的，而在顶点着色器中计算光照再进行插 值的过程是线性的，破坏了原计算的非线性关系，就会出现较大的视觉问题 。 因此，我们就需要 使用逐像素的方法来计算 高光反射。
            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
                
                //计算 反射方向
                fixed3 reflectDir = normalize(reflect(-worldLight,worldNormal));
                //计算 视线方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld,v.vertex).xyz);
                // fixed3 viewDir = normalize(UnityWorldSpaceViewDir(v.vertex));
                fixed3 specular= _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);

                o.color = ambient + diffuse + specular;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                return fixed4(i.color,1);
            }


            ENDCG
        }
    }
    FallBack "Specular"
}
