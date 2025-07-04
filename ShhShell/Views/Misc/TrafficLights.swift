//
//  TrafficLights.swift
//  ShhShell
//
//  Created by neon443 on 04/07/2025.
//

import SwiftUI

struct TrafficLightRed: View {
	var body: some View {
		ZStack {
			Image(systemName: "circle.fill")
				.resizable().scaledToFit()
				.foregroundStyle(.red)
			Image(systemName: "xmark")
				.resizable().scaledToFit()
				.bold()
				.scaleEffect(0.6)
				.foregroundStyle(
					ColorCodable(
						red: 0.5490196078,
						green: 0.1019607843,
						blue: 0.0588235294
					).stColor.suiColor
				)
		}
	}
}

struct TrafficLightYellow: View {
	var body: some View {
		ZStack(alignment: .center) {
			Image(systemName: "circle.fill")
				.resizable().scaledToFit()
				.foregroundStyle(.yellow)
			Image(systemName: "minus")
				.resizable().scaledToFit()
				.bold()
				.scaleEffect(0.6)
				.foregroundStyle(
					ColorCodable(
						red: 0.5803921569,
						green: 0.3411764706,
						blue: 0.0980392157
					).stColor.suiColor
				)
		}
	}
}

struct TrafficLightGreen: View {
	var body: some View {
		ZStack(alignment: .center) {
			Image(systemName: "circle.fill")
				.resizable().scaledToFit()
				.symbolRenderingMode(.palette)
				.foregroundStyle(.green)
			Rectangle()
				.foregroundStyle(
					ColorCodable(
						red: 0.1529411765,
						green: 0.3843137255,
						blue: 0.1176470588
					).stColor.suiColor
				)
				.scaleEffect(0.6)
				.aspectRatio(1, contentMode: .fit)
		}
	}
}

#Preview {
	Group {
		HStack {
			TrafficLightRed()
			TrafficLightYellow()
			TrafficLightGreen()
		}
	}
	.frame(width: 150, height: 50)
	.scaleEffect(4.9)
}
