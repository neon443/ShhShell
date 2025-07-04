//
//  invert.metal
//  ShhShell
//
//  Created by neon443 on 04/07/2025.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 invert(float2 pos, half4 color) {
	return half4(0, 1 - color.g, 1 - color.b, 1 - color.a);
}
