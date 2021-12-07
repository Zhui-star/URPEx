Shader "GAREN/URP/NPRCharacter"
{
    Properties
    {
        _BaseMap("Main Texture",2D)="white" {}
        [HDR]_BaseColor("Base Color", Color) = (1,1,1,1)
        //阴影区域贴图
        _ShadeMap("Shade Map",2D)="white" {} 
        //阴影区域颜色
        _ShadeColor("Shade Color",Color)=(0.5,0.5,0.5,1)
        _LightTreshold("Light Treshold",Range(0,1))=0
        _Steps("Diffuse Steps",Range(1,5))=1
        //Step 区域控制
        _StepArea("Step Area",Range(0,20))=0
        _LightOffsetX("Light Offset X",Range(-1,1))=0
        _LightOffsetY("Light Offset Y",Range(-1,1))=0
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
