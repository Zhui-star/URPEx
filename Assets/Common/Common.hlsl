
// 半兰伯特光照模型
half HalfLamebert(half3 lightDirWS,half3 normalDirWS)
{
    return dot(lightDirWS,normalDirWS)*0.5+0.5;
}