
// 半兰伯特光照模型
half HalfLamebert(half3 lightDirWS,half3 normalDirWS)
{
    return dot(lightDirWS,normalDirWS)*0.5+0.5;
}

// 平滑Step 函数 让它不仅仅是0/1 
// https://www.ronja-tutorials.com/2019/11/29/fwidth.html
half aaStep(half compValue, half gradient){
    //函数偏导  GPU 光栅化合并是 2X2 个像素一起合并 ddx 表示 右边像素该值-左边像素该值 ddy表示 下面像素该值-上面像素该值 
    // fwidth=abs(ddx)+abs(ddy)
    half change = fwidth(gradient);

    // 范围最小值与最大值
    half lowerEdge = compValue - change;
    half upperEdge = compValue + change;
    
    // 求得 inverse lerp 't' 
    half stepped = (gradient - lowerEdge) / (upperEdge - lowerEdge);
    stepped = saturate(stepped);
    return stepped;
}
