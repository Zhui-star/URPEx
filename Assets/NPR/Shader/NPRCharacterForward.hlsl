
// 光照API 库
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 纹理采样库
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
// 颜色库 (包含颜色转亮度值)
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "../../Common/Common.hlsl"

// 前向渲染输入结构体
struct ForwardVertexInput
{
    float4 positionOS : POSITION;   // 模型空间下的顶点位置
    float4 normalOS :   NORMAL;     // 模型空间下的法线
    float2 uv : TEXCOORD0;          // 第一套UV
};

// 前向渲染输出结构体
struct ForwardVertexOutput
{
    float4 uv : TEXCOORD0;          // XY 存储第一套UV, ZW TODO 
    float4 positionCS : SV_POSITION; // 裁剪空间下的位置坐标
    float3 positionWS: TEXCOORD1;      // 世界空间位置坐标
    float3 normalWS : TECOORD2;        //世界空间法线法相
    float3 worldLightDir : TEXCOORD3;  //世界空间主光源方向
    float3 viewDirWS    : TEXCOORD4;    // 世界空间下视角方向
};

//前向渲染顶点着色器
ForwardVertexOutput ForwardVertex (ForwardVertexInput input)
{
    //初始化输出结构体
    ForwardVertexOutput output = (ForwardVertexOutput)0;

    // ShaderVaribleFunction.hlsl 声明 取得各个空间下的位置坐标
    VertexPositionInputs positionInput= GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS=positionInput.positionCS;
    output.positionWS=positionInput.positionWS;

    //UV
    output.uv.xy=input.uv;

    // ShaderBaribleFunction.hlsl 声明 取得世界空间下的 切线 副切线 法线 方向
    VertexNormalInputs normalInput= GetVertexNormalInputs(input.normalOS.xyz);
    output.normalWS=SafeNormalize(normalInput.normalWS);

    // Lighting.hlsl 获得主光源方向， 颜色 ， (距离衰减， 阴影衰减 虽然没任何吊用 因为都是1 但是只要胆子大 可以搞出意想不到的效果呢)
    Light mainLight=GetMainLight();

    // 这一块我们添加一个光的方向控制
    half3 worldLightDir=mainLight.direction;
    worldLightDir.x+= _LightOffsetX;
    worldLightDir.y+=_LightOffsetY;

    //SafeNormalize 详解参考 Common.hlsl 做了一个 half min 约束
    output.worldLightDir=SafeNormalize(worldLightDir);

    // 计算世界空间下的视角方向
    output.viewDirWS=SafeNormalize(GetWorldSpaceViewDir(output.positionWS));

    return output;
}

//前向渲染片段着色器
half4 ForwardFrag (ForwardVertexOutput input) : SV_Target
{
    //取得环境光RGB
    half3 ambientColor =_GlossyEnvironmentColor .xyz*_EnviormentIntesity;

    //贴图采样
    half4 basemapAlbedo =  SampleAlbedoAlpha(input.uv.xy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    basemapAlbedo*=_BaseColor;
    half4 shadeAlbedo= SampleAlbedoAlpha(input.uv.xy, TEXTURE2D_ARGS(_ShadeMap, sampler_ShadeMap));
    shadeAlbedo*=_ShadeColor;

    // 通过一个光照阀值控制阴影区域大小
    half diffuseStep=_LightTreshold;
    half LDotN =dot(input.worldLightDir,input.normalWS);
    LDotN= saturate(LDotN- diffuseStep);

    //Step 控制色阶
    half oneOverSteps=1.0h/_Steps;
    half quantizedNdotL = floor(LDotN * _Steps);

    // 这里0.01h 说实话 我没法解释 aaStep详情请看Common.hlsl 是一个进阶版的Step 它将不在返回0/1 而是更加平滑 这对于边界非常好
    half stepAreaControl=(oneOverSteps*dot(input.worldLightDir,input.normalWS)*_StepArea);
    LDotN = (quantizedNdotL + aaStep(saturate(quantizedNdotL * oneOverSteps), LDotN - 0.01h))*stepAreaControl;

    // 主光源分级
    Light mainLight=GetMainLight();

    // 亮部区域光照
    half3 lightColor=mainLight.color*LDotN;
    half luminance = Luminance(lightColor);

    //色调分离
    half4 litAlbedo=lerp(shadeAlbedo,basemapAlbedo, saturate(luminance));

    // 主光源漫反射最终颜色
    half3 diffuseLightColor=litAlbedo.rgb*litAlbedo.rgb;

    // 全局光照计算 URP 全局光照计算变得非常简单 bakeGI Ambient light  light probe 等

    /*//Ramp 采样分级
    half halfLamebert=HalfLamebert(input.worldLightDir,input.normalWS);
    half4 rampColor= SAMPLE_TEXTURE2D(_RampTexture, sampler_RampTexture,half2(halfLamebert,halfLamebert))*_RampIntensity;
    */
    
    //片原颜色输出
    half4 outputColor=half4(1,1,1,1);
    outputColor.rgb=diffuseLightColor+ambientColor;

    return outputColor;
}