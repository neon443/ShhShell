//
//  CRT.metal
//  ShhShell
//
//  Created by neon443 on 25/08/2025.
//

#include <metal_stdlib>
using namespace metal;

//learning shaders stuff here
[[ stitchable ]] half4 opacityInvert(float2 position, half4 color) {
	return half4(1, 0, 0, color.a);
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
