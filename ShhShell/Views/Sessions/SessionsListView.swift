//
//  SessionsView.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import SwiftUI
import SwiftTerm

struct SessionsListView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
	@ObservedObject var container = TerminalViewContainer.shared
	
    var body: some View {
		if !container.sessions.isEmpty {
			Section("Sessions") {
				ForEach(container.sessionIDs, id: \.self) { key in
					SessionView(hostsManager: hostsManager, key: key)
						.id(container.sessions[key]!.handler.connected)
				}
			}
		}
    }
}

#Preview {
	SessionsListView(
		handler: SSHHandler(host: Host.debug),
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
