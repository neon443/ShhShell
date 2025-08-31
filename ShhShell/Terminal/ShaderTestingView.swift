//
//  ShaderTestingView.swift
//  ShhShell
//
//  Created by neon443 on 25/08/2025.
//

import SwiftUI

struct ShaderTestingView: View {
	@State private var start = Date.now
	
	var body: some View {
		if #available(iOS 17, *) {
			TimelineView(.animation) { tl in
				let time = start.distance(to: tl.date)
				ZStack {
					VStack {
						HStack {
							Image(systemName: "figure.walk.circle")
								.resizable().scaledToFit()
								.foregroundStyle(.blue)
							Image(systemName: "arrow.right")
								.foregroundStyle(.gray)
								.frame(width: 25, height: 25)
							Image(systemName: "figure.walk.circle")
								.resizable().scaledToFit()
								.foregroundStyle(.blue)
								.colorEffect(ShaderLibrary.redify())
						}
						
						Image(systemName: "figure.walk.circle")
							.resizable().scaledToFit()
							.foregroundStyle(.blue)
							.colorEffect(ShaderLibrary.rainbow(.float(time)))
						
						Image(systemName: "figure.walk.circle")
							.resizable().scaledToFit()
							.foregroundStyle(.blue)
							.distortionEffect(
								ShaderLibrary.wave(.float(time)),
								maxSampleOffset: .zero
							)
						Rectangle()
							.padding(.vertical, 20)
							.foregroundStyle(.red)
							.compositingGroup()
							.visualEffect {
								content,
								proxy in
								content.distortionEffect(
									ShaderLibrary.waveFlag(.float(time), .float2(proxy.size)),
									maxSampleOffset: CGSize(width: 0, height: 40)
								)
							}
						
						Rectangle()
							.colorEffect(
								ShaderLibrary.sinebow(.float2(300, 200), .float(time))
							)
					}
					.brightness(0.2)
					
					Rectangle()
						.foregroundStyle(.black.opacity(1))
						.visualEffect { content, proxy in
							content
								.colorEffect(
									ShaderLibrary.crt(
										.float2(proxy.size),
										.float(time)
									)
								)
						}
						.opacity(0.75)
						.blendMode(.overlay)
						.allowsHitTesting(false)
				}
			}
		}
	}
}

#Preview {
	ShaderTestingView()
}
