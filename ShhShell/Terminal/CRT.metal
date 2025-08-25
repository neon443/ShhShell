//
//  CRT.metal
//  ShhShell
//
//  Created by neon443 on 25/08/2025.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

//learning shaders stuff here
[[ stitchable ]] half4 loupe(float2 pos, SwiftUI::Layer layer, float2 size, float2 touch) {
	float maxDist = 0.1;
	float2 uv = pos/size;
	float2 center = touch/size;
	float2 delta = uv-center;
	float aspectRatio = size.x/size.y;
	float dist = (delta.x * delta.x) + (delta.y * delta.y) / aspectRatio;
	float totalZoom = 1;
	if(dist < maxDist) {
		totalZoom /= 2;
	}
	float2 newPos = delta * totalZoom + center;
	return layer.sample(newPos*size);
}

[[ stitchable ]] float2 waveFlag(float2 pos, float time, float2 size) {
	float2 distance = pos/size;
	pos.y += sin(time*5 + pos.x/20) * 5 * distance.x;
	return pos;
}

[[ stitchable ]] float2 wave(float2 pos, float time) {
	pos.y += sin(time*4 + pos.y/30) * 10;
	return pos;
}

[[ stitchable ]] half4 rainbow(float2 pos, half4 color, float time) {
	if(color.a == 0) {
		return half4(0,0,0,0);
	}
	float angle = atan2(pos.y, pos.x) + time;
	return half4(
				 sin(angle),
				 sin(angle + 2),
				 sin(angle + 4),
				 color.a
				 );
}

[[ stitchable ]] half4 opacityInvert(float2 position, half4 color) {
	return half4(1, 0, 0, 1-color.a);
}

[[ stitchable ]] half4 redify(float2 position, half4 color) {
	if (color.a == 0) {
		return half4(0,0,0,0);
	}
	return half4(1 * color.a, 0, 0, color.a);
}

[[ stitchable ]] half4 passthrough(float2 position, half4 color) {
	return color;
}
