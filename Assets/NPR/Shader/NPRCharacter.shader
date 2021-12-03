Shader "Unlit/NPRCharacter"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 500

        Pass
        {
            HLSLPROGRAM
            Tags{"ForwardBase"="UniversalForward"}

            #pragma vertex ForwardVertex
            #pragma fragment ForwardFrag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct ForwardInput
            {
                float4 positionObj : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct ForwardOutput
            {
                float4 uv : TEXCOORD0;
                float4 postionClip : SV_POSITION;
            };

            ForwardOutput ForwardVertex (ForwardInput Input)
            {
                ForwardOutput output;
                return o;
            }

            half4 ForwardFrag (ForwardOutput Input) : SV_Target
            {
                half4 outputColor;
                outputColor= half4(1,1,1,1);

                return outputColor;
            }
            ENDCG
        }
    }
}
