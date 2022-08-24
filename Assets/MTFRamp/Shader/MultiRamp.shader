Shader "Unlit/MultiRamp"
{
    Properties
    {
        _RampTex("Ramp Tex",2D)="white"{}
        _UvRange("UV Range",Vector)=(0,0,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"  "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM
                #pragma vertex ForwardPassVertex
                #pragma fragment ForawrdPassFragment

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                struct AppData
                {
                    float4 positionOS : POSITION;
                    float2 texcoord : TEXCOORD0;
                    float4 normalOS :   NORMAL;
                };

                struct Varyings
                {
                    float2 texcoord : TEXCOORD0;
                    float4 positionCS : SV_POSITION;
                    float4 normalWS : TEXCOORD1;
                    float3 lightDirWS : TEXCOORD2;
                };

                CBUFFER_START(UnityPerMaterial)
                    half4 _UvRange;
                CBUFFER_END

                TEXTURE2D(_RampTex);
                SAMPLER(sampler_RampTex);

                Varyings ForwardPassVertex (AppData input)
                {
                    Varyings output=(Varyings)0;
                    output.normalWS.xyz = SafeNormalize(TransformObjectToWorldNormal(input.normalOS));
                    Light light = GetMainLight();
                    output.lightDirWS =  SafeNormalize(light.direction);
                    output.positionCS = TransformObjectToHClip(input.positionOS);
                    return output;
                }

                half SampleLambert(float3 normalWS,float3 lightDirWS)
                {
                    half diffuse =  dot(normalWS,lightDirWS)*0.5+0.5;
                    return diffuse;
                }
            
                half4 ForawrdPassFragment (Varyings input) : SV_Target
                {
                    half diffuse = SampleLambert(input.normalWS,input.lightDirWS);
                    half y = diffuse*(_UvRange.w-_UvRange.y)+_UvRange.y;
                    half3 color  =  SAMPLE_TEXTURE2D_LOD(_RampTex,sampler_RampTex,half2(diffuse.x,y), 0.0).rgb;
                    return half4(color,1);
                }
            ENDHLSL
        }
    }
}
