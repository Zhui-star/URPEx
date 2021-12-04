

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

 CBUFFER_START(UnityPerMaterial)
        half4 _BaseColor;
        half _LightTreshold;
        half _LightOffsetX;
        half _LightOffsetY;     
        half4 _RampTexture_ST;     
        half4 _BaseMap_ST; 
        half  _RampIntensity;     
        half _EnviormentIntesity;                                                     
 CBUFFER_END

TEXTURE2D(_RampTexture); SAMPLER(sampler_RampTexture);