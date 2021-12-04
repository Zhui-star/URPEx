Shader "GAREN/URP/NPRCharacter"
{
    Properties
    {
        _BaseMap("Main Texture",2D)="white" {}
        [HDR]_BaseColor("Base Color", Color) = (1,1,1,1)
        _LightTreshold("Light Treshold",Range(-1,1))=0
        _LightOffsetX("Light Offset X",Range(-1,1))=0
        _LightOffsetY("Light Offset Y",Range(-1,1))=0
        _RampTexture("Ramp Texture",2D)="white" {}
        _RampIntensity("Ramp Intensity",Range(0.5,2))=1.2
        _EnviormentIntesity("Enviorment Intensity",Range(0,2))=0.2
    }
    SubShader
    {
        Tags {
            "RenderPipeline" = "UniversalPipeline" 
            "RenderType"="Opaque"          
             }

        LOD 100
        
        Pass
        { 
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            #include "NPRCharacterInput.hlsl"
            #include "NPRCharacterForward.hlsl"

            #pragma vertex ForwardVertex
            #pragma fragment ForwardFrag

            ENDHLSL
        }
    }
}
