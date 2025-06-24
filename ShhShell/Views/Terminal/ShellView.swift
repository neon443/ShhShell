//
//  ShellView.swift
//  ShhShell
//
//  Created by neon443 on 22/06/2025.
//

import SwiftUI

struct ShellView: View {
	@ObservedObject var handler: SSHHandler
	
    var body: some View {
		NavigationStack {
			ZStack {
				if !handler.connected {
					DialogView(handler: handler, showDialog: !handler.connected)
				}
				TerminalController(handler: handler)
			}
			.toolbar {
				ToolbarItem {
					Button() {
						handler.go()
					} label: {
						Label(
							handler.connected ? "Disconnect" : "Connect",
							systemImage: handler.connected ? "xmark.app.fill" : "power"
						)
					}
				}
			}
		}
    }
}

#Preview {
	ShellView(handler: SSHHandler(host: Host.debug))
}
