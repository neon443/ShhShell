//
//  ShellView.swift
//  ShhShell
//
//  Created by neon443 on 22/06/2025.
//

import SwiftUI

struct ShellView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var hostsManager: HostsManager
	
	@ObservedObject var container = TerminalViewContainer.shared
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		NavigationStack {
			ZStack {
				hostsManager.selectedTheme.background.suiColor
					.ignoresSafeArea(.all)
				TerminalController(handler: handler, hostsManager: hostsManager)
				
				Group {
					Color.gray.opacity(0.2)
						.transition(.opacity)
					Image(systemName: "bell.fill")
						.font(.largeTitle)
						.shadow(color: .black, radius: 5)
				}
				.opacity(handler.bell ? 1 : 0)
			}
			.onAppear {
				handler.applySelectedTheme()
			}
		}
	}
}

#Preview {
	ShellView(
		handler: SSHHandler(host: Host.debug, keyManager: nil),
		hostsManager: HostsManager()
	)
}
