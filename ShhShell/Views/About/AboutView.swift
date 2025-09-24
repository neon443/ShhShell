//
//  AboutView.swift
//  ShhShell
//
//  Created by neon443 on 02/08/2025.
//

import SwiftUI

struct AboutView: View {
	@ObservedObject var hostsManager: HostsManager
	
    var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
							.ignoresSafeArea(.all)
			VStack {
				hostsManager.settings.appIcon.image
					.resizable().scaledToFit()
					.frame(width: 100)
					.clipShape(RoundedRectangle(cornerRadius: 22))
				Text("ShhShell")
					.font(.largeTitle.monospaced())
				HStack {
					Text(Bundle.main.appVersion)
						.monospaced()
						.font(.subheadline)
					Text(Bundle.main.appBuild)
						.monospaced()
						.font(.callout)
				}
				.padding(.bottom)
				
				HStack(spacing: 10) {
					Link(destination: URL(string: "https://libssh.org")!) {
						Text("LibSSH")
							.padding(10)
							.background(.gray.opacity(0.7))
							.foregroundStyle(.black)
							.clipShape(RoundedRectangle(cornerRadius: 7.5))
							.shadow(radius: 2)
					}
					Link(destination: URL(string: "https://github.com/migueldeicaza/SwiftTerm")!) {
						Text("SwiftTerm")
							.padding(10)
							.background(.gray.opacity(0.7))
							.foregroundStyle(.black)
							.clipShape(RoundedRectangle(cornerRadius: 7.5))
							.shadow(radius: 2)
					}
				}
				
				Button {
					hostsManager.setOnboarding(to: false)
				} label: {
					Text("Show Welcome")
				}
				
				NavigationLink {
					ShaderTestingView()
				} label: {
					VStack {
						Text("Shader Playground")
							.bold()
						Text("A collection of shaders I made while learning!")
							.font(.caption2)
					}
				}
			}
			.transition(.scale)
			.frame(maxWidth: .infinity)
			.padding()
		}
    }
}

#Preview {
    AboutView(hostsManager: HostsManager())
}
