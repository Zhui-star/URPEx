
// 光照API 库
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 纹理采样库
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
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
    output.worldLightDir=SafeNormalize(worldLightDir-input.positionOS.xyz);

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
    half4 basemapColor=  SampleAlbedoAlpha(input.uv.xy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

    // 通过一个光照阀值控制阴影区域大小
    half LDotN = step(_LightTreshold,dot(input.worldLightDir,input.normalWS));
    half Lambert =LDotN*0.5+0.5;

    // 对漫反射的色阶进行控制
    Lambert=smoothstep(0,1,Lambert);
    half nprStep=floor(Lambert*2)/2;

    //Ramp 采样分级
    half halfLamebert=HalfLamebert(input.worldLightDir,input.normalWS);
    half4 rampColor= SAMPLE_TEXTURE2D(_RampTexture, sampler_RampTexture,half2(halfLamebert,halfLamebert))*_RampIntensity;

    //输出片元颜色
    half3 diffuseColor= _MainLightColor.rgb*_BaseColor.rgb*nprStep*rampColor.rgb*basemapColor.rgb;

    half4 outputColor=half4(1,1,1,1);
     outputColor.rgb=diffuseColor+ambientColor;

    return outputColor;
}