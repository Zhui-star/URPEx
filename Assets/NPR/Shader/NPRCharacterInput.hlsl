#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

 CBUFFER_START(UnityPerMaterial)
        half4 _BaseColor;
        half _LightTreshold;
        half _LightOffsetX;
        half _LightOffsetY;        
        half4 _BaseMap_ST; 
        half  _RampIntensity;       
        half4 _ShadeMap_ST;
        half4 _ShadeColor;             
        half _GIOcclusion;               
 CBUFFER_END

TEXTURE2D(_ShadeMap);SAMPLER(sampler_ShadeMap);