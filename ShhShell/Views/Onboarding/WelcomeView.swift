//
//  WelcomeView.swift
//  ShhShell
//
//  Created by neon443 on 27/08/2025.
//

import SwiftUI

struct WelcomeView: View {
	@ObservedObject var hostsManager: HostsManager
	@State private var spawnDate: Date = .now
	
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
							.transition(.opacity)
							.shadow(color: .white, radius: time > 2.25 ? 0 : 5)
					}
				}
				//				.padding(.top, time > 3 ? 25 : 0)
				
				if time > 3 {
					Spacer()
				}
				
				WelcomeChunk(
					systemImage: "bolt.fill",
					title: "Blazing Fast",
					para: "",
					delay: 4
				)
				WelcomeChunk(
					image: "apple.terminal.on.rectangle.fill",
					title: "Multiple Sessions",
					para: "Connect to the same host again and again, or different ones",
					delay: 5
				)
				WelcomeChunk(
					systemImage: "swatchpalette.fill",
					title: "Themes",
					para: "Customise ShhShell by importing themes, or make your own!",
					delay: 6
				)
				WelcomeChunk(
					systemImage: "lock.shield.fill",
					title: "Secure",
					para: "ShhShell uses secure Elliptic Curve keys, and keeps you safe by verifying hostkeys haven't changed",
					delay: 7
				)
				WelcomeChunk(
					systemImage: "ellipsis.circle",
					title: "And more...",
					para: "Snippets, iCloud Sync, Fonts, Terminal Filters, Connection History",
					delay: 8
				)
				
				if time > 3 {
					Spacer()
				}
				if time > 9 {
					Button {
						hostsManager.setOnboarding(to: true)
					} label: {
						if #available(iOS 19, *) {
							Text("Continue")
								.monospaced()
								.font(.title)
								.foregroundStyle(.black)
						} else {
							ZStack {
								Color.terminalGreen
								Text("Continue")
									.monospaced()
									.bold()
									.foregroundStyle(.black)
							}
							.clipShape(RoundedRectangle(cornerRadius: 50))
						}
					}
					.tint(.terminalGreen)
					.modifier(glassButton(prominent: true))
				}
			}
			.animation(.spring, value: time)
			.preferredColorScheme(.dark)
		}
	}
}

#Preview {
	WelcomeView(hostsManager: HostsManager(previews: true))
}
