//
//  CRT.metal
//  ShhShell
//
//  Created by neon443 on 25/08/2025.
//

#include <metal_stdlib>
using namespace metal;

//learning shaders stuff here
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
