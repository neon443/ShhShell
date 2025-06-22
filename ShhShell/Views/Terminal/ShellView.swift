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
				TerminalController(handler: handler)
			}
			.toolbar {
				ToolbarItem {
					Button() {
						if handler.connected {
							handler.disconnect()
						} else {
							handler.connect()
						}
					} label: {
						if handler.connected {
							Label("Disconnect", image: "xmark.square.fill")
						} else {
							Label("Connect", image: "power")
						}
					}
				}
			}
		}
    }
}

#Preview {
	ShellView(handler: SSHHandler(host: Host.debug))
}
