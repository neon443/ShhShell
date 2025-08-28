//
//  WelcomeView.swift
//  ShhShell
//
//  Created by neon443 on 27/08/2025.
//

import SwiftUI

struct WelcomeView: View {
	@State private var spawnDate: Date = .now
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		TimelineView(.animation) { tl in
			let time = tl.date.timeIntervalSince(spawnDate)
			VStack {
				VStack(spacing: 20) {
					if time > 0.1 {
							Image("regular")
								.resizable().scaledToFit()
								.frame(width: 100)
								.clipShape(RoundedRectangle(cornerRadius: 22))
								.shadow(color: .white, radius: time > 0.25 ? 5 : 0)
								.transition(.scale)
					}
					if time > 2 {
						Text("Welcome")
							.monospaced()
							.font(.largeTitle)
							.bold()
							.transition(.blurReplace)
					}
				}
				.padding(.top, time > 3 ? 50 : 0)
				
				if time > 3 {
					Spacer()
				}
					
				WelcomeChunk(
					symbol: "bolt.fill",
					title: "Blazing Fast",
					para: "",
					delay: 4
				)
				WelcomeChunk(
					symbol: "apple.terminal.on.rectangle.fill",
					title: "Multiple Sessions",
					para: "Connect to the same host again and again, or different ones",
					delay: 5
				)
				WelcomeChunk(
					symbol: "swatchpalette.fill",
					title: "Themes",
					para: "Customise ShhShell by importing themes, or make your own!",
					delay: 6
				)
				WelcomeChunk(
					symbol: "lock.shield.fill",
					title: "Secure",
					para: "ShhShell uses secure Elliptic Curve keys, and keeps you safe by verifying hostkeys haven't changed",
					delay: 7
				)
				WelcomeChunk(
					symbol: "ellipsis.circle",
					title: "And more...",
					para: "Snippets, iCloud Sync, Fonts, Terminal Filters, Connection History",
					delay: 8
				)
				
				if time > 3 {
					Spacer()
				}
				if time > 9 {
#if swift(>=6.2)
					Button("Continue") { dismiss() }
						.buttonStyle(.glassProminent)
#else
					Button {
						dismiss()
					} label: {
						ZStack {
							Color.terminalGreen
							Text("Continue")
								.monospaced()
								.bold()
								.foregroundStyle(.black)
						}
						.clipShape(RoundedRectangle(cornerRadius: 50))
					}
					.buttonStyle(.plain)
					.frame(width: .infinity, height: 50)
					.padding(.horizontal, 75)
#endif
				}
			}
			.onDisappear {
				
			}
			.animation(.spring, value: time)
			.preferredColorScheme(.dark)
		}
	}
}

#Preview {
	WelcomeView()
}
