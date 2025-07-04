//
//  TrafficLights.swift
//  ShhShell
//
//  Created by neon443 on 04/07/2025.
//

import SwiftUI

struct TrafficLightRed: View {
	let background: Color = .red
	let foreground: Color = ColorCodable(
		red: 0.5490196078,
		green: 0.1019607843,
		blue: 0.0588235294
	).stColor.suiColor
	
	var body: some View {
		ZStack {
			Image(systemName: "circle.fill")
				.resizable().scaledToFit()
				.foregroundStyle(background)
			Image(systemName: "xmark")
				.resizable().scaledToFit()
				.bold()
				.scaleEffect(0.6)
				.foregroundStyle(foreground)
		}
	}
}

struct TrafficLightYellow: View {
	let background: Color = .yellow
	let foreground: Color = ColorCodable(
		red: 0.5803921569,
		green: 0.3411764706,
		blue: 0.0980392157
	).stColor.suiColor
	
	var body: some View {
		ZStack(alignment: .center) {
			Image(systemName: "circle.fill")
				.resizable().scaledToFit()
				.foregroundStyle(background)
			Image(systemName: "minus")
				.resizable().scaledToFit()
				.bold()
				.scaleEffect(0.7)
				.foregroundStyle(foreground)
		}
	}
}

struct TrafficLightGreen: View {
	@State var enabled: Bool = true
	
	var body: some View {
		let background: Color = .green
		let foreground: Color = ColorCodable(
			red: 0.1529411765,
			green: 0.3843137255,
			blue: 0.1176470588
		).stColor.suiColor
		ZStack(alignment: .center) {
			Image(systemName: "circle.fill")
				.resizable().scaledToFit()
				.symbolRenderingMode(.palette)
				.foregroundStyle(background)
			if !enabled {
				RoundedRectangle(cornerRadius: 5)
					.foregroundStyle(foreground)
					.scaleEffect(0.6)
					.aspectRatio(1, contentMode: .fit)
					.clipShape(RoundedRectangle(cornerRadius: 5))
				Rectangle()
					.foregroundStyle(background)
					.scaleEffect(0.8)
					.aspectRatio(0.2, contentMode: .fit)
					.rotationEffect(.degrees(45))
			} else {
				ZStack(alignment: .center) {
					Group {
						Rectangle()
							.foregroundStyle(foreground)
							.scaleEffect(0.6)
							.rotationEffect(.degrees(45))
							.aspectRatio(1, contentMode: .fit)
							.clipShape(RoundedRectangle(cornerRadius: 5))
					}
					VStack(spacing: 0) {
						VStack(alignment: .trailing) {
							Rectangle()
								.scaleEffect(0.7, anchor: .bottomTrailing)
								.aspectRatio(1, contentMode: .fit)
						}
						.aspectRatio(2, contentMode: .fit)
						.border(.red)
						VStack(alignment: .leading) {
							Rectangle()
								.scaleEffect(0.7, anchor: .topLeading)
								.aspectRatio(1, contentMode: .fit)
						}
						.aspectRatio(2, contentMode: .fit)
						.border(.red)
					}
					.border(.blue)
				}
			}
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
