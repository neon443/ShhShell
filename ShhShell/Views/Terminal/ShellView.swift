//
//  ShellView.swift
//  ShhShell
//
//  Created by neon443 on 22/06/2025.
//

import SwiftUI

struct ShellView: View {
	@ObservedObject var handler: SSHHandler
	@Environment(\.dismiss) var dismiss
	
	@State private var terminalControllerRef: TerminalController?
	
    var body: some View {
		NavigationStack {
			ZStack {
				terminalControllerRef
				
				Group {
					Color.gray.opacity(0.2)
						.transition(.opacity)
					Text("🔔")
						.font(.title)
				}
				.opacity(handler.bell ? 1 : 0)
				
				if !handler.connected {
					DialogView(handler: handler, showDialog: !handler.connected)
				}
			}
			.task {
				terminalControllerRef = TerminalController(handler: handler)
			}
			.toolbar {
				ToolbarItem {
					Button() {
						handler.disconnect()
						if !handler.connected { dismiss() }
					} label: {
						Label("Disconnect", systemImage: "xmark.app.fill")
					}
				}
				//TODO: FIX
//				ToolbarItem(placement: .cancellationAction) {
//					Button() {
//						dismiss()
//					} label: {
//						Label("Close", systemImage: "arrow.down.right.and.arrow.up.left")
//					}
//				}
			}
			.onChange(of: handler.connected) { _ in
				if !handler.connected { dismiss() }
			}
			.navigationTitle(handler.title)
			.navigationBarTitleDisplayMode(.inline)
		}
    }
}

#Preview {
	ShellView(handler: SSHHandler(host: Host.debug))
}
