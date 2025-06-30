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
				TerminalController(handler: handler, hostsManager: hostsManager)
					.onAppear {
						if let sessionID = handler.sessionID {
							container.sessions[sessionID]?.terminalView.restoreScrollback()
						}
					}
				
				Group {
					Color.gray.opacity(0.2)
						.transition(.opacity)
					Image(systemName: "bell.fill")
						.font(.largeTitle)
						.shadow(color: .black, radius: 5)
				}
				.opacity(handler.bell ? 1 : 0)
				
				if !handler.connected {
					DialogView(handler: handler, showDialog: !handler.connected)
				}
			}
			.onChange(of: handler.connected) { _ in
				if !handler.connected { dismiss() }
			}
			.onAppear {
				handler.applySelectedTheme()
			}
			.navigationTitle(handler.title)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button() {
						dismiss()
					} label: {
						Label("Close", systemImage: "arrow.down.right.and.arrow.up.left")
					}
				}
				ToolbarItem(placement: .cancellationAction) {
					Button() {
						handler.disconnect()
						if !handler.connected { dismiss() }
					} label: {
						Label("Disconnect", systemImage: "xmark.app.fill")
					}
				}
			}
		}
    }
}

#Preview {
	ShellView(
		handler: SSHHandler(host: Host.debug),
		hostsManager: HostsManager()
	)
}
