Shader "My06/SpecularPixel"
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
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };
            
            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;


                return o;
            }

            fixed4 frag(v2f i) : SV_Target{

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
                
                //计算 反射方向
                fixed3 reflectDir = normalize(reflect(-worldLight,worldNormal));
                //计算 视线方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);

                fixed3 specular= _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);

                return fixed4(ambient+ diffuse + specular,1);
            }


            ENDCG
        }
    }
    FallBack "Specular"
}
