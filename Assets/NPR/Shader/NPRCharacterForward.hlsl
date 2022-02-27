
// 光照API 库
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

// 纹理采样库
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

// 颜色库 (包含颜色转亮度值)
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

// 数据输入库 包含InputData. InputData拥有bakeGI normalWS等等一系列封装方便实用Lighting.hlsl库中的光照计算
//在core.hlsl 被引用

#include "../../Common/Common.hlsl"

//阴影相关库
//1. 获取阴影坐标
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

// 前向渲染输入结构体
struct ForwardVertexInput
{
    float4 positionOS : POSITION;       // 模型空间下的顶点位置
    float4 normalOS :   NORMAL;         // 模型空间下的法线
    float2 uv : TEXCOORD0;              // 第一套UV

    #if defined(LIGHTMAP_ON)        
        float2 lightmapUV : TEXCOORD1;  //光照贴图UV
    #endif
};

// 前向渲染输出结构体
struct ForwardVertexOutput
{
    float4 uv : TEXCOORD0;             // XY 存储第一套UV, ZW TODO 
    float4 positionCS : SV_POSITION;   //裁剪空间下的位置坐标
    float3 positionWS: TEXCOORD1;      //世界空间位置坐标
    float3 normalWS : TECOORD2;        //世界空间法线法相
    float3 worldLightDir : TEXCOORD3;  //世界空间主光源方向
    float3 viewDirWS    : TEXCOORD4;   //世界空间下视角方向

    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 5); //声明光照贴图UV及球谐UV 
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

    //光照UV转换并且传入输出结构体 //Lighting.hlsl
    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);

    //球谐UV 转换
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

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

//初始化InputData 来自 universalrenderpipline/Input.hlsl
 inline void InitializeInputData(ForwardVertexOutput input, half facing, out InputData inputData)
 {
      inputData = (InputData)0;

      //无法线贴图的情况
      inputData.normalWS = input.normalWS * facing;
      inputData.viewDirectionWS =SafeNormalize(input.viewDirWS);
      
      //获得全局光照明
      inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
      inputData.bakedGI*=(1-_GIOcclusion);

      inputData.positionWS = input.positionWS;

//阴影坐标获取
#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
      inputData.shadowCoord=TransformWorldToShadowCoord(input.positionWS);
#else
      inputData.shadowCoord=(float4)0;
#endif
 }

//前向渲染片段着色器
// 正面的 VFACE 输入为正，
// 背面的为负。根据这种情况
// 输出两种颜色中的一种。
half4 ForwardFrag (ForwardVertexOutput input,half facing : VFACE) : SV_Target
{
    //片原颜色输出
    half4 outputColor=(half4)0;

    //贴图采样
    half4 basemapAlbedo =  SampleAlbedoAlpha(input.uv.xy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    basemapAlbedo*=_BaseColor;
    half4 shadeAlbedo= SampleAlbedoAlpha(input.uv.xy, TEXTURE2D_ARGS(_ShadeMap, sampler_ShadeMap));
    shadeAlbedo*=_ShadeColor;

    //初始化InputData
    InputData inputData;
    InitializeInputData(input, facing, inputData);

    half4 shadowMask=half4(1,1,1,1);
#if !defined(LIGHTMAP_ON)
    shadowMask = unity_ProbesOcclusion;
#endif

    // 主光源分级
    //全局光影响主光源强度
    Light mainLight=GetMainLight(inputData.shadowCoord,inputData.positionWS,shadowMask);
    
    
    //衰减BakeGI根据当前MaiNLIGHT方向 以及避免投递的阴影太暗等 缓和(阴影后续会加上) /urp/Lighting.hlsl
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, half4(0, 0, 0, 0));

    half3 GI= inputData.bakedGI;

    // 通过一个光照阀值控制阴影区域大小
    half diffuseStep=_LightTreshold;
    half LDotN =dot(input.worldLightDir,input.normalWS);
    LDotN= saturate(LDotN- diffuseStep);

    //Step 控制色阶
    half quantizedNdotL = floor(LDotN);

    // 这里0.01h 说实话 我没法解释 aaStep详情请看Common.hlsl 是一个进阶版的Step 它将不在返回0/1 而是更加平滑 这对于边界非常好
    LDotN =  aaStep(saturate(quantizedNdotL), LDotN - 0.01h)
    *mainLight.shadowAttenuation*mainLight.distanceAttenuation;

    // 亮部区域光照
    half3 lightColor=mainLight.color*LDotN;
    half luminance = Luminance(lightColor);

    //色调分离
    half4 litAlbedo=lerp(shadeAlbedo,basemapAlbedo, saturate(luminance));

    // 主光源漫反射最终颜色
    half3 diffuseLightColor=litAlbedo.rgb*litAlbedo.rgb;

    outputColor.rgb+=diffuseLightColor;

    /*//Ramp 采样分级
    half halfLamebert=HalfLamebert(input.worldLightDir,input.normalWS);
    half4 rampColor= SAMPLE_TEXTURE2D(_RampTexture, sampler_RampTexture,half2(halfLamebert,halfLamebert))*_RampIntensity;
    */

    // return half4(GI,1);
    outputColor.rgb+=GI;


    return outputColor;
}