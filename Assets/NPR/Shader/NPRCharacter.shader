Shader "GAREN/URP/NPRCharacter"
{
    Properties
    {
        //基础贴图
        _BaseMap("Main Texture",2D)="white" {}
        //物体基础色
        [HDR]_BaseColor("Base Color", Color) = (1,1,1,1)
        //阴影区域贴图
        _ShadeMap("Shade Map",2D)="white" {} 
        //阴影区域颜色
        _ShadeColor("Shade Color",Color)=(0.5,0.5,0.5,1)
        //阴影区域阀值 阀值越高阴影越少
        _LightTreshold("Light Treshold",Range(0,1))=0
        //色阶区域控制
        _StepArea("Step Area",Range(0,20))=0
        //光源X轴偏移
        _LightOffsetX("Light Offset X",Range(-1,1))=0
        //光源Y轴偏移
        _LightOffsetY("Light Offset Y",Range(-1,1))=0
        //全局光照遮蔽
        _GIOcclusion("Global illumiance occlusion",Range(0,1))=0
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

            /////////unity 内置变体/////////
            //直射光 光照贴图混合全局光光照贴图
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            //开启光照贴图
            #pragma multi_compile _ LIGHTMAP_ON

            ///////URP 渲染管线内置变体/////
            //全局光照与实时光照混合
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING     
            
            //阴影采样
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE

            //支持软阴影
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            //全局像素着色器球谐光照
            //#pragma multi_compile _ EVALUATE_SH_MIXED 

            #pragma vertex ForwardVertex
            #pragma fragment ForwardFrag

            ENDHLSL
        }
    }
}
