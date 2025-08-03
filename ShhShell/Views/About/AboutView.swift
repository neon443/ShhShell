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
//			List {
			VStack(alignment: .leading) {
				UIImage().appIcon
					.resizable().scaledToFit()
					.frame(width: 100)
					.clipShape(RoundedRectangle(cornerRadius: 26))
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
				
				Section("Thanks to") {
					Link(destination: URL(string: "https://libssh.org")!) {
						Text("LibSSH")
							.background(.red)
					}
				}
			}
			.frame(maxWidth: .infinity)
			.padding()
//			}
//			.scrollContentBackground(.hidden)
		}
    }
}

#Preview {
    AboutView(hostsManager: HostsManager())
}
