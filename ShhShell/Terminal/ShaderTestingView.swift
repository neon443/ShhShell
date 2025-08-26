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
		Image(systemName: "figure.walk.circle")
			.font(.system(size: 300))
			.foregroundStyle(.blue)
			.colorEffect(ShaderLibrary.redify())
		Section("Shaded") {
			TimelineView(.animation) { tl in
				let time = start.distance(to: tl.date)
				Image(systemName: "figure.walk.circle")
					.font(.system(size: 300))
					.foregroundStyle(.blue)
					.distortionEffect(
						ShaderLibrary.wave(
							.float(time)
						),
						maxSampleOffset: .zero
					)
				Rectangle()
					.frame(width: 200, height: 100)
					.padding(.vertical, 20)
					.foregroundStyle(.red)
					.compositingGroup()
					.visualEffect {
						content,
						proxy in
						content.distortionEffect(
							ShaderLibrary.waveFlag(
								.float(time),
								.float2(proxy.size)
							),
							maxSampleOffset: CGSize(width: 0, height: 40)
						)
					}
			}
		}
		Section("Shaded") {
			TimelineView(.animation) { tl in
				let time = start.distance(to: tl.date)
				Rectangle()
					.frame(width: 300, height: 200)
					.colorEffect(
						ShaderLibrary.sinebow(
							.float2(300, 200),
							.float(time)
						)
					)
				Image(systemName: "figure.walk.circle")
					.font(.system(size: 300))
					.foregroundStyle(.blue)
					.colorEffect(ShaderLibrary.rainbow(
						.float(time)
					))
			}
		}
		Section("Original") {
			Image(systemName: "figure.walk.circle")
				.font(.system(size: 300))
				.foregroundStyle(.blue)
		}
	}
}

#Preview {
	ShaderTestingView()
}
